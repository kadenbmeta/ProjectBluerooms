extends Control



# NO LONGER USED.



var game = null
var path = null
var generalNode

var testPath = preload("res://assets/Levels/Test/test_game.tscn")
var gmapPath = preload("res://assets/Levels/Test-GMap/gmap_game.tscn")
var infPath = preload("res://assets/Levels/Test-Infinite/Room-testTEST.tscn")
var fullInfPath = preload("res://assets/Levels/Test-Infinite/Level-test.tscn")
var diffPath = preload("res://assets/Levels/Test-Differences/Level-diff.tscn")
var editPath = preload("res://assets/Levels/Test-Editable/Level-edit.tscn")
var yootPath = preload("res://assets/Levels/Test-Yoot/Level-yoot.tscn")
var cubePath = preload("res://assets/Levels/Test-Cube/Level-cube.tscn")
var enemyPath = preload("res://assets/Levels/Test-Enemy/Level-enemy.tscn")

func startLevel(bIsGame=false,v3PlayerPlacement=Vector3(0,0,0)):
	if !bIsGame:
		var newPlayer = preload("res://assets/Game/Player.tscn").instance()
		var menuPause = preload("res://assets/Game/pause.tscn").instance()
		generalNode = Node.new()
		get_tree().get_root().add_child(generalNode)
		generalNode.add_child(game)
		generalNode.add_child(newPlayer)
		generalNode.add_child(menuPause)
		newPlayer.translation = v3PlayerPlacement
		global.playerPos = v3PlayerPlacement
	else:
		get_tree().get_root().add_child(game)
	
	hide()
	WrldEnv.environment = WrldEnv.game_env

func resetLevel():
	MusicPlayer.stop()
	
	global.resetVars()
	
	generalNode.queue_free()
	
	game = path.instance()
	
	var newPlayer = preload("res://assets/Game/Player.tscn").instance()
	var menuPause = preload("res://assets/Game/pause.tscn").instance()
	generalNode = Node.new()
	get_tree().get_root().add_child(generalNode)
	generalNode.add_child(game)
	generalNode.add_child(newPlayer)
	generalNode.add_child(menuPause)
	newPlayer.translation = Vector3(0,5,0)
	global.playerPos = Vector3(0,5,0)



func _on_buttonSingle_pressed():
	print("Singleplayer (General Test) started!")
	game = testPath.instance()
	path = testPath
	startLevel(true)

func _on_buttonLevel0_pressed():
	print("Level 0 (GridMap/GMap Test) Started!")
	game = gmapPath.instance()
	path = gmapPath
	startLevel(true)

func _on_buttonInfinite_pressed():
	print("Room testTEST Started!")
	game = infPath.instance()
	path = infPath
	startLevel(false,Vector3(0,5,0))

func _on_buttonInfinite2_pressed():
	print("Infinite Test Started!")
	game = fullInfPath.instance()
	path = fullInfPath
	startLevel(false,Vector3(0,5,0))

func _on_buttonSizeRand_pressed():
	print("Size/Rand [Diff(er(ences))] Test Started!")
	path = diffPath
	game = path.instance()
	startLevel(false,Vector3(0,5,0))

# COMMENTED CODE (& lobby music)
func _ready():
	MusicPlayer.musicSwitch("res://assets/Audio/Music1.ogg")
# PAST THIS POINT IS NON-SINGLEPLAYER ONLY

#func _ready():
## warning-ignore:return_value_discarded
#	get_tree().connect("network_peer_connected",self,"_player_connected")

#func _player_connected(id):
#	print("Player connected!")
#	global.otherPlayerId = id
#	var game = testPath.instance()
#	get_tree().get_root().add_child(game)
#	hide()

#func _on_buttonHost_pressed():
#	print("Hosting.")
#	var host = NetworkedMultiplayerENet.new()
#	var res = host.create_server(3134,2)
#	if res != OK:
#		print("Error creating!")
#		return
#
#	$buttonSingle.hide()
#	$buttonJoin.hide()
#	$buttonHost.disabled = true
#	get_tree().set_network_peer(host)

#func _on_buttonJoin_pressed():
#	print("Joining...")
#	var host = NetworkedMultiplayerENet.new()
#	host.create_client($ipEdit.text,3134)
#	get_tree().set_network_peer(host)
#	$buttonSingle.hide()
#	$buttonHost.hide()
#	$buttonJoin.disabled = true
	pass

func _on_buttonEdit_pressed():
	print("Edit Test Started!")
	path = editPath
	game = path.instance()
	startLevel(false,Vector3(0,5,0))

func _on_buttonYoot_pressed():
	print("Yoot Test Started!")
	path = yootPath
	game = path.instance()
	startLevel(false,Vector3(0,5,0))

func _on_buttonCube_pressed():
	print("Cube Test Started!")
	path = cubePath
	game = path.instance()
	startLevel(false,Vector3(0,5,0))

func _on_buttonEnemy_pressed():
	print("Enemy Test Started!")
	path = enemyPath
	game = path.instance()
	startLevel(false,Vector3(0,5,0))
