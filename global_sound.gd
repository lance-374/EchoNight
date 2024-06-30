extends Node

var myNode = preload("res://Map/Scene/light_spawn.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func spawnLight():
	var instance = myNode.instantiate()
	add_child(instance)
