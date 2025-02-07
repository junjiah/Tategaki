import express from 'express'
import favicon from 'serve-favicon'
import index from './app/index.html'
import tategaki from './app/tategaki/index.html'
import feedPage from './app/feed/index.html'
import errorPage from './app/error/index.html'
import fetch from 'node-fetch'

const app = express!
app.use favicon __dirname + '/public/img/favicon.ico'

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

app.get(/telegraph\/.+/) do(req, res)
	let match = req.path.match(/telegraph\/(.+)/)
	let url = match[1] + '?return_content=true'

	fetch(url).then(do(data)
		data.json!
	).then(do(data)
		res.json data
	).catch do(e)
		res.json { "ok": false, "error": "BAD_JSON" }

app.get(/tategaki\/.+/) do(req, res)
	res.send tategaki.body

app.get(/^\/?$/) do(req, res)
	res.send index.body

app.get(/.+/) do(req, res)
	res.send tategaki.body

imba.serve app.listen(process.env.PORT or 3000)