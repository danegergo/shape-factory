extends CharacterBody3D

@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@onready var hold_point: Node3D = $HoldPoint
@onready var main_scene: Node3D = $".."

@export var SPEED := 15.0

var ray_cast_hit: Node3D
var is_holding := false 

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("use"):
		ray_cast_hit = ray_cast_3d.get_collider()
		if !is_holding:
			if ray_cast_hit:
				if ray_cast_hit.collision_layer == 2:
					ray_cast_hit.reparent(hold_point)
					ray_cast_hit.position = Vector3.ZERO
					ray_cast_hit.freeze = true
					is_holding = true
				elif ray_cast_hit.collision_layer == 4:
					ray_cast_hit.get_parent().get_parent().toggle_door()
		else:
			if ray_cast_hit and ray_cast_hit is Area3D:
				print(ray_cast_hit)
			var object_held: RigidBody3D = hold_point.get_child(0)
			object_held.reparent(main_scene)
			object_held.freeze = false
			is_holding = false
			
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
