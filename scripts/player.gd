extends CharacterBody3D
class_name Player

@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@onready var hold_point: Node3D = $HoldPoint
@onready var main_scene: Node3D = $".."
@onready var sprint_bar: ProgressBar = %SprintBar
@onready var timer: Timer = $Timer

@export var SPEED := 15.0
@export var SPINT_USE_RATE := 0.5
@export var SPINT_RECHARGE_RATE := 0.5

var ray_cast_hit: Node3D
var item_currently_held: Item
var last_item_looked_at: Item
var is_using_lever := false

func _process(delta: float) -> void:
	var ray_cast_hit = ray_cast_3d.get_collider()
	if ray_cast_hit and ray_cast_hit.collision_layer == 2:
		ray_cast_hit.highlight()
		last_item_looked_at = ray_cast_hit
	elif last_item_looked_at:
		last_item_looked_at.un_highlight()
		last_item_looked_at = null
		
		
	if Input.is_action_just_pressed("use"):
		handle_use_action()
	elif Input.is_action_just_released("use"):
		is_using_lever = false
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		self.velocity += get_gravity() * delta
		
	if is_using_lever and ray_cast_hit:
		handle_lever_pull(delta)

	set_player_velocity()
	handle_sprint_cooldown()
	move_and_slide()
	
func set_player_velocity() -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var sprint_multiplier := 1.5 if (int(Input.is_action_pressed("sprint")) * int(sprint_bar.value > 0)) else 1.0
	if direction:
		self.velocity.x = direction.x * sprint_multiplier * SPEED
		self.velocity.z = direction.z * sprint_multiplier * SPEED
	else:
		self.velocity.x = move_toward(velocity.x, 0, SPEED)
		self.velocity.z = move_toward(velocity.z, 0, SPEED)
	
func handle_sprint_cooldown() -> void:
	if Input.is_action_pressed("sprint") and sprint_bar.value > 0 and self.velocity != Vector3.ZERO:
		sprint_bar.visible = true
		sprint_bar.value -= SPINT_USE_RATE
		timer.start()
	elif sprint_bar.value < 100 and timer.is_stopped():
		sprint_bar.value += SPINT_RECHARGE_RATE
	elif sprint_bar.value >= 100:
		sprint_bar.visible = false

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
	if ray_cast_hit and ray_cast_hit.collision_layer == 35 and ray_cast_hit.is_open:
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
