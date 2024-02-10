@tool
extends RigidBody3D

@export_enum("keyboard", "gamepad1", "gamepad2", "gamepad3") var listen_to: String = "keyboard"
@export_category("Car Player")
@export var acceleration := 64.0
@export var max_speed := 24.0

const STEER_ANGLE := 18.0
const TURN_SPEED := 7.5
const MESH_OFFSET := Vector3(0, -0.6, 0)


@onready var mesh: Node3D = $Mesh
@onready var mesh_parts: Array[Node] = mesh.get_children()
@onready var collision: CollisionShape3D = $Collision
@onready var ground_ray: RayCast3D = $GroundRay
@onready var abs_ground_ray: RayCast3D = $AbsoluteGroundRay
@onready var camera: Camera3D = $Camera


var ws_input := 0.0
var ad_input := 0.0

func _physics_process(_delta: float) -> void:
	mesh.global_position = global_position + MESH_OFFSET
	ground_ray.global_position = global_position
	ground_ray.rotation = mesh.rotation
	abs_ground_ray.global_position = global_position
	camera.global_position = global_position + (mesh.basis.y * 4) + (mesh.basis.z * 6.25)
	camera.rotation = Vector3(mesh.rotation.x - PI/18, mesh.rotation.y, 0)
	
	if ground_ray.is_colliding():
		apply_central_force(-mesh.basis.z * ws_input)
	linear_velocity = linear_velocity.limit_length(max_speed)
	for part in mesh_parts:
		if part.name == "Body": continue
		part.rotation.x = fmod(part.rotation.x + deg_to_rad(linear_velocity.dot(-mesh.basis.z)), 2*PI)
		if part.name.begins_with("F"):
			part.rotation.y = ad_input * 1.75

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		mesh.rotation = rotation
		return
	
	_handle_inputs()
	_particles()
	
	var new_rotation = mesh.basis.rotated(mesh.basis.y, ad_input)
	mesh.basis = mesh.basis.slerp(new_rotation, TURN_SPEED * delta)
	mesh.global_transform = mesh.global_transform.orthonormalized()
	
	if ground_ray.is_colliding():
		var ground_normal = ground_ray.get_collision_normal()
		var xform = align_with_y(ground_normal)
		mesh.global_transform = mesh.global_transform.interpolate_with(xform, 10.0 * delta)
	elif abs_ground_ray.is_colliding():
		var ground_normal = abs_ground_ray.get_collision_normal()
		var xform = align_with_y(ground_normal)
		mesh.global_transform = mesh.global_transform.interpolate_with(xform, 10.0 * delta)


func _handle_inputs() -> void:
	ws_input = Input.get_axis(listen_to + "_backward", listen_to + "_forward") * acceleration
	ad_input = move_toward(ad_input, Input.get_axis(listen_to + "_right", listen_to + "_left") * deg_to_rad(STEER_ANGLE) * (linear_velocity.dot(-mesh.basis.z) / max_speed), get_process_delta_time() * TURN_SPEED)


func align_with_y(ground_normal) -> Transform3D:
	var xform = mesh.global_transform
	xform.basis.y = ground_normal
	xform.basis.x = -xform.basis.z.cross(ground_normal)
	return xform.orthonormalized()


func _particles() -> void:
	var particles = mesh.get_node("Particles") as GPUParticles3D
	if not particles: return
	
	if not linear_velocity.is_equal_approx(Vector3.ZERO) and ws_input and ground_ray.is_colliding():
		particles.emitting = true
	else:
		particles.emitting = false
