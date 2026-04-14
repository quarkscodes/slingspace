extends RigidBody3D

@export var drag_factor := 0.001
@export var max_speed := 200.0
@export var acceleration := 0.05
@export var brake_strength := 0.98
@export var input_response := 0.4

@onready var speed_display := %SpeedDisplay

var forward_speed := 0.0
var pitch_input := 0.0
var roll_input := 0.0
var yaw_input := 0.0


func _process(delta: float) -> void:
	angular_velocity.x = Input.get_axis("pitch_up", "pitch_down") * input_response
	angular_velocity.y = Input.get_axis("yaw_left", "yaw_right") * input_response
	angular_velocity.z = Input.get_axis("roll_left", "roll_right") * input_response
	
	basis = basis.rotated(basis.x, -angular_velocity.x * PI * delta)
	basis = basis.rotated(basis.y, -angular_velocity.y * PI * delta)
	basis = basis.rotated(basis.z, -angular_velocity.z * PI * delta) 
	basis = basis.orthonormalized()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var forward_dir := -global_transform.basis.z
	
	if Input.is_action_pressed("throttle_up"):
		state.linear_velocity += \
			forward_dir * acceleration * Input.get_action_strength("throttle_up")
	
	if Input.is_action_pressed("throttle_down"):
		state.linear_velocity *= brake_strength

	var current_speed := state.linear_velocity.length()
	
	speed_display.text = str(snapped(current_speed, 0.1))
	
	#Code below applies some drag - not sure if will be used in the end
	if current_speed > 0:
		var drag := -state.linear_velocity.normalized() * current_speed * current_speed * drag_factor
		state.linear_velocity += drag
	
	move_and_collide(state.linear_velocity)
