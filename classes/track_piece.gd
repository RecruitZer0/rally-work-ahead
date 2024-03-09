class_name TrackPiece extends StaticBody3D

@export_category("Track Piece")
@export var attach_points: Array[TrackPoint]:
	set(value):
		attach_points = value
		if Engine.is_editor_hint():
			update_configuration_warnings()
@export var powerup_points: Array[TrackPoint]
@export var snapping := false

const SNAP_DISTANCE := 10.0

func _get_configuration_warnings():
	var warnings := PackedStringArray([])
	if attach_points.size() < 2:
		warnings.append("You must define at least 2 attach pointts.\nWithout this, the track piece won't snap to other pieces.")
	return warnings

func _enter_tree() -> void:
	self.add_to_group("TrackPieces")
	for point in attach_points: 
		point.add_to_group("AttachPoints")
	for point in powerup_points: 
		point.add_to_group("PowerUpPoints")
	

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("TrackPieces"):
		if not node.is_node_ready():
			await node.ready

func _process(_delta: float) -> void:
	if snapping:
		snap()


func snap() -> void:
	var attach_to := find_nearest_attach()
	if not attach_to:
		return
	var point := closest_point_to(attach_to.global_position)
	
	global_rotation = -(attach_to.global_rotation + point.rotation).rotated(point.basis.y, point.rotation.y)
	rotation.y += PI + (2 * attach_to.global_rotation.y)
	global_position = attach_to.global_position - (point.global_position - global_position)

func closest_point_to(pos: Vector3) -> TrackPoint:
	var points := attach_points
	points.sort_custom(func(a, b): 
			return a.global_position.distance_squared_to(pos) < b.global_position.distance_squared_to(pos) )
	return points[0]

func find_nearest_attach() -> TrackPoint:
	var all_attaches: Array[Node] = []
	for node in get_tree().get_nodes_in_group("AttachPoints"):
		if not node in attach_points and not node.get_parent().snapping:
			all_attaches.append(node)
	if all_attaches.size() == 0:
		return null
	
	for point in attach_points:
		all_attaches.sort_custom(func(a, b): 
			return point.global_position.distance_squared_to(a.global_position) < point.global_position.distance_squared_to(b.global_position) )
		if point.global_position.distance_to(all_attaches[0].global_position) < SNAP_DISTANCE:
			return all_attaches[0]
	return null
