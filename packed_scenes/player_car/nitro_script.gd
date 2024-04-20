@tool
class_name PlayerNitro extends Node

@export_category("Nitro")
@export_range(0, 100, 0.1, "suffix:%") var fuel := 100.0
@export_range(0, 1, 0.01, "or_greater", "hide_slider") var force_multiplier := 0.35
@export_range(0, 20, 0.1, "or_greater", "hide_slider", "suffix:%/s") var fuel_usage := 20.0
@export_range(0, 100, 0.1, "suffix:%") var falloff_start := 15.0

var activated := false
var replenish_cooldown := 3.0


const BASE_POWER := 50.0

@onready var parent: PlayerCar = get_parent()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	replenish_cooldown = move_toward(replenish_cooldown, 0, delta)
	if replenish_cooldown == 0:
		fuel = move_toward(fuel, 100, delta * fuel_usage * 1.3)
	
	
	if Input.is_action_pressed(parent.listen_to + "_nitro") and fuel > 0:
		activated = true
		fuel = move_toward(fuel, 0, delta * fuel_usage)
		replenish_cooldown = 3.0
		parent.apply_central_force(-parent.mesh.basis.z * get_nitro_force() * BASE_POWER)
	else:
		activated = false


func get_nitro_force() -> float:
	if not activated:
		return 0
	return clampf(fuel**2, 0, falloff_start**2) / falloff_start**2
