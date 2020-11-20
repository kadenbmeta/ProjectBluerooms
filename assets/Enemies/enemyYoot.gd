extends Area



var speed = 5

const MAX_DISTANCE = 60

var lifeInSeconds = 60

var alive = true



func _ready():
	$Sprites.animation = "idle"
	$YootPlayer3D.stream = load("res://assets/Audio/Slow1.ogg")
	$YootPlayer3D.play()
	lifeInSeconds = 60

func _physics_process(delta):
	look_at(global.playerPos,Vector3.UP)
	if !global.pausing and alive:
		$YootPlayer3D.stream_paused = false
		$Sprites.playing = true
		var thisTranslation = global_transform.basis.z*delta*speed
		var thisBlock = get_global_transform().origin
		translation -= thisTranslation
		global.destroyThisBlock.append(thisBlock)
		global.debugMsg("Moving with translation of {"+str(thisTranslation)+"} and destroying blocks at {"+str(thisBlock)+"}",true,["enemyYoot.gd","_physics_process"])
	else:
		global.debugMsg("Currently paused",true,["enemyYoot.gd","_physics_process"])
		$YootPlayer3D.stream_paused = true
		$Sprites.playing = false

func _on_Yoot_body_entered(body):
	if body.name == "Player" and alive:
		global.debugMsg("Hit player while alive",true,["enemyYoot.gd","_on_Yoot_body_entered"])
		$Sprites.animation = "angry"
		speed = 0
		translation += global_transform.basis.z*3
		var lookPos = get_global_transform().origin
		body.death(true,lookPos)

func _process(delta):
	if !global.pausing:
		lifeInSeconds -= delta
	if lifeInSeconds <= 0:
		global.debugMsg("lifeInSeconds hit/passed 0",true,["enemyYoot.gd","_process"])
		alive = false
		$Sprites.animation = "death"
		if lifeInSeconds <= -3:
			queue_free()
	if sqrt(pow(abs(get_global_transform().origin.x-global.playerPos.x),2)+pow(abs(get_global_transform().origin.z-global.playerPos.z),2)) >= MAX_DISTANCE:
		hide()
	else:
		show()
