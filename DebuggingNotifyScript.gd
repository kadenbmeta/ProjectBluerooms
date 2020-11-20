extends Control



func _process(_delta):
	if global.debugging:
		show()
	else:
		hide()
