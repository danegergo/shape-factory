extends StaticBody3D

@onready var belt_area: Area3D = $BeltArea

@export var CONVEYOR_SPEED := 5.0

#func _physics_process(delta: float) -> void:
	#move_objects_on_belt(delta)
	
func _on_belt_area_body_entered(item: Item) -> void:
	item.conveyor_direction = self.transform.basis.x * CONVEYOR_SPEED
	item.conveyor_count += 1

func _on_belt_area_body_exited(item: Item) -> void:
	item.conveyor_count -= 1 

func move_objects_on_belt(delta: float) -> void:
	for item: Item in belt_area.get_overlapping_bodies():
		item.global_translate(self.transform.basis.x * CONVEYOR_SPEED * delta)
