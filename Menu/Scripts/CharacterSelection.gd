extends MenuBar


const Human = preload("res://PlayerControlledChars/Human/Scene/Human.tscn")
const Zombie = preload("res://PlayerControlledChars/Zombie/Scene/Zombie.tscn")
var player
@onready var textBoxForCharSelection =$"Container/MarginContainer/VBoxContainer/CharacterSelection/Display Currently Playing"
var type
var my_peer_id
@onready var audio = $Container/AudioStreamPlayer
@onready var zombie = $Container/PS1_Zombie
@onready var aniplayer = $Container/AnimationPlayer
@onready var container = $Container
@onready var human = $Container/Human
@onready var confirm = $Container/MarginContainer/VBoxContainer/CharacterSelection/Confirm

# Called when the node enters the scene tree for the first time.
func _ready():
	my_peer_id = self.name.to_int()
	zombie.visible = false
	human.visible = false

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	if !is_multiplayer_authority():
		self.hide()

func _on_confirm_pressed():
	print(type)
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	if type == "Zombie":
		var Zombieplayer = Zombie.instantiate()
		Zombieplayer.name = name
		container.hide()
		Zombieplayer.position = Vector3(10,5,0)
		zombie.visible = false
		human.visible = false
		add_child(Zombieplayer)

	elif type == "Human":
		var Humanplayer = Human.instantiate()
		Humanplayer.name = name
		container.hide()
		Humanplayer.position = Vector3(10,5,0)
		zombie.visible = false
		human.visible = false
		add_child(Humanplayer)
		
	else:
		audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Error.wav")
		audio.play()

func _on_choose_zombie_pressed():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav")
	audio.play()
	confirm.show()
	
	type = "Zombie"
	textBoxForCharSelection.clear()
	textBoxForCharSelection.add_text("You are currently playing as a : " + type)
	aniplayer.play("spin")
	human.visible = false
	zombie.visible = true

func _on_choose_human_pressed():
	type = "Human" 
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	confirm.show()
	textBoxForCharSelection.clear()
	textBoxForCharSelection.add_text("You are currently playing as a : " + type)
	aniplayer.play("spinHuman")
	zombie.visible = false
	human.visible = true

func _on_confirm_mouse_entered():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Forward.wav")
	audio.play()


func _on_choose_human_mouse_entered():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Forward.wav")
	audio.play()


func _on_choose_zombie_mouse_entered():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Forward.wav")
	audio.play()
