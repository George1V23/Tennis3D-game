extends "Character.gd"


const left = Vector3(0, 0, -1)
const right = Vector3(0, 0, 1)
const up = Vector3(1, 0, 0)
const down = Vector3(-1, 0, 0)


onready var PC = get_parent().get_node("PC")
onready var racketStrings_centre = $Racket.get_node("StringsCollisionShape").global_transform.origin
onready var backhand_reach_len = abs($LeftArea.translation.x)+$LeftArea/CollisionShape.shape.extents.x 
onready var forehand_reach_len = abs($RightArea.translation.x)+$RightArea/CollisionShape.shape.extents.x
onready var forw_reach_len = abs($LeftArea.translation.x)+$LeftArea/CollisionShape.shape.extents.z
onready var court_halfLen = get_parent().get_node("Field/Landmarks/BaselineAndCentreMark").translation.x
onready var serveCourt_halfWidth = get_parent().get_node("Field/Landmarks/SidelineAndServiceLine").translation.z
onready var serveCourt_len = get_parent().get_node("Field/Landmarks/SidelineAndServiceLine").translation.x

func _ready():
	pass

func _process(delta):
	if not serving:
		move_aim_swing(delta)
	if need_to_serve:
		serve()
	if serving and Ball.holder == null:
		aim_for_serve()
#	swing()


func move_aim_swing(d: float):
	direction = Vector3.ZERO
	moveState = MoveState.IDLE

	var v_dir: Vector3 = Ball.translation-self.translation
	var dir_to_ball := Vector3(v_dir.x, 0, v_dir.z)
	var dist_to_ball: float = sqrt(v_dir.x*v_dir.x + v_dir.z*v_dir.z) 
	 
	if get_parent().server == "PC":
	# Cazurile din timpul servirii:
		if get_parent().stare_curenta == "S0 - Unul din jucatori trebuie sa serveasca.":
			direction = Vector3.ZERO
			moveState = MoveState.IDLE
		elif get_parent().stare_curenta == "S1 - Mingea a fost servita.":
			if v_dir.x > 0: #mingea nu a depasit inca corpul NPC-ului
				# Daca mingea se apropie vertiginos de NPC, acesta trebuie sa evite sa 
				#ia contact cu ea inainte sa atinga terenul, peretii sau alte obiecte,
				#pentru a nu se acorda fault si implicit punct celui ce a servit.
				if dist_to_ball < serveCourt_len+forw_reach_len:
					direction = Vector3(0,0,-sign(dir_to_ball.z))
					moveState = MoveState.RUN
				# Daca mingea tinde sa se departeze de NPC in coordonata z, 
				#acesta trebuie sa se deplaseze in lateral spre directia ei, ca 
				#sa poata s-o intercepteze daca ulterior atinge curtea de serva,
				#pentru a evita ca PC-ul sa obtina un as din serva.
				elif sign(Ball.linear_velocity.z) == sign(dir_to_ball.z):
					if abs(dir_to_ball.z) < 1:
						direction = Vector3(0, 0, dir_to_ball.z)
					else:
						direction = Vector3(0, 0, sign(dir_to_ball.z))
					moveState = MoveState.RUN
		elif get_parent().stare_curenta == "S3 - Mingea a atins curtea de serviciu.":
			aim_and_swing()
			if dist_to_ball > 1:
				direction = dir_to_ball.normalized()
				moveState = MoveState.RUN
			elif v_dir.x < forw_reach_len: #daca e prea aproape de minge se retrage in spate
				direction = Vector3(-direction.x,0,direction.z)
				moveState = MoveState.WALK
		elif get_parent().stare_curenta == "S4 - Mingea a atins fileul dupa lovitura de servire. (Let)":
			if v_dir.x > 0: #mingea nu a depasit inca corpul NPC-ului
				direction = -dir_to_ball.normalized()
				if dist_to_ball < serveCourt_len:
					moveState = MoveState.RUN
				else:
					moveState = MoveState.WALK
	# Cazurile dupa servire:
		elif get_parent().stare_curenta == "S7 - Receptorul servei a lovit mingea.":
			# Dupa ce a lovit mingea, NPC-ul e bine sa se retraga spre zona de 
			#mijloc a terenului si in spate pentru a avea mai multe sanse 
			#de a returna lovitura urmatoare a PC-ului.
			if Ball.translation.x >= 0: #daca mingea a trecut spre curtea adversa
				if self.translation.distance_to(Vector3(-court_halfLen,0,0)) > 1:
					direction = (Vector3(-court_halfLen,0,0)-self.translation).normalized()
					moveState = MoveState.WALK
