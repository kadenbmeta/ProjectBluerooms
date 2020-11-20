extends GridMap



# THIS SHOULDN'T BE USED.
# If it is being used by something other than a test then fix it.


var destroyThisBlockItem = 0

const MAX_DISTANCE = 60

func _process(_delta):
	print("--------------------------------------------\nyootableLevel.gd\n--------------------------------------------")
	# YOOT BLOCKS
	
	while global.destroyThisBlock.size() > destroyThisBlockItem:
		# Center world_to_map
		var blockPos = global.destroyThisBlock[destroyThisBlockItem]
		blockPos -= translation
		# Get GMap blockPos
		blockPos = world_to_map(blockPos)
		# Go through all contacts of Yoot
		for xSet in range(-1,2):
			for ySet in range(0,4):
				for zSet in range(-1,2):
					# Continue if tile exists
					if get_cell_item(blockPos.x+xSet,ySet,blockPos.z+zSet) != INVALID_CELL_ITEM:
						# Remove block(s) contacting Yoot
						set_cell_item(blockPos.x+xSet,ySet,blockPos.z+zSet,INVALID_CELL_ITEM)
						#print(blockPos.x+xSet," ",ySet," ",blockPos.z+zSet)
#					else:
#						if global.alreadySent.find(blockPos) == -1:
#							print(blockPos)
#							global.alreadySent.append(blockPos)
		# Next position
		destroyThisBlockItem += 1
		#global.destroyThisBlock.remove(0)
	
	# UNLOAD FAR ROOMS
	
	if sqrt(pow(abs(translation.x-global.playerPos.x),2)+pow(abs(translation.z-global.playerPos.z),2)) >= MAX_DISTANCE:
		hide()
	else:
		show()
