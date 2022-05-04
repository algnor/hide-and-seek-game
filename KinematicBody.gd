extends KinematicBody

export var walk_speed := 5
export var sprint_speed := 7
export var crouch_speed := 3
export var speed_smoothing = 0.2
export var jump_strenght := 4
export var gravity := 9.82
export var sprint_fov = 90
export var sneak_fov = 60
export var fov = 75

export var lean_amount = 0.05

var _velocity := Vector3.ZERO
var _snap_vector := Vector3.DOWN

var sprinting := 0
var crouching := 0
var last_pos := transform.origin
var move_amount = 0
var move_speed_smoothing = 0
var time_at_jump = -INF
var time_at_land = -INF
onready var _spring_arm: SpringArm = $SpringArm
onready var _model: Spatial = $Armature
onready var _animation = $AnimationTree
onready var _camera = $SpringArm/Camera

func _physics_process(delta):
	var move_direction := Vector3.ZERO
	move_direction.z = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	move_direction.x = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	
	crouching = Input.get_action_strength("move_crouch")
	sprinting = Input.get_action_strength("move_sprint")
	
	var target_speed = walk_speed
	var target_fov = fov
	var target_camera_distance = 3.5
	if sprinting: 
		target_speed = sprint_speed
		target_fov = sprint_fov
		target_camera_distance = 4
	elif crouching: 
		target_speed = crouch_speed
		target_fov = sneak_fov
		target_camera_distance = 3.5
	_camera.fov = lerp(_camera.fov, target_fov, 0.1)
	_spring_arm.spring_length = lerp(_spring_arm.spring_length, target_camera_distance, 0.1)
	 
	_velocity.x = lerp(_velocity.x, move_direction.x * target_speed, 0.2)
	_velocity.z = lerp(_velocity.z, move_direction.z * target_speed, 0.2)
	_velocity.y -= gravity * delta
	
	var just_landed := is_on_floor() and _snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("move_jump")

	
	if is_jumping:
		time_at_jump = OS.get_ticks_msec()
		_velocity.y = jump_strenght
		_snap_vector = Vector3.ZERO

	elif just_landed:
		time_at_land = OS.get_ticks_msec()
		_snap_vector = Vector3.DOWN
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP, true)
	
	var current_velocity = (transform.origin - last_pos) / delta
	last_pos = transform.origin
	
	if _velocity.length() > 0.2:
		var look_direction = Vector2(_velocity.z, _velocity.x).angle()
		_model.rotation.y = lerp_angle(_model.rotation.y, look_direction - PI/2, 0.2)
		_model.rotation.x = abs(Vector2(_velocity.z, _velocity.x).length() * lean_amount)
		


	move_amount = lerp(move_amount, clamp(current_velocity.length(), 0, 1), 1)
	_animation.set("parameters/moving/blend_amount", move_amount)
	var move_speed = 0
	if crouching:  move_speed = -1
	if sprinting: move_speed = 1
	move_speed_smoothing = lerp(move_speed_smoothing, move_speed, 0.2)
	_animation.set("parameters/move_speed/blend_amount", move_speed_smoothing)
	#_animation.set("parameters/jump/active", is_jumping or (OS.get_ticks_msec() - time_at_jump < 208))
	_animation.set("parameters/landed/active", just_landed or (OS.get_ticks_msec() - time_at_land < 333))
