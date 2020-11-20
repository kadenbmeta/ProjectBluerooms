extends MeshInstance

# Lol what even

#var isFlying = []
#
#func _on_Area_body_entered(body):
#	print(str(body)+"\nEND")
#	if !(body is StaticBody):
#		print("NON STATIC: "+str(body))
#		isFlying.append(body)
#		#move_and_collide(velocity * delta)
##		while $Area.overlaps_body(body):
##			body.transform.origin += Vector3(0,1,0)
#
#func _on_Area_body_exited(body):
#	print("EXIT")
#	if body in isFlying:
#		isFlying.erase(body)
#
#func _process(delta):
#	#pass
#	print(str(isFlying)+"\nEND")
#	for body in isFlying:
#		body.transform.origin += Vector3(0,2,0)
