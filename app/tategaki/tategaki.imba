import { Telegraph } from '../telegraph'


# `Tategaki` deals with downloaded article from Telegra.ph
# Adding features like TCY
export class Tategaki
	re = /tategaki(\/[^\/]+)(\/debug)?$/
	baseURL = 'https://api.telegra.ph/getPage' 
	query = '?return_content=true'

	prop path
	prop debugMode
	prop url
	prop telegraph\Telegraph

	prop heading
	prop app


	def loadData data
		telegraph = new Telegraph data.result.content
		telegraph.title = data.result.title
		telegraph.author = data.result.author_name

		def styleNum x, isMonth=yes
			const base = (isMonth ? '\u32C0' : '\u33E0').charCodeAt 0
			return String.fromCharCode(parseInt(x) - 1 + base)
		
		let re = /.+-(\d\d)-(\d\d)(-[1-9]\d{0,})?$/
		let matches = re.exec data.result.path
		telegraph.date = { month: styleNum(matches[1]), day: styleNum(matches[2], no) } 

	def makeTitle
		heading = document.createElement 'header'
		heading.innerHTML = `<h1>{telegraph.preProcess telegraph.title}</h1>`
		document.title = telegraph.title + ' – Denpo'

		author = document.createElement 'span'
		author.id = 'info'
		author.innerHTML = `<span id="author">{telegraph.translateToHTML [telegraph.author]}</span>`
		heading.appendChild author
	
	def makeArticle
		app = document.getElementById 'app'
		let article = document.createElement 'article'
		article.innerHTML = telegraph.translatedHTML.trim!
		article.insertBefore heading, article.firstChild
		app.appendChild article

		if debugMode
			app.classList.add 'debug'
	
	# Bug: Cannot scroll at the very left part of `<body>` (Safari)
	def enableHandOffScrolling
		const scrollContainer = document.querySelector('body')
		scrollContainer.addEventListener "wheel", do(e)
			if e.altKey or e.shiftKey
				return

			const x = e.deltaX
			const y = e.deltaY

			e.preventDefault!

			# Tell if using trackpad. But will lose accuracy.
			if Math.abs(y) < 5 or Math.abs(x) > 0 and Math.abs(x) < 5
				return

			scrollContainer.scrollLeft -= y

	# Since not all browser support full-width transformation,
	# it'll do some unicode calc to do that.
	# Delta between codes of characters in full-width is as same 
	# as ASCII, so choose zero as base for calculation.
	def transformToFullWidth x
		const base = '0'.charCodeAt(0)
		const newBase = '\uff10'.charCodeAt(0)  # Full-width zero
		const current = x.charCodeAt(0)
		return String.fromCharCode(current - base + newBase)

	# Yokogaki in Tategaki (Tategaki-Chyu-Yokogaki)
	def tcy ele
		const text = ele.innerHTML.trim!
		if /^[\w\p{Script=Latin}]/.test text
			# Words with only one lettre should turn to full-width
			# and lose `latin` class
			if text.length == 1  
				if ele.parentElement.tagName == 'I' or ele.parentElement.tagName == 'EM'
					return false
				ele.innerHTML = transformToFullWidth text
				ele.classList.remove 'latin'
				ele.removeAttribute 'lang'
			# Abbreviations and numbers no more than 4 digits should
			# turn to full-width
			else if /^([A-Z]{3,}|\d{4,})$/.test text
				ele.innerHTML = Array.from(text, do(x)
					transformToFullWidth x
				).join('')
				# Works only in Firefox `text-transform`
				# latin.classList.add 'latin-full-width' 
				ele.classList.remove 'latin'
				ele.removeAttribute 'lang'
			# Other numbers should do TCY but be rendered by CJK fonts
			else if /^[A-Z]{2}|\d{2,3}$/.test text
				ele.innerHTML = text
				ele.classList.remove 'latin'
				ele.removeAttribute 'lang'
				ele.classList.add 'tcy'
			# Special cond: Percentage
			else if /^\d{1,3}%$/.test text
				const matches = /^(\d{1,3})%$/.exec text
				let unit = document.createElement 'span'
				let digit = matches[1]
				if digit.length == 1
					digit = transformToFullWidth digit
				unit.innerHTML = `<span {digit.length == 1 ? '' : 'class="tcy"'}>{digit}</span>&#8288;％`
				ele.replaceWith unit
			# Scale height of the ele to decide whether TCY
			else if ele.offsetHeight < 23
				ele.innerHTML = text
				ele.classList.add 'tcy'

	def processLatinTags
		let latinTags = document.getElementsByClassName 'latin'
		let eles = []
		for t in latinTags
			eles.push t
		for ele in eles
			if not tcy ele
				continue
			
	# Whole process of post-rendering
	def parse data
		# TODO: Validate Telegraph
		loadData data
		imba.mount <app>
		makeTitle!
		makeArticle!
		processLatinTags!


	constructor pathname
		const execed = re.exec pathname
		path = execed[1]
		debugMode = execed[2] != undefined
		url = baseURL + path + query
		if debugMode
			console.log url