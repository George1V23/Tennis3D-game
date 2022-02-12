extends "Character.gd"


func _process(delta):
	if not serving:
		move(delta)
	aim(delta)
	
	if need_to_serve:
		serve()
	swing(delta*30)


func move(d: float):
	var up = Input.is_action_pressed("forward")
	var down = Input.is_action_pressed("back")
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
	
	if up and not down:
		direction.x = -d
	elif down and not up:
		direction.x = d
	else: 
		direction.x = 0
	
	if left and not right:
		direction.z = d
	elif right and not left:
		direction.z = -d
	else: 
		direction.z = 0
	
	if direction.x != 0 or direction.z != 0:
		if Input.is_action_pressed("sprint"):
			moveState = MoveState.RUN
		else: 
			moveState = MoveState.WALK
	else:
		moveState = MoveState.IDLE
	
	if motion > 0:
		move_and_slide(direction.normalized()*speed, FLOOR_NORMAL)


var v_tinta := 0.0
func aim(var d: float):
	if v_tinta < 1:
		v_tinta += d
	
	if Ball.last_hit_by == "PC":
		get_parent().get_node("PC_AimTarget").visible = false
		return
	elif not get_parent().get_node("PC_AimTarget").visible:
		get_parent().get_node("PC_AimTarget").visible = true
		get_parent().get_node("PC_AimTarget").translation.x = -15
		get_parent().get_node("PC_AimTarget").translation.z = 0
		aim_target = get_parent().get_node("PC_AimTarget").translation
	
	var key_pressed = false
	var direction := Vector3.ZERO
	if Input.is_key_pressed(KEY_UP):
		direction += Vector3(-1,0,0)
		key_pressed = true
	if Input.is_key_pressed(KEY_DOWN):
		direction += Vector3(1,0,0)
		key_pressed = true
	if Input.is_key_pressed(KEY_LEFT):
		direction += Vector3(0,0,1)
		key_pressed = true
	if Input.is_key_pressed(KEY_RIGHT):
		direction += Vector3(0,0,-1)
		key_pressed = true
	
	if key_pressed:
		aim_target += direction.normalized()*v_tinta
	else:
		v_tinta = 0
	
	get_parent().get_node("PC_AimTarget").translation.x = aim_target.x
	get_parent().get_node("PC_AimTarget").translation.z = aim_target.z


func serve():
	if Input.is_action_just_pressed("swing"):
		if can_serve:
			$Info.set_text("")
			serving = true
		else:
			$Info.set_text("Jucatorul n-are voie sa serveasca din afara zonei corespunzatoare!")


func swing(var speed: float):
	# La servire face ca jucatorul sa fie nevoit sa mai apese pe tasta "space"
	#pentru lovirea mingii, dupa ce anterior a apasat-o ca PC-ul sa inceapa 
	#ridicarea mingii si miscarea pentru serva.
	if need_to_serve:
		$SwingPower.value = 0
		swing_timing = 0
		Input.action_release("swing")
		return
	
	if Input.is_action_just_pressed("swing"):
		swing_timing = 0.01
	if Input.is_action_pressed("swing"):
		swing_timing += speed
		# se termina timpul de pendulare al rachetei:
		if swing_timing >= MAX_SWING_TIMING: 
			Input.action_release("swing")
	elif Input.is_action_just_released("swing"):
		pass
	
	$SwingPower.value = swing_timing*swing_timing
