extends Node

@onready var lightNode = preload("res://Map/Scene/light_spawn.tscn")
var instance
# Called when the node enters the scene tree for the first time.
var spectrum
var volume
func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0, 0)

func _process(delta):
	volume = spectrum.get_magnitude_for_frequency_range(0, 10000).length()

func spawnLight(pos):
	instance = lightNode.instantiate()
	instance.position = pos
	add_child(instance)
	
func removeLight():
	instance.queue_free()
	instance = load("res://Map/Scene/light_spawn.tscn")
	
func setLightPosition(pos):
	instance.position = pos
