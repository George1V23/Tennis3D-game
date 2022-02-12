extends Node

# Multimea de stari din timpul unui punct al jocului de tenis prin care se 
#determina regulile ce trebuie impuse.
const stari: Array = [
	# Starile posibile din timpul servirii:
	"S0 - Unul din jucatori trebuie sa serveasca.", #-> starea initiala
	"S1 - Mingea a fost servita.",
	"S2 - Serva pierduta. Va incepe o noua serva.", #-> stare finala
	"S3 - Mingea a atins curtea de serviciu.",
	"S4 - Mingea a atins fileul dupa lovitura de servire. (Let)",
	"S5 - Cel ce a servit castiga punctul.", #-> stare finala
	"S6 - Mingea atinge curtea de serviciu dupa ce a atins fileul. Se va repeta serva.", #-> stare finala
	# Dupa servire se pot atinge urmatoarele stari:
	"S7 - Receptorul servei a lovit mingea.",
	"S8 - Mingea a atins curtea servitorului.",
	"S9 - Mingea a atins fileul fiind lovita de receptor.",
	"S10 - Cel ce a servit a lovit mingea.",
	"S11 - Receptorul servei castiga punctul.", #-> stare finala
	"S12 - Mingea a atins curtea receptorului.",
	"S13 - Mingea a atins fileul fiind lovita de cel ce a servit."
	]


onready var stare_curenta : String = stari[0] 

# Variabile pentru serva:
onready var server : String
onready var serverZone := true #true->right zone, false->left zone
onready var serveChances := 2

# Repere din teren ce ajuta la verificarea pozitionarii corecte la servire (de tip vectori)
onready var BaselineAndCenterMark_intersection: Vector3 = $Field.get_node("Landmarks/BaselineAndCentreMark").translation
onready var SidelineAndServiceLine_intersection: Vector3 = $Field.get_node("Landmarks/SidelineAndServiceLine").translation

func _ready():
	# Se alege un jucator aleator pentru a incepe meciul de tenis.
	randomize()
	if randi() % 2 == 0:
		server = "PC"
		$Ball.pick_up_by($PC)
		$PC.need_to_serve = true
	else:
		server = "NPC"
		$Ball.pick_up_by($NPC)
		$NPC.need_to_serve = true
	
	$Timer.wait_time = 0.001
	startNewServe()


# Daca un jucator trebuie sa serveasca, seteaza variabilele care indica daca pozitia e corecta.
var poz_VarfPicior: Vector3
var poz_MarginePiciorSt: Vector3
var poz_MarginePiciorDr: Vector3
func _process(delta):
	if $PC.need_to_serve:
		$PC.can_serve = false #presupunerea initiala
		poz_VarfPicior = $PC.get_node("Skeleton/left_toe_base/PozitieVarf").global_transform.origin
		if poz_VarfPicior.x > BaselineAndCenterMark_intersection.x:
			poz_MarginePiciorSt = $PC.get_node("Skeleton/left_toe_base/PozitieMargineSt").global_transform.origin
			poz_MarginePiciorDr = $PC.get_node("Skeleton/right_toe_base/PozitieMargineDr").global_transform.origin
			if serverZone == false: #zona stanga
				if poz_MarginePiciorDr.z > BaselineAndCenterMark_intersection.z and poz_MarginePiciorSt.z < SidelineAndServiceLine_intersection.z:
					$PC.can_serve = true
			elif poz_MarginePiciorSt.z < -BaselineAndCenterMark_intersection.z and poz_MarginePiciorDr.z > -SidelineAndServiceLine_intersection.z:
					$PC.can_serve = true
	elif $NPC.need_to_serve:
		$NPC.can_serve = false #presupunerea initiala
		poz_VarfPicior = $NPC.get_node("Skeleton/left_toe_base/PozitieVarf").global_transform.origin
		if poz_VarfPicior.x < -BaselineAndCenterMark_intersection.x:
			poz_MarginePiciorSt = $NPC.get_node("Skeleton/left_toe_base/PozitieMargineSt").global_transform.origin
			poz_MarginePiciorDr = $NPC.get_node("Skeleton/right_toe_base/PozitieMargineDr").global_transform.origin
			if serverZone == false: #zona stanga
				if poz_MarginePiciorDr.z < -BaselineAndCenterMark_intersection.z and poz_MarginePiciorSt.z > -SidelineAndServiceLine_intersection.z:
					$NPC.can_serve = true
			elif poz_MarginePiciorSt.z > BaselineAndCenterMark_intersection.z and poz_MarginePiciorDr.z < SidelineAndServiceLine_intersection.z:
					$NPC.can_serve = true


