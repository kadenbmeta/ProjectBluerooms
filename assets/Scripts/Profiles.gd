extends Node



var history
# 15 lines fit in screenHeight
# screenHeight = windowHeight - 20
# windowHeight[default] = 1024
# screenHeight[default] = 1004
# x * 15 = 1004
# 1004 / 15 = x
# lineHeight = x
# lineHeight * y = screenHeight
# y * lineHeight = screenHeight
# screenHeight / lineHeight = y
# y = fittingLines
var queue = []
var canType = false
var canBool = false
var canNum = false
var names = []
var current = ""
var firstTime = false

func _ready():
	# core files
	var dir = Directory.new()
	if !dir.dir_exists("user://core"):
		global.debugMsg("Attempting to create directory user://core threw the error of {"+str(dir.make_dir("user://core"))+"}",true,["Profiles.gd","_ready"])
	if !dir.file_exists("user://core/pBR.htss"):
		global.debugMsg("Creating user://core/pBR.htss",true,["Profiles.gd","_ready"])
		var pbr = ConfigFile.new()
		pbr.save("user://core/pBR.htss")
		if pbr.load("user://core/pBR.htss") == OK:
			pbr.set_value("you","isNerd",true)
			pbr.set_value("you","isCool",true)
			pbr.save("user://core/pBR.htss")
	if !dir.file_exists("user://core/hemiReal.psef"):
		global.debugMsg("Creating user://core/hemiReal.psef",true,["Profiles.gd","_ready"])
		var stl = ConfigFile.new()
		stl.save("user://core/hemiReal.psef")
		if stl.load("user://core/hemiReal.psef") == OK:
			stl.set_value("you","isNerd",true)
			stl.set_value("you","isCool",true)
			stl.save("user://core/hemiReal.psef")
	# other files
	if !dir.dir_exists("user://versions"):
		global.debugMsg("Attempting to create directory user://versions threw the error of {"+str(dir.make_dir("user://versions"))+"}",true,["Profiles.gd","_ready"])
	# startup
	history = $Console.text
	var startup = ""
	for percent in range(0,101,global.rng.randi_range(8,10)):
		startup += "\nLoading \"pBR.htss\"... ("+str(percent)+"%)"
	startup += "\nDONE! :D"
	for character in startup:
		queue.append(character)
	#startMsg()
	if !global.loadedUpdate:
		if dir.dir_exists("user://versions"):
			var versionFiles = []
			if dir.open("user://versions") == OK:
				dir.list_dir_begin()
				var filename = dir.get_next()
				while filename != "":
					if (filename.ends_with(".pck") or filename.ends_with(".zip")) and !dir.current_is_dir():
						versionFiles.append(filename)
					filename = dir.get_next()
			if versionFiles.size() > 0:
				if versionFiles.size() == 1:
					global.debugMsg("One version file found",true,["Profiles.gd","_ready"])
					var startupAdd = "\nOne version pack found in user://versions,\nwould you like to use it?\n[ONLY USE IF YOU GOT IT FROM AN\nOFFICIAL SEMITAU ENTERTAINMENT PAGE]\n(Y: Use pack found in user://versions,\nN: Use pack paired with executeable)\n[y/n]"
					for character in startupAdd:
						queue.append(character)
				else:
					global.debugMsg("Multiple version files found",true,["Profiles.gd","_ready"])
					var startupAdd = "\nMultiple version packs found in user://versions,\nwould you like to choose one?\n[ONLY USE IF YOU GOT IT FROM AN\nOFFICIAL SEMITAU ENTERTAINMENT PAGE]\n(Y: Choose a pack found in user://versions to use,\nN: Use pack paired with executeable)\n[y/n]"
					for character in startupAdd:
						queue.append(character)
			else:
				global.debugMsg("user://versions directory has no versions",true,["Profiles.gd","_ready"])
				startMsg()
		else:
			global.debugMsg("user://versions directory not found",true,["Profiles.gd","_ready"])
			startMsg()
	else:
		global.debugMsg("Already loaded an update",true,["Profiles.gd","_ready"])
		startMsg()
	
func startMsg():
	updateNames()
	var startup = ""
	startup += "\nPlease enter your name,\nif your name is found your file will be loaded.\nOtherwise, a new file will be made.\nPress enter without typing to get a list of names."
	startup += "\n>>>"
	for character in startup:
		queue.append(character)

