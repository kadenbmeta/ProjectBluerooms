extends Spatial



# Speeds
#const WALK_SPEED = 5
#const RUN_SPEED = 15
const MOVE_SPEED = 30
const TURN_SPEED = 360
const DIM_SPEED = 6

# Distance
var distancePerRoom = 0
var distancePerTurn = 0

# Rooms/objects
#onready var roomLine = [$FullMap/Row1, $FullMap/Row2, $FullMap/Row3]
onready var roomRows = [
	[$FullMap/RoomUL, $FullMap/RoomUP, $FullMap/RoomUR],
	[$FullMap/RoomLEFT, $FullMap/RoomCENTER, $FullMap/RoomRIGHT],
	[$FullMap/RoomDL, $FullMap/RoomDOWN, $FullMap/RoomDR]
]
onready var roomColumns = [
	[$FullMap/RoomLEFT, $FullMap/RoomUL, $FullMap/RoomDL],
	[$FullMap/RoomCENTER, $FullMap/RoomUP, $FullMap/RoomDOWN],
	[$FullMap/RoomRIGHT, $FullMap/RoomUR, $FullMap/RoomDR]
]

# Action(s)
var action = "."
var optionsChosen = []
const MENU_OPTIONS = {
	"Start": {
		"Play": {
			"Normal": {
				"Last Unlocked Stage": [
					"startLastLevel"
				],
				"Level 1": {
					"Stage 1": [
						"startLevel",
						"res://assets/Levels/Houseish/Level-houseishEASY.tscn"
					],
					"Stage 2": [
						"startLockedLevel", [
							"res://assets/Levels/Houseish/Level-houseish.tscn",
							1
						]
					]
				},
				"Level 2": {
					"Stage 1": [
						"startLockedLevel", [
							"res://assets/Levels/Bluered/Level-blueredEASY.tscn",
							2
						]
					],
					"Stage 2": [
						"startLockedLevel", [
							"res://assets/Levels/Bluered/Level-bluered.tscn",
							3
						]
					]
				},
				"Level 3": {
					"Stage 1": [
						"startLockedLevel", [
							"res://assets/Levels/Long/Level-longEASY.tscn",
							4
						]
					],
					"Stage 2": [
						"startLockedLevel", [
							"res://assets/Levels/Long/Level-long.tscn",
							5
						]
					]
				}
			},
			"Explore\n(All unlocked)": {
				"Level 1": {
					"Stage 1": [
						"startLevel",
						"res://assets/Levels/Houseish/Level-houseishEASY.tscn"
					],
					"Stage 2": [
						"startLevel",
						"res://assets/Levels/Houseish/Level-houseish.tscn"
					],
					"Stage 3 (Challenge)": [
						"startLevel",
						"res://assets/Levels/Houseish/Level-houseishHARD.tscn"
					]
				},
				"Level 2": {
					"Stage 1": [
						"startLevel",
						"res://assets/Levels/Bluered/Level-blueredEASY.tscn"
					],
					"Stage 2": [
						"startLevel",
						"res://assets/Levels/Bluered/Level-bluered.tscn"
					]
				},
				"Level 3": {
					"Stage 1": [
						"startLevel",
						"res://assets/Levels/Long/Level-longEASY.tscn"
					],
					"Stage 2": [
						"startLevel",
						"res://assets/Levels/Long/Level-long.tscn"
					],
				}
			},
			"Completion\n(Story mode in one sitting)": [
				"seedMenu"
			]
		},
		"Quit": [
			"quitGame"
		],
		"Back to PL\n(Profiles)": [
			"restartGame"
		]
	}
}
var currentOptions = []

# Transition
var dimming = false

# Labels
var labels = []



func wut():
	print("wut")
	global.debugMsg("wut",true,["menu-3Dvisual.gd","wut"])

func quitGame():
	global.debugMsg("Saving profile {"+global.profileInUse+"} and quitting",true,["menu-3Dvisual.gd","quitGame"])
	global.saveFile(global.profileInUse)
	get_tree().quit()

func restartGame():
	global.debugMsg("Saving profile {"+global.profileInUse+"} and restarting to profile screen",true,["menu-3Dvisual.gd","restartGame"])
	global.saveFile(global.profileInUse)
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/Game/Profiles.tscn")

