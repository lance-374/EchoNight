extends Node

@onready var lightNode = preload("res://Map/Scene/light_spawn.tscn")
var instance
# Called when the node enters the scene tree for the first time.

@rpc("call_local")
func spawnLight(pos):
	instance = lightNode.instantiate()
	instance.position = pos
	add_child(instance)
	
@rpc("call_local")
func removeLight():
	instance.queue_free()
	instance = load("res://Map/Scene/light_spawn.tscn")
	
@rpc("call_local")
func setLightPosition(pos):
	instance.position = pos
