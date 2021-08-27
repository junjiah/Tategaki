export class Telegraph
	prop translatedHTML = ""
	prop title


	# Raw replacements for specific puncs & symbols
	def preProcess text
		return text
			.replace(/\u0020*\n[\u0020\n]*/g, '\u200B\u204B') 
			.replace(/——|──/g, '――').replace(/……/g, '⋯⋯')
			# 1) Extra newline; 2) Dashes to U+2015

	# Replacements for HTML tags
	def postProcess text
		return text
			.replace(/\u200B\u204B/g, '<br />&emsp;')
	
	def squeeze text
		const isOpeningBracket = do(ch)
			# The code of opening bracket is always odd
			return ch.charCodeAt(0) % 2 == 0

		def replacer _watch, puncs, _offset, _string
			let squeezed = Array.from(puncs, do(punc)
				if /[\u3001\u3002\uff01\uff0c\uff1a\uff1b\uff1f]/.test punc
					return `<span class="squeeze-other-punc">{punc}</span>`

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
	
	def makeUnits text
		const re = /((?:[\uff10-\uff19\uff21-\uff3a\uff41-\uff5a]|[^\d\p{Script=Latin}\u0020-\u0023\u0025-\u002a\u002c-\u002f\u003a\u003b\u003f\u0040\u005b-\u005d\u005f\u007b\u007d\u00a1\u00a7\u00ab\u00b2\u00b3\u00b6\u00b7\u00b9\u00bb-\u00bf\u2010-\u2013\u2018\u2019\u201c\u201d\u2020\u2021\u2026\u2027\u2030\u2032-\u2037\u2039\u203a\u203c-\u203e\u2047-\u2049\u204e\u2057\u2070\u2074-\u2079\u2080-\u2089\u2150\u2153\u2154\u215b-\u215e\u2160-\u217f\u2474-\u249b\u2e18\u2e2e])+)|((?![\uff10-\uff19\uff21-\uff3a\uff41-\uff5a])[\d\p{Script=Latin}\u0020-\u0023\u0025-\u002a\u002c-\u002f\u003a\u003b\u003f\u0040\u005b-\u005d\u005f\u007b\u007d\u00a1\u00a7\u00ab\u00b2\u00b3\u00b6\u00b7\u00b9\u00bb-\u00bf\u2010-\u2013\u2018\u2019\u201c\u201d\u2020\u2021\u2026\u2027\u2030\u2032-\u2037\u2039\u203a\u203c-\u203e\u2047-\u2049\u204e\u2057\u2070\u2074-\u2079\u2080-\u2089\u2150\u2153\u2154\u215b-\u215e\u2160-\u217f\u2474-\u249b\u2e18\u2e2e]+)/gu

		text = preProcess text

		let matches = []
		let match = re.exec text
		while match
			matches.push match
			match = re.exec text
		
		return matches.map do(match)
			content: match[0]
			isLatin: match[2] != undefined

	def translateToHTML nodes
		let result = ""
		for node in nodes
			if typeof node is "string"
				groups = makeUnits node
				
				let combined = ''

				# Telegra.ph customisations:
				# 1) Three _ / - / * or above will generate an `<hr>`
				if groups.length == 1 and /^_{3,}|-{3,}|\*{3,}$/.test groups[0].content
					combined += '<hr />'
				else
					groups.forEach do(group)
						if group.isLatin
							combined += `<span class="latin" lang="en">{group.content}</span>`
						else
							combined += squeeze group.content

				result += combined 
			else
				let attrsRaw = ''
				if node.attrs
					attrsRaw = Object.entries(node.attrs).map(do(entry)
						let key = entry[0]
						let value = entry[1]
						if (key == 'href' or key == 'src') and value[0] == '/'
							value = 'https://telegra.ph' + value
						return `{key}="{value}"`
					).join ' '

				result += "<{node.tag}{attrsRaw ? ' ' + attrsRaw : ''}>{translateToHTML node.children}</{node.tag}>"
		translatedHTML = postProcess result


	constructor content
		translatedHTML = translateToHTML content