func _process(_delta):
	updateNames()
	if $Console.text.ends_with("<"):
		global.debugMsg("Loading file {"+current+"} with firstTime of {"+str(firstTime)+"}",true,["Profiles.gd","_process"])
		global.loadFile(current,firstTime)
	else:
		# GUI scale
		var windowSize = get_viewport().size
		$BG.rect_size = windowSize
		$Console.rect_size = Vector2(windowSize.x-40,windowSize.y-20)
		# Update history and queue
		if queue.size() > 0:
			history += queue[0]
			queue.remove(0)
			$Console.text = history
		# Check for input
		if !canType and !canBool and !canNum:
			if history.ends_with("\n>>>"):
				global.debugMsg("Switching to input mode",true,["Profiles.gd","_process"])
				canType = true
			if history.ends_with("\n[y/n]"):
				global.debugMsg("Switching to Y/N mode",true,["Profiles.gd","_process"])
				canBool = true
			if history.ends_with("\nNUMBER:"):
				global.debugMsg("Switching to number mode",true,["Profiles.gd","_process"])
				canNum = true
		# Fit/skip lines
	# warning-ignore:integer_division
		var linesThatFit = int(floor(windowSize.y-20))/int(600/15)
		$Console.lines_skipped = $Console.text.split("\n").size()-linesThatFit
		if $Console.lines_skipped < 0:
			$Console.lines_skipped = 0

