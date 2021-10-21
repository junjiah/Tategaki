export def getAnchor
	let splited = document.URL.split '#'
	splited.length > 1 ? '#' + splited[1] : null

export def validateColourHex hex
	/^#([0-9A-F]{3}){1,2}$/i.test hex

def changeProperty variable, value
	document.documentElement.style.setProperty variable, value

export def changeColour colour, value
	document.documentElement.style.setProperty colour, value
	