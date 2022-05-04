extends KinematicBody

export var walk_speed := 5
export var sprint_speed := 7
export var crouch_speed := 3
export var speed_smoothing = 0.2
export var jump_strenght := 4
export var gravity := 9.82

export var lean_amount = 0.05

var _velocity := Vector3.ZERO
var _snap_vector := Vector3.DOWN

var sprinting := 0.1
var crouching := 0.1

onready var _spring_arm: SpringArm = $SpringArm
onready var _model: Spatial = $Armature

func _physics_process(delta):
	var move_direction := Vector3.ZERO
	move_direction.z = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	move_direction.x = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y).normalized()
	
	crouching = Input.get_action_strength("move_crouch")
	sprinting = Input.get_action_strength("move_sprint")
	
	var target_speed = walk_speed
	if sprinting: target_speed = sprint_speed
	if crouching: target_speed = crouch_speed
	 
	_velocity.x = lerp(_velocity.x, move_direction.x * target_speed, 0.2)
	_velocity.z = lerp(_velocity.z, move_direction.z * target_speed, 0.2)
	_velocity.y -= gravity * delta
	
	var just_landed := is_on_floor() and _snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("move_jump")
	
	if is_jumping:
		_velocity.y = jump_strenght
		_snap_vector = Vector3.ZERO
	elif just_landed:
		_snap_vector = Vector3.DOWN
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP, true)
	
	if _velocity.length() > 0.2:
		var look_direction = Vector2(_velocity.z, _velocity.x).angle()
		_model.rotation.y = lerp_angle(_model.rotation.y, look_direction + -PI/2, 0.2)
		_model.rotation.x = abs(Vector2(_velocity.z, _velocity.x).length() * lean_amount)


func _process(delta):
	#_spring_arm.translation = translation
	pass

