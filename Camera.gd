extends Camera

onready var player = get_parent().get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = player._velocity.rotated(player._velocity)
	rotation.x = velocity.x
	pass
