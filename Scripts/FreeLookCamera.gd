extends Camera

var sensitivity = 300
var move_speed = 0.1

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass

func _input(event):
	if event is InputEventMouseMotion:
		mouse_look(event)
	elif event is InputEventMouseButton:
		zoom(event)
	elif event is InputEventKey:
		move(event)
	pass

func mouse_look(event):
	var left_right = clamp(event.relative.x/sensitivity, -PI/2, PI/2)
	var up_down = clamp(event.relative.y/sensitivity, -PI/2, PI/2)
	rotate_y(-left_right)
	rotate_object_local(Vector3(1,0,0), -up_down)
	pass

func zoom(event):
	var scroll = event.factor
	if event.button_index == BUTTON_WHEEL_DOWN:
		translate_object_local(Vector3(0,0,scroll))
	elif event.button_index == BUTTON_WHEEL_UP:
		translate_object_local(Vector3(0,0,-scroll))
	pass

func move(event):
	if Input.is_key_pressed(KEY_UP):
		translate_object_local(Vector3(0,move_speed,0))
	if Input.is_key_pressed(KEY_DOWN):
		translate_object_local(Vector3(0,-move_speed,0))
	if Input.is_key_pressed(KEY_LEFT):
		translate_object_local(Vector3(-move_speed,0,0))
	if Input.is_key_pressed(KEY_RIGHT):
		translate_object_local(Vector3(move_speed,0,0))
	pass
