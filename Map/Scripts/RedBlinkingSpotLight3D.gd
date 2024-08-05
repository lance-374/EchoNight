extends SpotLight3D

# Parameters for flickering effect
@export var min_intensity: float = 0
@export var max_intensity: float = 20
#@export var flicker_speed: float = 1

func _process(delta: float) -> void:
	# Flicker intensity
	light_energy = randf_range(min_intensity, max_intensity)
	
	# Optionally, flicker color for a more dynamic effect
	#var r = randf_range(0.8, 1.0)  # Red component
	#var g = randf_range(0.8, 1.0)  # Green component
	#var b = randf_range(0.8, 1.0)  # Blue component
	#light_color = Color(r, g, b, 1)
