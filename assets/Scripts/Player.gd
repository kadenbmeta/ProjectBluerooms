extends KinematicBody



# Global move vars
var velocity = Vector3()
var direction = Vector3()

# Turn vars
var cam_angle = 0
var cam_change = Vector2()

# Fly vars
const FLY_SPEED = 10
const FLY_ACCEL = 4

# Walk vars
var gravity = -9.8 * 3
const MAX_SPEED = 5
const MAX_RUNNING_SPEED = 15
const ACCEL = 2
const DEACCEL = 6
var sprinting = false

# Jump vars
var jump_height = 15
var has_contact = false

# Slope vars
const MAX_SLOPE_ANGLE = 60

# Text vars
var text_speed = 10
var visible_charactersWithRemainder = 0

# Object vars
onready var head = $Head
onready var cam = $Head/Camera
onready var tail = $Tail
onready var thoughtBox = $ThoughtBox
onready var deathScreen = $DeathScreen
onready var deathText = $DeathScreen/DeathText
onready var itemText = $ItemBox
onready var light = $Light

# Death/Win vars
var isDead = false
const TOTAL_FADE_TIME = 1
const TOTAL_MSG_TIME = 3
var elapsedMsgTime = 0
const DEATH_MSGS = [
	# General
	"Death has claimed another",
	"I'll be waiting.",
	"Death is among us"
#	# References
#	"M (+) R T I S",
#	"Stay determined!",
#	"You died.",
#	"Mission Failed",
#	"Score: &e0",
#	"Game.Over"
]
const DIM_SPEED = 6

# Items
var points = 0
var pointsToWin
var nextLevelPath
var keys = 0
var nextLevelID
var thisLevelID

# Joypad
var xAxis = 0
var yAxis = 0

# Audio
export(Resource) var WALK_SOUND
export(Resource) var RUN_SOUND

# Time
var singularTime = 0



func _ready():
	isDead = false
	deathScreen.color = Color(142/255,22/255,22/255,0)
	thoughtBox.visible_characters = 0
	deathText.text = "PLACEHOLDER TEXT"

# Call movement while not pausing
func _physics_process(delta):
	if !global.pausing:
		if global.hasTutorialText:
			global.debugMsg("Has yellow text",true,["Player.gd","_physics_process"])
			$ThoughtBox.set("custom_colors/font_color", Color(1,1,0,1))
			thoughts(delta)
			singularTime = 0
		else:
			global.debugMsg("Has non-yellow text",true,["Player.gd","_physics_process"])
			$ThoughtBox.set("custom_colors/font_color", Color(1,1,1,1))
			$ThoughtBox.visible_characters = -1
			$ThoughtBox.text = global.currentText
		aim()
#		noclipset(false)
#		if global.flying:
#			global.debugMsg("Player is flying",true,["Player.gd","_physics_process"])
#			fly(delta)
#		else:
#			global.debugMsg("Player is walking, not flying",true,["Player.gd","_physics_process"])
		walk(delta)
		global.playerPos = translation
		if translation.y <= -10:
			global.debugMsg("Player fell into void",true,["Player.gd","_physics_process"])
			death()

# Update cam_change
func _input(event):
	if !global.pausing:
		if event is InputEventMouseMotion:
			global.debugMsg("Mouse motion detected, saving cam_change",true,["Player.gd","_input"])
			cam_change = event.relative
			cam_change.y *= global.inversionY
		if event is InputEventJoypadMotion:
			if global.controllerTurnRight:
				xAxis = JOY_AXIS_2
				yAxis = JOY_AXIS_3
			else:
				xAxis = JOY_AXIS_0
				yAxis = JOY_AXIS_1
			xAxis = Input.get_joy_axis(0,xAxis)
			yAxis = Input.get_joy_axis(0,yAxis)*global.inversionY
			# xAxis deadzone
			if abs(xAxis) <= global.deadzone:
				xAxis = 0
			else:
				var axisSign = xAxis / abs(xAxis)
				xAxis = abs(xAxis)
				xAxis -= global.deadzone
				xAxis *= 1+global.deadzone
				xAxis *= axisSign
			# yAxis deadzone
			if abs(yAxis) <= global.deadzone:
				yAxis = 0
			else:
				var axisSign = yAxis / abs(yAxis)
				yAxis = abs(yAxis)
				yAxis -= global.deadzone
				yAxis *= 1+global.deadzone
				yAxis *= axisSign
			global.debugMsg("Joy motion detected, saving xAxis and yAxis",true,["Player.gd","_input"])

