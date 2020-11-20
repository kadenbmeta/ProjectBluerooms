extends GridMap



var hasPlayer = false
var queuedQueueFree = false

export(Array, Resource) var possibleStreams

onready var thoughtsWhenOpened = get_parent().get_parent().thoughtsWhenOpened

func _ready():
	hide()
#	if global_transform.origin == global.lastOpenedDoorPos:
#		queue_free()
#	else:
#		print(global_transform.origin,"!=",global.lastOpenedDoorPos)

func _on_Area_body_entered(body):
	if body.name == "Player":
		hasPlayer = true
		global.debugMsg("Player has entered door's area",true,["Door.gd","_on_Area_body_entered"])

func _on_Area_body_exited(body):
	if body.name == "Player":
		hasPlayer = false
		global.debugMsg("Player has exited door's area",true,["Door.gd","_on_Area_body_exited"])

func _process(_delta):
	if queuedQueueFree:
		collision_layer = 0
		collision_mask = 0
		hide()
		if !$Audio.playing:
			queue_free()
	else:
		if get_parent().doorsToCheck != 0:
			var myDir
			if translation.x > 0:
				myDir = "x+"
			elif translation.x < 0:
				myDir = "x-"
			else:
				if translation.z > 0:
					myDir = "z+"
				else:
					myDir = "z-"
			if myDir == get_parent().doorDirToDelete:
				global.debugMsg("After checking new doors, door with myDir of {"+myDir+"} was removed.",true,["Door.gd","_process"])
				get_parent().doorsToCheck = 0
				queue_free()
			else:
				global.debugMsg("After checking new doors, door with myDir of {"+myDir+"} was kept. It wasn't the door with myDir of {"+get_parent().doorDirToDelete+"}",true,["Door.gd","_process"])
				get_parent().doorsToCheck -= 1
				show()
		else:
			show()
		if Input.is_action_just_pressed("control_use") and !global.hasTutorialText:
			if hasPlayer:
				global.debugMsg("Action-control_use just pressed, global.hasTutorialText is false and hasPlayer is true. Opening door.",true,["Door.gd","_process"])
				# Rolls
				var roll = global.rng.randi_range(1,100)
				global.debugMsg(["In TheUnseen spawning, a {",roll,"} was rolled. The needed value is {",get_parent().get_parent().get_parent().lookAwayChance,"} or less."],true,["Door.gd","_process"])
				if roll <= get_parent().get_parent().get_parent().lookAwayChance:
					global.debugMsg("Spawning an Unseen",true,["Door.gd","_process"])
					var unseen = load("res://assets/Enemies/TheUnseen.tscn").instance()
					get_parent().get_parent().add_child(unseen)
					unseen.global_transform.origin = global_transform.origin
				# Generate room
				var levelNode = get_parent()
				while !global.startsWith(levelNode.name, "Level-"):
					levelNode = levelNode.get_parent()
				if levelNode.hasDoors == true:
					var generationDir
					var deleteDir
					if translation.x > 0:
						generationDir = "x+"
						deleteDir = "x-"
					elif translation.x < 0:
						generationDir = "x-"
						deleteDir = "x+"
					else:
						if translation.z > 0:
							generationDir = "z+"
							deleteDir = "z-"
						else:
							generationDir = "z-"
							deleteDir = "z+"
					global.debugMsg("Calling generateRoom with generationDir of {"+generationDir+"}",true,["Door.gd","_process"])
					levelNode.generateRoom(generationDir,deleteDir)
				# Double door glitch prevention
				global.lastOpenedDoorPos = global_transform.origin
				# Open room
				if get_parent().get_parent().open == false:
					get_parent().get_parent().open = true
					if thoughtsWhenOpened.size() != 0:
						for thought in thoughtsWhenOpened:
							if global.alreadySent.find(thought) == -1:
								global.thoughtQueue.append(thought)
								global.alreadySent.append(thought)
				var soundIndex = 0
				if possibleStreams.size() > 0:
					soundIndex = global.rng.randi_range(0,possibleStreams.size()-1)
				$Audio.stream = possibleStreams[soundIndex]
				$Audio.play()
				hide()
				queuedQueueFree = true
			else:
				global.debugMsg("Action-control_use just pressed, global.hasTutorialText is false BUT hasPlayer is false. Keeping this door closed.",true,["Door.gd","_process"])
