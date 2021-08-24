import { Telegraph } from '../telegraph'
import fetch from 'node-fetch'
import '../css/style.css'

let re = /tategaki(\/.+)/
let path = (re.exec window.location.pathname)[1]

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
	app.innerHTML = telegraph.translatedHTML.trim!
	app.insertBefore heading, app.firstChild

	let latinsElements = document.getElementsByClassName 'latin'
	let latins = []
	for ele in latinsElements
		latins.push ele
	for latin in latins
		let text = latin.innerHTML.trim!
		if /^[\w\p{Script=Latin}]/.test text
			if text.length == 1
				latin.innerHTML = transformToFullWidth text
				latin.classList.remove 'latin'
			else if /^([A-Z]+|\d{4,})$/.test text
				latin.innerHTML = Array.from(text, do(x)
					transformToFullWidth x
				).join('')
				# Works only in Firefox `text-transform`
				# latin.classList.add 'latin-full-width' 
				latin.classList.remove 'latin'
			else if /^\d{2,3}$/.test text
				latin.innerHTML = text
				latin.classList.add 'latin-combine'
			else if /^\d{2,3}%$/.test text
				let matches = /^(\d{1,3})%$/.exec text
				let unit = document.createElement 'span'
				let digit = matches[1]
				if digit.length == 1
					digit = transformToFullWidth digit
				unit.innerHTML = `<span class="latin latin-combine">{digit}</span>％`
				latin.replaceWith unit
			else if latin.offsetHeight <= 24
				latin.innerHTML = text
				latin.classList.add 'latin-combine'

def transformToFullWidth x
	let base = '0'.charCodeAt(0)
	let newBase = '\uff10'.charCodeAt(0)
	let current = x.charCodeAt(0)
	let newChar = String.fromCharCode(current - base + newBase)
	return newChar

tag app
	<self#app lang="zh-Hant">