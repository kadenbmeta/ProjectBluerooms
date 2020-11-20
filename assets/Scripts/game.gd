extends Node

# IS USELESS IN SINGLEPLAYER. JUST ADD PLAYER IN MANUALLY.

#func _ready():
#	if global.otherPlayerId != -1:
#		# Ourself
#		var thisPlayer = preload("res://assets/Game/Player.tscn").instance()
#		thisPlayer.set_name(str(get_tree().get_network_unique_id()))
#		thisPlayer.set_network_master(get_tree().get_network_unique_id())
#		add_child(thisPlayer)
#
#		# Other
#		var otherPlayer = preload("res://assets/Game/Player.tscn").instance()
#		otherPlayer.set_name(str(global.otherPlayerId))
#		otherPlayer.set_network_master(global.otherPlayerId)
#		add_child(otherPlayer)
#	else:
#		var singlePlayer = preload("res://assets/Game/Player.tscn").instance()
#		add_child(singlePlayer)
