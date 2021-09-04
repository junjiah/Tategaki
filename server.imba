import express from 'express'
import tategaki from './app/tategaki/index.html'
import feedPage from './app/feed/index.html'

const app = express!

app.get(/rss\/.+/) do(req, res)
	let match = req.path.match(/rss\/(.+)/)
	let url = match[1]

	let Parser = require 'rss-parser'
	let parser = new Parser!
	let feed = await parser.parseURL url

	res.json feed.items

app.get(/feed/) do(req, res)
	res.send feedPage.body

app.get(/tategaki\/.+/) do(req, res)
	unless req.accepts(['html']) == 'html'
		return res.sendStatus(404)
	
	''' Could probably add a Telegram bot to send a message for each valid visit
	unless /\/debug$/.test req.path
		let baseURL = "https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
		var request = new XMLHttpRequest!
		let url = "{baseURL}?chat_id={chatID}&text={req.path}"
		request.open "GET", url, true
		request.send!
	'''

	res.send tategaki.body

imba.serve app.listen(process.env.PORT or 3000)