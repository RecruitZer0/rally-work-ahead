extends HBoxContainer

@export var player: PlayerCar
@onready var active: OptionButton = $ActivePower
@onready var stored: OptionButton = $StoredPower

func _ready() -> void:
	for item in PowerData.Powers:
		active.add_item(item)
		stored.add_item(item)
	player.powerup.connect("consumed_power", _update_values)

func _change_active(index: int) -> void:
	player.powerup.active_power = index

func _change_stored(index: int) -> void:
	player.powerup.stored_power = index

func _update_values(_player: PlayerCar, _power: int):
	active.select(player.powerup.active_power)
	stored.select(player.powerup.stored_power)