func startLevel(levelScene):
	global.debugMsg("Starting standard level {"+levelScene+"}.",true,["menu-3Dvisual.gd","startLevel"])
	global.currentLevel = levelScene
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/Game/GameAKAgeneral.tscn")

func startLockedLevel(levelScene,levelID):
	global.debugMsg("Attempting to start locked level {"+levelScene+"} with ID of {"+str(levelID)+"}.",true,["menu-3Dvisual.gd","startLockedLevel"])
	if global.progress["story"].find(levelID) != -1:
		global.debugMsg("Level {"+levelScene+"} is unlocked.",true,["menu-3Dvisual.gd","startLockedLevel"])
		if $"Camera/Light".omni_range <= 0:
			startLevel(levelScene)
		else:
			dimming = true
	else:
		global.debugMsg("Level {"+levelScene+"} is locked. Sending player back.",true,["menu-3Dvisual.gd","startLockedLevel"])
		optionsChosen.remove(optionsChosen.size()-1)

func startLastLevel():
	if global.progress.keys().find("story") != -1:
		if global.progress["story"].size() > 0:
			var largest = 0
			for level in global.progress["story"]:
				if largest < level:
					largest = level
			global.debugMsg("Starting last level, which is ID {"+str(largest)+"}.",true,["menu-3Dvisual.gd","startLastLevel"])
			match largest:
				1:
					startLevel("res://assets/Levels/Houseish/Level-houseish.tscn")
				2:
					startLevel("res://assets/Levels/Bluered/Level-blueredEASY.tscn")
				3:
					startLevel("res://assets/Levels/Bluered/Level-bluered.tscn")
				4:
					startLevel("res://assets/Levels/Long/Level-longEASY.tscn")
				5:
					startLevel("res://assets/Levels/Long/Level-long.tscn")
		else:
			global.debugMsg("Starting last level, which is ID 0 because player hasn't played story mode yet.",true,["menu-3Dvisual.gd","startLastLevel"])
			startLevel("res://assets/Levels/Houseish/Level-houseishEASY.tscn")
	else:
		global.debugMsg("Starting last level, which is ID 0 because player hasn't played story mode yet.",true,["menu-3Dvisual.gd","startLastLevel"])
		startLevel("res://assets/Levels/Houseish/Level-houseishEASY.tscn")

func _ready():
	global.rng.randomize()
	
	# BUILD
	global.undeclared["buildDate"] = "UNBUILT"
#	global.undeclared["newVar"] = "EPIC"
	global.version = "Alpha-1.0+"
	
	WrldEnv.environment = WrldEnv.game_env
	MusicPlayer.stop()
	updateOptions()
	# Get labels
	labels = global.getFamilyMembersWithType($"../2Dgui",[Label])
	# Get title text
	if OS.has_feature("early_access"):
		global.debugMsg("Early access detected.",true,["menu-3Dvisual.gd","_ready"])
		$"../2Dgui/FirstScreen/Title".text += "\n(Early Access)"
	$"../2Dgui/FirstScreen/Controls".text += global.version+"] {"+global.undeclared["buildDate"]+"}"# <"+global.undeclared["newVar"]+">"

