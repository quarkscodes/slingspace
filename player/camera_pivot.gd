extends Node3D

@onready var player = %Player

func _process(delta: float) -> void:
	basis = basis.slerp(%Player.get("basis"), 20.0)
	basis = basis.orthonormalized()
	look_at(player.get("position"))
