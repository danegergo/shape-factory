extends Node3D

@export var MIN_SPAWN_DELAY := 5.0
@export var MAX_SPAWN_DELAY := 10.0

@onready var spawn_point_1: Node3D = $ItemSpawnPoints/SpawnPoint1
@onready var spawn_point_2: Node3D = $ItemSpawnPoints/SpawnPoint2
@onready var spawn_timer_1: Timer = $ItemSpawnPoints/SpawnPoint1/SpawnTimer1
@onready var spawn_timer_2: Timer = $ItemSpawnPoints/SpawnPoint2/SpawnTimer2
@onready var expected_item_display_1: MeshInstance3D = $Walls/CSGBox3D5/CSGBox3D3/CSGBox3D4/ExpectedItemDisplay1
@onready var expected_item_display_2: MeshInstance3D = $Walls/CSGBox3D5/CSGBox3D5/CSGBox3D4/ExpectedItemDisplay2
@onready var expected_item_display_1_small: MeshInstance3D = $Walls/CSGBox3D5/CSGBox3D3/CSGBox3D4/ExpectedItemDisplay1Small
@onready var expected_item_display_2_small: MeshInstance3D = $Walls/CSGBox3D5/CSGBox3D5/CSGBox3D4/ExpectedItemDisplay2Small
@onready var items: Node3D = $Items
@onready var score: RichTextLabel = $UI/Score
@onready var game_over: RichTextLabel = $UI/GameOver
@onready var player_ui: Control = $Player/UI

const item_scene: PackedScene = preload("res://item/item.tscn")

const ITEM_COLORS := [
	"#4287f5",	#blue
	"#f54254",	#red
	"#42f557"	#green
]

const ITEM_SHAPES = [ "BoxMesh", "PrismMesh", "TubeTrailMesh" ]

var item_queue := []
var items_delivered: int = 0

func _on_spawn_timer_timeout() -> void:
	spawn_item(spawn_point_1)
	spawn_timer_1.wait_time = randf_range(MIN_SPAWN_DELAY, MAX_SPAWN_DELAY)
	
func _on_spawn_timer_2_timeout() -> void:
	spawn_item(spawn_point_2)
	spawn_timer_2.wait_time = randf_range(MIN_SPAWN_DELAY, MAX_SPAWN_DELAY)
	
func _on_id_1_body_entered(item: Item) -> void:
	process_arrived_item(expected_item_display_1, expected_item_display_1_small, item) 

func _on_id_2_body_entered(item: Item) -> void:
	process_arrived_item(expected_item_display_2, expected_item_display_2_small, item)

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func spawn_item(spawn_point: Node3D) -> void:
	var new_item: Item = item_scene.instantiate()
	var new_item_mesh_instance: MeshInstance3D = new_item.find_child("MeshInstance3D")
	
	var item_color = ITEM_COLORS.pick_random()
	new_item.color = item_color
	var item_shape = ITEM_SHAPES.pick_random()
	new_item.shape = item_shape
	match item_shape:
		"BoxMesh":
			new_item_mesh_instance.mesh = BoxMesh.new()
		"PrismMesh":
			new_item_mesh_instance.mesh = PrismMesh.new()
		"TubeTrailMesh":
			new_item_mesh_instance.mesh = TubeTrailMesh.new()
	new_item_mesh_instance.material_override = StandardMaterial3D.new()
	new_item_mesh_instance.material_override.albedo_color = item_color
	new_item.global_position = spawn_point.global_position
	
	var new_queue_item := { "shape": ITEM_SHAPES.pick_random(), "color": item_color}
	if expected_item_display_1.mesh.get_class() == "PlaceholderMesh":
		set_display(expected_item_display_1, new_queue_item)
	elif expected_item_display_2.mesh.get_class() == "PlaceholderMesh":
		set_display(expected_item_display_2, new_queue_item)
	elif expected_item_display_1_small.mesh.get_class() == "PlaceholderMesh":
		set_display(expected_item_display_1_small, new_queue_item)
	elif expected_item_display_2_small.mesh.get_class() == "PlaceholderMesh":
		set_display(expected_item_display_2_small, new_queue_item)
	else:
		item_queue.push_back(new_queue_item)
	items.add_child(new_item)
	
func process_arrived_item(display: MeshInstance3D, small_display: MeshInstance3D, item: Item) -> void:
	var item_mesh_instance: MeshInstance3D = item.find_child("MeshInstance3D")
	if item_mesh_instance.mesh.get_class() != display.mesh.get_class() or \
	item_mesh_instance.material_override.albedo_color != display.material_override.albedo_color:
		get_tree().paused = true
		score.visible = false
		player_ui.visible = false
		game_over.find_child("Score").text = "Items delivered: " + str(items_delivered)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		game_over.visible = true
		return
	
	items_delivered += 1
	score.text = "Items delivered: " + str(items_delivered)
	play_score_increase_animation()
	MIN_SPAWN_DELAY -= 0.1
	MAX_SPAWN_DELAY -= 0.1
	set_display(display, { "shape": small_display.mesh.get_class(), "color": small_display.material_override.albedo_color })
	var next_item_data = item_queue.pop_front()
	if next_item_data:
		set_display(small_display, next_item_data)
	else:
		set_display(small_display, { "shape": "PlaceholderMesh", "color": "#ffffff" })
	item.queue_free()
		
func set_display(display: MeshInstance3D, data: Dictionary) -> void:
	match data.shape:
		"PlaceholderMesh":
			display.mesh = PlaceholderMesh.new()
		"BoxMesh":
			display.mesh = BoxMesh.new()
			display.rotation.x = 0
		"PrismMesh":
			display.mesh = PrismMesh.new()
			display.rotation.x = 0
		"TubeTrailMesh":
			display.mesh = TubeTrailMesh.new()
			display.rotation.x = deg_to_rad(90)
	display.material_override.albedo_color = data.color

func play_score_increase_animation():
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(score, "scale", 2.1 * Vector2.ONE, 0.2)
	tween.tween_property(score, "scale", 1.8 * Vector2.ONE, 0.2)
