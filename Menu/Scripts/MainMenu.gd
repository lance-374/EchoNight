extends MenuBar

signal addressEntered(address)
signal hostWorldStart()
signal characterType(type)
var host = true
var type
@onready var audio = $sfxPlayer
var pauseSound = "res://Assets/Menu/Audio/Menu_Sound_Pause.wav"
var forwardSound = "res://Assets/Menu/Audio/Menu_Sound_Forward.wav"
@onready var textBoxForCharSelection = $"MarginContainer/VBoxContainer/CharacterSelection/Display Currently Playing"

# Called when the node enters the scene tree for the first time.
func _ready():
	$AddressEntry.hide()# Replace with function body.
	$MarginContainer/VBoxContainer/CharacterSelection.hide()
	textBoxForCharSelection.add_text("Please choose to play as a human or zombie")

func _on_join_button_pressed():
	audio.stream = load(pauseSound) # Replace with function body.
	audio.play()
	
	$MarginContainer/VBoxContainer/MainMenu.hide()
	$AddressEntry.show()

func _on_address_entry_text_submitted(address):
	emit_signal("addressEntered",address)
	emit_signal("characterType", type)

func _on_host_button_pressed():
	audio.stream = load(pauseSound) # Replace with function body.
	audio.play()
	emit_signal("hostWorldStart")


func _on_host_button_mouse_entered():
	audio.stream = load(forwardSound) # Replace with function body.
	audio.play()


func _on_join_button_mouse_entered():
	audio.stream = load(forwardSound) # Replace with function body.
	audio.play() # Replace with function body.
