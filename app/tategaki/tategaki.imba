export class Tategaki
	prop rootElement\HTMLElement

	# Split raw HTML to classes `cjk` and `latin`
	def splitLatinFromCJK node\Node=rootElement, shouldSqeeze=yes, depth=0
		if node.nodeName[0] != '#'
			if node.nodeName is 'P' and node.childNodes.length is 1
				const text = node.childNodes[0].nodeValue
				if text and text.trim! is '❧'
					let hr = document.createElement 'hr'
					node.parentNode.insertBefore hr, node
					node.parentNode.removeChild node
					return

			for child in Array.from(node.childNodes)
				splitLatinFromCJK child, shouldSqeeze, depth+1
		else
			# TODO: If `depth == 1` and has no tag, wrap it into a `<p>`
			const text = node.nodeValue
			unless node.nodeName == '#text' and text.trim!
				return

			const re = /((?:[\uff10-\uff19\uff21-\uff3a\uff41-\uff5a]|[^\d\p{Script=Latin}\u0020-\u0023\u0025-\u002a\u002c-\u002f\u003a\u003b\u003f\u0040\u005b-\u005d\u005f\u007b\u007d\u00a1\u00a7\u00ab\u00b2\u00b3\u00b6\u00b7\u00b9\u00bb-\u00bf\u2010-\u2013\u2018\u2019\u201c\u201d\u2020\u2021\u2026\u2027\u2030\u2032-\u2037\u2039\u203a\u203c-\u203e\u2047-\u2049\u204e\u2057\u2070\u2074-\u2079\u2080-\u2089\u2150\u2153\u2154\u215b-\u215e\u2160-\u217f\u2474-\u249b\u2e18\u2e2e])+)|((?![\uff10-\uff19\uff21-\uff3a\uff41-\uff5a])[\d\p{Script=Latin}\u0020-\u0023\u0025-\u002a\u002c-\u002f\u003a\u003b\u003f\u0040\u005b-\u005d\u005f\u007b\u007d\u00a1\u00a7\u00ab\u00b2\u00b3\u00b6\u00b7\u00b9\u00bb-\u00bf\u2010-\u2013\u2018\u2019\u201c\u201d\u2020\u2021\u2026\u2027\u2030\u2032-\u2037\u2039\u203a\u203c-\u203e\u2047-\u2049\u204e\u2057\u2070\u2074-\u2079\u2080-\u2089\u2150\u2153\u2154\u215b-\u215e\u2160-\u217f\u2474-\u249b\u2e18\u2e2e]+)/gu
			let matches = []
			let match = re.exec text
			while match
				matches.push match
				match = re.exec text

			matches.forEach do(match)
				let newEle = document.createElement 'span'
				const isLatin = match[2] != undefined

				newEle.classList.add (isLatin ? 'latin' : 'cjk')
				if isLatin
					newEle.setAttribute 'lang', 'en'

				let innerText = Tategaki.correctPuncs match[0].replace /^\n|\n$/g, ''
				if shouldSqeeze and !isLatin
					innerText = squeeze innerText
				if match[0][0] == '\n'
					innerText = '<br />&emsp;' + innerText
				innerText = innerText.replaceAll '\n', '<br />&emsp;'
				newEle.innerHTML = innerText

				node.parentNode.insertBefore newEle, node

			node.parentNode.removeChild node
	
	def removeStyle ele\HTMLElement=rootElement
		if ele.nodeName[0] != '#' and ele.nodeName != 'IFRAME'
			ele.removeAttribute 'style'
			ele.removeAttribute 'class'
			ele.removeAttribute 'width'
			ele.removeAttribute 'height'
			for child in Array.from(ele.children)
				removeStyle child

	# Raw replacements for specific puncs & symbols
	static def correctPuncs text
		return text
			.replace(/——|──/g, '――')
			.replace(/……/g, '⋯⋯')
			# 1) Extra newline; 2) Dashes to U+2015; 3) Correct ellipsis
	
	# Puncuation Squeezing, a.k.a. Puncuation Size & Pos Adjustment
	# More info please refer to `style.css`
	def squeeze text
		const isOpeningBracket = do(ch)
			# The code of opening bracket is always odd
			return ch.charCodeAt(0) % 2 == 0

		def replacer _watch, puncs, _offset, _string
			let squeezed = Array.from(puncs, do(punc)
				if /[\uff01\uff1a\uff1b\uff1f]/.test punc
					return `<span class="squeeze-other-punc">{punc}</span>`
				else if /[\u3001\u3002\uff0c]/.test punc
					# Use up-right puncs (JP form)
					# At current only applied to debug mode
					return `<span class="squeeze-other-punc correct-punc"">{punc}</span>`

				let result = `<span class="{(isOpeningBracket punc) ? 'squeeze-in' : 'squeeze-out'}">{punc}</span>`
				if isOpeningBracket punc
					result =  `<span class="squeeze-in-space"> </span>` + result
				else
					result = result + `<span class="squeeze-out-space"> </span>`

				return result
			).join ''

			return `<span class="squeeze">{squeezed}</span>`

		# Other punctuations: \u3001\u3002\uff01\uff0c\uff1a\uff1b\uff1f
		# Brackets: \u3008-\u3011\u3014-\u301B\uff08\uff09
		let re = /([\u3001\u3002\uff01\uff0c\uff1a\uff1b\uff1f\u3008-\u3011\u3014-\u301B\uff08\uff09]+)/g
		text = text.replace(re, replacer)

	# Since not all browser support full-width transformation,
	# it'll do some unicode calc to do that.
	# Delta between codes of characters in full-width is as same 
	# as ASCII, so choose zero as base for calculation.
	def transformToFullWidth x
		const base = '0'.charCodeAt(0)
		const newBase = '\uff10'.charCodeAt(0)  # Full-width zero
		const current = x.charCodeAt(0)
		return String.fromCharCode(current - base + newBase)

	# Yokogaki in Tategaki (Tategaki-Chyu-Yokogaki)
	def tcy
		let p = document.querySelector('p')
		let fontSizeRaw\string = window.getComputedStyle(p)['font-size'].match(/(\d+)px/)[1]
		let fontSize = parseInt fontSizeRaw

		let eles\HTMLElement[] = Array.from(rootElement.getElementsByClassName 'latin')
		for ele in eles
			const text = ele.innerText.trim!

			if /^[\w\p{Script=Latin}]/.test text
				# Words with only one lettre should turn to full-width
				# and lose `latin` class
				if text.length == 1
					if ele.parentElement.tagName == 'I' or ele.parentElement.tagName == 'EM'
						continue
					ele.innerHTML = transformToFullWidth text
					ele.classList.remove 'latin'
					ele.removeAttribute 'lang'
				# Abbreviations and numbers no more than 4 digits should
				# turn to full-width
				else if /^([A-Z]{3,}|\d{4,})$/.test text
					ele.innerHTML = Array.from(text, do(x)
						transformToFullWidth x
					).join('')
					# Works only in Firefox `text-transform`
					# latin.classList.add 'latin-full-width' 
					ele.classList.remove 'latin'
					ele.removeAttribute 'lang'
				# Other numbers should do TCY but be rendered by CJK fonts
				else if /^[A-Z]{2}$|^\d{2,3}$/.test text
					ele.innerHTML = text
					ele.classList.remove 'latin'
					ele.removeAttribute 'lang'
					ele.classList.add 'tcy'
				# Special cond: Percentage
				else if /^\d{1,3}%$/.test text
					const matches = /^(\d{1,3})%$/.exec text
					let unit = document.createElement 'span'
					let digit = matches[1]
					if digit.length == 1
						digit = transformToFullWidth digit
					unit.innerHTML = `<span {digit.length == 1 ? '' : 'class="tcy"'}>{digit}</span>&#8288;％`
					ele.replaceWith unit
				# Scale height of the ele to decide whether TCY
				else
					let threshold = fontSize
					if ele.innerText != text 
						threshold *= 1.5
					else
						threshold *= 1.333
					if ele.getBoundingClientRect!.height <= threshold 
						ele.innerHTML = text
						ele.classList.remove 'latin'
						ele.removeAttribute 'lang'
						ele.classList.add 'tcy'

	# `element` must be on the screen
	constructor element\HTMLElement, shouldSqueeze=yes
		rootElement = element
		element.classList.add 'tategaki'

		removeStyle!
		splitLatinFromCJK element, shouldSqueeze