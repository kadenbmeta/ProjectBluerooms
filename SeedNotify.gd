extends Label



func _process(_delta):
	var windowSize = get_viewport().size
	margin_right = windowSize.x
	margin_bottom = windowSize.y
	text = str(global.rng.seed)
