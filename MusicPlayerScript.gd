extends AudioStreamPlayer



func musicSwitch(file):
	stop()
	stream = load(file)
	play()

func _process(_delta):
	if !global.pausing:
		stream_paused = false
	else:
		stream_paused = true
