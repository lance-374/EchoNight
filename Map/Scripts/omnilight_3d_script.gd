extends DirectionalLight3D

var myVec = Vector3(0,0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	OmniLight3D.light_energy = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("clap"):
		OmniLight3D.light_energy = 5
		await(5)
		OmniLight3D.light_energy = 0