var pauza_meniu = false
func _input(event):
	# Daca se apasa butonul pentru meniul de pauza:
	if Input.is_key_pressed(KEY_ESCAPE):
		pauza_meniu = not pauza_meniu
		Engine.time_scale = abs(Engine.time_scale-1)
		
		$PC.set_process_input(not pauza_meniu)
		$Camera.current = not pauza_meniu
		
		$CardanExt/CardanInt/Camera.current = pauza_meniu
		$CardanExt.set_process_input(pauza_meniu)
	
	# Daca se apasa butonul pentru a reseta: 
	elif Input.is_key_pressed(KEY_R):
		# -pozitionarea camerei pentru vizualizarea libera a scenei
		if pauza_meniu:
			$CardanExt.resetare_pozitie()
		# -pozitia jucatorilor la locul de servire numai daca cineva 
		#trebuie sa serveasca si inca nu a servit.
		elif ($PC.need_to_serve and not $PC.serving) or ($NPC.need_to_serve and not $NPC.serving):
			$Timer.stop()
			$Timer.wait_time = 0.01
			serveChances += 1
			startNewServe()


func startNewServe():
	if serveChances == 0: #punct pierdut pt cel ce serveste; va incepe o noua serva
		$Score.add_point_to(receiver())
	serveChances -= 1
	
	#Se porneste cronometrul pentru declansarea repozitionarii jucatorilor pentru serva.
	$Timer.start()
	$Ball.last_hit_by = ""
	stare_curenta = stari[0]

func _on_Timer_timeout():
	# La inceperea unei noi serve se sterg urmele de contact ale mingii cu 
	#suprafata din timpul punctului tocmai incheiat.
	get_tree().call_group("urme", "queue_free")
	$InfoPunct.set_text("")
	
	$PC.swing_timing = 0
	$NPC.swing_timing = 0
	
	# Muta jucatorul intr-o pozitie potrivita pentru a servi.
	$PC.translation = BaselineAndCenterMark_intersection
	$NPC.translation = -BaselineAndCenterMark_intersection
	
	var translateSideAmount = SidelineAndServiceLine_intersection.z / 3.0
	if serverZone == false:
		$PC.translation.z += translateSideAmount
		$NPC.translation.z -= translateSideAmount
	else :
		$PC.translation.z -= translateSideAmount
		$NPC.translation.z += translateSideAmount
	
	var translateBackAmount = translateSideAmount / 2.0
	$PC.translation.x += translateBackAmount
	$NPC.translation.x -= translateBackAmount
	
	# Mingea va fi tinuta de jucatorul ce urmeaza sa serveasca
	if server == "PC":
		$Ball.pick_up_by($PC)
		$PC.need_to_serve = true 
		$NPC.need_to_serve = false
	else:
		$Ball.pick_up_by($NPC)
		$NPC.need_to_serve = true
		$PC.need_to_serve = false
	$Ball.last_hit_by = ""
	
	$Timer.wait_time = 2 #revine la timpul normal pentru incepere al servei


