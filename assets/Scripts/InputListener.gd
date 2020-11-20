extends Control



var first = true
var ignored
var num = 0

func _process(_delta):
	var windowSize = get_viewport().size
	$ColorRect.rect_size = windowSize
	$Label.rect_size = windowSize

func _input(event):
	#print("--------------")
	#print(InputEvent.scancode)
	if event.is_pressed() and !event.is_echo():
		if event is InputEventKey:
			global.debugMsg("Event just pressed was an InputEventKey",true,["InputListener.gd","_input"])
			answerWith(InputEventKey,event)#.scancode)
		elif event is InputEventJoypadButton:
			global.debugMsg("Event just pressed was an InputEventJoypadButton",true,["InputListener.gd","_input"])
			answerWith(InputEventJoypadButton,event)#.button_index)
		elif event is InputEventJoypadMotion:
			global.debugMsg("Event just pressed was an InputEventJoypadMotion",true,["InputListener.gd","_input"])
			answerWith(InputEventJoypadMotion,event)#.axis)

func answerWith(type,input):
	global.debugMsg("Sending input chosen to input menu and closing input listener.",true,["InputListener.gd","answerWith"])
	get_parent().chosenInput = input
	get_parent().chosenType = type
	#get_parent().notYet = true
	queue_free()