func _process(delta):
	# Gui placement
	var windowWidth = get_viewport().size.x
	var windowHeight = get_viewport().size.y
	for currentLabel in labels:
		currentLabel.margin_right = windowWidth
		currentLabel.margin_bottom = windowHeight
		match currentLabel.name:
			"Right":
				currentLabel.margin_left = (windowWidth*(2.0/3.0))+50
			"Left":
				currentLabel.margin_right = (windowWidth*(1.0/3.0))-50
			"Selection":
				currentLabel.margin_right = (windowWidth*(2.0/3.0))+50
				currentLabel.margin_left = (windowWidth*(1.0/3.0))-50
	$Camera.fov = global.fov
	if !global.pausing:
		if !dimming:
			if optionsChosen == []:
				$"../2Dgui/FirstScreen".show()
			else:
				$"../2Dgui/FirstScreen".hide()
			match action:
				".":
					global.debugMsg("Currently no menu action",true,["menu-3Dvisual.gd","_process"])
					# Check for action
					$"../2Dgui".hide()
					if Input.is_action_just_pressed("move_left"):
						action = "A"
						distancePerTurn = 0
						cycleOptions(true)
					elif Input.is_action_just_pressed("move_right"):
						action = "D"
						distancePerTurn = 0
						cycleOptions(false)
					elif Input.is_action_just_pressed("move_forward"):
						action = "W"
						distancePerRoom = 0
						optionsChosen.append(currentOptions[0])
						updateOptions()
					elif Input.is_action_just_pressed("move_backward"):
						action = "S"
						distancePerRoom = 0
						if optionsChosen.size() != 0:
							optionsChosen.remove(optionsChosen.size()-1)
							updateOptions()
					else:
						$"../2Dgui".show()
				"A":
					global.debugMsg("Turning left",true,["menu-3Dvisual.gd","_process"])
					# Turn left
					$Camera.rotation_degrees.y += TURN_SPEED*delta
					distancePerTurn += TURN_SPEED*delta
					if distancePerTurn >= 90:
						$Camera.rotation_degrees.y = stepify($Camera.rotation_degrees.y,90)
						action = "."
				"D":
					global.debugMsg("Turning right",true,["menu-3Dvisual.gd","_process"])
					# Turn right
					$Camera.rotation_degrees.y -= TURN_SPEED*delta
					distancePerTurn += TURN_SPEED*delta
					if distancePerTurn >= 90:
						$Camera.rotation_degrees.y = stepify($Camera.rotation_degrees.y,90)
						action = "."
				"W":
					global.debugMsg("Confirming",true,["menu-3Dvisual.gd","_process"])
					# Confirm
					var direction = Vector3()
					direction -= $Camera.get_global_transform().basis.z
					move(direction,delta,0)
				"S":
					global.debugMsg("Cancelling",true,["menu-3Dvisual.gd","_process"])
					# Cancel
					var direction = Vector3()
					direction += $Camera.get_global_transform().basis.z
					move(direction,delta,180)
		else:
			global.debugMsg("Currently dimming menu",true,["menu-3Dvisual.gd","_process"])
			if get_parent().has_node("PauseMenu"):
				$"../PauseMenu".queue_free()
			$"../2Dgui/Options".hide()
			$"../2Dgui".show()
			$"Camera/Light".omni_range -= delta*DIM_SPEED
			if $"Camera/Light".omni_range <= 0:
				callCommand(true)

func updateMode():
	if optionsChosen.size() > 3:
		if optionsChosen[1] == "Play":
			match optionsChosen[2]:
				"Normal":
					global.gameMode = "story"
				"Explore\n(All unlocked)":
					global.gameMode = "explore"
				"Completion\n(Story mode in one sitting)":
					global.gameMode = "complete"
	global.debugMsg("global.gameMode now is {"+global.gameMode+"}",true,["menu-3Dvisual.gd","updateMode"])

func callCommand(_isDimmingCall=false):
	updateMode()
	var command = MENU_OPTIONS
	for option in optionsChosen:
		command = command[option]
#	if command[0] == "startLockedLevel" and isDimmingCall:
#		return
	match typeof(command):
		TYPE_STRING:
			global.debugMsg("Calling command {"+command+"} using <call(command)> because command is TYPE_STRING",true,["menu-3Dvisual.gd","callCommand"])
			call(command)
		TYPE_ARRAY:
			global.debugMsg("Command is TYPE_ARRAY, checking size",true,["menu-3Dvisual.gd","callCommand"])
			if command.size() > 1:
				global.debugMsg("Command.size() is > 1, checking command[1]'s type",true,["menu-3Dvisual.gd","callCommand"])
				match typeof(command[1]):
					TYPE_STRING:
						global.debugMsg("Calling command {"+str(command[0], command[1])+"} using <call(command[0], command[1])> because command[1] is TYPE_STRING",true,["menu-3Dvisual.gd","callCommand"])
						call(command[0], command[1])
					TYPE_ARRAY:
						global.debugMsg("Calling command {"+str(command[0], command[1])+"} using <callv(command[0], command[1])> because command[1] is TYPE_ARRAY",true,["menu-3Dvisual.gd","callCommand"])
						callv(command[0], command[1])
			else:
				global.debugMsg("Calling command {"+command[0]+"} using <call(command[0])> because command.size() is <= 1",true,["menu-3Dvisual.gd","callCommand"])
				call(command[0])

