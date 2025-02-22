extends StaticBody3D

@export_enum("BoxMesh", "PrismMesh", "TubeTrailMesh") var output := "BoxMesh"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var inside_area: Area3D = $InsideArea
@onready var item_display: MeshInstance3D = $CSGBox3D3/CSGBox3D4/ItemDisplay

var is_open := false

func _ready() -> void:
	match output:
		"BoxMesh":
			item_display.mesh = BoxMesh.new()
			item_display.rotation.x = 0
		"PrismMesh":
			item_display.mesh = PrismMesh.new()
			item_display.rotation.x = 0
		"TubeTrailMesh":
			item_display.mesh = TubeTrailMesh.new()
			item_display.rotation.x = deg_to_rad(90)

func open_door() -> void:
	if animation_player.is_playing() or is_open:
		return
		
	animation_player.play("open")
	is_open = true

func fabricate() -> void:
	if animation_player.is_playing() or !is_open:
		return
		
	animation_player.play("fabricate")
	is_open = false
	var animation_length = animation_player.get_animation("fabricate").length
	
	if inside_area.has_overlapping_bodies():
		get_tree().create_timer(animation_length / 2).timeout.connect(func(): inside_area.get_overlapping_bodies()[0].find_child("MeshInstance3D").mesh = PrismMesh.new())