func _process(delta):
	if !global.pausing:
		singularTime += delta
	# GUI placement
	var windowWidth = get_viewport().size.x
	var windowHeight = get_viewport().size.y
	var windowSize = get_viewport().size
	thoughtBox.margin_bottom = windowHeight-100
	thoughtBox.margin_right = windowWidth
	deathScreen.rect_size = windowSize
	deathText.margin_bottom = windowHeight
	deathText.margin_right = windowWidth
	itemText.margin_bottom = windowHeight
	itemText.margin_right = windowWidth-20
	# FOV
	cam.fov = global.fov
	# Item box/points
	itemText.text = "Points: "+str(points)+"/"+str(pointsToWin)+"\nKeys: "+str(keys)
	if global.gameMode == "complete":
		if !global.pausing:
			global.undeclared["fullTime"] += delta
		itemText.text += "\nComplete Time: "+str(int(global.undeclared["fullTime"]))
	if global.undeclared.keys().find("speedrunTimer") != -1:
		if global.undeclared["speedrunTimer"]:
			global.debugMsg("global.undeclared[\"speedrunTimer\"] == true, showing timer",true,["Player.gd","_process"])
			itemText.text += "\nCurrent Run Time: "+str(int(singularTime))+"\nBeginning Seed: "+str(global.undeclared["firstSeed"])+"\nCurrent Seed: "+str(global.rng.seed)
	if points >= pointsToWin:
		global.debugMsg("Player passed level requiring {"+str(pointsToWin)+"} pts using {"+str(points)+"} pts.",true,["Player.gd","_process"])
		# Win screen
		$StepsAudio.stop()
		MusicPlayer.playing = false
		if get_parent().has_node("PauseMenu"):
			$"../PauseMenu".queue_free()
		global.pausing = true
		light.omni_range -= delta*DIM_SPEED
		if light.omni_range <= 0:
			global.resetVars()
			if nextLevelID != 0 and global.gameMode == "story":
				if global.progress.keys().find("story") == -1:
					global.progress["story"] = []
				if global.progress["story"].find(nextLevelID) == -1:
					global.debugMsg("Player unlocked the next level, ID {"+str(nextLevelID)+"}, for the first time",true,["Player.gd","_process"])
					global.progress["story"].append(nextLevelID)
					global.saveFile(global.profileInUse)
			if nextLevelPath != "none":
				global.debugMsg("Loading level {"+nextLevelPath+"}",true,["Player.gd","_process"])
				global.currentLevel = nextLevelPath
# warning-ignore:return_value_discarded
				get_tree().reload_current_scene()
			else:
				global.debugMsg("No set next level, returning to menu",true,["Player.gd","_process"])
# warning-ignore:return_value_discarded
				get_tree().change_scene("res://assets/Game/Menu.tscn")
	else:
		# Death screen
		if isDead:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if deathScreen.color.a == 1:
				if deathText.text == "PLACEHOLDER TEXT":
					# Switch to death message screen
					global.debugMsg("Switching death screen from tinting mode to text mode",true,["Player.gd","_process"])
					deathScreen.color = Color(0,0,0,1)
					deathText.text = DEATH_MSGS[global.rng.randi_range(0,DEATH_MSGS.size()-1)]
					deathText.show()
					elapsedMsgTime = 0
				# Progress death message time
				elapsedMsgTime += delta
				if elapsedMsgTime >= TOTAL_MSG_TIME:
					# Restart
	# warning-ignore:return_value_discarded
					$"/root/DebuggingNotify/TheUnseenSprite".hide()
					global.debugMsg("Restarting level",true,["Player.gd","_process"])
					global.resetVars()
					get_tree().reload_current_scene()
			else:
				global.debugMsg("Tinting screen",true,["Player.gd","_process"])
				# Tint screen if screen isn't 100% red
				deathScreen.color = Color(0.25,0,0,deathScreen.color.a)
				deathScreen.color.a += delta/TOTAL_FADE_TIME
				# Prevent screen from going over 1 alpha
				deathScreen.color.a = clamp(deathScreen.color.a,0,1)

