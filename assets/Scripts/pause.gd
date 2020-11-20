extends Control



var currentSetPage = 0
onready var buttons = global.getFamilyMembersWithType($Main, [Button])
onready var oButtons = global.getFamilyMembersWithType($Settings, [Button])
onready var oSliders = global.getFamilyMembersWithType($Settings, [HSlider])
onready var oCheckboxes = global.getFamilyMembersWithType($Settings, [CheckBox])
const OPTION_ORDER = {
	-1: [
		"prevButton",
		"saveButton",
		"nextButton"
	],
	0: [
		"mouseSlider",
		"controllerSlider",
		"fovSlider"
	],
	1: [
		"musicSlider",
		"sfxSlider",
		"deadzoneSlider"
	],
	2: [
		[
			"yInversionBool",
			"shiftBool",
			"speedBool"
		],
		[
			"joyTurnBool",
			"NONE",
			"NONE"
		],
		[
			"NONE",
			"fullBool",
			"NONE"
		]
	]
}
var chosenInput
var chosenType
var chosenAction
var notYet = false
var lastIndex



func _ready():
	# Go to main section
	$Visual/title.text = "Paused."
	$Main.show()
	$Settings.hide()
	$Input.hide()
	$Unused.hide()
	# Remember values
	$Settings/mouseSlider.value = global.mouse_sensitivity
	$Settings/controllerSlider.value = global.controller_sensitivity
	$Settings/fovSlider.value = global.fov
	$Settings/musicSlider.value = global.musicMultiplier
	$Settings/sfxSlider.value = global.sfxMultiplier
	$Settings/deadzoneSlider.value = global.deadzone
	if global.inversionY == -1:
		$Settings/yInversionBool.pressed = true
	else:
		$Settings/yInversionBool.pressed = false
	$Settings/shiftBool.pressed = global.shiftToggle
	$Settings/fullBool.pressed = OS.window_fullscreen
	$Settings/joyTurnBool.pressed = global.controllerTurnRight
	$Settings/speedBool.pressed = global.undeclared["speedrunTimer"]
	# Close pause menu
	visible = false
	global.pausing = false
	if global.gameMode != "notPlaying":
		# Force mouse into middle of screen
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for item in global.ACTION_NAMES:
		$Input/inputList.add_item(item)
		$Input/inputList.set_item_tooltip_enabled($Input/inputList.get_item_count()-1,false)

