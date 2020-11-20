extends Sprite3D



func _process(_delta):
	look_at(global.playerPos,Vector3.UP)
	global.debugMsg("Looking at {"+str(global.playerPos)+"}",true,["boardSprite.gd","_process"])
