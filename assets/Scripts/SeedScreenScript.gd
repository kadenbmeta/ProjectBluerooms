extends Node



var scancodes = []



func _process(_delta):
	var windowSize = get_viewport().size
	$ColorRect.margin_right = windowSize.x
	$ColorRect.margin_bottom = windowSize.y
	$Label.margin_right = windowSize.x
	$Label.margin_bottom = windowSize.y
	$Label.text = "Please input a seed:\n["
	for code in scancodes:
		$Label.text += char(code)
	if scancodes.size() > 0:
		var trimmed = $Label.text.trim_prefix("Please input a seed:\n[")
		if trimmed.is_valid_integer():
			$Label.text += "]\n{"+trimmed+"}\n(An empty seed will choose a random seed for you)"
		else:
			$Label.text += "]\n{"+str(trimmed.hash())+"}\n(An empty seed will choose a random seed for you)"
	else:
		$Label.text += "]\n{Create a seed for me}\n(An empty seed will choose a random seed for you)"

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if scancodes.size() < 20 and ((48 <= event.scancode and 57 >= event.scancode) or (65 <= event.scancode and 90 >= event.scancode)):
			global.debugMsg(["Pressed letter/number with scancode of {",event.scancode,"} while under 20 characters"],true,["SeedScreenScript.gd","_input"])
			scancodes.append(event.scancode)
		elif event.scancode == KEY_BACKSPACE and scancodes.size() > 0:
			global.debugMsg(["Pressed backspace while over 0 characters"],true,["SeedScreenScript.gd","_input"])
			scancodes.remove(scancodes.size()-1)
		elif event.scancode == KEY_ENTER:
			if scancodes.size() > 0:
				global.debugMsg(["Seed given, hashing and setting."],true,["SeedScreenScript.gd","_input"])
				var chosen = ""
				for code in scancodes:
					chosen += char(code)
				if chosen.is_valid_integer():
					global.rng.seed = int(chosen)
				else:
					global.rng.seed = chosen.hash()
			else:
				global.debugMsg(["Blank seed given, randomizing."],true,["SeedScreenScript.gd","_input"])
				global.rng.randomize()
			global.undeclared["fullTime"] = 0
			global.undeclared["firstSeed"] = global.rng.seed
			global.currentLevel = "res://assets/Levels/Houseish/Level-houseishEASY.tscn"
			global.debugMsg(["Switching to level id 0 gave the error {",get_tree().change_scene("res://assets/Game/GameAKAgeneral.tscn"),"}"],true,["SeedScreenScript.gd","_input"])
