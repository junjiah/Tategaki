import '../css/style.css'
import { Article } from './article'
import fetch from 'node-fetch'

# Entrance
tag app
	<self#app lang="zh-Hant">
		<article#loading>
			<h1> '⏳'

imba.mount <app>

# Browser resizing
def adjustArticleHeight
	def articleHeight
		const threshold = 712
		if window.innerHeight >= threshold
			return 32rem
		
		const raw = 32 - Math.ceil((threshold - window.innerHeight) / 18)
		if raw < 20
			return 20rem

		return "{raw}rem"

	let articles = document.getElementsByTagName('article')
	let figs = document.querySelectorAll('figure')

	for article in articles
		article.style.height = articleHeight!
	for fig in figs 
		let img = fig.querySelector('img')
		img.style.height = articleHeight!

window.onresize = adjustArticleHeight

# Get RSS feed
let queryString = window.location.search

const searchParams = new URLSearchParams queryString
let url = searchParams.get 'url'

fetch('/rss/' + url).then(do(res)
	res.json!
).then do(data)
	let items = data.items
	document.title = data.title + ' – Denpo'

	let app = document.getElementById 'app'
	app.removeChild app.querySelector '#loading'
	for item in items
		# console.log item
		new Article item
	adjustArticleHeight!

# @ts-ignore
document.fonts.onloadingdone = do(e)
	# Forcing Chrome to re-calculate TCY width
	# It's unbearably worked-around
	for ele\HTMLElement in document.getElementsByClassName 'tcy'
		ele.style.display = 'none'
		setTimeout(do
			ele.style.display = 'inline'
		1)