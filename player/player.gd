#extends RigidBody3D
#
#const SPEED = 0.2
#const DRAG_FACTOR = 0.001
#
#func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#else:
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#
#func _process(delta: float) -> void:
	#angular_velocity.x = Input.get_axis("rotate_up", "rotate_down") * 0.5
	#angular_velocity.y = Input.get_axis("rotate_left", "rotate_right") * 0.5
	#angular_velocity.z = Input.get_axis("roll_left", "roll_right") * 0.5
	#
	#basis = basis.rotated(basis.x, -angular_velocity.x * PI * delta)
	#basis = basis.rotated(basis.y, -angular_velocity.y * PI * delta)
	#basis = basis.rotated(basis.z, -angular_velocity.z * PI * delta) 
	#basis = basis.orthonormalized()
	#transform.basis = basis
#
#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#if Input.is_action_pressed("thrust_forward"):
		#var forward_dir = -global_transform.basis.z
		#state.linear_velocity += forward_dir * SPEED * Input.get_action_strength("thrust_forward")
	#
	#if Input.is_action_pressed("brake"):
		#state.linear_velocity *= 0.9
#
	#var speed = state.linear_velocity.length()
	#if speed > 0:
		#var drag = -state.linear_velocity.normalized() * speed * speed * DRAG_FACTOR
		#state.linear_velocity += drag
	#
	#move_and_collide(state.linear_velocity)
	
extends CharacterBody3D

@export var max_speed = 500.0
@export var acceleration = 0.5
@export var pitch_speed = 1.5
@export var roll_speed = 1.9
@export var yaw_speed = 1.25  # Set lower for linked roll/yaw
@export var input_response = 8.0

var forward_speed = 0.0
var pitch_input = 0.0
var roll_input = 0.0
var yaw_input = 0.0

func get_input(delta):
	if Input.is_action_pressed("throttle_up"):
		forward_speed = lerp(forward_speed, max_speed, acceleration * delta)
	if Input.is_action_pressed("throttle_down"):
		forward_speed = lerp(forward_speed, 0.0, acceleration * delta)

	pitch_input = lerp(pitch_input, Input.get_axis("pitch_down", "pitch_up"),
			input_response * delta)
	roll_input = lerp(roll_input, Input.get_axis("roll_right", "roll_left"),
			input_response * delta)
	yaw_input = lerp(yaw_input, Input.get_axis("yaw_right", "yaw_left"), input_response * delta)
	#yaw_input = roll_input

func _physics_process(delta):
	get_input(delta)
	rotate_z(roll_input * roll_speed * delta)
	rotate_x(pitch_input * pitch_speed * delta)
	rotate_y(yaw_input * yaw_speed * delta)
	transform.basis = transform.basis.orthonormalized()
	velocity = -transform.basis.z * forward_speed
	move_and_collide(velocity * delta)
