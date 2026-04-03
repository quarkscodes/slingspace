extends Camera3D

@export var lerp_speed = 20.0
@export var offset = Vector3(0.0, 2.0, 6.0)
@onready var target = %Player

# change to use quaternions for rotation and separate follow
func _physics_process(delta):
	if !target:
		return
	
	var target_xform = target.global_transform.translated_local(offset)
	global_transform = global_transform.interpolate_with(target_xform, lerp_speed * delta)
	
	look_at(target.global_transform.origin, target.transform.basis.y)
