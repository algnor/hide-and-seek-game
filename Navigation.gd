extends Navigation

var started = true
var enemy = load("res://models/enemy.tscn")
func _ready():
	if started:
		add_child(enemy.instance())



func _on_Timer_timeout():
	if started:
		add_child(enemy.instance())
