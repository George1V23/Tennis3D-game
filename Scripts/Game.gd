extends Node


func _enter_tree():
	# When the node enters the Scene Tree, it becomes active
	# and  this function is called. Children nodes have not entered
	# the active scene yet. In general, it's better to use _ready()
	# for most cases.
	$World.get_node("Score").hide()
	$World.get_node("FPS").hide()
	$World/PC.get_node("SwingPower").hide()
	$World/PC.get_node("Info").hide()
	Engine.time_scale = 0
#	$World.set_pause_mode(true)
#	$World.set_process(false)
#	$World.set_physics_process(fals)
#	$World.set_process_input(false)
#	$World.hide()
	pass


# This function is called after _enter_tree, but it ensures
# that all children nodes have also entered the Scene Tree,
# and became active.
func _ready():
	#OS.vsync_enabled = false
	pass


func _exit_tree():
	# When the node exits the Scene Tree, this function is called.
	# Children nodes have all exited the Scene Tree at this point
	# and all became inactive.
	pass


func _process(delta):
	# This function is called every frame.
	pass


func _physics_process(delta):
	# This is called every physics frame.
	pass


func _on_Button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Menu.queue_free()
	
	var width := 1280
	var height := 720
	OS.set_window_size(Vector2(width,height))
	OS.set_window_fullscreen(true)
	
	$World.get_node("Score").show()
	$World.get_node("FPS").show()
	$World/PC.get_node("SwingPower").show()
	$World/PC.get_node("Info").show()
	Engine.time_scale = 1
#	$World.set_pause_mode(false)
#	$World.set_process(true)
#	$World.set_physics_process(true)
#	$World.set_process_input(true)
#	$World.show()


func _on_Button2_pressed():
	get_tree().quit()
