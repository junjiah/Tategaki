import { Tategaki } from 'tategaki'
import { detect } from 'detect-browser'


export class Article
	prop item
	prop heading
	prop date
	prop author = ''
	prop dateRaw = ''
	prop dateStyled = ''

	def makeHeading
		heading = document.createElement 'div'
		heading.classList.add 'headline'
		heading.innerHTML = `<h1><a href="{item['link']}">{item.title}</a></h1>`
		
		let filled = no
		
		if item['creator']
			author = item['creator'].trim!
			filled = yes
		else if item['author']
			author = item['author'].trim!
			filled = yes

		if item['isoDate']
			dateRaw = item['isoDate']

			let re = /(\d{4})-([01]\d)-([0-3]\d)/
			let match = re.exec dateRaw

			if match
				const year = parseInt match[1]
				const month = parseInt match[2] 
				const day = parseInt match[3] 

				def styleNum x, isMonth=yes
					const base = (isMonth ? '\u32C0' : '\u33E0').charCodeAt 0
					return String.fromCharCode(x - 1 + base)

				dateStyled = `{year}年{styleNum month}{styleNum day, no}`
				filled = yes



		if filled
			let info = document.createElement 'span'
			info.id = 'info'
			info.innerText = `{author}{!!author and !!dateRaw ? '\u25AA' : ''}{dateStyled}` 
			heading.appendChild info
	
	def makeArticle
		let app = document.getElementById 'app'

		let article = document.createElement 'article'
		let content = item['content:encoded'] 
		if not content
			content = item['content']
		if not content
			content = `<p>{item['summary']}<a href="{item['link']}">{'⋯⋯'}</a></p>`
		article.innerHTML = content.trim!
		article.insertBefore heading, article.firstChild

		let spacing = document.createElement 'div'
		spacing.classList.add 'after-article'

		app.appendChild article
		app.appendChild spacing

		const browser = detect!
		if browser
			document.body.classList.add browser.name

		let tategaki = new Tategaki article, true, true, true, true
		app.appendChild article

		tategaki.parse!
	
	def parse
		makeHeading!
		makeArticle!
	
	constructor item
		item = item
		parse!
