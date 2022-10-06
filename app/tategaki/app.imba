import { Article } from './article'
import fetch from 'node-fetch'


let articleStore = new Article window.location.pathname

def adjustArticleHeight
	def articleHeight
		const threshold = 696
		if window.innerHeight >= threshold
			return 32rem

		const raw = 32 - Math.ceil((threshold - window.innerHeight) / 18)
		if raw < 20
			return 20rem

		return "{raw}rem"

	let article = document.getElementsByTagName('article')[0]
	let imgs = document.getElementsByTagName('img')

	article.style.height = articleHeight!
	for img in imgs
		img.style.height = articleHeight!

window.onresize = adjustArticleHeight

fetch('/telegraph/' + articleStore.urlNoQuery).then(do(res)
	res.json!
).then do(data)
	if data.ok
		articleStore.parse data
		adjustArticleHeight!
		let imgs = Array.from document.getElementsByTagName('img')
		for img\HTMLImageElement in imgs
			const ratio = img.naturalWidth / img.naturalHeight
			if ratio > 2
				let canvas = document.createElement 'canvas'
				canvas.height = img.naturalWidth
				canvas.width = img.naturalHeight

				let rotatedImg = document.createElement 'img'
				rotatedImg.src = img.src

				let ctx = canvas.getContext '2d'

				ctx.translate img.naturalHeight, 0
				ctx.rotate 0.5 * Math.PI
				ctx.drawImage rotatedImg, 0, 0

				let parentElement = img.parentElement
				parentElement.insertBefore canvas, img
				parentElement.removeChild img
	else
		let errorHint = data.error is "PAGE_NOT_FOUND" ? 'page-not-found' : 'bad-json'
		window.location.replace `./error/{errorHint}`

# @ts-ignore
document.fonts.onloadingdone = do(e)
	# Forcing Chrome to re-calculate TCY width
	# It's unbearably worked-around
	for ele\HTMLElement in document.getElementsByClassName 'tcy'
		ele.style.display = 'none'
		setTimeout(do
			ele.style.display = 'inline'
		1)

# Entrance, will not render anything except `<Footer>`
# before retrieving data
tag app
	<self#app lang="zh-Hant">
		<Footer>

# Extra information. Should be removed in future
tag Footer
	<self>
		<div>
		<div>
