export class Telegraph
	prop translatedHTML = ""
	prop title

	def translateToHTML content
		let result = ""
		for c in content
			if typeof c is "string"
				groups = cjkGroupsOf c
				let combined = ''
				groups.forEach do(group)
					if group.isLatin
						combined += `<span class="latin" lang="en">{group.content}</span>`
					else if group.isCJK
						combined += `<span class="cjk">{group.content}</span>`
					else
						combined += group.content

				result += combined 
			else
				let attrsRaw = ''
				if c.attrs
					attrsRaw = Object.entries(c.attrs).map(do(entry)
						let key = entry[0]
						let value = entry[1]
						if (key == 'href' or key == 'src') and value[0] == '/'
							value = 'https://telegra.ph' + value
						# console.log key, value
						return `{key}="{value}"`
					).join ' '

				result += "<{c.tag}{attrsRaw ? ' ' + attrsRaw : ''}>{translateToHTML c.children}</{c.tag}>"
		translatedHTML = postProcess result
	
	def preProcess text
		return text.replace(/——|──/g, '――').replace(/……/g, '⋯⋯')
	
	def postProcess text
		return text.replace('\n \n', '<br />&emsp;')
			.replace('\n', '<br />&emsp;')
	
	def cjkGroupsOf text
		let reg = /((?:[\uff10-\uff19\uff21-\uff3a\uff41-\uff5a]|[^\d\p{Script=Latin}\u0021-\u0023\u0025-\u002a\u002c-\u002f\u003a\u003b\u003f\u0040\u005b-\u005d\u005f\u007b\u007d\u00a1\u00a7\u00ab\u00b2\u00b3\u00b6\u00b7\u00b9\u00bb-\u00bf\u2010-\u2013\u2018\u2019\u201c\u201d\u2020\u2021\u2026\u2027\u2030\u2032-\u2037\u2039\u203a\u203c-\u203e\u2047-\u2049\u204b\u204e\u2057\u2070\u2074-\u2079\u2080-\u2089\u2150\u2153\u2154\u215b-\u215e\u2160-\u217f\u2474-\u249b\u2e18\u2e2e])+)|((?![\uff10-\uff19\uff21-\uff3a\uff41-\uff5a])[\d\p{Script=Latin}\u0021-\u0023\u0025-\u002a\u002c-\u002f\u003a\u003b\u003f\u0040\u005b-\u005d\u005f\u007b\u007d\u00a1\u00a7\u00ab\u00b2\u00b3\u00b6\u00b7\u00b9\u00bb-\u00bf\u2010-\u2013\u2018\u2019\u201c\u201d\u2020\u2021\u2026\u2027\u2030\u2032-\u2037\u2039\u203a\u203c-\u203e\u2047-\u2049\u204b\u204e\u2057\u2070\u2074-\u2079\u2080-\u2089\u2150\u2153\u2154\u215b-\u215e\u2160-\u217f\u2474-\u249b\u2e18\u2e2e]+)/gu

		text = preProcess text

		let matches = []
		let match = reg.exec text
		while match
			matches.push match
			match = reg.exec text
		
		# console.log matches
		
		let labelled = matches.map do(match)
			content: match[0]
			isCJK: no # match[1] != undefined
			isLatin: match[2] != undefined

		# Serve as a \0 to deal with all Latin
		labelled.push
			content: ""
			isCJK: yes
			isLatin: no

		# console.log labelled

		let processed = []
		let isLastLatin = no
		let lastLatin = null
		labelled.forEach do(l)
			if isLastLatin
				if l.content is ' ' or l.isLatin
					lastLatin += l.content 
					return
				else
					processed.push
						content: lastLatin 
						isLatin: yes
					isLastLatin = no
			else if l.isLatin
				isLastLatin = true
				lastLatin = l.content
				return
				
			processed.push
				content: l.content
				isCJK: l.isCJK
				isLatin: no
		
		# console.log processed

		return processed