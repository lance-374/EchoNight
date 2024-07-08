extends SpotLight3D

# Minimum and maximum duration in seconds for the light to stay in its current state
var min_duration: float = 0.1
var max_duration: float = 1.0
#var visible = 
# Function to toggle the visibility of the light
func toggle_light():
	visible = !visible

# Function to start the blinking effect
func start_blinking():
	toggle_light()
	# Schedule the next toggle
	var next_toggle_duration = randf_range(min_duration, max_duration)
	await(get_tree().create_timer(next_toggle_duration))
	start_blinking()

# Called when the node enters the scene tree for the first time
func _ready():
	randomize() # Initialize random number generator
	start_blinking()
