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
	for child: PlanetMeshFace in get_children():
		var face: PlanetMeshFace = child
		face.regenerate_mesh(planet_data)
