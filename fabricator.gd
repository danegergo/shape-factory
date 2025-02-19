extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_open := false

func open_door() -> void:
	if !animation_player.is_playing() and !is_open:
		animation_player.play("open")
	is_open = true

func close_door() -> void:
	if !animation_player.is_playing() and is_open:
		animation_player.play("close")
	is_open = false
