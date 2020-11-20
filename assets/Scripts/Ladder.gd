extends MeshInstance


func _on_Area_body_entered(body):
	if body.name == "Player":
		global.flying = true
		global.debugMsg("Player now on ladder, turned on flying",true,["Ladder.gd","_on_Area_body_entered"])

func _on_Area_body_exited(body):
	if body.name == "Player":
		global.flying = false
		global.debugMsg("Player now off ladder, turned off flying",true,["Ladder.gd","_on_Area_body_exited"])
