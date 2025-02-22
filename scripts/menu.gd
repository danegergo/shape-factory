extends Node3D

@onready var respawn_point: Node3D = $RespawnPoint

const main_scene: PackedScene = preload("res://stage1.tscn")

func _on_area_3d_body_entered(body: Node3D) -> void:
	body.global_position = respawn_point.global_position

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)
