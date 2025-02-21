extends Node3D

@onready var item_spawn_points: Node3D = $ItemSpawnPoints
@onready var spawn_timer: Timer = $SpawnTimer

const item_scene: PackedScene = preload("res://item/item.tscn")

const ITEM_COLORS = {
	"blue": "#4287f5",
	"red": "#f54254",
	"green": "#42f557"
}

var ITEM_SHAPES = {
	"box": "box",
	"prism": "prism"
}

var STAGE_DATA := {
	"Stage1": {
		"items": {
			"Sp1": [
				{ 
					"shape": ITEM_SHAPES.box,
					"color": ITEM_COLORS.blue
				},
				{ 
					"shape": ITEM_SHAPES.prism,
					"color": ITEM_COLORS.red
				},
				{ 
					"shape": ITEM_SHAPES.box,
					"color": ITEM_COLORS.green
				}
			],
			"Sp2": [
				{ 
					"shape": ITEM_SHAPES.prism,
					"color": ITEM_COLORS.green
				},
				{ 
					"shape": ITEM_SHAPES.prism,
					"color": ITEM_COLORS.green
				},
				{ 
					"shape": ITEM_SHAPES.box,
					"color": ITEM_COLORS.red
				}
			]
		},
		"expected_items": {
			"Id1": [
				{ 
					"shape": ITEM_SHAPES.box,
					"color": ITEM_COLORS.blue
				},
				{ 
					"shape": ITEM_SHAPES.prism,
					"color": ITEM_COLORS.red
				},
				{ 
					"shape": ITEM_SHAPES.box,
					"color": ITEM_COLORS.green
				}
			],
			"Id2": [
				{ 
					"shape": ITEM_SHAPES.prism,
					"color": ITEM_COLORS.green
				},
				{ 
					"shape": ITEM_SHAPES.prism,
					"color": ITEM_COLORS.green
				},
				{ 
					"shape": ITEM_SHAPES.box,
					"color": ITEM_COLORS.red
				}
			]
		},
	}
}

var current_stage_data: Dictionary
var current_item_index: int = 0
var id1_expected_item_index: int = 0
var id2_expected_item_index: int = 0

func _ready() -> void:
	current_stage_data = STAGE_DATA[self.name]

func _on_spawn_timer_timeout() -> void:
	for spawn_point in current_stage_data.items:
		if current_item_index >= current_stage_data.items[spawn_point].size():
			continue
		var new_item: Item = item_scene.instantiate()
		var new_item_mesh_instance: MeshInstance3D = new_item.find_child("MeshInstance3D")
		var next_item_data: Dictionary = current_stage_data.items[spawn_point][current_item_index]
			
		self.add_child(new_item)
		match next_item_data.shape:
			"box":
				new_item_mesh_instance.mesh = BoxMesh.new()
				new_item.shape = "box"
			"prism":
				new_item_mesh_instance.mesh = PrismMesh.new()
				new_item.shape = "prism"
		new_item_mesh_instance.material_override = StandardMaterial3D.new()
		new_item_mesh_instance.material_override.albedo_color = next_item_data.color
		new_item.color = next_item_data.color
		new_item.global_position = item_spawn_points.find_child(spawn_point).global_position
		
	current_item_index += 1

func _on_id_1_body_entered(item: Item) -> void:
	if id1_expected_item_index >= current_stage_data.expected_items.Id1.size():
		get_tree().quit()
		
	var expected_item = current_stage_data.expected_items.Id1[id1_expected_item_index]
	if item.shape == expected_item.shape and item.color == expected_item.color:
		item.queue_free()
		id1_expected_item_index += 1
	else:
		get_tree().quit()
