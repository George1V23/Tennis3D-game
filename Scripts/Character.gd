extends KinematicBody

#constante
const FLOOR_NORMAL = Vector3(0, 1, 0)
const MAX_MOTION = 20
const MAX_SWING_TIMING = 10
enum MoveState {IDLE, WALK, RUN}

#variabilele pentru miscare
var direction := Vector3()
var moveState = MoveState.IDLE 
var motion := 0
var speed := 0.0

#variabile pentru lovirea mingii
var ball_inArea := false
var swing_timing := 0.0
var aim_target := Vector3()

#variabilele pentru serva
var need_to_serve := false
var can_serve := false
var serving := false


onready var Animator = $AnimationPlayer/AnimationTree
onready var Ball = get_node("../Ball")
#onready var TrackingBallShape = $TrackingBall_Area/CollisionShape
onready var def_rot_y = self.rotation.y


func _process(delta):
	if serving:
		animate_serve()
	else:
		animate_movement()

func _physics_process(delta):
#	$TrackingBall_Area.global_transform.origin = $Skeleton/right_shoulder.global_transform.origin
#	if Ball.translation.z > $Racket.get_node("StringsCollisionShape").global_transform.origin.z:
#		$Skeleton/right_hand/Grab_Position3D.rotate_y(-delta)
#	else:
#		$Skeleton/right_hand/Grab_Position3D.rotate_y(delta)
	$Racket.global_transform = $Skeleton/right_hand/Grab_Position3D/Racket_Position3D.global_transform
	# Pentru serva:
	if serving == true and Ball.picked_up == false and swing_timing > 0:
		# In timpul executarii miscarii de lovire la serva, se va roti racheta 
		#spre minge pana la un anumit unghi, ca sa aibe loc detectia coliziunii
		if $Skeleton/right_hand/Grab_Position3D.rotation_degrees.y > 0:
			$Skeleton/right_hand/Grab_Position3D.rotate_y(PI/8)
		$Racket.serve_ball = true
	else:
		$Racket.serve_ball = false


func animate_movement():
	self.rotation.y = def_rot_y
	
	if moveState == MoveState.IDLE:
		if motion > 0:
			motion -= 1
	elif moveState == MoveState.WALK:
		if motion < MAX_MOTION/2:
			motion += 1
		elif motion > MAX_MOTION/2:
			motion -= 1
	elif moveState == MoveState.RUN:
		if motion != MAX_MOTION:
			motion += 1
	
	var orientation_sign = sin(def_rot_y)
	if motion > MAX_MOTION/2:
		# Intoarcerea caracterului cu 180 de grade pt alergarea in sensul opus
		if direction.x*orientation_sign < 0:
			self.rotate_y(PI)
		# Intoarcerea caracterului cu 45 de grade pt alergarea in diagonala:
		if direction.z*orientation_sign < 0:
			self.rotate_y(PI/4*orientation_sign*sin(self.rotation.y))
		elif direction.z*orientation_sign > 0:
			self.rotate_y(-PI/4*orientation_sign*sin(self.rotation.y))
	
	var blend_amount = (2.0/MAX_MOTION)*motion - 1
	if sin(def_rot_y)*direction.x < 0 and motion <= MAX_MOTION/2: #mersul cu spatele(cand nu sprinteaza)
		#daca directia e in diagonala
		if direction.z < 0:
			self.rotate_y(-PI/4*sin(self.rotation.y))
		elif direction.z > 0:
			self.rotate_y(PI/4*sin(self.rotation.y))
		
		if Animator.get("parameters/Swing/active") == false:
			Animator.set("parameters/IdleWalkRun/blend_amount", -1)
			$AnimationPlayer.play_backwards("Walk")
			Animator.active = false
		else: #Cazul in care se executa lovirea mingii se opreste mersul cu spatele.
			motion = 0
			moveState = MoveState.IDLE
	elif direction.z != 0 and motion <= MAX_MOTION/2: #mersul in lateral
		if Ball.holder != null: #dupa servire (in timpul disputei punctului)
			self.rotate_y(sign(direction.z)*PI/2)
			if direction.x != 0:
				self.rotate_y(sign(direction.x)*sign(direction.z)*PI/4)
			Animator.set("parameters/IdleWalkRun/blend_amount", blend_amount)
			Animator.set("parameters/JoggingSwitch/active", false)
		else:
			if direction.z*orientation_sign < 0: #pt partea stanga e nevoie de o mica rotatie
				self.rotate_y(PI/8)
			Animator.set("parameters/Jogging/Add2/add_amount", motion*1.0/MAX_MOTION)
			Animator.set("parameters/JoggingSwitch/active", true)
		Animator.active = true
	else: #miscarea normala sau stationarea
		Animator.set("parameters/IdleWalkRun/blend_amount", blend_amount)
		if Ball.holder == null and motion > 9 and motion <= 10:
			Animator.set("parameters/Jogging/Add2/add_amount", 1.0)
			Animator.set("parameters/JoggingSwitch/active", true)
		else:
			Animator.set("parameters/JoggingSwitch/active", false)
		Animator.active = true
	
	if motion <= 10:
		if Ball.holder == null:
			$AnimationPlayer.playback_speed = 1.5
			speed = motion
		else:
			$AnimationPlayer.playback_speed = 1
			speed = motion*motion/MAX_MOTION
	else:
		speed = motion
		if speed > 15:
			speed = 15

func animate_serve():
	# Daca e in miscare sau se uita in directia gresita nu trebuie sa serveasca.
	if moveState != MoveState.IDLE or self.rotation.y != def_rot_y:
		serving = false
		return
	
	if need_to_serve == true:
		Animator.active = false
		$AnimationPlayer.play("Serve")
	
	# aruncarea mingii:
	if Ball.picked_up and $AnimationPlayer.current_animation_position > 2:
		Ball.drop()
		Ball.translate(Vector3(0, 4, 0))
	
	#terminarea animatiei:
	if $AnimationPlayer.current_animation_position > 2.8:
		serving = false #serving animation finished
		#move body approximately where body is in animation end:
		self.translation.x += 3*sin(def_rot_y)
	
	need_to_serve = false
	can_serve = false


func animate_swing(var type, var seek_position, var time_scale):
#	if swing_timing > 0 and ball_inArea:
#		var hit_type
#		var seek_position
#		var time_scale
#		var side_dist = TrackingBallShape.global_transform.origin.z - Ball.global_transform.origin.z
#		if side_dist >= 0:
#			hit_type = sin(def_rot_y)
#			seek_position = 1
#			time_scale = 1.5
#		else:
#			hit_type = -sin(def_rot_y)
#			seek_position = 0.7
#			time_scale = 1.5
			
	Animator.active = true
	if Animator.get("parameters/Swing/active") == false:
		Animator.set("parameters/BackhandForehand/blend_position", type)
		Animator.set("parameters/SwingSeek/seek_position", seek_position)
		Animator.set("parameters/SwingTimeScale/scale", time_scale)
		Animator.set("parameters/Swing/active", true)
#	else:
#		Animator.set("parameters/Swing/active", false)


#func _on_TrackingBall_Area_body_entered(body):
#	if(body.name == "Ball"):
#		ball_inArea = true
#
#		print("\nENTERED Tracking "+str(def_rot_y))
#
#func _on_TrackingBall_Area_body_exited(body):
#	if(body.name == "Ball"):
#		print("EXITED Tracking")
##		hit_type = sin(def_rot_y)
##		seek_position = 1
##		ball_inArea = false
