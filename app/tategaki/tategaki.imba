import { Telegraph } from '../telegraph'
import fetch from 'node-fetch'
import '../css/style.css'

let re = /tategaki(\/[^\/]+)(\/debug)?$/
let execed = re.exec window.location.pathname
let path = execed[1]
let isDebug = execed[2] != undefined

let baseURL = 'https://api.telegra.ph/getPage'
let query = '?return_content=true'

let url = baseURL + path + query
console.log url
fetch(url).then(do(res)
	res.json!
).then do(data)
	# TODO: Validate Telegraph
	let telegraph = new Telegraph
	telegraph.translateToHTML data.result.content
	telegraph.title = data.result.title

	imba.mount <app>

	let heading = document.createElement('h1')
	heading.innerText = telegraph.preProcess telegraph.title
	document.title = telegraph.title + ' – Denpo'

	let app = document.getElementById('app')
	let article = document.createElement 'article'
	article.innerHTML = telegraph.translatedHTML.trim! 
	article.insertBefore heading, article.firstChild
	app.appendChild article

	if isDebug
		app.classList.add 'debug'

	let latinsElements = document.getElementsByClassName 'latin'
	let latins = []
	for ele in latinsElements
		latins.push ele
	for latin in latins
		let text = latin.innerHTML.trim!
		if /^[\w\p{Script=Latin}]/.test text
			if text.length == 1
				if latin.parentElement.tagName == 'I' or latin.parentElement.tagName == 'EM'
					continue
				latin.innerHTML = transformToFullWidth text
				latin.classList.remove 'latin'
				latin.removeAttribute 'lang'
			else if /^([A-Z]+|\d{4,})$/.test text
				latin.innerHTML = Array.from(text, do(x)
					transformToFullWidth x
				).join('')
				# Works only in Firefox `text-transform`
				# latin.classList.add 'latin-full-width' 
				latin.classList.remove 'latin'
				latin.removeAttribute 'lang'
			else if /^\d{2,3}$/.test text
				latin.innerHTML = text
				latin.classList.remove 'latin'
				latin.removeAttribute 'lang'
				latin.classList.add 'latin-combine'
			else if /^\d{2,3}%$/.test text
				let matches = /^(\d{1,3})%$/.exec text
				let unit = document.createElement 'span'
				let digit = matches[1]
				if digit.length == 1
					digit = transformToFullWidth digit
				unit.innerHTML = `<span class="latin-combine">{digit}</span>&#8288;％`
				latin.replaceWith unit
			else if latin.offsetHeight < 23
				latin.innerHTML = text
				latin.classList.add 'latin-combine'
	
	# Bug: Cannot scroll at the very left part of body (Safari)
	if isDebug
		return
		const scrollContainer = document.querySelector('body')
		scrollContainer.addEventListener "wheel", do(e)
			console.log 'wheel'
			if e.altKey or e.shiftKey
				return

			let x = e.deltaX
			let y = e.deltaY

			e.preventDefault!

			if Math.abs(y) < 5 or Math.abs(x) > 0 and Math.abs(x) < 5
				return

			scrollContainer.scrollLeft -= y

def transformToFullWidth x
	let base = '0'.charCodeAt(0)
	let newBase = '\uff10'.charCodeAt(0)
	let current = x.charCodeAt(0)
	let newChar = String.fromCharCode(current - base + newBase)
	return newChar

tag app
	css footer
		pos:fixed
		b:0
		l:0
		r:0
		writing-mode:horizontal-tb
		ta:center
		p:10px
		c:#787f86
		lh:normal

	<self#app lang="zh-Hant">
		<footer.latin>
			<small>
				<b> "Denpo in Tategaki"
				" is under early development. If any issue arise, feel free to contact Toto at "
				<a href="mailto:the@unpopular.me"> "the@unpopular.me"
				" or join " 
				<a href="https://t.me/denpo_beta"> "Telegram Group"
				" at your convenience."