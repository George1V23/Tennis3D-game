extends Spatial


onready var init_transform = self.transform
onready var init_rot = $CardanInt.rotation
onready var init_zoom = $CardanInt/Camera.fov


func _process(delta):
	if get_parent().pauza_meniu == true:
		control_camera(10.0/Engine.get_frames_per_second())
		#previne rasturnarea camerei video cu susul in jos:
		$CardanInt.rotation.x = clamp($CardanInt.rotation.x, 0, PI*3/4)

#func _on_pause_pressed():
#	get_node("pause_popup").set_exclusive(true)
#	get_node("pause_popup").popup()
#	get_tree().set_pause(true)
#
#func _on_unpause_pressed():
#	get_node("pause_popup").hide()
#	get_tree().set_pause(false)

# proprietati pozitionare in inaltime cardan
var h = 20
var h_min = 0.1
var h_max = 25
var v_h = 0.4 #viteza

# limitele pentru deplasarea cardanului camerei
onready var limita_x = get_node("../Field").get_node("Edge/NorthWall").translation.x
onready var limita_y = get_node("../Field").get_node("Edge/Ceiling").translation.y
onready var limita_z = get_node("../Field").get_node("Edge/EastWall").translation.z

func control_camera(var unitate: float):
	# Inalta sau coboara cardanul.
	var translatie = Vector3()
	if Input.is_key_pressed(KEY_UP) and h+v_h*unitate <= h_max:
		h += v_h*unitate
		self.translation.y = h
	if Input.is_key_pressed(KEY_DOWN) and h-v_h*unitate >= h_min:
		h -= v_h*unitate
		self.translation.y = h
		
	# Roteste cardanul exterior in jurul axei Y.
	var rotatie_y = 0
	if Input.is_key_pressed(KEY_RIGHT):
		rotatie_y += PI/12
	if Input.is_key_pressed(KEY_LEFT):
		rotatie_y += -PI/12
	rotate_object_local(Vector3.UP, rotatie_y*unitate)
	
	# Face posibila translatarea cardanului prin interiorul arenei in functie 
	# de directia cadrului camerei:
	translatie = Vector3()
	if Input.is_key_pressed(KEY_W):
		translatie.z -= 1*unitate
	if Input.is_key_pressed(KEY_S):
		translatie.z += 1*unitate
	if Input.is_key_pressed(KEY_A):
		translatie.x -= 1*unitate
	if Input.is_key_pressed(KEY_D):
		translatie.x += 1*unitate
	$CardanInt/Camera.translate(translatie)
	self.global_transform.origin = $CardanInt/Camera.global_transform.origin
	self.global_transform.origin.x = clamp(self.global_transform.origin.x, -limita_x, limita_x)
	self.global_transform.origin.y = clamp(self.global_transform.origin.y, 0.1, limita_y)
	self.global_transform.origin.z = clamp(self.global_transform.origin.z, -limita_z, limita_z)
	$CardanInt/Camera.translation = Vector3()


# proprietati mouse
var senzitivitate_mouse: float = 0.005
var inverseaza_x = false
var inverseaza_y = false

# proprietati zoom camera
var zoom = 120
var zoom_min = 1
var zoom_max = 120
var v_zoom = 1

func _unhandled_input(event):
	if get_parent().pauza_meniu == false:
		return
	
	if event is InputEventMouseMotion:
		# Roteste cardanul exterior in jurul axei Y.
		if event.relative.x != 0:
			var dir = 1 if inverseaza_x else -1
			rotate_object_local(Vector3.UP, dir*event.relative.x*senzitivitate_mouse)
		# Roteste cardanul interior in jurul axei X.
		if event.relative.y != 0:
			var dir = 1 if inverseaza_y else -1
			$CardanInt.rotate_object_local(Vector3.RIGHT, dir*event.relative.y*senzitivitate_mouse)
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoom -= v_zoom
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom += v_zoom
		zoom = clamp(zoom, zoom_min, zoom_max)
		$CardanInt/Camera.fov = lerp($CardanInt/Camera.fov, zoom, v_zoom)


# Readuce cardanele si camera la transformarile initiale
func resetare_pozitie():
	self.transform = init_transform
	$CardanInt.rotation = init_rot
	$CardanInt/Camera.fov = init_zoom
