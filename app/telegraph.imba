# `Telegraph` retrieve data from Telegra.ph and translate it
# to HTML for later progress
export class Telegraph
	prop title
	prop author
	prop date
	
	prop contentHTML = ""


	# Please refer to JSON file created by `https://api.telegra.ph/getPage`
	# A node may contain tag, attributes and its children
	def translateToHTML nodes
		let result = ""
		for node in nodes
			if typeof node is "string"
				# Telegra.ph customisations:
				# 1) Three _ / - / * or above will generate an `<hr>`
				if /^_{3,}|-{3,}|\*{3,}$/.test node
					result += '<hr />'
				if /\*:.+:\*/.test node
					def rubyReplacer match, before, offset, string
						def replacer m, p1, o, s
							let _class = ''
							if /[\u02d9\u02c9\u02ca\u02c7\u02cb\u02ea\u02eb\u3105-\u312d\u31a0-\u31b2\u31b4\u31b5\u31b7]/.test p1
								_class = 'bopomofo'
							elif /\p{Script=Latin}/u.test p1
								_class = 'pinyin'

							return `<rt class="{_class}">{p1}</rt>`

						const after = before.replace /\/([^\/]+)\//g, replacer
						return `<ruby>{after}</ruby>`

					result += node.replace /\*:([^:]+):\*/g, rubyReplacer
				else
					result += node
			else 
				let attrsRaw = ''
				if node.attrs
					attrsRaw = Object.entries(node.attrs).map(do(entry)
						let key = entry[0]
						let value = entry[1]
						if value[0] == '/'
							if key == 'href'
								value = '.' + value
							else if key == 'src'
								value = 'https://telegra.ph/' + value
						return `{key}="{value}"`
					).join ' '

				result += "<{node.tag}{attrsRaw ? ' ' + attrsRaw : ''}>{translateToHTML node.children}</{node.tag}>"
		return result

	constructor content
		contentHTML = translateToHTML content