#				else:
#					direction = (Vector3(-court_halfLen,0,0)-self.translation)/speed
				
		elif get_parent().stare_curenta == "S8 - Mingea a atins curtea servitorului.":
			if self.translation.distance_to(Vector3(-court_halfLen,0,0)) > 1:
				direction = (Vector3(-court_halfLen,0,0)-self.translation).normalized()
				moveState = MoveState.WALK
#			else:
#				direction = (Vector3(-court_halfLen,0,0)-self.translation)/speed
			
		elif get_parent().stare_curenta == "S9 - Mingea a atins fileul fiind lovita de receptor.":
			if self.translation.distance_to(Vector3(-court_halfLen,0,0)) > 1:
				direction = (Vector3(-court_halfLen,0,0)-self.translation).normalized()
				moveState = MoveState.WALK
#			else:
#				direction = (Vector3(-court_halfLen,0,0)-self.translation)/speed
			
		elif get_parent().stare_curenta == "S10 - Cel ce a servit a lovit mingea.":
			# Daca mingea nu a depasit NPC-ul si se departeaza in lateral 
			#de el, acesta se va deplasa in lateral spre ea:
			if v_dir.x > 0 and sign(Ball.linear_velocity.z) == sign(dir_to_ball.z):
				if abs(dir_to_ball.z) < 1:
					direction = Vector3(0, 0, dir_to_ball.z)
				else:
					direction = Vector3(0, 0, sign(dir_to_ball.z))
				
				if Ball.translation.x < 0: #mingea depaseste mijlocul terenului
					moveState = MoveState.RUN
				else: #mingea se afla inca in partea receptorului
					moveState = MoveState.WALK
			# Altfel incearca sa anticipeze pozitia unde cade mingea in teren, 
			#retragandu-se in spate si spre minge in lateral:
			elif self.translation.distance_to(Vector3(-(court_halfLen+forw_reach_len),0,dir_to_ball.z)) > 1:
				direction = (Vector3(-(court_halfLen+forw_reach_len),0,dir_to_ball.z)-self.translation).normalized()
				moveState = MoveState.WALK
			else:
				direction = (Vector3(-(court_halfLen+forw_reach_len),0,dir_to_ball.z)-self.translation)/speed
				moveState = MoveState.WALK
			# Daca mingea e prea aproape de jucator se retrage sa nu-l atinga:
			if v_dir.x > 0 and dist_to_ball < forw_reach_len:
				direction = down
				moveState = MoveState.WALK
				# daca mingea pare ca iese din teren
				if get_parent().is_ball_in_player_court("NPC") == false:
					direction = Vector3(0,0,-sign(v_dir.z))
					moveState = MoveState.RUN
			
			# Daca NPC-ul se afla intr-o zona mai avansata si mingea pare sa 
			#atinga curtea daca-l depaseste pe acesta, atunci el va lovi mingea
			#fara ca sa astepte sa mai atinga terenul. 
