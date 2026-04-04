extends RigidBody3D

@export var drag_factor = 0.001
@export var max_speed = 200.0
@export var acceleration = 0.2
@export var brake_strength = 0.99
@export var pitch_speed = 0.5
@export var roll_speed = 0.5
@export var yaw_speed = 0.5
@export var input_response = 8.0

var forward_speed = 0.0
var pitch_input = 0.0
var roll_input = 0.0
var yaw_input = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

#func get_input(delta):
	#if Input.is_action_pressed("throttle_up"):
		#forward_speed = lerp(forward_speed, max_speed, acceleration * delta)
	#if Input.is_action_pressed("throttle_down"):
		#forward_speed = lerp(forward_speed, 0.0, acceleration * delta)
#
	#pitch_input = lerp(pitch_input, Input.get_axis("pitch_down", "pitch_up"), input_response * delta)
	#roll_input = lerp(roll_input, Input.get_axis("roll_right", "roll_left"), input_response * delta)
	#yaw_input = lerp(yaw_input, Input.get_axis("yaw_right", "yaw_left"), input_response * delta)

func _process(delta: float) -> void:
	angular_velocity.x = Input.get_axis("pitch_up", "pitch_down") * pitch_speed
	angular_velocity.y = Input.get_axis("yaw_left", "yaw_right") * yaw_speed
	angular_velocity.z = Input.get_axis("roll_left", "roll_right") * roll_speed
	
	basis = basis.rotated(basis.x, -angular_velocity.x * PI * delta)
	basis = basis.rotated(basis.y, -angular_velocity.y * PI * delta)
	basis = basis.rotated(basis.z, -angular_velocity.z * PI * delta) 
	basis = basis.orthonormalized()
	transform.basis = basis

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var forward_dir = -global_transform.basis.z
	
	if Input.is_action_pressed("throttle_up"):
		state.linear_velocity += forward_dir * acceleration * Input.get_action_strength("throttle_up")
	
	if Input.is_action_pressed("throttle_down"):
		state.linear_velocity *= brake_strength

	#var current_speed = state.linear_velocity.length()
#	
	#if current_speed > 0:
		#var drag = -state.linear_velocity.normalized() * current_speed * current_speed * drag_factor
		#state.linear_velocity += drag
	
	move_and_collide(state.linear_velocity)
