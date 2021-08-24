import { XMLHttpRequest } from 'xmlhttprequest'
import express from 'express'
import tategaki from './app/tategaki/index.html'

const app = express!

# catch-all route that returns our index.html
# app.get(/.*/) do(req,res)
# 	# only render the html for requests that prefer an html response
# 	unless req.accepts(['image/*', 'html']) == 'html'
# 		return res.sendStatus(404)

# 	res.send index.body

let BOT_TOKEN = "1891548049:AAHFSUXkGwyMSek8H3_UHuxtQzuNKK3gaGo"
let chatID = "@to_use_denpo"

app.get(/tategaki\/.+/) do(req, res)
	unless req.accepts(['html']) == 'html'
		return res.sendStatus(404)
	
	unless /\/debug$/.test req.path
		let baseURL = "https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
		var request = new XMLHttpRequest!
		let url = "{baseURL}?chat_id={chatID}&text={req.path}"
		request.open "GET", url, true
		request.send!

	res.send tategaki.body


imba.serve app.listen(process.env.PORT or 3000)