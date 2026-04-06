extends Node3D

@onready var player = %Player

# I think the issue lies in the setup of the target_basis but I could be wrong
func _process(delta: float) -> void:
	var target_xform: Transform3D = player.get_global_transform_interpolated()
	basis = basis.slerp(target_xform.basis, 3.0 * delta)
	basis = basis.orthonormalized()
	
	var camera_angular_velocity: float = Input.get_axis("camera_pitch_up", "camera_pitch_down") * 0.5
	basis = basis.rotated(basis.x, -camera_angular_velocity * PI * delta)
	
	position = player.position
