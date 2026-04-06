extends Node3D

@onready var player = %Player

# I think the issue lies in the setup of the target_basis but I could be wrong
func _process(delta: float) -> void:
	var target_xform: Transform3D = player.get_global_transform_interpolated()
	basis = basis.slerp(target_xform.basis, 1.5 * delta)
	basis = basis.orthonormalized()
	
	position = player.position
