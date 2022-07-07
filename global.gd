extends Node



var version = "If you are reading this there's a coding issue"
var undeclared = {}



# NOTES
# --------------------------------------------------------------------
# Roughness 0 has a creepy effect on textures
#
# "If stop_on_slope is true, body will not slide on slopes when you
# include gravity in linear_velocity and the body is standing still."
# - move_and_slide(),
# https://docs.godotengine.org/en/stable/classes/class_kinematicbody.html#class-kinematicbody-method-move-and-slide

var ideasOrTodoList = {
	"C U R R E N T":
		
		"Features: Version loader",
		
	"REQUIRED": {
		"STARTr": null,
		
		
		
		"Level": [
			"bluered - challenge",
			"long - challenge",
			"bridges"],
		"Bugfixes": [
			#"Angry Yoot in wall",
			"Running/walking sound during pause"],
		"Items": [
			"Bombs"],
		"Features": [
			"VR",
			"Mobile Android",
			"Camera bobbing",
			"Version loader",
			"Modding support"],
		"Audio": [
			"Walking (better)",
			"Key"],
		"General": [
			"Better fitting gui"],
		
		
		
		"ENDr": null},
	"WANTS": {
		"STARTw": null,
		
		
		
		"???": [
			"???"],
		
		
		
		"ENDw": null},
	"CONSIDER IN THE FUTURE": {
		"STARTf": null,
		
		
		
		"Endings": [
			"Glitch level",
			"Actual room picture",
			"Outside of map",
			"TEST from RESET [?]",
			"Play as Yoot"],
		"Modes": [
			"Speedrun",
			"Hardcore",
			"One-Room Endless Survival",
			"Seed input"],
		"Words": [
			"Kenopsia",
			"Anemoia",
			"Agnosthesia",
			"Lilo",
			"Onism",
			"Scabulous",
			"Wytai",
			"Kuebiko",
			"Lachesism"],
		
		
		
		"ENDf": null}
}

var credits = {
	"FONTS": {
		"Pixellari": "Zacchary Dempsey-Plante",
		"Pixel Intv": "Pixel Sagas",
		"Pixel Bug": [
			"Matheus Padovani - https://www.facebook.com/Padovanirs",
			"Peter Quini"]},
	"SOFTWARE": {
		"Game Engine": "Godot Engine",
		"Audio": [
			"BeepBox.co",
			"Cakewalk",
			"Audacity"]}
}

# --------------------------------------------------------------------



# Declare vars

var pausing
var flying
var playerPos
var destroyThisBlock = []
var thoughtQueue = []
var currentLevel
var lastOpenedDoorPos = Vector3()
var hasTutorialText = false
var currentText
var currentMode
var gameMode = "notPlaying"
var originalInputMap = {}


# Debug vars

var alreadySent = []
var lastTime = ""
var debugMsgBank = []
var debugFileBanks = ""
var debugging = false
var debugNotif



# Profile

var profileInUse = "N O N E"
var loadedUpdate = false



# Settings/saved vars

var mouse_sensitivity# = 0.3
var controller_sensitivity# = 5
var fov# = 70
var musicMultiplier# = 0.4
var sfxMultiplier# = 0.5
var deadzone# = 0.4
var inversionY# = 1
var shiftToggle# = false
var progress
var firstPlay = {}
var controllerTurnRight



# Constants

const ACTION_NAMES = [
	"Forward - move_forward",
	"Left - move_left",
	"Right - move_right",
	"Backward - move_backward",
	"Jump - move_jump",
	"Sprint - move_sprint",
	"Pause - control_pause",
	"Open door - control_use",
	"Advance yellow text - control_think",
	"Dump debug file - debug"]


# RNG

var rng = RandomNumberGenerator.new()



func _ready():
	debugMsg("Test debug, no path")
	debugMsg("Test debug, with path",true,["Item1","Item2","Item3"])
	global.rng.randomize()
	resetVars()
	# Get original input map
	for action in InputMap.get_actions():
		originalInputMap[action] = InputMap.get_action_list(action)

func _process(_delta):
	if profileInUse != "N O N E":
		for action in InputMap.get_actions():
			InputMap.action_set_deadzone(action,deadzone)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfxMultiplier))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(musicMultiplier))
		if thoughtQueue.size() == 0:
			hasTutorialText = false
		else:
			hasTutorialText = true
	if Input.is_action_just_pressed("debug"):
		debugging = !debugging
		if !debugging:
			createDebugFile()

func createDebugFile():
	var debugFile = File.new()
	var time = OS.get_datetime()
	var dateFormatted = str(time.year,"-",time.month,"-",time.day,"-",time.hour,"h",time.minute,"m",time.second,"s")
	debugFile.open("user://debug/dump-"+dateFormatted+".txt", File.WRITE)
	debugFile.store_line(debugFileBanks)
	debugFile.close()
	print("DEBUG FILE DUMPED")



