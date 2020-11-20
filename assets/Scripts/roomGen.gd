extends Spatial



# Unknown vars
var genZMin
var genZMax
var genXMin
var genXMax

# Size of rooms
export(int) var sizeX
export(int) var sizeZ

# Layout as rectangle size starting from middle (not including middle) going each of the 4 directions
var roomsOfXPos = 2
var roomsOfZPos = 2
var roomsOfXNeg = 2
var roomsOfZNeg = 2

# Rooms to generate
export(Array, Resource) var possibleRooms

# Generation type
export(bool) var hasDoors = true

# Door gen
var occupied = [Vector3(0,0,0)]



# Level music to play
export(String) var levelMusicPath



# Thoughts to queue on level start
export(Array, String) var levelStartThoughts



# Next level
export(String) var nextLevelPath = "none"
export(int) var pointsToWin
export(int) var nextLevelID = 0
export(int) var thisLevelID = 0



# Enemies
export(int, 100) var lookAwayChance = 0



func _ready():
	# Get bounds
	genZMin = -(sizeZ)
	genZMax = sizeZ
	genXMin = -(sizeX)
	genXMax = sizeX
	# Queue level thoughts to player
	if levelStartThoughts.size() != 0 and global.gameMode == "story":
		if global.firstPlay.keys().find(thisLevelID) == -1:
			global.thoughtQueue += levelStartThoughts
		else:
			if global.firstPlay[thisLevelID] != false:
				global.thoughtQueue += levelStartThoughts

	# Start playing level music
	MusicPlayer.musicSwitch(levelMusicPath)
	# Tell player point max
	$"../Player".pointsToWin = pointsToWin
	$"../Player".nextLevelPath = nextLevelPath
	$"../Player".nextLevelID = nextLevelID
	$"../Player".thisLevelID = thisLevelID