func _on_Ball_body_entered(body):
	if not $Timer.is_stopped() or $Ball.holder != null:
		print("-time")
		return
	
	# In timpul disputarii unui punct, pentru a se putea observa mai bine unde a
	#avut loc contactul mingii cu terenul, se adauga urme.
	if body.name == "Ground":
		var urma = load("res://Scenes/UrmaMinge.tscn")
		var urma_minge = urma.instance()
		$Field.add_child(urma_minge)
		urma_minge.global_transform.origin.x = $Ball.global_transform.origin.x
		urma_minge.global_transform.origin.z = $Ball.global_transform.origin.z
	
	print(stare_curenta)
	print("curr="+body.name+"; own="+body.owner.name)
	
	# Tranzitiile posibile (identificate de conditii) din timpul starilor servirii:
	if stare_curenta == stari[0]:
		if body.name == "Racket" and body.owner.name == server:
			#mingea ia contact cu racheta celui ce serveste 
			stare_curenta = stari[1]
		else: #mingea atinge altceva inafara de racheta, jucatorul nereusind sa loveasca mingea 
			stare_curenta = stari[2]
			$InfoPunct.set_text("SERVICE FAULT")
		
	elif stare_curenta == stari[1]: 
		if body.name == "Ground" and is_ball_in_service_court(): 
			#mingea atinge curtea pentru servire
			stare_curenta = stari[3]
		elif body.name == "Net": 
			#mingea ia contact cu plasa
			stare_curenta = stari[4]
			$InfoPunct.set_text("NET")
		elif (body.name == "KinematicBody" or body.name == "Racket") and body.owner.name == receiver(): 
			#mingea e atinsa de jucatorul advers sau de racheta lui inainte sa atinga pamantul 
			stare_curenta = stari[5]
			$InfoPunct.set_text(receiver()+" FAULT")
		else: #cel ce serveste NU nimereste curtea pentru servire 
			stare_curenta = stari[2]
			if body.name == "Ground" or body.name == "Edge":
				$InfoPunct.set_text("SERVICE OUT")
			else:
				$InfoPunct.set_text("SERVICE FAULT")
		
	elif stare_curenta == stari[4]:
		if body.name == "Net": 
			#mingea ia contact in mod repetat cu plasa/fileul
			stare_curenta = stari[4]
			$InfoPunct.set_text("NET")
		elif body.name == "Ground" and is_ball_in_service_court():
			#mingea atinge curtea de serva dupa ce a atins fileul
			stare_curenta = stari[6]
			$InfoPunct.set_text("LET")
		elif (body.name == "KinematicBody" or body.name == "Racket") and body.owner.name == receiver(): 
			#mingea e atinsa de jucatorul advers sau de racheta lui, dupa ce ricoseaza din plasa 
			stare_curenta = stari[6]
			$InfoPunct.set_text("LET")
		else: #mingea NU atinge curtea de serva, dupa ce ricoseaza din plasa 
			stare_curenta = stari[2]
			if body.name == "Ground" or body.name == "Edge":
				$InfoPunct.set_text("SERVICE OUT")
			else:
				$InfoPunct.set_text("SERVICE FAULT")
		
	# Tranzitiile posibile dupa ce jucatorul reuseste sa serveasca:
	elif stare_curenta == stari[3]:
		if body.name == "Racket" and body.owner.name == receiver(): 
			#mingea ia contact cu racheta receptorului
			stare_curenta = stari[7]
		else: #mingea ia contact cu altceva decat racheta receptorului
			stare_curenta = stari[5] 
			$InfoPunct.set_text(server+" ACE")
		
	elif stare_curenta == stari[7]:
		if body.name == "Ground" and is_ball_in_player_court(server):
			#mingea atinge curtea celui ce a servit
			stare_curenta = stari[8]
		elif body.name == "Net": 
			#mingea ia contact cu plasa
			stare_curenta = stari[9]
		elif body.name == "Racket" and body.owner.name == server:
			#mingea ia contact cu racheta celui ce a servit
			stare_curenta = stari[10]
		elif body.name == "KinematicBody" and body.owner.name == server:
			#mingea il atinge pe cel ce a servit pe corp
			stare_curenta = stari[11]
			$InfoPunct.set_text(server+" FAULT")
		else: #mingea atinge stalpii, afara curtii sau afara terenului
			stare_curenta = stari[5]
			$InfoPunct.set_text(receiver()+" OUT")
		
	elif stare_curenta == stari[8]:
		if body.name == "Racket" and body.owner.name == server:
			#mingea ia contact cu racheta servitorului, dupa ce a atins curtea lui
			stare_curenta = stari[10]
		else:
			stare_curenta = stari[11]
			if body.name == "KinematicBody" and body.owner.name == server:
				$InfoPunct.set_text(server+" FAULT")
			else:
				$InfoPunct.set_text(receiver()+" IN")
		
	elif stare_curenta == stari[9]:
		if body.name == "Net":
			#mingea ia contact in mod repetat cu plasa/fileul, receptorul lovind ultimul mingea
			stare_curenta = stari[9]
		elif body.name == "Ground" and is_ball_in_player_court(server):
			#mingea cade in curtea celui ce a servit, dupa ce a atins plasa
			stare_curenta = stari[8]
		elif body.name == "Racket" and body.owner.name == server:
			#mingea ia contact cu racheta celui ce a servit, dupa ce a atins plasa
			stare_curenta = stari[10]
		elif body.name == "KinematicBody" and body.owner.name == server:
			#mingea il atinge pe cel ce a servit pe corp
			stare_curenta = stari[11]
			$InfoPunct.set_text(server+" FAULT")
		else: 
			#mingea atinge altceva decat curtea servitorului, dupa ce a atins plasa
			stare_curenta = stari[5]
			$InfoPunct.set_text(receiver()+" OUT")
		
	elif stare_curenta == stari[10]:
		if body.name == "Ground" and is_ball_in_player_court(receiver()):
			#mingea atinge curtea receptorului
			stare_curenta = stari[12]
		elif body.name == "Net": 
			#mingea ia contact cu plasa
			stare_curenta = stari[13]
		elif body.name == "Racket" and body.owner.name == receiver():
			#mingea ia contact cu racheta receptorului
			stare_curenta = stari[7]
		elif body.name == "KinematicBody" and body.owner.name == receiver():
			#mingea il atinge pe receptor pe corp
			stare_curenta = stari[5]
			$InfoPunct.set_text(receiver()+" FAULT")
		else: #mingea atinge stalpii, afara curtii sau afara terenului
			stare_curenta = stari[11]
			$InfoPunct.set_text(server+" OUT")
		
	elif stare_curenta == stari[12]:
		if body.name == "Racket" and body.owner.name == receiver():
			#mingea ia contact cu racheta receptorului, dupa ce a atins curtea lui
			stare_curenta = stari[7]
		else:
			stare_curenta = stari[5]
			if body.name == "KinematicBody" and body.owner.name == receiver():
				$InfoPunct.set_text(receiver()+" FAULT")
			else:
				$InfoPunct.set_text(server+" IN")
		
	elif stare_curenta == stari[13]:
		if body.name == "Net":
			#mingea ia contact in mod repetat cu plasa/fileul, servitorul lovind ultimul mingea
			stare_curenta = stari[13]
		elif body.name == "Ground" and is_ball_in_player_court(receiver()):
			#mingea cade in curtea receptorului, dupa ce a atins plasa
			stare_curenta = stari[12]
		elif body.name == "Racket" and body.owner.name == receiver():
			#mingea ia contact cu racheta receptorului, dupa ce a atins plasa
			stare_curenta = stari[7]
		elif body.name == "KinematicBody" and body.owner.name == receiver():
			#mingea il atinge pe receptor pe corp
			stare_curenta = stari[5]
			$InfoPunct.set_text(receiver()+" FAULT")
		else: 
			#mingea atinge altceva decat curtea receptorului, dupa ce a atins plasa
			stare_curenta = stari[11]
			$InfoPunct.set_text(server+" OUT")
	
	print("new: "+stare_curenta)
	# Daca s-a atins una dintre starile finale:
	if stare_curenta == stari[2]:
		startNewServe()
	elif stare_curenta == stari[5]:
		$Score.add_point_to(server)
		startNewServe()
	elif stare_curenta == stari[6]:
		serveChances += 1
		startNewServe()
	elif stare_curenta == stari[11]:
		$Score.add_point_to(receiver())
		startNewServe()


