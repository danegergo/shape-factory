extends CharacterBody3D
class_name Player

@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@onready var hold_point: Node3D = $HoldPoint
@onready var main_scene: Node3D = $".."

@export var SPEED := 15.0

var ray_cast_hit: Node3D
var item_currently_held: Item
var is_using_lever := false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("use"):
		handle_use_action()
	elif Input.is_action_just_released("use"):
		is_using_lever = false
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_using_lever:
		handle_lever_pull(delta)

	set_player_velocity()
	move_and_slide()
	
func set_player_velocity() -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func handle_use_action() -> void:
	ray_cast_hit = ray_cast_3d.get_collider()
	if !item_currently_held:
		perform_action()
	else:
		drop_item()

func perform_action():
	if ray_cast_hit:
		if ray_cast_hit.collision_layer == 2:
			# Pick up item
			ray_cast_hit.move_to_node(hold_point, true)
			item_currently_held = ray_cast_hit
			ray_cast_3d.add_exception(item_currently_held)
		elif ray_cast_hit.collision_layer == 4:
			# Open fabricator door
			ray_cast_hit.owner.open_door()
		elif ray_cast_hit.collision_layer == 8:
			# Start pulling lever
			if ray_cast_hit.owner.is_open:
				is_using_lever = true

func drop_item() -> void:
	if ray_cast_hit and ray_cast_hit.collision_layer == 35 and ray_cast_hit.is_open: # if fabricator clicked
		item_currently_held.move_to_node(ray_cast_hit.find_child("ItemPlacePoint"))
	else:
		item_currently_held.drop_item()
	ray_cast_3d.remove_exception(item_currently_held)
	item_currently_held = null

func handle_lever_pull(delta: float) -> void:
	var rotation_angle := -Input.get_last_mouse_velocity().y / 100 * delta
	var final_lever_rotation_z := ray_cast_hit.rotation_degrees.z + rad_to_deg(rotation_angle)
	if final_lever_rotation_z >= -70 and final_lever_rotation_z <= 0.001:
		ray_cast_hit.rotate_z(rotation_angle)
	elif final_lever_rotation_z < -70:
		ray_cast_hit.owner.fabricate()
