import { Tategaki } from 'tategaki'


export class Article
	prop item
	prop heading

	def makeTitle
		heading = document.createElement 'header'
		heading.innerHTML = `<h1><a href="{item['link']}">{Tategaki.correctPuncs item.title}</a></h1>`
	
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

		let tategaki = new Tategaki article
		app.appendChild article
		app.appendChild spacing
		

		tategaki.tcy!
	
	def parse
		makeTitle!
		makeArticle!
	
	constructor item
		item = item
		parse!
