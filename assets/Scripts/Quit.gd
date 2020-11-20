extends ColorRect

# UNUSED

export var total_time = 0.5

func _process(delta):
	#print(color)
	if Input.is_action_pressed("ui_cancel"):
		if color == Color(0,0,0,1):
			# Quit game if screen is dark
			get_tree().quit()
		else:
			# Darken screen if screen isn't 100% dark
			color += Color(0,0,0,delta/total_time)
			# Prevent screen from going over 1 darkness
			color.a = clamp(color.a,0,1)
	else:
		# Brighten screen
		color -= Color(0,0,0,delta/total_time)
		# Prevent screen from going under 0 darkness
		color.a = clamp(color.a,0,1)
