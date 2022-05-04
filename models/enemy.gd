extends KinematicBody

var path = []
var curr_path = []
var path_node = 0
var curr_path_node

var speed = 5


onready var nav: Navigation = get_parent()
onready var player: KinematicBody = $"../../player"
onready var animation: AnimationPlayer = $AnimationPlayer

func _ready():
	move_to(player.global_transform.origin)

func _physics_process(delta):
	curr_path = path
	curr_path_node = path_node
	if curr_path_node < curr_path.size() - 1:
		var direction: Vector3 = (curr_path[path_node + 1] - global_transform.origin)
		#print(direction.length())
		#print(curr_path_node)
		if direction.length() < 0.1:
			#print(curr_path[curr_path_node])
			#print(global_transform.origin)
			path_node += 1
			
		else: 
			var velocity = move_and_slide(direction.normalized() * speed + Vector3.DOWN, Vector3.UP, true)
			rotation.y = lerp_angle(rotation.y, Vector2(velocity.z, velocity.x).angle(), 0.1)
			animation.play("running")
			
		if Vector3(curr_path[curr_path.size() - 1] - global_transform.origin).length() < 1: animation.play("standing")

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	#print(path)
	#print(curr_path)
	path_node = 0


func _on_Timer_timeout():
	move_to(player.global_transform.origin)
