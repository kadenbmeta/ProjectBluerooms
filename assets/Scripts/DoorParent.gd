extends Spatial



export(bool) var distanceDisappear = true

const MAX_DISTANCE = 60

onready var roomPos = get_parent().translation

var doorsToCheck = 0
var doorDirToDelete

func _process(_delta):
	roomPos = get_parent().translation
	# YOOT BLOCKS <-- why does this say that
	if distanceDisappear:
		if sqrt(pow(abs(roomPos.x-global.playerPos.x),2)+pow(abs(roomPos.z-global.playerPos.z),2)) >= MAX_DISTANCE:
			hide()
		else:
			show()