# Generation - No doors - OUTDATED
func _process(_delta):
	#print("PLAYERPOS="+str(global.playerPos))
	# Positive X, Negative X, Positive Z, Negative Z
	if !hasDoors:
		if global.playerPos.x >= genXMax:
			# Create as many rooms as needed
			var newRooms = []
			for roomNum in range(roomsOfZNeg+roomsOfZPos+1):
				# Choose room and instance
				## a = number of possible rooms
				## a - 1 = b
				## random integer from 0 to b (inclusive) = c
				## item c of possibleRooms is used
				if possibleRooms.size() != 1:
					newRooms.append(possibleRooms[global.rng.randi_range(0,possibleRooms.size()-1)].instance())
				else:
					newRooms.append(possibleRooms[0].instance())
				#
				# PLACE ROOMS IN POSITION
				#
				## X = edge for x+
				### edge for x+ = genXMax + another room size on X
				## Y = 0
				## Z = each room spot from {edge for z+} to {edge for z-}
				#
				# Place room in first spot
				newRooms[roomNum].translation = Vector3(genXMax+(sizeX*2),0,genZMin-sizeZ)
				# Move room as many times as there have been rooms
				if roomNum != 0:
					for _repeater in range(roomNum):
						newRooms[roomNum].translation += Vector3(0,0,sizeZ)
						#if roomNum == roomsOfXNeg+roomsOfXPos:
							#var spotCalcVect = newRooms[roomNum].translation/Vector3(sizeX,1,sizeZ)
							#print("SPOT #"+str(repeater+1)+" - ("+str(spotCalcVect.x)+", "+str(spotCalcVect.z)+")")
	#			else:
	#				var spotCalcVect = newRooms[roomNum].translation/Vector3(sizeX,1,sizeZ)
					#print("--------------------\nSPOT #0 - ("+str(spotCalcVect.x)+", "+str(spotCalcVect.z)+")")
			# Save rooms to scene
			for room in newRooms:
				add_child(room)
			# Add another x+ line to counter for calcs
			roomsOfXPos += 1
			# Move detection further down
			genXMax += sizeX
		if global.playerPos.x <= genXMin:
			# SEE COMMENTS IN [if global.playerPos.x >= genXMax:]
			var newRooms = []
			for roomNum in range(roomsOfZNeg+roomsOfZPos+1):
				if possibleRooms.size() != 1:
					newRooms.append(possibleRooms[global.rng.randi_range(0,possibleRooms.size()-1)].instance())
				else:
					newRooms.append(possibleRooms[0].instance())
				newRooms[roomNum].translation = Vector3(genXMin-(sizeX*2),0,genZMin-sizeZ)
				if roomNum != 0:
					for _repeater in range(roomNum):
						newRooms[roomNum].translation += Vector3(0,0,sizeZ)
	#					if roomNum == roomsOfXNeg+roomsOfXPos:
	#						var spotCalcVect = newRooms[roomNum].translation/Vector3(sizeX,1,sizeZ)
	#						#print("SPOT #"+str(repeater+1)+" - ("+str(spotCalcVect.x)+", "+str(spotCalcVect.z)+")")
	#			else:
	#				var spotCalcVect = newRooms[roomNum].translation/Vector3(sizeX,1,sizeZ)
					#print("--------------------\nSPOT #0 - ("+str(spotCalcVect.x)+", "+str(spotCalcVect.z)+")")
			for room in newRooms:
				add_child(room)
			roomsOfXNeg += 1
			genXMin -= sizeX
		if global.playerPos.z >= genZMax:
			# SEE COMMENTS IN [if global.playerPos.x >= genXMax:]
			var newRooms = []
			for roomNum in range(roomsOfXNeg+roomsOfXPos+1):
				if possibleRooms.size() != 1:
					newRooms.append(possibleRooms[global.rng.randi_range(0,possibleRooms.size()-1)].instance())
				else:
					newRooms.append(possibleRooms[0].instance())
				newRooms[roomNum].translation = Vector3(genXMin-sizeX,0,genZMax+(sizeZ*2))
				if roomNum != 0:
					for _repeater in range(roomNum):
						newRooms[roomNum].translation += Vector3(sizeX,0,0)
	#					if roomNum == roomsOfXNeg+roomsOfXPos:
	#						var spotCalcVect = newRooms[roomNum].translation/Vector3(sizeX,1,sizeZ)
	#						#print("SPOT #"+str(repeater+1)+" - ("+str(spotCalcVect.x)+", "+str(spotCalcVect.z)+")")
	#			else:
	#				var spotCalcVect = newRooms[roomNum].translation/Vector3(sizeX,1,sizeZ)
					#print("--------------------\nSPOT #0 - ("+str(spotCalcVect.x)+", "+str(spotCalcVect.z)+")")
			for room in newRooms:
				add_child(room)
			roomsOfZPos += 1
			genZMax += sizeZ
		if global.playerPos.z <= genZMin:
			# SEE COMMENTS IN [if global.playerPos.x >= genXMax:]
			var newRooms = []
			for roomNum in range(roomsOfXNeg+roomsOfXPos+1):
				if possibleRooms.size() != 1:
					newRooms.append(possibleRooms[global.rng.randi_range(0,possibleRooms.size()-1)].instance())
				else:
					newRooms.append(possibleRooms[0].instance())
				newRooms[roomNum].translation = Vector3(genXMin-sizeX,0,genZMin-(sizeZ*2))
				if roomNum != 0:
					for _repeater in range(roomNum):
						newRooms[roomNum].translation += Vector3(sizeX,0,0)
	#					if roomNum == roomsOfXNeg+roomsOfXPos:
	#						var spotCalcVect = newRooms[roomNum].translation/Vector3(sizeX,1,sizeZ)
	#						#print("SPOT #"+str(repeater+1)+" - ("+str(spotCalcVect.x)+", "+str(spotCalcVect.z)+")")
	#			else:
	#				var spotCalcVect = newRooms[roomNum].translation/Vector3(sizeX,1,sizeZ)
					#print("--------------------\nSPOT #0 - ("+str(spotCalcVect.x)+", "+str(spotCalcVect.z)+")")
			for room in newRooms:
				add_child(room)
			roomsOfZNeg += 1
			genZMin -= sizeZ

# Generation - Doors
func generateRoom(genDir,delDir):
	var newRoom = possibleRooms[global.rng.randi_range(0,possibleRooms.size()-1)].instance()
	var offsetVect = Vector3()
	match genDir:
		"x-":
			offsetVect.x -= sizeX
		"x+":
			offsetVect.x += sizeX
		"z-":
			offsetVect.z -= sizeZ
		"z+":
			offsetVect.z += sizeZ
	var roomPos = offsetVect+Vector3(stepify(global.playerPos.x,sizeX),0,stepify(global.playerPos.z,sizeZ))
	if occupied.find(roomPos) == -1:
		global.debugMsg("Generating room at {"+str(roomPos)+"}",true,["roomGen.gd","generateRoom"])
		occupied.append(roomPos)
		newRoom.translation = roomPos
		var doorsParent = newRoom.get_node("Doors")
		doorsParent.doorsToCheck = 4
		doorsParent.doorDirToDelete = delDir
		add_child(newRoom)
	else:
		global.debugMsg("Tried generating room at {"+str(roomPos)+"}, which was occupied, so it was removed.",true,["roomGen.gd","generateRoom"])
		newRoom.queue_free()
