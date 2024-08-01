extends OmniLight3D

# Parameters to control the flickering effect
@export var flicker_intensity: float = 0.2
@export var speed: float = 5.0

# Define limits for vertical movement to keep the light within a visible area
@export var min_y_pos: float = -1  # Minimum Y position limit
@export var max_y_pos: float = 2   # Maximum Y position limit
var initial_pos: Vector3 = Vector3()  # To store the initial position of the light

func _ready():
	initial_pos = position  # Store the initial position of the light

func _process(delta: float) -> void:
	# Randomly adjust the light's vertical position to simulate flickering
	var random_y_offset = randf_range(-flicker_intensity, flicker_intensity)
	
	var new_y_pos = position.y + random_y_offset
	# Clamp the new Y position to ensure the light stays within the specified vertical limits
	new_y_pos = clamp(new_y_pos, initial_pos.y + min_y_pos, initial_pos.y + max_y_pos)
	
	# Create a new position vector with the updated Y position
	var new_pos = Vector3(initial_pos.x, new_y_pos, initial_pos.z)
	
	# Smoothly interpolate to the new position to simulate a gentle flicker
	position = position.lerp(new_pos, speed * delta)
