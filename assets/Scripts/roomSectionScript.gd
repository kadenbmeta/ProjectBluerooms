extends GridMap



export(bool) var yootable = false
export(bool) var distanceDisappear = true

var destroyThisBlockItem = 0

const MAX_DISTANCE = 60

onready var roomPos = get_parent().translation

func _process(_delta):
	roomPos = get_parent().translation
	# YOOT BLOCKS
	if yootable:
		while global.destroyThisBlock.size() > destroyThisBlockItem:
			# Center world_to_map
			var blockPos = global.destroyThisBlock[destroyThisBlockItem]
			blockPos -= roomPos
			# Get GMap blockPos
			blockPos = world_to_map(blockPos)
			# Go through all contacts of Yoot
			for xSet in range(-1,2):
				for ySet in range(-1,4):
					for zSet in range(-1,2):
						# Continue if tile exists
						if get_cell_item(blockPos.x+xSet,ySet,blockPos.z+zSet) != INVALID_CELL_ITEM:
							# Remove block(s) contacting Yoot
							global.debugMsg("Yooted block at map vector {"+str(Vector3(blockPos.x+xSet,ySet,blockPos.z+zSet))+"}",true,["roomSectionScript.gd","_process"])
							set_cell_item(blockPos.x+xSet,ySet,blockPos.z+zSet,INVALID_CELL_ITEM)
			# Next position
			destroyThisBlockItem += 1
	# UNLOAD FAR ROOMS
	if distanceDisappear:
		if sqrt(pow(abs(roomPos.x-global.playerPos.x),2)+pow(abs(roomPos.z-global.playerPos.z),2)) >= MAX_DISTANCE:
			hide()
		else:
			show()
