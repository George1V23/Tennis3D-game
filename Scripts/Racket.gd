extends RigidBody


var serve_ball := false
var hit_power := 0.0

onready var net_height: float = get_node("../../Field/Landmarks/Net_topEdge").translation.y 

func _on_Area_body_entered(body):
	if body.name == "Ball" and serve_ball == true:
		hit_power = get_parent().swing_timing
		print("SERVE: "+str(hit_power))
		
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		
		var ball_origin = body.get_global_transform().origin
		var dist = get_parent().aim_target-ball_origin
		dist.y += net_height 
		var impulse = dist.normalized()*hit_power/2
		body.apply_central_impulse(impulse)
		
		body.last_hit_by = get_parent().name
		body.emit_signal("body_entered", self)
		print("---> "+str(body.last_hit_by)) 
		
		# Porneste sunetul de lovire a mingii:
		body.get_node("ServeAudio").unit_db = -sound_distance(body)/10
		body.get_node("ServeAudio").play()
		
		serve_ball = false
		get_parent().swing_timing = 0.0
		hit_power = 0


func _on_LeftArea_body_entered(body):
	if body.name == "Ball" and get_parent().swing_timing > 0.1:
		hit_power = get_parent().swing_timing
		print("ENTER BODY: "+str(hit_power))
		
		get_parent().animate_swing(-1, 0.6, 2)
		
		get_parent().get_node("Skeleton/right_hand/Grab_Position3D").look_at(body.translation, Vector3.UP)
		get_parent().get_node("Skeleton/right_hand/Grab_Position3D").rotate_y(-90)
		
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		
		var ball_origin = body.get_global_transform().origin
		var dir = get_parent().aim_target-ball_origin
		var dist = ball_origin.distance_to(get_parent().aim_target)
		var opposite = abs(dir.z)*abs(ball_origin.x)/abs(dir.x)
		var hypotenuse = sqrt(ball_origin.x*ball_origin.x + opposite*opposite)
		dir.y = net_height-ball_origin.y + hypotenuse/hit_power
		dir = dir.normalized()
		dir.x /= 1.1
		dir.y *= 1.3
		dir.z /= 1.1
		var impulse = dir*hit_power/3
		print(impulse)
		body.apply_central_impulse(impulse)
		
		body.last_hit_by = get_parent().name
		body.emit_signal("body_entered", self)
		print("---> "+str(body.last_hit_by))
		
		# Porneste sunetul de lovire a mingii:
		body.get_node("BackhandAudio").unit_db = -sound_distance(body)/10
		body.get_node("BackhandAudio").play()
		
		get_parent().swing_timing = 0.0
		hit_power = 0

func _on_RightArea_body_entered(body):
	if body.name == "Ball" and get_parent().swing_timing > 0.1:
		hit_power = get_parent().swing_timing
		print("ENTER BODY: "+str(hit_power))
		
		get_parent().animate_swing(1, 1.2, 1.5)
		
		get_parent().get_node("Skeleton/right_hand/Grab_Position3D").look_at(body.translation, Vector3.UP)
		get_parent().get_node("Skeleton/right_hand/Grab_Position3D").rotate_y(90)
		
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		
		var ball_origin = body.get_global_transform().origin
		var dir = get_parent().aim_target-ball_origin
		var dist = ball_origin.distance_to(get_parent().aim_target)
		var opposite = abs(dir.z)*abs(ball_origin.x)/abs(dir.x)
		var hypotenuse = sqrt(ball_origin.x*ball_origin.x + opposite*opposite)
		dir.y = net_height-ball_origin.y + hypotenuse/hit_power
		dir = dir.normalized()
		dir.x /= 1.1
		dir.y *= 1.3
		dir.z /= 1.1
		var impulse = dir*hit_power/3
		print(impulse)
		body.apply_central_impulse(impulse)
		
		body.last_hit_by = get_parent().name
		body.emit_signal("body_entered", self)
		print("---> "+str(body.last_hit_by))
		
		# Porneste sunetul de lovire a mingii:
		body.get_node("ForehandAudio").unit_db = -sound_distance(body)/10
		body.get_node("ForehandAudio").play()
		
		get_parent().swing_timing = 0.0
		hit_power = 0

onready var init_transform = get_parent().get_node("Skeleton/right_hand/Grab_Position3D").transform
func _on_Area_body_exited(body):
	get_parent().get_node("Skeleton/right_hand/Grab_Position3D").transform = init_transform


# Functia calculeaza distanta dintre pozitia camerei si minge pentru a ajusta
#intensitatea sunetului in functie de distanta din care vedem impactul.
func sound_distance(var body) -> float:
	var camera = get_parent().get_parent().get_node("Camera")
	var dir: Vector3 = body.global_transform.origin-camera.global_transform.origin
	var dist: float = sqrt(dir.x*dir.x + dir.y*dir.y + dir.z*dir.z)
	return dist
