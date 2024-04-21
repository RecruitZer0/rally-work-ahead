class_name PlayerCamera extends Node3D

@export_category("Car Camera")
@export var default_position := Vector3(0, 3, 7.5)

@onready var root := get_parent() as RigidBody3D
@onready var camera: Camera3D = $Camera
var desired_position := Vector3.ZERO
var desired_rotation := 0.0


func _process(_delta: float) -> void:
	desired_position = default_position
	desired_position.z += root.linear_velocity.dot(root.mesh.basis.z) / 20
	desired_position.x += root.linear_velocity.dot(root.mesh.basis.x) / 12
	desired_position.y -= root.linear_velocity.dot(root.mesh.basis.y) / 20
	desired_rotation = -atan2(desired_position.z, desired_position.x) + PI/2
	
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	tween.tween_property(camera, "position", desired_position, 0.05)
	tween.tween_property(camera, "rotation:y", desired_rotation, 0.05)