func is_ball_in_service_court() -> bool:
	var serviceCourt_length = SidelineAndServiceLine_intersection.x + $Ball.radius
	var serviceCourt_width = SidelineAndServiceLine_intersection.z + $Ball.radius
	var centreServiceLine_halfWidth = BaselineAndCenterMark_intersection.z + $Ball.radius
	
	#verifica ca mingea sa fie in zonele servei:
	if serviceCourt_length < abs($Ball.translation.x):
		return false
	elif serviceCourt_width < abs($Ball.translation.z):
		return false
	#verifica daca mingea se afla in zona corecta:
	if server == "PC":
		if serverZone == false:
			if $Ball.translation.x > 0 or $Ball.translation.z > centreServiceLine_halfWidth:
				return false
		if serverZone == true:
			if $Ball.translation.x > 0 or $Ball.translation.z < -centreServiceLine_halfWidth:
				return false
	elif server == "NPC":
		if serverZone == false:
			if $Ball.translation.x < 0 or $Ball.translation.z < -centreServiceLine_halfWidth:
				return false
		if serverZone == true:
			if $Ball.translation.x < 0 or $Ball.translation.z > centreServiceLine_halfWidth:
				return false
	return true 

func is_ball_in_player_court(player_name: String) -> bool:
	var court_halfLength = BaselineAndCenterMark_intersection.x + $Ball.radius
	var court_halfWidth = SidelineAndServiceLine_intersection.z + $Ball.radius
	
	if player_name == "PC":
		if $Ball.translation.x >= 0 and $Ball.translation.x <= court_halfLength:
			if $Ball.translation.z >= -court_halfWidth and $Ball.translation.z <= court_halfWidth:
				return true
	elif player_name == "NPC":
		if $Ball.translation.x >= -court_halfLength and $Ball.translation.x <= 0:
			if $Ball.translation.z >= -court_halfWidth and $Ball.translation.z <= court_halfWidth:
				return true
	return false


func receiver() -> String:
	if server == "PC":
		return "NPC"
	return "PC"
