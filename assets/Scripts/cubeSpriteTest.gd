extends AnimatedSprite3D



func _process(_delta):
	look_at(global.playerPos,Vector3.UP)
	
	for slice in range(8):
		if rotation_degrees.y > (-180+slice*45):
			if rotation_degrees.y < (-180+(slice+1)*45):
				animation = str(slice)
				global.debugMsg("Looking at {"+str(global.playerPos)+"} with animation {"+animation+"}.",true,["cubeSpriteTest.gd","_process"])
