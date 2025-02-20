extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var inside_area: Area3D = $InsideArea

var is_open := false

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
