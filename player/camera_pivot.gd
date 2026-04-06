extends Node3D

@export var input_response = 0.6
@export var interpolation_weight = 3.0

@onready var player = %Player


func _process(delta: float) -> void:
	var target_xform: Transform3D = player.get_global_transform_interpolated()
	basis = basis.slerp(target_xform.basis, interpolation_weight * delta)
	basis = basis.orthonormalized()
	
	var camera_angular_velocity: float = Input.get_axis("camera_pitch_up", "camera_pitch_down") \
		* input_response
	basis = basis.rotated(basis.x, -camera_angular_velocity * PI * delta)
	
	position = player.position
