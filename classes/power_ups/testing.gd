extends PowerUp



static func action(parent: PlayerCar) -> void:
	parent.powerup.using_power = true
	parent.linear_velocity.y += 100
	super(parent)
