extends KinematicBody



const CHARGE_SPEED = 15
var seenTurnSpeedLeft = 0.5
const SEEN_TOTAL = 0.5
var idleTurnSpeedLeft = 2
const IDLE_TOTAL = 2

const MAX_DISTANCE = 60

var lifeInSeconds = 120
var alive = true

var target = Vector3()

var actualID = 0

var chargeTurn = 2

var direction = Vector3()
var velocity = Vector3()

var requiredDistance = TAU/2



func _ready():
	lifeInSeconds = 60
	translation.y = 1.5
	
	seenTurnSpeedLeft = 0.5
	idleTurnSpeedLeft = 2
	target = Vector3()
	actualID = 0
	chargeTurn = 2
	direction = Vector3()
	velocity = Vector3()

func _physics_process(delta):
	if !global.pausing and alive: #and get_parent().open
		global.debugMsg("Is not pausing and alive, continuing _physics_process as normal",true,["enemyTST.gd","_physics_process"])
		$TerrorPlayer3D.stream_paused = false
		$Sprites.playing = true
		# MOVEMENT/BEHAVIOR CODE
		if target == Vector3():
			# Search
			global.debugMsg("TST doesn't have a target, searching",true,["enemyTST.gd","_physics_process"])
			idleTurnSpeedLeft -= delta
			if idleTurnSpeedLeft <= 0:
				# Turn
				global.debugMsg("TST turned.",true,["enemyTST.gd","_physics_process"])
				idleTurnSpeedLeft += IDLE_TOTAL
				actualID += 1
				$TerrorPlayer3D.stream = load("res://assets/Audio/TST_turn.wav")
				$TerrorPlayer3D.play()
			if $Sprites.animation == "eye_idle":
				# Detect player being seen
				if $VisibilityNotifier.is_on_screen() == true:
					global.debugMsg("TST locked eyes with player, target set",true,["enemyTST.gd","_physics_process"])
					target = global.playerPos
					target.y = 1.5
					chargeTurn = 2
					$TerrorPlayer3D.stream = load("res://assets/Audio/TST_shriek.wav")
					$TerrorPlayer3D.play()
		else:
			# Has target
			global.debugMsg("TST has a target",true,["enemyTST.gd","_physics_process"])
			if chargeTurn != 0:
				# Turning around currently
				global.debugMsg("TST is charge-turning",true,["enemyTST.gd","_physics_process"])
				seenTurnSpeedLeft -= delta
				if seenTurnSpeedLeft <= 0:
					# Turn
					seenTurnSpeedLeft += SEEN_TOTAL
					match chargeTurn:
						2:
							global.debugMsg("Halfway through charge-turn",true,["enemyTST.gd","_physics_process"])
							if global.rng.randi_range(0,1) == 0:
								actualID -= 1
							else:
								actualID += 1
							chargeTurn = 1
						1:
							global.debugMsg("Ending charge-turn",true,["enemyTST.gd","_physics_process"])
							actualID = 0
							chargeTurn = 0
							direction -= global_transform.basis.z
							velocity = CHARGE_SPEED*direction
							velocity.y = 0
							requiredDistance = global.dblVectDiff(global_transform.origin, target)
							requiredDistance *= 1.5
							$TerrorPlayer3D.stream = load("res://assets/Audio/TST_charge.wav")
							$TerrorPlayer3D.play()
			else:
				# Has turned around
				global.debugMsg("Has turned around, charging",true,["enemyTST.gd","_physics_process"])
# warning-ignore:return_value_discarded
				look_at(target-global_transform.origin,Vector3.UP)
				var lastPos = global_transform.origin
				move_and_slide(velocity,Vector3.UP)
				for slide in range(get_slide_count()-1):
					match get_slide_collision(slide).collider.name:
						"Player":
							# Player death
							global.debugMsg("TST hit player",true,["enemyTST.gd","_physics_process"])
							$Sprites.animation = "mouth_idle"
							global_transform.origin = global.playerPos
							translation += global_transform.basis.z*3
							var lookPos = get_global_transform().origin
							get_slide_collision(slide).collider.death(true,lookPos)
#						"Crate":
#							# Player find key
#							get_slide_collision(slide).collider.breakOpen()
				requiredDistance -= global.dblVectDiff(lastPos,global_transform.origin)
				var vectDiff = global.dblVectDiff(lastPos,global_transform.origin)
				if requiredDistance <= 0 or vectDiff <= 0.01:
					# Restart process
					global.debugMsg("Restarting to searching mode. Either requiredDistance, which is {"+str(requiredDistance)+"}, is less than or equal to 0 or global.dblVectDiff returned less than or equal to 0.01 with the last position and current position. global.dblVectDiff returned {"+str(vectDiff)+"} this time.",true,["enemyTST.gd","_physics_process"])
					seenTurnSpeedLeft = 0.5
					idleTurnSpeedLeft = 2
					target = Vector3()
					actualID = 0
					chargeTurn = 2
					direction = Vector3()
					velocity = Vector3()
		# Get actual sprite and set
		look_at(global.playerPos,Vector3.UP)
		var tempActual = actualID
		match int(stepify(rotation_degrees.y,90))%360:
			0:
				tempActual += 0
			90, -270:
				tempActual += 1
			-180, 180:
				tempActual += 2
			-90, 270:
				tempActual += 3
		var moving
		if target != Vector3() and chargeTurn == 0:
			moving = "move"
		else:
			moving = "idle"
		$Sprites.flip_h = false
		match tempActual%4:
			0:
				$Sprites.animation = "mouth_"+moving
			1:
				$Sprites.animation = "side_"+moving
				$Sprites.flip_h = true
			3:
				$Sprites.animation = "side_"+moving
			2:
				$Sprites.animation = "eye_"+moving
		global.debugMsg("Animation currently is {"+$Sprites.animation+"} and flip_h is {"+str($Sprites.flip_h)+"} because tempActual is {"+str(tempActual)+"} and moving is {"+moving+"}.",true,["enemyTST.gd","_physics_process"])
	else:
		global.debugMsg("Is pausing or dead, pausing audio and animation",true,["enemyTST.gd","_physics_process"])
		$TerrorPlayer3D.stream_paused = true
		$Sprites.playing = false

func _process(delta):
	if !global.pausing:
		lifeInSeconds -= delta
	if lifeInSeconds <= 0:
		global.debugMsg("lifeInSeconds hit/passed 0",true,["enemyTST.gd","_process"])
		queue_free()
	if global.dblVectDiff(global_transform.origin,global.playerPos) >= MAX_DISTANCE:
		hide()
	else:
		show()


func _on_Area_body_entered(body):
	if body.name == "Player":
		# Player death
		global.debugMsg("Hit player",true,["enemyTST.gd","_on_Area_body_entered"])
		$Sprites.animation = "mouth_idle"
		global_transform.origin = global.playerPos
		translation += global_transform.basis.z*3
		var lookPos = get_global_transform().origin
		body.death(true,lookPos)
