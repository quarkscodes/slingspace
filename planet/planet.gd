extends Node3D

func _ready() -> void:
	for child in get_children():
		var face: PlanetMeshFace = child
		face.regenerate_mesh()
		
