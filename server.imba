import express from 'express'
import tategaki from './app/tategaki/index.html'
import feedPage from './app/feed/index.html'
import errorPage from './app/error/index.html'

const app = express!

app.get(/rss\/.+/) do(req, res)
	let match = req.path.match(/rss\/(.+)/)
	let url = match[1]

	let Parser = require 'rss-parser'
	let parser = new Parser!

	parser.parseURL url, do(err, feed)
		res.json {
			found: not err
			title: err ? undefined : feed.title 
			items: err ? undefined : feed.items
		}

app.get(/error\/.+/) do(req, res)
	res.send errorPage.body

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