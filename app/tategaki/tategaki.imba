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

	let latins = document.getElementsByClassName 'latin'
	for latin in latins
		let text = latin.innerHTML
		if /[a-zA-Z\p{Script=Latin}\d]/.test(text) and latin.offsetHeight <= 30
			if text.length == 1
				if /[a-z]/.test(text)
					let base = 'a'.charCodeAt(0)
					let newBase = '\uff41'.charCodeAt(0)
					let current = text.charCodeAt(0)
					let newChar = String.fromCharCode(current - base + newBase)
					latin.innerHTML = newChar
				else if /[A-Z]/.test(text)
					let base = 'A'.charCodeAt(0)
					let newBase = '\uff21'.charCodeAt(0)
					let current = text.charCodeAt(0)
					let newChar = String.fromCharCode(current - base + newBase)
					latin.innerHTML = newChar
				else if /[0-9]/.test(text)
					let base = '0'.charCodeAt(0)
					let newBase = '\uff10'.charCodeAt(0)
					let current = text.charCodeAt(0)
					let newChar = String.fromCharCode(current - base + newBase)
					latin.innerHTML = newChar

			latin.style.textCombineUpright = "all"

global css html
	fs:18px

global css body 
	writing-mode:vertical-rl
	p:36px 54px 72px

tag app
	css .upright
		writing-mode:horizontal-tb

	<self#app>