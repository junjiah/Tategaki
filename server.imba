import express from 'express'
import tategaki from './app/tategaki/index.html'

const app = express!

# catch-all route that returns our index.html
# app.get(/.*/) do(req,res)
# 	# only render the html for requests that prefer an html response
# 	unless req.accepts(['image/*', 'html']) == 'html'
# 		return res.sendStatus(404)

# 	res.send index.body

app.get(/tategaki\/.+/) do(req, res)
	unless req.accepts(['html']) == 'html'
		return res.sendStatus(404)

	res.send tategaki.body

imba.serve app.listen(process.env.PORT or 3000)