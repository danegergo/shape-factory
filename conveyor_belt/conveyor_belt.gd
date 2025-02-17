extends StaticBody3D

@onready var belt_area: Area3D = $BeltArea

@export var CONVEYOR_SPEED := 5.0

func _physics_process(delta: float) -> void:
	for item: PhysicsBody3D in belt_area.get_overlapping_bodies():
		print(item)
		item.translate(Vector3.RIGHT * CONVEYOR_SPEED * delta)