func _process(_delta):
	if !has_node("InputListener") and !notYet:
		# GUI FITTING
		
		# Get size vars
		var windowSize = get_viewport().size
		# Visual
		$Visual/ColorRect.rect_size = windowSize
		$Visual/title.rect_size = windowSize
		# Main-Normal
		var MNAmount = (abs(40-(windowSize.x-40))-95)/2
		var MNStylebox = $Main.theme.get_stylebox("normal","Button")
		MNStylebox.border_width_left = MNAmount
		MNStylebox.border_width_right = MNAmount
		# Main-Hover
		var MHAmount = (abs(40-(windowSize.x-40))-125)/2
		var MHStylebox = $Main.theme.get_stylebox("hover","Button")
		MHStylebox.border_width_left = MHAmount
		MHStylebox.border_width_right = MHAmount
		# Main-Press
		var MPAmount = MHAmount
		var MPStylebox = $Main.theme.get_stylebox("pressed","Button")
		MPStylebox.border_width_left = MPAmount
		MPStylebox.border_width_right = MPAmount
		# Border sizing
		var SAmount = ((abs(40-(windowSize.x-40))-10)/2)/4
		var SLAmount = ((abs(40-(windowSize.x-40))-20)/2)/4
		# Setting-Normal
		var SNStylebox = $Settings.theme.get_stylebox("normal","Button")
		var GSNStylebox = $Settings/saveButton.theme.get_stylebox("normal","Button")
		SNStylebox.border_width_left = SAmount
		SNStylebox.border_width_right = SAmount
		GSNStylebox.border_width_left = SAmount
		GSNStylebox.border_width_right = SAmount
		# Setting-Hover
		var SHStylebox = $Settings.theme.get_stylebox("hover","Button")
		var GSHStylebox = $Settings/saveButton.theme.get_stylebox("hover","Button")
		SHStylebox.border_width_left = SLAmount
		SHStylebox.border_width_right = SLAmount
		GSHStylebox.border_width_left = SLAmount
		GSHStylebox.border_width_right = SLAmount
		# Setting-Pressed
		var SPStylebox = $Settings.theme.get_stylebox("pressed","Button")
		var GSPStylebox = $Settings/saveButton.theme.get_stylebox("pressed","Button")
		SPStylebox.border_width_left = SLAmount
		SPStylebox.border_width_right = SLAmount
		GSPStylebox.border_width_left = SLAmount
		GSPStylebox.border_width_right = SLAmount
		if $Visual/title.text == "Paused.":
			global.debugMsg("On general pause menu",true,["pause.gd","_process"])
			### Main
			$Main.show()
			$Settings.hide()
			$Input.hide()
			# Button sizing
			for buttonID in range(buttons.size()):
				buttons[buttonID].margin_left = 40
				buttons[buttonID].margin_right = windowSize.x-40
				var buttonHeight = windowSize.y/(buttons.size()+1)
				buttons[buttonID].margin_top = (buttonID*buttonHeight)+(buttonHeight+(buttonHeight*(1.0/10.0)))
				buttons[buttonID].margin_bottom = (buttonID*buttonHeight)+(buttonHeight+(buttonHeight*(9.0/10.0)))
		elif $Visual/title.text == "Settings":
			global.debugMsg("On settings pause menu",true,["pause.gd","_process"])
			### Settings
			$Main.hide()
			$Settings.show()
			$Input.hide()
			# Switch pages
			if Input.is_action_just_pressed("ui_page_up"):
				_on_nextButton_button_up()
			elif Input.is_action_just_pressed("ui_page_down"):
				_on_prevButton_button_up()
			currentSetPage = clamp(currentSetPage,0,OPTION_ORDER.keys().size()-2)
			# Mandatory sizing
			var buttonHeight = (windowSize.y-80)/6
			var buttonWidth = (windowSize.x-80)/3
			$Settings/instructions.margin_right = windowSize.x
			$Settings/instructions.margin_top = (1*buttonHeight)+(buttonHeight*(1.0/10.0))
			$Settings/instructions.margin_bottom = (1*buttonHeight)+(buttonHeight*(9.0/10.0))
			# Settings global buttons
			for button in oButtons:
				button.margin_top = (1*buttonHeight)+(buttonHeight+(buttonHeight*(1.0/10.0)))
				button.margin_bottom = (1*buttonHeight)+(buttonHeight+(buttonHeight*(9.0/10.0)))
				var colPlacement = OPTION_ORDER[-1].find(button.name)
				button.margin_left = 40+(colPlacement*buttonWidth)
				button.margin_right = 40+((colPlacement+1)*buttonWidth)
			# Slider sizing
			for slider in oSliders:
				if OPTION_ORDER[currentSetPage].find(slider.name) != -1:
					slider.show()
					var rowPlacement = 2+OPTION_ORDER[currentSetPage].find(slider.name)
					slider.margin_left = 40
					slider.margin_right = windowSize.x-40
					slider.margin_top = (rowPlacement*buttonHeight)+(buttonHeight+(buttonHeight*(1.0/10.0)))
					slider.margin_bottom = (rowPlacement*buttonHeight)+(buttonHeight+(buttonHeight*(9.0/10.0)))
					for label in global.getFamilyMembersWithType(slider,[Label]):
						label.margin_right = slider.rect_size.x
				else:
					slider.hide()
			# Checkbox sizing
			for box in oCheckboxes:
				if global.existsWithinArrays(box.name,OPTION_ORDER[currentSetPage]):
					box.show()
					var rowPlacement
					var colPlacement
					for row in OPTION_ORDER[currentSetPage]:
						if row is Array:
							for col in row:
								if col == box.name:
									rowPlacement = 2+OPTION_ORDER[currentSetPage].find(row)
									colPlacement = row.find(col)
					box.margin_left = 40+(colPlacement*buttonWidth)
					box.margin_right = 40+((colPlacement+1)*buttonWidth)
					box.margin_bottom = ((rowPlacement)*buttonHeight)+(buttonHeight+(buttonHeight*(5.0/10.0)))+(32*(rowPlacement-1))
					box.margin_top = ((rowPlacement-1)*buttonHeight)+(buttonHeight+(buttonHeight*(10.0/10.0)))+(32*(rowPlacement-1))
					for label in global.getFamilyMembersWithType(box,[Label]):
						label.margin_bottom = 0
						label.margin_top = -32
						label.margin_right = box.rect_size.x
				else:
					box.hide()
		else:
			global.debugMsg("On input pause menu",true,["pause.gd","_process"])
			### Input editor
			$Main.hide()
			$Settings.hide()
			$Input.show()
			# Size vars
			var buttonHeight = (windowSize.y-80)/6
#			var buttonWidth = (windowSize.x-80)/3
			# Mandatory sizing
			$Input/saveButtonInput.margin_top = (1*buttonHeight)+(buttonHeight+(buttonHeight*(1.0/10.0)))
			$Input/saveButtonInput.margin_bottom = (1*buttonHeight)+(buttonHeight+(buttonHeight*(9.0/10.0)))
			$Input/saveButtonInput.margin_left = 40
			$Input/saveButtonInput.margin_right = windowSize.x-40
			$Input/instructionsInput.margin_right = windowSize.x
			$Input/instructionsInput.margin_top = (1*buttonHeight)+(buttonHeight*(1.0/10.0))
			$Input/instructionsInput.margin_bottom = (1*buttonHeight)+(buttonHeight*(9.0/10.0))
			$Input/inputList.margin_top = (2*buttonHeight)+(buttonHeight+(buttonHeight*(1.0/10.0)))
			$Input/inputList.margin_bottom = windowSize.y-40
			$Input/inputList.margin_left = 40
			$Input/inputList.margin_right = windowSize.x-40
		# TOGGLE PAUSE
		
		if Input.is_action_just_pressed("control_pause"):
			global.debugMsg("Toggling pause",true,["pause.gd","_process"])
			visible = !visible
			if visible:
				$Visual/title.text = "Paused."
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				$Main/resumeButton.grab_focus()
			else:
				if global.gameMode != "notPlaying":
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			global.pausing = visible
	else:
		if has_node("InputListener"):
			global.debugMsg("InputListener exists, notYet set to true",true,["pause.gd","_process"])
			notYet = true
		else:
			global.debugMsg("InputListener DOESN'T exist and notYet is true, switching back to input menu",true,["pause.gd","_process"])
			for input in InputMap.get_action_list(chosenAction):
				if input is chosenType:
					InputMap.action_erase_event(chosenAction,input)
			InputMap.action_add_event(chosenAction,chosenInput)
			_on_inputList_item_selected(lastIndex)
			notYet = false

