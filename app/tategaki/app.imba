import { Tategaki } from './tategaki'
import fetch from 'node-fetch'
import '../css/style.css'


let tategaki = new Tategaki window.location.pathname 
const url = tategaki.url

fetch(url).then(do(res)
	res.json!
).then do(data)
	tategaki.parse data

document.fonts.onloadingdone = do(e)
	# Forcing Chrome to re-calculate TCY width
	# It's unbearably worked-around
	for ele in document.getElementsByClassName 'tcy'
		ele.style.display = 'none'
		setTimeout(do
			ele.style.display = 'inline'
		1)

# Entrance of `tategaki`, will not render anything except `<Footer>`
# before retrieving data
tag app
	<self#app lang="zh-Hant">
		<Footer>

# Extra information. Should be removed in future
tag Footer
	css self
		pos:fixed
		b:0
		l:0
		r:0
		writing-mode:horizontal-tb
		ta:center
		p:10px
		c:#787f86
		lh:normal

	<self.latin>
		<small>
			<b> "Denpo in Tategaki"
			" is under development. If any issue arise, feel free to contact Toto at "
			<a href="mailto:the@unpopular.me"> "the@unpopular.me"
			" or join " 
			<a href="https://t.me/denpo_beta"> "Telegram Group"
			" at your convenience."