#			if NPC.translation.x < -(serveCourt_len+forw_reach_len):
#				 if get_parent().is_ball_in_player_court("NPC"):
				
		elif get_parent().stare_curenta == "S12 - Mingea a atins curtea receptorului.":
			aim_and_swing()
			if dist_to_ball > 1:
				direction = dir_to_ball.normalized()
				moveState = MoveState.RUN
			elif v_dir.x < forw_reach_len: #daca e prea aproape de minge se retrage in spate
				direction = Vector3(-direction.x,0,direction.z)
				moveState = MoveState.WALK
		elif get_parent().stare_curenta == "S13 - Mingea a atins fileul fiind lovita de cel ce a servit.":
			# Daca mingea planeaza in zona curtii NPC-ului si nu l-a depasit: 
			if get_parent().is_ball_in_player_court("NPC") and v_dir.x > 0:
				#El trebuie sa se deplaseze langa ea la o distanta sigura pentru a nu o atinge:
				if dist_to_ball > 1:
					direction = dir_to_ball.normalized()
					moveState = MoveState.RUN
				elif v_dir.x < forw_reach_len: #daca e prea aproape de minge se retrage in spate
					direction = Vector3(-direction.x,0,direction.z)
					moveState = MoveState.WALK
				
				#???????
				var yz_dist = sqrt(Ball.linear_velocity.y*Ball.linear_velocity.y + Ball.linear_velocity.z*Ball.linear_velocity.z)
				if abs(Ball.linear_velocity.x) <= yz_dist:
					aim_and_swing()
				# Daca mingea pare ca o sa cada in apropiere NPC-ul nu mai risca 
				#sa vada daca poate nu atinge curtea si o returneaza:
				if Ball.translation.y < $Racket.net_height:
					if abs(Ball.linear_velocity.y) > abs(Ball.linear_velocity.x) and abs(Ball.linear_velocity.y) > abs(Ball.linear_velocity.z):
						aim_and_swing() 
			# Daca mingea l-a depasit pe NPC, trebuie sa alerge dupa ea ca sa 
			#ajunga in fata ei.
			elif v_dir.x < 0:
				direction = (dir_to_ball+Vector3(-forw_reach_len,0,0)).normalized()
				moveState = MoveState.RUN
	
	else: #cel ce serveste sau a servit este NPC-ului
	# Cazurile din timpul servirii:
		if get_parent().stare_curenta == "S0 - Unul din jucatori trebuie sa serveasca.":
			direction = Vector3.ZERO
			moveState = MoveState.IDLE
		elif get_parent().stare_curenta == "S1 - Mingea a fost servita.":
			# Daca mingea depaseste centrul terenului, dupa serva:
			if Ball.translation.x > 0 and Ball.linear_velocity.x > 0:
				if self.translation.z < 0:
					direction = right
				elif self.translation.z > 0:
					direction = left
				#pentru deplasarea lina pana la destinatie, dupa ce distanta devine mai mica ca norma directiei:
				if abs(self.translation.z) < 1: 
					direction = Vector3(0, 0, -self.translation.z)
				moveState = MoveState.WALK
		elif get_parent().stare_curenta == "S3 - Mingea a atins curtea de serviciu.":
			# Daca mingea depaseste centrul terenului, dupa serva:
			if Ball.translation.x > 0 and Ball.linear_velocity.x > 0:
				if self.translation.z < 0:
					direction = right
				elif self.translation.z > 0:
					direction = left
				#pentru deplasarea lina pana la destinatie, dupa ce distanta devine mai mica ca norma directiei:
				if abs(self.translation.z) < 1: 
					direction = Vector3(0, 0, -self.translation.z)
				moveState = MoveState.WALK
		elif get_parent().stare_curenta == "S4 - Mingea a atins fileul dupa lovitura de servire. (Let)":
			# Daca mingea depaseste centrul terenului, dupa serva:
			if Ball.translation.x > 0 and Ball.linear_velocity.x > 0:
				if self.translation.z < 0:
					direction = right
				elif self.translation.z > 0:
					direction = left
				#pentru deplasarea lina pana la destinatie, dupa ce distanta devine mai mica ca norma directiei:
				if abs(self.translation.z) < 1: 
					direction = Vector3(0, 0, -self.translation.z)
				moveState = MoveState.WALK
	# Cazurile dupa servire:
		elif get_parent().stare_curenta == "S7 - Receptorul servei a lovit mingea.":