# Mouse sensitivity
func _on_HSlider_value_changed(value):
	global.mouse_sensitivity = value

# Quit
func _on_Button_button_up():
	get_tree().quit()

# Menu
func _on_Button2_button_up():
	global.resetVars()
	global.gameMode = "notPlaying"
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/Game/Menu.tscn")

# Restart
func _on_resetButton_button_up():
# warning-ignore:return_value_discarded
	global.resetVars()
	get_tree().reload_current_scene()

# Dev - Breakpoint
func _on_breakButton_button_up():
	pass # Breakpoint

# Dev - Env
func _on_envButton_button_up():
	if WrldEnv.environment == WrldEnv.game_env:
		WrldEnv.environment = WrldEnv.default_env
	else:
		WrldEnv.environment = WrldEnv.game_env

# Fov
func _on_fovSlider_value_changed(value):
	global.fov = value

# Volume
func _on_musicSlider_value_changed(value):
	global.musicMultiplier = value
func _on_sfxSlider_value_changed(value):
	global.sfxMultiplier = value

# Controller sensitivity
func _on_controllerSlider_value_changed(value):
	global.controller_sensitivity = value

# Deadzone for controller
func _on_deadzoneSlider_value_changed(value):
	global.deadzone = value

# Invert Y - Flight controls
func _on_yInversionBool_toggled(_button_pressed):
	global.inversionY *= -1

# Shift mode - Toggle or hold?
func _on_shiftBool_toggled(button_pressed):
	global.shiftToggle = button_pressed

# Resolution
func _on_resSlider_value_changed(_value):
	pass # Replace with funcion body.

# Fullscreen
func _on_fullBool_toggled(button_pressed):
	OS.window_fullscreen = button_pressed

# Save settings
func _on_saveButton_button_up():
	global.saveFile(global.profileInUse)
	$Visual/title.text = "Paused."
	$Main/resumeButton.grab_focus()

# Resume
func _on_resumeButton_button_up():
	Input.action_press("control_pause")

# Settings
func _on_settingsButton_button_up():
	$Visual/title.text = "Settings"
	$Settings/saveButton.grab_focus()

# Previous page
func _on_prevButton_button_up():
	currentSetPage -= 1
	$Settings/saveButton.grab_focus()
	currentSetPage = clamp(currentSetPage,0,OPTION_ORDER.keys().size()-2)

# Next page
func _on_nextButton_button_up():
	currentSetPage += 1
	$Settings/saveButton.grab_focus()
	currentSetPage = clamp(currentSetPage,0,OPTION_ORDER.keys().size()-2)

# Input editor
func _on_inputButton_button_up():
	$Visual/title.text = "Input"
	$Input/saveButtonInput.grab_focus()

# Input list item chosen
func _on_inputList_item_activated(index):
	var tempChosenAction = $Input/inputList.get_item_text(index)
	chosenAction = ""
	for characterIndex in range(tempChosenAction.find_last(" ")+1,len(tempChosenAction)):
		chosenAction += tempChosenAction[characterIndex]
	var listener = load("res://assets/Game/InputListener.tscn").instance()
	add_child(listener)

# Update input text
func _on_inputList_item_selected(index):
	lastIndex = index
	var temp = $Input/inputList.get_item_text(index)
	var final = ""
	for characterIndex in range(temp.find_last(" ")+1,len(temp)):
		final += temp[characterIndex]
	$Input/instructionsInput.text = final+" ="
	for event in InputMap.get_action_list(final):
		$Input/instructionsInput.text += " "+global.eventTitle(event)
		if InputMap.get_action_list(final).find(event) == InputMap.get_action_list(final).size()-1:
			$Input/instructionsInput.text += ")"
		else:
			$Input/instructionsInput.text += ","

# Update input text to default
func _on_inputList_nothing_selected():
	$Input/instructionsInput.text = "[No action selected]"

# Use left joystick to turn
func _on_joyTurnBool_toggled(button_pressed):
	global.controllerTurnRight = button_pressed

# Show speedrun timer
func _on_speedBool_toggled(button_pressed):
	global.undeclared["speedrunTimer"] = button_pressed
