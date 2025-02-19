extends RigidBody3D

@onready var main_scene: Node3D = $".."

var is_picked_up := false
var target_node: Node3D

func _physics_process(delta: float) -> void:
	if target_node:
		if self.global_position.distance_squared_to(target_node.global_position) > 0.31:
			self.global_position = self.global_position.lerp(target_node.global_position, 0.1)
		elif !is_picked_up:
			self.reparent(target_node)
			target_node = null

func move_to_node(target_node: Node3D, is_pick_up := false) -> void:
	self.freeze = true
	self.target_node = target_node
	is_picked_up = is_pick_up

func drop_item():
	self.reparent(main_scene)
	self.freeze = false
	is_picked_up = false
	target_node = null
