@tool
extends StaticBody3D

@export var planet_data: PlanetData:
	set(val): 
		planet_data = val
		on_data_changed()
		if planet_data != null and not planet_data.is_connected("changed", on_data_changed):
			planet_data.connect("changed", on_data_changed)


func _ready() -> void:
	on_data_changed()


func on_data_changed() -> void:
	planet_data.min_height = 99999.0
	planet_data.max_height = 0.0
	for child: Node3D in get_children():
		if child is PlanetMeshFace:
			var face: PlanetMeshFace = child
			face.regenerate_mesh(planet_data)
