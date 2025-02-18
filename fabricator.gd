extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_open := false

func toggle_door():
	if animation_player.is_playing():
		return
	if !is_open:
		animation_player.play("open")
	else:
		animation_player.play("close")
	is_open = !is_open
