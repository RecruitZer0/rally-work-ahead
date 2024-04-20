class_name PlayerPower extends Node

@export_category("Power")
@export var active_power: PowerData.Powers
@export var stored_power: PowerData.Powers
@export var using_power := false

@onready var parent: PlayerCar = get_parent()

signal consumed_power(player: PlayerCar, power: int)

func consume_power():
	var used_power := active_power
	active_power = stored_power
	stored_power = PowerData.Powers.None
	emit_signal("consumed_power", get_parent(), used_power)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(parent.listen_to + "_power") and not using_power:
		PowerData.power_classes[active_power].call("action", parent)
