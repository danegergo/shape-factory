extends StaticBody3D

@onready var belt_area: Area3D = $BeltArea

@export var CONVEYOR_SPEED := 5.0

var left_corner: bool

func _ready() -> void:
	left_corner = self.rotation.y == 0

func _on_belt_area_body_entered(item: Item) -> void:
	if left_corner:
		item.conveyor_direction = self.transform.basis.z * CONVEYOR_SPEED
	else:
		item.conveyor_direction = -self.transform.basis.x * CONVEYOR_SPEED
	item.conveyor_count += 1

func _on_belt_area_body_exited(item: Item) -> void:
	item.conveyor_count -= 1 
	
func _on_turn_area_body_entered(item: Item) -> void:
	if left_corner:
		item.conveyor_direction = self.transform.basis.x * CONVEYOR_SPEED
	else:
		item.conveyor_direction = -self.transform.basis.z * CONVEYOR_SPEED

func move_objects_on_belt(delta: float) -> void:
	for item: Item in belt_area.get_overlapping_bodies():
		item.global_translate(self.transform.basis.x * CONVEYOR_SPEED * delta)
