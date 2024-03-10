extends Label

@export var car: RigidBody3D
@onready var nitro: Node = car.get_node("Nitro")

func _process(_delta: float) -> void:
	text = "
	Position: %s
	Velocity: %s
	Speed: %s
	Speed Limit: %s
	Nitro Fuel: %s
	Nitro cooldown: %s
	" % \
	[car.global_position,
	car.linear_velocity,
	car.linear_velocity.dot(-car.mesh.basis.z),
	car.speed_limit,
	nitro.fuel,
	nitro.replenish_cooldown
	]