#			if Ball.translation.x < 0: #mingea depaseste mijlocul terenului
#				if dist_to_ball > 1:
#					direction = dir_to_ball.normalized()
#				else:
#					direction = dir_to_ball
#				moveState = MoveState.RUN
#			else: #mingea se afla inca in partea receptorului
#				if Ball.linear_velocity.z * dir_to_ball.z <= 0: #in coordonata z, mingea vine spre NPC
#					direction = Vector3(0, 0, dir_to_ball.normalized().z)
#					moveState = MoveState.WALK
			##### sa se retraga putin in spate, ferindu-se de minge, sa vada ->daca cade in teren sa o loveasca
			
			# Daca mingea nu a depasit NPC-ul si se departeaza in lateral 
			#de el, acesta se va deplasa in lateral spre ea:
			if v_dir.x > 0 and sign(Ball.linear_velocity.z) == sign(dir_to_ball.z):
				if abs(dir_to_ball.z) < 1:
					direction = Vector3(0, 0, dir_to_ball.z)
				else:
					direction = Vector3(0, 0, sign(dir_to_ball.z))
				
				if Ball.translation.x < 0: #mingea depaseste mijlocul terenului
					moveState = MoveState.RUN
				else: #mingea se afla inca in partea receptorului
					moveState = MoveState.WALK
			# Altfel incearca sa anticipeze pozitia unde cade mingea in teren, 
			#retragandu-se in spate si spre minge in lateral:
			elif self.translation.distance_to(Vector3(-(court_halfLen+forw_reach_len),0,dir_to_ball.z)) > 1:
				direction = (Vector3(-(court_halfLen+forw_reach_len),0,dir_to_ball.z)-self.translation).normalized()
				moveState = MoveState.WALK
			else:
				direction = (Vector3(-(court_halfLen+forw_reach_len),0,dir_to_ball.z)-self.translation)/speed
				moveState = MoveState.WALK
			# Daca mingea e prea aproape de jucator se retrage sa nu-l atinga:
			if v_dir.x > 0 and dist_to_ball < forw_reach_len:
				direction = down
				moveState = MoveState.WALK
				# daca mingea pare ca iese din teren
				if get_parent().is_ball_in_player_court("NPC") == false:
					direction = Vector3(0,0,-sign(v_dir.z))
					moveState = MoveState.RUN
				elif Ball.translation.y < $Racket.net_height:
					aim_and_swing()
			
			# Daca NPC-ul se afla intr-o zona mai avansata si mingea pare sa 
			#atinga curtea daca-l depaseste pe acesta, atunci el va lovi mingea
			#fara ca sa astepte sa mai atinga terenul. 
#			if NPC.translation.x < -(serveCourt_len+forw_reach_len):
#				 if get_parent().is_ball_in_player_court("NPC"):
		elif get_parent().stare_curenta == "S8 - Mingea a atins curtea servitorului.":
			aim_and_swing()
			if dist_to_ball > 1:
				direction = dir_to_ball.normalized()
				moveState = MoveState.RUN
			elif v_dir.x < forw_reach_len: #daca e prea aproape de minge se retrage in spate
				direction = Vector3(-direction.x,0,direction.z)
				moveState = MoveState.WALK
		elif get_parent().stare_curenta == "S9 - Mingea a atins fileul fiind lovita de receptor.":
			# Daca mingea planeaza in zona curtii NPC-ului si nu l-a depasit: 
			if get_parent().is_ball_in_player_court("NPC") and v_dir.x > 0:
				#El trebuie sa se deplaseze langa ea la o distanta sigura pentru a nu o atinge:
				if dist_to_ball > 1:
					direction = dir_to_ball.normalized()
