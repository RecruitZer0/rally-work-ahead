class_name PowerUp extends Script



static func action(parent: PlayerCar) -> void:
	parent.powerup.consume_power()
	parent.powerup.using_power = false