# Death trigger
func death(changeAim=false,aimAt=Vector3()):
	$StepsAudio.stop()
	if global.firstPlay.keys().find(thisLevelID) == -1:
		global.debugMsg("Removing yellow text because player died on this level for the first time.",true,["Player.gd","death"])
		global.firstPlay[thisLevelID] = false
		global.saveFile(global.profileInUse)
	MusicPlayer.playing = false
	if get_parent().has_node("PauseMenu"):
		$"../PauseMenu".queue_free()
	global.pausing = true
	if changeAim:
		global.debugMsg("changeAim is true, aiming at {"+str(aimAt)+"}",true,["Player.gd","death"])
		cam.look_at(aimAt,Vector3.UP)
	isDead = true

# Toggle noclip when needed
func noclipset(bool_in):
	global.debugMsg("Updating noclip",true,["Player.gd","noclipset"])
	var int_in
	if bool_in:
		int_in = 0
	else:
		int_in = 1
	if collision_layer != int_in:
		collision_layer = int_in
		collision_mask = int_in

# Player translate with gravity
func walk(delta):
	# reset direction
	direction = Vector3()
	
	# camera basis
	var aim = cam.get_global_transform().basis
	
	# Z motion
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z*Input.get_action_strength("move_forward")
	elif Input.is_action_pressed("move_backward"):
		direction += aim.z*Input.get_action_strength("move_backward")
	
	# X motion
	if Input.is_action_pressed("move_left"):
		direction -= aim.x*Input.get_action_strength("move_left")
	elif Input.is_action_pressed("move_right"):
		direction += aim.x*Input.get_action_strength("move_right")
	
	# Remove y in direction
	direction.y = 0
	
	# Normalize speed so diagonals aren't fast and etc
	direction = direction.normalized()
	global.debugMsg("direction == {"+str(direction)+"}",true,["Player.gd","walk"])
	
#	#	# Raycast contact
#	if has_contact and !is_on_floor():
#		#pass
#		has_contact = false
# warning-ignore:return_value_discarded
		#move_and_collide(Vector3(0,-1,0))
	
	# Gravity
	if !is_on_floor():
		global.debugMsg("Not on floor, applying gravity",true,["Player.gd","walk"])
		velocity.y += gravity * delta
	
	# is_on_floor() doesn't work in this case, using raycast instead.
	# Check for contact and give gravity when necessary - (RAMPS ARE SCREWED)