#				else:
#					direction = dir_to_ball/speed
				moveState = MoveState.RUN
				if forw_reach_len < v_dir.x: #daca e prea aproape de minge se retrage in spate
					direction = Vector3(-direction.x,0,direction.z)
					moveState = MoveState.WALK
				# Daca NPC-ul se afla la centrul curtii si mingea pare ca o sa 
				#cada in apropiere, NPC-ul nu mai risca sa vada daca poate nu 
				#atinge curtea si o returneaza:
				var yz_dist = sqrt(Ball.linear_velocity.y*Ball.linear_velocity.y + Ball.linear_velocity.z*Ball.linear_velocity.z)
				if abs(self.translation.x) < serveCourt_len+forw_reach_len and abs(Ball.linear_velocity.x) <= yz_dist:
					aim_and_swing()
			# Daca mingea l-a depasit pe NPC, trebuie sa alerge dupa ea ca sa 
			#ajunga in fata ei.
			elif v_dir.x < 0:
				direction = (dir_to_ball+Vector3(-forw_reach_len,0,0)).normalized()
				moveState = MoveState.RUN
		elif get_parent().stare_curenta == "S10 - Cel ce a servit a lovit mingea.":
			if self.translation.distance_to(Vector3(-court_halfLen,0,0)) > 1:
				direction = (Vector3(-court_halfLen,0,0)-self.translation).normalized()
				moveState = MoveState.WALK
#			else:
#				direction = (Vector3(-court_halfLen,0,0)-self.translation)/speed
			
		elif get_parent().stare_curenta == "S12 - Mingea a atins curtea receptorului.":
			if self.translation.distance_to(Vector3(-court_halfLen,0,0)) > 1:
				direction = (Vector3(-court_halfLen,0,0)-self.translation).normalized()
				moveState = MoveState.WALK
#			else:
#				direction = (Vector3(-court_halfLen,0,0)-self.translation)/speed
			
		elif get_parent().stare_curenta == "S13 - Mingea a atins fileul fiind lovita de cel ce a servit.":
			if self.translation.distance_to(Vector3(-court_halfLen,0,0)) > 1:
				direction = (Vector3(-court_halfLen,0,0)-self.translation).normalized()
				moveState = MoveState.WALK
#			else:
#				direction = (Vector3(-court_halfLen,0,0)-self.translation)/speed
			
	
	move_and_slide(direction*speed, FLOOR_NORMAL)

# Ca NPC-ul sa nu inceapa se serveasca brusc, se ia un repaos de 2 sec.
var start_time := 0.0
func serve():
	if can_serve:
		if start_time == 0.0:
			start_time = OS.get_ticks_msec()
		elif (OS.get_ticks_msec()-start_time)/1000 >= 2:
			start_time = 0.0
			serving = true
	else:
		start_time = 0.0

var change_side_zone = 0
var change_forw_zone = 0
var side_zone = 0
var forw_zone = 0
var side_dist = 0
var forw_dist = 0
var rng = RandomNumberGenerator.new()

func aim_for_serve():
	side_zone = 1
	forw_zone = 2
	
	randomize()
	change_side_zone = randi()%2
	if change_side_zone == 1:
		randomize()
		side_zone = randi()%3 + 1
	
	randomize()
	change_forw_zone = randi()%2
	if change_forw_zone == 1:
		randomize()
		forw_zone = randi()%2 + 2
		
	var court_end = get_node("..").BaselineAndCenterMark_intersection
	var serveCourt_corner = get_node("..").SidelineAndServiceLine_intersection
	side_dist = serveCourt_corner.z*side_zone/3 #distanta in lateral fata de centrul terenului
	forw_dist = serveCourt_corner.x*forw_zone/3 #distanta inainte fata de centrul terenului
	
	randomize()
	change_side_zone = randi()%2
	if change_side_zone == 1:
		rng.randomize()
		side_dist += rng.randf_range(-side_dist/4, side_dist/4)
	
	randomize()
	change_forw_zone = randi()%2
	if change_forw_zone == 1:
		rng.randomize()
		forw_dist += rng.randf_range(-forw_dist/4, forw_dist/4)
	
	if self.translation.z > 0: #serveste din dreapta
		aim_target.z = -side_dist
	elif self.translation.z < 0: #serveste din stanga
		aim_target.z = side_dist
	aim_target.x = forw_dist
	
	var aim_dist = self.global_transform.origin.distance_to(aim_target)
	rng.randomize()
	swing_timing = rng.randf_range(30, 36)/aim_dist*10
	if swing_timing > 10:
		swing_timing = 10
	print("aim_distance::: "+str(swing_timing))

