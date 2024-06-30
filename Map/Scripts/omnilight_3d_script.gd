extends OmniLight3D

var liVec = Vector3(0,0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	light_energy = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("clap"):
		var sLight = GlobalSound.spawnLight()
		await get_tree().create_timer(1).timeout
		remove_child(sLight)