func _input(event):
	if canNum:
		if event is InputEventKey and event.is_pressed():
			if 48 <= event.scancode and 57 >= event.scancode:
				# NUMBER
				global.debugMsg("Number with scancode {"+str(event.scancode)+"} pressed in number mode",true,["Profiles.gd","_input"])
				queue.append(char(event.scancode))
			elif event.scancode == KEY_BACKSPACE and history[-1] != ":":
				# DELETE
				global.debugMsg("Backspace pressed in num mode",true,["Profiles.gd","_input"])
				history.erase(len(history)-1,1)
				$Console.text = history
			elif event.scancode == KEY_ENTER:
				# SEND
				global.debugMsg("Enter pressed in number mode",true,["Profiles.gd","_input"])
				history += "\n"
				var justTypedStart = history.find_last(":")+1
				var justTypedEnd = history.find_last("\n")-1
				if justTypedEnd < justTypedStart:
					global.debugMsg("Invalid, is blank in number mode.",true,["Profiles.gd","_input"])
					var moreText = "Invalid input. Please input a number.\nNUMBER:"
					for character in moreText:
						queue.append(character)
				else:
					global.debugMsg("Seems to be a valid number",true,["Profiles.gd","_input"])
					var justTypedString = ""
					for character in range(justTypedStart,justTypedEnd+1):
						justTypedString += history[character]
					var versionFiles = []
					var dir = Directory.new()
					if dir.dir_exists("user://versions"):
						if dir.open("user://versions") == OK:
							dir.list_dir_begin()
							var filename = dir.get_next()
							while filename != "":
								if (filename.ends_with(".pck") or filename.ends_with(".zip")) and !dir.current_is_dir():
									versionFiles.append(filename)
								filename = dir.get_next()
						if int(justTypedString) >= versionFiles.size():
							global.debugMsg("Invalid, number too large.",true,["Profiles.gd","_input"])
							var moreText = "Invalid input. Please input a number shown,\nyours was too big.\nNUMBER:"
							for character in moreText:
								queue.append(character)
						else:
							if ProjectSettings.load_resource_pack("user://versions/"+versionFiles[int(justTypedString)]):
								global.debugMsg("{"+versionFiles[int(justTypedString)]+"} version loaded",true,["Profiles.gd","_input"])
								global.loadedUpdate = true
							else:
								global.debugMsg("{"+versionFiles[int(justTypedString)]+"} version failed to load",true,["Profiles.gd","_input"])
							canNum = false
							startMsg()
					else:
						global.debugMsg("user://versions directory doesn't exist",true,["Profiles.gd","_input"])
						canNum = false
						startMsg()
	if canBool:
		if event is InputEventKey and event.is_pressed():
			if event.scancode == KEY_Y:
				global.debugMsg("Y pressed",true,["Profiles.gd","_input"])
				history += " YES\n"
				canBool = false
				var dir = Directory.new()
				if dir.dir_exists("user://versions"):
					var versionFiles = []
					if dir.open("user://versions") == OK:
						dir.list_dir_begin()
						var filename = dir.get_next()
						while filename != "":
							if (filename.ends_with(".pck") or filename.ends_with(".zip")) and !dir.current_is_dir():
								versionFiles.append(filename)
							filename = dir.get_next()
					if versionFiles.size() == 1:
						if ProjectSettings.load_resource_pack("user://versions/"+versionFiles[0]):
							global.debugMsg("{"+versionFiles[0]+"} version loaded",true,["Profiles.gd","_input"])
							global.loadedUpdate = true
						else:
							global.debugMsg("{"+versionFiles[0]+"} version failed to load",true,["Profiles.gd","_input"])
						startMsg()
					elif versionFiles.size() <= 0:
						global.debugMsg("No version files found",true,["Profiles.gd","_input"])
						startMsg()
					else:
						global.debugMsg("Multiple version files found, getting choice",true,["Profiles.gd","_input"])
						var moreText = ""
						for fileID in range(versionFiles.size()):
							moreText += str(fileID)+": "+str(versionFiles[fileID])+"\n"
						moreText += "What file to use?\n(Input the number corresponding to the filename)\nNUMBER:"
						for character in moreText:
							queue.append(character)
				else:
					global.debugMsg("user://versions doesn't exist",true,["Profiles.gd","_input"])
					startMsg()
			elif event.scancode == KEY_N:
				global.debugMsg("N pressed",true,["Profiles.gd","_input"])
				history += " NO\n"
				canBool = false
				startMsg()
	if canType:
		if event is InputEventKey and event.is_pressed():
			if 65 <= event.scancode and 90 >= event.scancode:
				# UPPER and LOWER
				var offset = 0
				if !event.shift:
					offset += 32
					global.debugMsg("Lowercase letter with scancode (for uppercase version) of {"+str(event.scancode)+"} pressed",true,["Profiles.gd","_input"])
				else:
					global.debugMsg("Uppercase letter with scancode of {"+str(event.scancode)+"} pressed",true,["Profiles.gd","_input"])
				queue.append(char(event.scancode+offset))
			if 48 <= event.scancode and 57 >= event.scancode:
				# NUMBER
				global.debugMsg("Number with scancode {"+str(event.scancode)+"} pressed",true,["Profiles.gd","_input"])
				queue.append(char(event.scancode))
			elif event.scancode == KEY_ENTER:
				# SEND
				global.debugMsg("Enter pressed",true,["Profiles.gd","_input"])
				history += "\n"
				$Console.text = history
				canType = false
				var justTypedStart = history.find_last(">")+1
				var justTypedEnd = history.find_last("\n")-1
				if justTypedEnd < justTypedStart:
					# ">>>"
					global.debugMsg("Sending names list",true,["Profiles.gd","_input"])
					queue.append("NAMES LIST:\n")
					if names.size() > 0:
						for name in names:
							queue.append(name+"\n")
					else:
						queue.append("[no files found]\n")
					queue.append("\n>>>")
				else:
					# ">>>???"
					var justTypedString = ""
					for character in range(justTypedStart,justTypedEnd+1):
						justTypedString += history[character]
					if names.find(justTypedString) == -1:
						# ">>>[NEW]"
						global.debugMsg("Creating new profile {"+justTypedString+"}",true,["Profiles.gd","_input"])
						for percent in range(0,101,global.rng.randi_range(10,15)):
							queue.append("\nCreating new file... ("+str(percent)+"%)")
						queue.append("\nDONE! :DDDDDDDDDDDDDDDDD\n<")
						current = justTypedString
						firstTime = true
					else:
						# ">>>[EXISTING]"
						global.debugMsg("Loading existing profile {"+justTypedString+"}",true,["Profiles.gd","_input"])
						for percent in range(0,101,global.rng.randi_range(10,15)):
							queue.append("\nLoading file... ("+str(percent)+"%)")
						queue.append("\nDONE! :DDDDDDDDDDDDDDDDD\n<")
						current = justTypedString
						firstTime = false
			elif event.scancode == KEY_BACKSPACE and history[-1] != ">":
				# DELETE
				global.debugMsg("Backspace pressed",true,["Profiles.gd","_input"])
				history.erase(len(history)-1,1)
				$Console.text = history

func updateNames():
	names = []
	var dir = Directory.new()
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if filename.ends_with(".cfg") and !dir.current_is_dir():
				names.append(filename.trim_suffix(".cfg"))
			filename = dir.get_next()
	global.debugMsg("names == {"+str(names)+"}",true,["Profiles.gd","updateNames"])