func aim_and_swing():
	# Alegerea zonei in functie de pozitia adversarului:
	randomize()
	if PC.translation.x > court_halfLen:
		change_forw_zone = randi()%4
		if change_forw_zone == 0: # in 25% din cazuri
			forw_zone = 0
		else:
			randomize()
			change_forw_zone = randi()%3
			if change_forw_zone == 0: # in 33.33% din 75% din cazuri
				forw_zone = 2
			else:
				forw_zone = 1 # in 66.66% din 75% din cazuri
	elif PC.translation.x > serveCourt_len:
		change_forw_zone = randi()%10
		if change_forw_zone == 0: # in 10% din cazuri
			forw_zone = 0
		elif change_forw_zone < 5:
			forw_zone = 1 # in 40% din cazuri
		else: 
			forw_zone = 2 # in 50% din cazuri
	else:
		change_forw_zone = randi()%20
		if change_forw_zone == 0: # in 5% din cazuri
			forw_zone = 0
		elif change_forw_zone <= 7:
			forw_zone = 1 # in 35% din cazuri
		else: 
			forw_zone = 2 # in 60% din cazuri
	# alegerea zonei in lateral:
	randomize()
	if abs(PC.translation.z) <= serveCourt_halfWidth/4:
		change_side_zone = randi()%4
		if change_side_zone == 0: # in 25% din cazuri
			side_zone = 0 #zona din mijloc 
		else: 
			randomize()
			if randi()%2 == 0: 
				side_zone = -1 # 37.5% din cazuri
			else:
				side_zone = 1 # 37.5% din cazuri
	elif abs(PC.translation.z) >= serveCourt_halfWidth:
		change_side_zone = randi()%20
		if change_side_zone == 0: # in 5% din cazuri
			side_zone = sign(PC.translation.z) #zona in care e adversarul 
		elif change_side_zone > 7: # in 60% din cazuri 
			side_zone = -sign(PC.translation.z) #zona opusa adversarului 
		else: # in 35% din cazuri
			side_zone = 0 #zona de mijloc
	else:
		change_side_zone = randi()%10
		if change_side_zone < 2: # in 20% din cazuri
			side_zone = sign(PC.translation.z) #zona in care e adversarul 
		elif change_side_zone < 5: # in 30% din cazuri 
			side_zone = -sign(PC.translation.z) #zona opusa adversarului 
		else: # in 50% din cazuri
			side_zone = 0 #zona de mijloc
	
	rng.randomize()
	forw_dist = rng.randf_range(forw_zone*court_halfLen/3, (forw_zone+1)*court_halfLen/3)
	rng.randomize()
	if side_zone == 0:
		side_dist = rng.randf_range(-serveCourt_halfWidth*2/3, serveCourt_halfWidth*2/3)
	elif side_zone == 1:
		side_dist = rng.randf_range(serveCourt_halfWidth, serveCourt_halfWidth*2/3)
	else:
		side_dist = rng.randf_range(-serveCourt_halfWidth*2/3, -serveCourt_halfWidth)
	aim_target = Vector3(forw_dist, 0, side_dist)
	
	var aim_dist = $Racket.global_transform.origin.distance_to(aim_target)
	swing_timing = rng.randf_range(1.5, 1.7)*aim_dist/10
	print("aim_dist=="+str(swing_timing))
	# Jucatorul nu trebuie sa loveasca mingea daca se afla inca in terenul advers. 
	if Ball.translation.x >= 0:
		swing_timing = 0

#func swing():
#	if serving:
#		swing_timing = 8
#	elif Ball.last_hit_by == "PC":
#		swing_timing = 8
#	else:
#		swing_timing = 0
#	pass
