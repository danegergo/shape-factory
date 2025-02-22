extends RigidBody3D
class_name Item

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var box_outline: MeshInstance3D = $MeshInstance3D/BoxOutline
@onready var prism_outline: MeshInstance3D = $MeshInstance3D/PrismOutline
@onready var cylinder_outline: MeshInstance3D = $MeshInstance3D/CylinderOutline

var is_picked_up := false
var is_highlighted := false
var conveyor_count := 0
var conveyor_direction: Vector3
var target_node: Node3D
var shape: String
var color: String

func _physics_process(delta: float) -> void:
	if conveyor_count:
		self.global_translate(conveyor_direction * delta)
	
	if target_node:
		if self.global_position.distance_squared_to(target_node.global_position) > 0.0001:
			self.global_position = self.global_position.lerp(target_node.global_position, 0.1)
		elif !is_picked_up:
			self.gravity_scale = 1
			target_node = null

func move_to_node(target_node: Node3D, is_pick_up := false) -> void:
	self.gravity_scale = 0
	self.target_node = target_node
	is_picked_up = is_pick_up

func drop_item() -> void:
	self.gravity_scale = 1
	is_picked_up = false
	target_node = null

func highlight() -> void:
	if is_highlighted or is_picked_up:
		return
		
	if mesh_instance_3d.mesh is BoxMesh:
		box_outline.visible = true
	elif mesh_instance_3d.mesh is PrismMesh:
		prism_outline.visible = true
	elif mesh_instance_3d.mesh is TubeTrailMesh:
		cylinder_outline.visible = true
	is_highlighted = true
		
func un_highlight() -> void:
	if !is_highlighted:
		return
		
	if mesh_instance_3d.mesh is BoxMesh:
		box_outline.visible = false
	elif mesh_instance_3d.mesh is PrismMesh:
		prism_outline.visible = false
	elif mesh_instance_3d.mesh is TubeTrailMesh:
		cylinder_outline.visible = false
	is_highlighted = false