func resetVars():
	debugMsg("[global.gd -> resetVars] Reset resettable vars")
	# Resettable globals
	pausing = false
	flying = false
	playerPos = Vector3()
	destroyThisBlock = []
	thoughtQueue = []
	lastOpenedDoorPos = Vector3()
	hasTutorialText = false
	currentText = ""

func loadFile(name, firstTime=false):
	debugMsg("[global.gd -> loadFile] Loading file user://{"+str(name)+"}.cfg with firstTime being {"+str(firstTime)+"}.")
	var savefile = ConfigFile.new()
	if firstTime:
		savefile.save("user://"+name+".cfg")
	var err = savefile.load("user://"+name+".cfg")
	if err == OK:
		# Get setting values
		mouse_sensitivity = savefile.get_value("control", "mouseSensitive", 0.3)
		controller_sensitivity = savefile.get_value("control", "joySensitive", 5)
		fov = savefile.get_value("graphics", "visionField", 70)
		musicMultiplier = savefile.get_value("audio", "musicVol", 0.4)
		sfxMultiplier = savefile.get_value("audio", "sfxVol", 0.5)
		deadzone = savefile.get_value("control", "deadzone", 0.4)
		inversionY = savefile.get_value("control", "invertY", 1)
		shiftToggle = savefile.get_value("control", "shiftMode", false)
		progress = savefile.get_value("save", "progress", {
			"story": []
		})
		firstPlay = savefile.get_value("save", "diedOn", {})
		var currentInputMap
		if savefile.has_section_key("control","inputMap"):
			currentInputMap = savefile.get_value("control", "inputMap")
		else:
			currentInputMap = originalInputMap
		for action in InputMap.get_actions():
			InputMap.action_erase_events(action)
			for newEvent in currentInputMap[action]:
				InputMap.action_add_event(action,newEvent)
		controllerTurnRight = savefile.get_value("control", "ctrlTurnRight", true)
		undeclared["speedrunTimer"] = savefile.get_value("misc", "speedrunTimer", false)
		# Save file in case of missing settings
		saveFile(name)
		# Boot menu
		profileInUse = name
		debugMsg("[global.gd -> loadFile] Switched to scene res://assets/Game/Menu.tscn, error {"+str(get_tree().change_scene("res://assets/Game/Menu.tscn"))+"} given.")
	else:
		debugMsg("[global.gd -> loadFile] File load user://{"+str(name)+"}.cfg with firstTime being {"+str(firstTime)+"} is probably invalid, cannot load. Error given was {"+str(err)+"}, not OK")

func saveFile(name):
	var currentFile = ConfigFile.new()
	var err = currentFile.load("user://"+name+".cfg")
	if err == OK:
		# Set setting values
		currentFile.set_value("control", "mouseSensitive", mouse_sensitivity)
		currentFile.set_value("control", "joySensitive", controller_sensitivity)
		currentFile.set_value("graphics", "visionField", fov)
		currentFile.set_value("audio", "musicVol", musicMultiplier)
		currentFile.set_value("audio", "sfxVol", sfxMultiplier)
		currentFile.set_value("control", "deadzone", deadzone)
		currentFile.set_value("control", "invertY", inversionY)
		currentFile.set_value("control", "shiftMode", shiftToggle)
		currentFile.set_value("save", "progress", progress)
		currentFile.set_value("save", "diedOn", firstPlay)
		var currentInputMap = {}
		for action in InputMap.get_actions():
			currentInputMap[action] = InputMap.get_action_list(action)
		currentFile.set_value("control", "inputMap", currentInputMap)
		currentFile.set_value("control", "ctrlTurnRight", controllerTurnRight)
		currentFile.set_value("misc", "speedrunTimer", undeclared["speedrunTimer"])
		# Save file
		debugMsg("[global.gd -> saveFile] File save user://{"+str(name)+"}.cfg threw error of {"+str(currentFile.save("user://"+name+".cfg"))+"}")
	else:
		debugMsg("[global.gd -> saveFile] File load user://{"+str(name)+"}.cfg is probably invalid, cannot load. Error given was {"+str(err)+"}, not OK")

func dblPtDiff(ax,ay,bx,by):
	var returnVal = sqrt(pow(abs(ax-bx),2)+pow(abs(ay-by),2))
	debugMsg("[global.gd -> dblPtDiff] The difference of the points ({"+str(ax)+"},{"+str(ay)+"}) and ({"+str(bx)+"},{"+str(by)+"}) is {"+str(returnVal)+"}")
	return returnVal

func dblVectDiff(a,b):
	var returnVal = sqrt(pow(abs(a.x-b.x),2)+pow(abs(a.z-b.z),2))
	debugMsg("[global.gd -> dblVectDiff] Ignoring Y vects, the difference of the vectors {"+str(a)+"} and {"+str(b)+"} is {"+str(returnVal)+"}")
	return returnVal