#	if is_on_floor():
#		has_contact = true
##		var n = tail.get_collision_normal()
##		#print("n = "+str(n))
##		var floor_angle = rad2deg(acos(n.dot(Vector3(0,-1,0))))
##		floor_angle -= 180
##		#print(floor_angle)
##		if (floor_angle > MAX_SLOPE_ANGLE) or (floor_angle < -MAX_SLOPE_ANGLE):
##			#print("GRAV")
##			velocity.y += gravity * delta
##		else:
##			pass
##			#print("NON")
##			#has_contact = false
#	else:
##		if !tail.is_colliding():
##			#pass
##			has_contact = false
##		else:
##			pass
##			#has_contact = false
#		has_contact = false
#		velocity.y += gravity * delta
	
	# Get adjustable x and z velocity
	var temp_velocity = velocity
	temp_velocity.y = 0
	
	# Toggle sprint
	if Input.is_action_just_pressed("move_sprint") and global.shiftToggle:
		sprinting = !sprinting
		global.debugMsg("Shift toggle is on and sprint was just pressed, toggled sprint. Now sprinting == {"+str(sprinting)+"}",true,["Player.gd","walk"])
	
	# Get max speed depending on sprinting boolean
	var speed
	var sound
	if (Input.is_action_pressed("move_sprint") and !global.shiftToggle) or (sprinting and global.shiftToggle):
		speed = MAX_RUNNING_SPEED
		sound = RUN_SOUND
	else:
		speed = MAX_SPEED
		sound = WALK_SOUND
	
	# where player goes at max speed
	var target = direction * speed
	global.debugMsg("target == {"+str(target)+"}",true,["Player.gd","walk"])
	
	# Check general direction of temp_velocity (which holds previous direction) and direction (which holds current direction)
	var acceleration
	if direction.dot(temp_velocity) > 0:
		# Accelerate, they're the same general direction
		acceleration = ACCEL
	else:
		# Decelerate, they're different directions
		acceleration = DEACCEL
	global.debugMsg("acceleration == {"+str(acceleration)+"}",true,["Player.gd","walk"])
	
	# Easing
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration*delta)
	
	# Update velocity with linear interpolated values
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	# Jumping
	#print("CONTACT:"+str(has_contact)+"\nISONFLOOR:"+str(is_on_floor())+"\nTAIL:"+str(tail.is_colliding()))
	if tail.is_colliding() and Input.is_action_just_pressed("move_jump"):
		global.debugMsg("Jumping",true,["Player.gd","walk"])
		velocity.y = jump_height
	
	# Check for substantial movement
	var another_temp = velocity
	another_temp.x = abs(another_temp.x)
	another_temp.z = abs(another_temp.z)
	another_temp.y = abs(another_temp.y)
	if pow((pow(another_temp.x,2)+pow(another_temp.z,2)),0.5) < 0.5:
		velocity.x = 0
		velocity.z = 0
	
	if tail.is_colliding() and (Input.is_action_pressed("move_backward") or Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		if !$StepsAudio.playing or ($StepsAudio.stream != sound):
			$StepsAudio.stream = sound
			$StepsAudio.play()
	else:
		$StepsAudio.stop()
	#if another_temp.y < 0.2:
		#velocity.y = 0
	
	#if another_temp.y == 0.49:
		#velocity.y = 0#.49
	
	#print("PREVELOCITY: " + str(velocity))
	
	# Move player
	global.debugMsg("Pre-velocity == {"+str(velocity)+"}",true,["Player.gd","walk"])
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	global.debugMsg("Post-velocity == {"+str(velocity)+"}",true,["Player.gd","walk"])

# Player translate without gravity
func fly(delta):
	# reset direction
	direction = Vector3()
	
	# camera basis
	var aim = cam.get_global_transform().basis
	
	# Z motion
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	elif Input.is_action_pressed("move_backward"):
		direction += aim.z
	
	# X motion
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	elif Input.is_action_pressed("move_right"):
		direction += aim.x
	global.debugMsg("direction (pre-normalization) == {"+str(direction)+"}",true,["Player.gd","fly"])
	
	# Normalize speed so diagonals aren't fast and etc
	direction = direction.normalized()
	global.debugMsg("direction (post-normalization) == {"+str(direction)+"}",true,["Player.gd","fly"])
	
	# where player goes at max speed
	var target = direction * FLY_SPEED
	global.debugMsg("target == {"+str(target)+"}",true,["Player.gd","fly"])
	
	# Easing
	velocity = velocity.linear_interpolate(target, FLY_ACCEL*delta)
	global.debugMsg("velocity == {"+str(velocity)+"}",true,["Player.gd","fly"])
	
	# Move player
# warning-ignore:return_value_discarded
	move_and_slide(velocity)

# Player rotation
func aim():
	if cam_change.length() > 0 or (abs(xAxis) > 0 or abs(yAxis) > 0):
		global.debugMsg("Rotating head",true,["Player.gd","aim"])
		# Rotate view
		head.rotate_y(deg2rad(-cam_change.x * global.mouse_sensitivity))
		cam.rotate_x(deg2rad(-cam_change.y * global.mouse_sensitivity))
		# Controller
		head.rotate_y(deg2rad(-xAxis * global.controller_sensitivity))
		cam.rotate_x(deg2rad(-yAxis * global.controller_sensitivity))
		# Restrict vertical view motion: -90 to 90 causes backwards movement glitch
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -89, 89)
		# Reset cam_change
		cam_change = Vector2()

# Update thought text
func thoughts(delta):
	if global.thoughtQueue.size() != 0:
		if Input.is_action_just_pressed("control_think"):
			global.debugMsg("Advancing yellow text",true,["Player.gd","thoughts"])
			if thoughtBox.visible_characters >= len(thoughtBox.text):
				global.thoughtQueue.remove(0)
				visible_charactersWithRemainder = 0
			else:
				visible_charactersWithRemainder = len(thoughtBox.text)
	if global.thoughtQueue.size() != 0:
		thoughtBox.text = global.thoughtQueue[0]
	else:
		thoughtBox.text = ""
	visible_charactersWithRemainder += delta*text_speed
	thoughtBox.visible_characters = floor(visible_charactersWithRemainder)
