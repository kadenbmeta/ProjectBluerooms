extends Area



export(String) var type

onready var roomPos = get_parent().translation

const MAX_DISTANCE = 60

var collected = false



func _on_Thing_body_entered(body):
	if !collected:
		if body.name == "Player":
			match type:
				"thing":
					body.points += 1
					$Audio.playing = true
					collected = true
					global.debugMsg("Player got a thing, now at {"+str(body.points)+"} points.",true,["Item.gd","_on_Thing_body_entered"])
				"safe":
					if body.keys > 0:
						body.keys -= 1
						body.points += 1
						$Audio.playing = true
						collected = true
						global.debugMsg("Player used a key on a safe, now at {"+str(body.keys)+"} keys and {"+str(body.points)+"} points.",true,["Item.gd","_on_Thing_body_entered"])
					else:
						global.currentText = "I need a key."
						global.debugMsg("Player attempted to use a key on a safe, but is at {"+str(body.keys)+"} keys.",true,["Item.gd","_on_Thing_body_entered"])
				"key":
					body.keys += 1
					$Audio.playing = true
					collected = true
					global.debugMsg("Player got a key, now at {"+str(body.keys)+"} keys.",true,["Item.gd","_on_Thing_body_entered"])
				"crate":
					global.currentText = "I need to break this open."
					global.debugMsg("Player found a crate",true,["Item.gd","_on_Thing_body_entered"])
		elif global.startsWith(body.name, "TST") and type == "crate":
			global.debugMsg("TST hit a crate",true,["Item.gd","_on_Thing_body_entered"])
			breakOpen()



func _process(_delta):
	if !global.pausing:
		$Animation.playing = true
		look_at(global.playerPos,Vector3.UP)
		if global.dblVectDiff(get_global_transform().origin,global.playerPos) >= MAX_DISTANCE:
			hide()
		else:
			show()
	else:
		$Animation.playing = false
	if collected:
		hide()
		if $Audio.playing == false:
			global.debugMsg("Audio finished, using <queue_free()>",true,["Item.gd","_process"])
			queue_free()



func breakOpen():
	if type == "crate":
		var newThing = load("res://assets/Items/Key.tscn").instance()
		get_parent().add_child(newThing)
		newThing.global_transform.origin = global_transform.origin
		hide()
		$Audio.playing = true
		collected = true
		global.debugMsg("Created a key and set crate up for deletion",true,["Item.gd","breakOpen"])


func _on_Key_body_exited(body):
	if body.name == "Player":
		global.currentText = ""
		global.debugMsg("Reset white text.",true,["Item.gd","_on_Key_body_exited"])
