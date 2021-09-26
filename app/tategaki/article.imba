import { Telegraph } from '../telegraph'
import { Tategaki } from 'tategaki'
import { detect } from 'detect-browser'


# `Article` deals with downloaded article from Telegra.ph
# Adding features like TCY
export class Article
	reLegacy = /tategaki(\/[^\/]+)(\/debug)?$/
	re = /(\/[^\/]+)(\/debug)?$/
	baseURL = 'https://api.telegra.ph/getPage' 
	query = '?return_content=true'

	prop path
	prop debugMode
	prop url
	prop telegraph\Telegraph

	prop heading

	prop tategaki

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
		heading = document.createElement 'div'
		heading.classList.add 'headline'
		heading.innerHTML = `<h1>{telegraph.title}</h1>`
		document.title = telegraph.title + ' – Tategaki'

		if telegraph.author
			author = document.createElement 'span'
			author.id = 'info'
			author.innerHTML = `<span id="author">{telegraph.translateToHTML [telegraph.author]}</span>`
			heading.appendChild author
	
	def makeArticle
		let app = document.getElementById 'app'

		let article = document.createElement 'article'
		article.innerHTML = telegraph.contentHTML.trim!
		article.insertBefore heading, article.firstChild

		const browser = detect!
		if browser
			document.body.classList.add browser.name

		tategaki = new Tategaki article, true, true, true
		app.appendChild article

		tategaki.parse!

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
			
	# Whole process of post-rendering
	def parse data
		# TODO: Validate Telegraph
		loadData data
		imba.mount <app>
		makeTitle!
		makeArticle!


	get urlNoQuery
		baseURL + path

	constructor pathname
		let execed = reLegacy.exec pathname
		if not execed
			execed = re.exec pathname
		
		path = execed[1]
		debugMode = execed[2] != undefined
		url = baseURL + path + query
		
		if debugMode
			console.log url