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
						combined += `<span class="latin">{group.content}</span>`
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
						`{key}="{value}"`
					).join ' '

				result += "<{c.tag}{attrsRaw ? ' ' + attrsRaw : ''}>{translateToHTML c.children}</{c.tag}>" + (c.tag is 'p' ? '\n' : '')
		translatedHTML = result
	
	def cjkGroupsOf text
		let reg = /([^\p{Script=Latin}—]+)|(\p{Script=Latin}+)/gu

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
	
export let telegraph = new Telegraph