func move(direction,delta,offset):
	global.debugMsg("Moving towards direction {"+str(direction)+"}",true,["menu-3Dvisual.gd","move"])
	$Camera.translation += direction*MOVE_SPEED*delta
	distancePerRoom += MOVE_SPEED*delta
	if distancePerRoom >= 12:
		global.debugMsg("Has moved enough.",true,["menu-3Dvisual.gd","move"])
		$Camera.translation.x = stepify($Camera.translation.x,12)
		$Camera.translation.z = stepify($Camera.translation.z,12)
		shift(getLookAxis(offset))
		action = "."

func getLookAxis(offset=0):
	$Camera.rotation_degrees.y = int(stepify($Camera.rotation_degrees.y,90))%360
	var returnVal
	match int($Camera.rotation_degrees.y+offset):
		0:
			returnVal = "UP"
		90, -270:
			returnVal = "LEFT"
		-180, 180:
			returnVal = "DOWN"
		270, -90:
			returnVal = "RIGHT"
		var _Else:
			returnVal = "ERROR"
	global.debugMsg("Value {"+str(int($Camera.rotation_degrees.y+offset))+"} returned {"+returnVal+"}",true,["menu-3Dvisual.gd","getLookAxis"])
	return returnVal

func shift(direction):
	global.debugMsg("Shifting in direction {"+direction+"}",true,["menu-3Dvisual.gd","shift"])
	match direction:
		"DOWN":
			var moveTheseRooms = roomRows[0]
			roomRows.append(roomRows[0])
			roomRows.remove(0)
			for room in moveTheseRooms:
				room.translation.z += 12*3
		"UP":
			var moveTheseRooms = roomRows[-1]
			roomRows.push_front(roomRows[-1])
			roomRows.remove(roomRows.size()-1)
			for room in moveTheseRooms:
				room.translation.z -= 12*3
		"RIGHT":
			var moveTheseRooms = roomColumns[0]
			roomColumns.append(roomColumns[0])
			roomColumns.remove(0)
			for room in moveTheseRooms:
				room.translation.x += 12*3
		"LEFT":
			var moveTheseRooms = roomColumns[-1]
			roomColumns.push_front(roomColumns[-1])
			roomColumns.remove(roomColumns.size()-1)
			for room in moveTheseRooms:
				room.translation.x -= 12*3

func updateOptions():
	var optionPath = MENU_OPTIONS
	for option in optionsChosen:
		optionPath = optionPath[option]
	if typeof(optionPath) == TYPE_DICTIONARY:
		global.debugMsg("Picked an option of TYPE_DICTIONARY, which is not a final option",true,["menu-3Dvisual.gd","updateOptions"])
		currentOptions = optionPath.keys()
	else:
		global.debugMsg("Picked an option NOT of TYPE_DICTIONARY, which IS a final option",true,["menu-3Dvisual.gd","updateOptions"])
		if optionPath[0] != "startLockedLevel":
			dimming = true
		else:
			callCommand()
	optionText()

func cycleOptions(reverse=false):
	match reverse:
		false:
			global.debugMsg("Cycling options rightwards",true,["menu-3Dvisual.gd","cycleOptions"])
			currentOptions.append(currentOptions[0])
			currentOptions.remove(0)
		true:
			global.debugMsg("Cycling options leftwards",true,["menu-3Dvisual.gd","cycleOptions"])
			currentOptions.push_front(currentOptions[-1])
			currentOptions.remove(currentOptions.size()-1)
	optionText()

func optionText():
	$"../2Dgui/Options/Selection".text = currentOptions[0]
	if currentOptions.size() == 1:
		global.debugMsg("Only one option, hiding left and right peek options",true,["menu-3Dvisual.gd","optionText"])
		$"../2Dgui/Options/Sides".hide()
	else:
		global.debugMsg("Multiple options, showing left and right peek options",true,["menu-3Dvisual.gd","optionText"])
		$"../2Dgui/Options/Sides".show()
		$"../2Dgui/Options/Sides/Left".text = currentOptions[-1]
		$"../2Dgui/Options/Sides/Right".text = currentOptions[1]

func seedMenu():
	global.gameMode = "complete"
	global.debugMsg(["Switching to seed menu gave error of {",get_tree().change_scene("res://assets/Game/SeedScreen.tscn"),"}"],true,["menu-3Dvisual.gd","seedMenu"])
