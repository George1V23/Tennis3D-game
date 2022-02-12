extends RigidBody


var picked_up : bool
var holder : KinematicBody
var last_hit_by : String


onready var radius = ($CollisionShape.shape.radius + $CollisionShape.shape.margin)*$CollisionShape.scale.x

func _ready():
	# Amortizarea velocitatii mingii pentru o miscare mai lina
	self.linear_damp = 0.1
	self.angular_damp = 0.1
	pass


func _process(delta):
	if picked_up:
		self.global_transform = holder.get_node("Skeleton/left_hand/Ball_Position3D").global_transform


func pick_up_by(character: KinematicBody):
	holder = character
	$CollisionShape.set_disabled(true)
	self.set_mode(MODE_STATIC)
	picked_up = true

func drop():
	holder = null
	$CollisionShape.set_disabled(false)
	self.set_mode(MODE_RIGID)
	picked_up = false
