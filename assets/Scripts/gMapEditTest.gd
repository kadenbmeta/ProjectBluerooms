extends GridMap



func _process(_delta):
	if Input.is_action_just_pressed("control_use"):
		var blockCoord = world_to_map(Vector3(global.playerPos.x,global.playerPos.y-2,global.playerPos.z))
		print(blockCoord)
		set_cell_item(blockCoord.x,blockCoord.y,blockCoord.z,INVALID_CELL_ITEM)
		global.debugMsg("Removed block under player, which is a map vector3 of {"+str(blockCoord)+"}.",true,["gMapEditTest.gd","_process"])
