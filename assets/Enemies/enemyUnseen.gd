extends Area



var timeLeft = 1

func _ready():
	$Sprites.animation = "start"
	$UnseenPlayer3D.play()
#	$Sight.enabled = true

func _physics_process(delta):
	if !global.pausing:
#		var castLocation = (global.playerPos-global_transform.origin)*2
#		$Sight.cast_to = castLocation
#		$Sight/SightSee.scale.y = castLocation.length()
		look_at(global.playerPos,Vector3.UP)
		$UnseenPlayer3D.stream_paused = false
		$Sprites.playing = true
		look_at(global.playerPos,Vector3.UP)
		global_transform.origin.y = global.playerPos.y
		timeLeft -= delta
		if timeLeft <= 0:
			match $Sprites.animation:
				"start":
					global.debugMsg("Switching to screaming mode",true,["enemyUnseen.gd","_process"])
					timeLeft += 3
					$Sprites.animation = "scream"
				"scream":
					hide()
					global.debugMsg("Checking for death, if no other messages occur, it was survived.",true,["enemyUnseen.gd","_process"])
					$Sight.translation.y = 0
					var thisCollider = $Sight.move_and_collide(global.playerPos-global_transform.origin).collider
					if $VisibilityNotifier.is_on_screen() and thisCollider.name == "Player":
						global.debugMsg("Player is still looking at The Unseen",true,["enemyUnseen.gd","_process"])
						$"/root/DebuggingNotify/TheUnseenSprite".show()
						thisCollider.death(false)
					queue_free()
	else:
		global.debugMsg("Game is paused",true,["enemyUnseen.gd","_process"])
		$UnseenPlayer3D.stream_paused = true
		$Sprites.playing = false

func _on_Unseen_body_entered(body):
	if body.name == "Player":
		global.debugMsg("Player hit Unseen",true,["enemyUnseen.gd","_on_Unseen_body_entered"])
		body.death(true,global_transform.origin)
