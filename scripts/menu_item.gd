extends RigidBody3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

const ITEM_COLORS := [
	"#4287f5",	#blue
	"#f54254",	#red
	"#42f557"	#green
]

var conveyor_count := 0
var conveyor_direction: Vector3

func _ready() -> void:
	var mesh_id = randi_range(1, 3)
	var color_index = randi_range(0, 2)
	match mesh_id:
		1:
			mesh_instance_3d.mesh = BoxMesh.new()
		2:
			mesh_instance_3d.mesh = PrismMesh.new()
		3:
			mesh_instance_3d.mesh = TubeTrailMesh.new()
	mesh_instance_3d.material_override = StandardMaterial3D.new()
	mesh_instance_3d.material_override.albedo_color = ITEM_COLORS[color_index]
	
func _physics_process(delta: float) -> void:
	if conveyor_count:
		self.global_translate(conveyor_direction * delta)
