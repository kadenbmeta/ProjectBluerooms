extends Node



var level

func _ready():
	var levelPath = str(global.currentLevel)
	level = load(str(levelPath)).instance()
	add_child(level)
	$Player.translation = Vector3(0,5,0)
	global.playerPos = Vector3(0,5,0)
	global.debugMsg("Loaded level {"+levelPath+"} as child of game/generalNode",true,["gameAKAgeneralnode.gd","_ready"])
	
func _process(_delta):
	if !has_node("PauseMenu") and !global.pausing:
		global.debugMsg("Pause menu missing, bringing back",true,["gameAKAgeneralnode.gd","_process"])
		var pauseMenu = load("res://assets/Game/pause.tscn").instance()
		add_child(pauseMenu)