# THIS IS BUILT IN! String.begins_with()
func startsWith(strIn, prefix):
	var returnVal = strIn.trim_prefix(prefix) != strIn
	debugMsg("Does {"+strIn+"} start with {"+prefix+"}? Answer is {"+str(returnVal)+"}",true,["global.gd","startsWith"])
	return returnVal

func getFamilyMembersWithType(startNode, types):
	var others = [startNode]
	var these = []
	while others.size() > 0:
		if others[0].get_child_count() > 0:
			for child in others[0].get_children():
				for currentType in types:
					if child is currentType:
						these.append(child)
						break
					if currentType == types[-1]:
						others.append(child)
		others.remove(0)
	var theseStr = []
	for item in these:
		theseStr.append(item.name)
	debugMsg("The family members of {"+startNode.name+"} that fall under the type(s) {"+str(types)+"} are {"+str(theseStr)+"}",true,["global.gd","getFamilyMembersWithType"])
	return these

func existsWithinArrays(strToFind, startArray):
	var arraysToCheck = [startArray]
	while arraysToCheck.size() > 0:
		for item in arraysToCheck[0]:
			if item is Array:
				arraysToCheck.append(item)
			elif item is String:
				if item == strToFind:
					debugMsg("The string, {"+strToFind+"}, exists within the (nested) array, {"+str(startArray)+"}.",true,["global.gd","existsWithinArrays"])
					return true
		arraysToCheck.remove(0)
	debugMsg("The string, {"+strToFind+"}, DOES NOT exist within the (nested) array, {"+str(startArray)+"}.",true,["global.gd","existsWithinArrays"])
	return false

func eventTitle(event):
	if event is InputEventKey:
		debugMsg("Event given was a InputEventKey, returning <event.as_text()>.",true,["global.gd","eventTitle"])
		return "Keyboard key: "+event.as_text()
	elif event is InputEventJoypadButton:
		debugMsg("Event given was a InputEventJoypadButton, returning <Input.get_joy_button_string(event.button_index)>.",true,["global.gd","eventTitle"])
		return "Joypad button: "+Input.get_joy_button_string(event.button_index)
	elif event is InputEventJoypadMotion:
		debugMsg("Event given was a InputEventJoypadMotion, returning something along lines of 'Joystick [Left/Right]: [Left/Right/Up/Down]'",true,["global.gd","eventTitle"])
		var axis = event.axis
		var val = event.axis_value
		if val == 1:
			match axis:
				JOY_AXIS_0:
					return "Joystick Left: Right"
				JOY_AXIS_1:
					return "Joystick Left: Down"
				JOY_AXIS_2:
					return "Joystick Right: Right"
				JOY_AXIS_3:
					return "Joystick Right: Down"
		else:
			match axis:
				JOY_AXIS_0:
					return "Joystick Left: Left"
				JOY_AXIS_1:
					return "Joystick Left: Up"
				JOY_AXIS_2:
					return "Joystick Right: Left"
				JOY_AXIS_3:
					return "Joystick Right: Up"

func debugMsg(msg="NO MSG FOUND",new=false,pathItems=[]):
	if debugging:
		var time = OS.get_datetime()
		var timeFormatted = str("(",time.month,"/",time.day,"|",time.hour,":",time.minute,":",time.second,")")
		var printMsg
		if debugMsgBank == []:
			debugMsgBank = [timeFormatted]
		if lastTime == "":
			lastTime = timeFormatted
		if typeof(msg) == TYPE_ARRAY:
			var tempMsg = ""
			for item in msg:
				tempMsg += str(item)
			msg = tempMsg
		if !new:
			printMsg = str(msg)
		else:
			var path = "["
			for item in pathItems:
				path += item
				if pathItems.find(item) == pathItems.size()-1:
					path += "]"
				else:
					path += " -> "
			printMsg = str(path," ",msg)
		var fullPrint = ""
		if debugMsgBank.find(printMsg) == -1:
			debugMsgBank.append(printMsg)
		for msgItem in debugMsgBank:
			fullPrint += str(msgItem)+"\n"
		if alreadySent.find(fullPrint) == -1:
			if timeFormatted != lastTime:
				debugFileBanks += fullPrint+"\n"
				alreadySent.append(fullPrint)
				lastTime = timeFormatted
				debugMsgBank = []

func passedPos(globalPos,globalCurrent,globalFirst,globalFirstPos=Vector3()):
	if globalFirstPos == Vector3():
		globalFirstPos = globalPos
	
	var firstLessX = (globalFirst.x < globalFirstPos.x)
	var firstLessZ = (globalFirst.z < globalFirstPos.z)
	
	if firstLessX:
		if (globalCurrent.x > globalPos.x):
			return true
	else:
		if (globalCurrent.x < globalPos.x):
			return false
	
	if firstLessZ:
		if (globalCurrent.z > globalPos.z):
			return true
	else:
		if (globalCurrent.z < globalPos.z):
			return false
