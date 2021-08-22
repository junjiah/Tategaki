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
		if latin.offsetHeight <= 30
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