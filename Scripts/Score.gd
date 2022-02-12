extends Label

onready var PC = {
	points = 0, 
	games = 0, 
	sets = 0
}

onready var NPC = {
	points = 0, 
	games = 0, 
	sets = 0
}

onready var PC_game_score = 0
onready var NPC_game_score = 0

func _process(delta):
	text = "PC -- "+str(PC.sets) +" | "+ str(PC.games) +" | "+ str(PC_game_score) +"\n"
	text += "NPC -- "+str(NPC.sets) +" | "+ str(NPC.games) +" | "+ str(NPC_game_score)

func add_point_to(player: String):
	if player == "PC":
		PC.points += 1
		if PC.games == 6 and NPC.games == 6: # tiebreak
			if PC.points >= 7:
				if NPC.points <= PC.points-2: #PC win the tiebreak
					PC.points = 0
					NPC.points = 0
					PC.games += 1
		elif PC.points == 5: #PC game win (was advantage)
			PC.points = 0
			NPC.points = 0
			PC.games += 1
		elif PC.points == 4:
			if NPC.points == 4: #deuce (was advantage NPC)
				PC.points = 3
				NPC.points = 3
			elif NPC.points == 3: #PC has advantage (was deuce)
				pass
			else: #PC win (PC score was 40 and NPC score was 30 or 15 or 0)
				PC.points = 0
				NPC.points = 0
				PC.games += 1
		
		if PC.games == 7: #PC wins a set
			PC.games = 0
			NPC.games = 0
			PC.sets += 1
		elif PC.games == 6 and NPC.games <= 4: #PC wins a set
			PC.games = 0
			NPC.games = 0
			PC.sets += 1
		
	elif player == "NPC":
		NPC.points += 1
		if NPC.games == 6 and PC.games == 6: #tiebreak
			if NPC.points >= 7:
				if PC.points <= NPC.points-2: #NPC win the tiebreak
					NPC.points = 0
					PC.points = 0
					NPC.games += 1
		elif NPC.points == 5: #NPC game win (was advantage)
			NPC.points = 0
			PC.points = 0
			NPC.games += 1
		elif NPC.points == 4:
			if PC.points == 4: #deuce (was advantage PC)
				NPC.points = 3
				PC.points = 3
			elif PC.points == 3: #NPC has advantage (was deuce)
				pass
			else: #NPC win (NPC score was 40 and PC score was 30 or 15 or 0)
				NPC.points = 0
				PC.points = 0
				NPC.games += 1
		
		if NPC.games == 7: #NPC wins a set
			NPC.games = 0
			PC.games = 0
			NPC.sets +=1
		elif NPC.games == 6 and PC.games <= 4: #NPC wins a set
			NPC.games = 0
			PC.games = 0
			NPC.sets += 1
	
	if PC.games == 6 and NPC.games == 6: # in tiebreak
		PC_game_score = PC.points
		NPC_game_score = NPC.points
		if get_parent().server == "PC":
			get_parent().server = "NPC"
		else:
			get_parent().server = "PC"
	elif PC.points == 3 and NPC.points == 3:
		PC_game_score = "DEUCE"
		NPC_game_score = "DEUCE"
	else:
		if PC.points == 4:
			PC_game_score = "ADV"
		if NPC.points == 4:
			NPC_game_score = "ADV"
		if PC.points == 3:
			PC_game_score = "40"
		if NPC.points == 3:
			NPC_game_score = "40"
		if PC.points < 3:
			PC_game_score = 15*PC.points
		if NPC.points < 3:
			NPC_game_score = 15*NPC.points
		
		# schimbarea jucatorului ce serveste:
		if PC.points == 0 and NPC.points == 0:
			if get_parent().server == "PC":
				get_parent().server = "NPC"
			else:
				get_parent().server = "PC"
	
	get_parent().serverZone = not get_parent().serverZone
	get_parent().serveChances = 2
