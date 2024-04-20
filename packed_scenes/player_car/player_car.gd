@tool
class_name PlayerCar extends RigidBody3D

@export_enum("keyboard", "gamepad1", "gamepad2", "gamepad3") var listen_to: String = "keyboard"
@export_category("Car Player")
@export var acceleration := 56.0
@export var max_speed := 32.0

const STEER_ANGLE := 18.0
const TURN_SPEED := 6.0
const MESH_OFFSET := Vector3(0, -0.6, 0)


@onready var mesh: Node3D = $Mesh
@onready var mesh_parts: Array[Node] = mesh.get_children()
@onready var collision: CollisionShape3D = $Collision
@onready var camera: PlayerCamera = $Camera
@onready var ground_ray: RayCast3D = $GroundRay
@onready var abs_ground_ray: RayCast3D = $AbsoluteGroundRay
@onready var nitro: PlayerNitro = $Nitro
@onready var powerup: PlayerPower = $Power


var ws_input := 0.0
var ad_input := 0.0
@onready var speed_limit := 0.0

func _physics_process(delta: float) -> void:
	if ground_ray.is_colliding():
		apply_central_force(-mesh.basis.z * ws_input * acceleration)
	
	
	speed_limit = move_toward(speed_limit, max_speed + (max_speed * nitro.get_nitro_force() * nitro.force_multiplier), acceleration * delta)
	linear_velocity = linear_velocity.limit_length(speed_limit)
	
	
	for part in mesh_parts:
		if part.name == "Body": continue
		part.rotation.x = fmod(part.rotation.x + deg_to_rad(linear_velocity.dot(mesh.basis.z)), 2*PI)
		if part.name.begins_with("F"):
			part.rotation.y = ad_input * deg_to_rad(STEER_ANGLE) * 2

func _process(delta: float) -> void:
	_children_positions()
	if Engine.is_editor_hint():
		mesh.rotation = rotation
		return
	
	_handle_inputs()
	_handle_particles()
	
	#print(linear_velocity.dot(-mesh.basis.z))
	#print(speed_limit)
	
	var new_rotation = mesh.basis.rotated(mesh.global_basis.y, ad_input * deg_to_rad(STEER_ANGLE))
	mesh.basis = mesh.basis.slerp(new_rotation, TURN_SPEED * delta)
	mesh.global_transform = mesh.global_transform.orthonormalized()
	
	_align_mesh_to_ground(delta)


func _handle_inputs() -> void:
	ws_input = Input.get_axis(listen_to + "_backward", listen_to + "_forward")
	ad_input = move_toward(ad_input, Input.get_axis(listen_to + "_right", listen_to + "_left") * clampf(linear_velocity.dot(-mesh.basis.z) / max_speed, -1, 1), 10 * get_process_delta_time())

func _children_positions() -> void:
	mesh.global_position = global_position + MESH_OFFSET
	ground_ray.global_position = global_position
	ground_ray.rotation = mesh.rotation
	abs_ground_ray.global_position = global_position
	camera.global_position = global_position
	camera.rotation = mesh.rotation

func _align_mesh_to_ground(delta: float) -> void:
	var ground_normal: Vector3
	if ground_ray.is_colliding():
		ground_normal = ground_ray.get_collision_normal()
	elif abs_ground_ray.is_colliding():
		ground_normal = abs_ground_ray.get_collision_normal()
	else:
		return
	var xform := mesh.global_transform
	
	xform.basis.y = ground_normal
	xform.basis.x = -xform.basis.z.cross(ground_normal)
	xform = xform.orthonormalized()
	
	mesh.global_transform = mesh.global_transform.interpolate_with(xform, 10.0 * delta)


func _handle_particles() -> void:
	var particles = mesh.get_node("Particles") as GPUParticles3D
	if not particles: return
	
	if not linear_velocity.is_equal_approx(Vector3.ZERO) and ws_input > 0 and ground_ray.is_colliding():
		particles.emitting = true
	else:
		particles.emitting = false
