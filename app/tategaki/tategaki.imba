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
	heading.innerText = telegraph.title
	document.title = telegraph.title + ' – Denpo'

	let app = document.getElementById('app')
	app.innerHTML = telegraph.translatedHTML.trim!
	app.insertBefore heading, app.firstChild

	let latinsElements = document.getElementsByClassName 'latin'
	let latins = []
	for ele in latinsElements
		latins.push ele
	for latin in latins
		let text = latin.innerHTML
		if /[a-zA-Z\p{Script=Latin}\d]/.test(text)
			if latin.offsetHeight <= 30
				if text.length == 1
					if /[a-z]/.test(text)
						latin.innerHTML = transformToFullWidth text, 'a', '\uff41'
					else if /[A-Z]/.test(text)
						latin.innerHTML = transformToFullWidth text, 'A', '\uff21'
					else if /[0-9]/.test(text)
						latin.innerHTML = transformToFullWidth text, '0', '\uff10'
					latin.classList.remove 'latin'
				else if /^[A-Z]+$/.test(text)
					latin.innerHTML = Array.from(text, do(x)
						transformToFullWidth x, 'A', '\uff21'
					).join('')
					latin.classList.remove 'latin'
				else
					latin.style.textCombineUpright = "all"

def transformToFullWidth x, baseChar, newBaseChar
	let base = baseChar.charCodeAt(0)
	let newBase = newBaseChar.charCodeAt(0)
	let current = x.charCodeAt(0)
	let newChar = String.fromCharCode(current - base + newBase)
	return newChar


tag app
	# css .upright
	# 	writing-mode:horizontal-tb

	<self#app>