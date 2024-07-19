extends OmniLight3D

# Parameters to control the flickering effect
@export var flicker_intensity: float = 0.2
@export var speed: float = 5.0

func _process(delta: float) -> void:
	# Randomly adjust the light's position to simulate flickering
	var random_offset = Vector3(
		randf_range(-flicker_intensity, flicker_intensity),
		randf_range(-flicker_intensity, flicker_intensity),
		randf_range(-flicker_intensity, flicker_intensity)
	)
	
	# Smoothly interpolate to the new position to simulate a gentle flicker
	position = position.lerp(position + random_offset, speed * delta)
