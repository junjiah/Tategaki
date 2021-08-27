import express from 'express'
import tategaki from './app/tategaki/index.html'
import { XMLHttpRequest } from 'xmlhttprequest'


const chatID = "@to_use_denpo"
const BOT_TOKEN = "1891548049:AAHFSUXkGwyMSek8H3_UHuxtQzuNKK3gaGo"

const app = express!

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