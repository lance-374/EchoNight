extends Control

signal addressEntered(address)
signal hostWorldStart()
signal characterType(type)
var host: bool
var type
@onready var audio = $AudioStreamPlayer

var pauseSound =  "res://Assets/Menu/Audio/Menu_Sound_Pause.wav"#Press
var forwardSound = "res://Assets/Menu/Audio/Menu_Sound_Forward.wav" #Mouse Enter"res://Assets/Menu/Audio/Menu_Sound_Forward.wav"


func _ready():
	audio.bus = "MenuAudio"




#TitleScreen
func _on_play_button_pressed():
	audio.stream = load(pauseSound) # Replace with function body.
	audio.play()
	$FogLayer.hide()
	$TitleScreen.hide()
	$MultiplayerScreen.show()

func _on_options_button_pressed():
	audio.stream = load(pauseSound) # Replace with function body.
	audio.play()

func _on_quit_button_pressed():
	audio.stream = load(pauseSound) # Replace with function body.
	audio.play()
	get_tree().quit()



#MultiplayerScreen
func _on_host_button_pressed():
	host = true
	audio.stream = load(pauseSound) # Replace with function body.
	audio.play()
	$MultiplayerScreen/AddressEntry.hide()
	$MultiplayerScreen/StartButton.text = "START SERVER"
	$MultiplayerScreen/StartButton.show()
	


func _on_join_button_pressed():
	host = false
	audio.stream = load(pauseSound) # Replace with function body.
	audio.play()
	$MultiplayerScreen/AddressEntry.show()
	$MultiplayerScreen/StartButton.text = "JOIN SERVER"
	$MultiplayerScreen/StartButton.show()
	
	




func _on_start_button_pressed():
	audio.stream = load(pauseSound) # Replace with function body.
	audio.play()
	if not host:
		var address = $MultiplayerScreen/AddressEntry.text
		if address == "":
			address = "localhost"
		emit_signal("addressEntered", address)
	else:
		emit_signal("hostWorldStart")
	emit_signal("characterType", type)
	
	$MultiplayerScreen.hide()

func _on_back_button_pressed():
	audio.stream = load(pauseSound) # Replace with function body.
	audio.play()
	$MultiplayerScreen.hide()
	$FogLayer.show()
	$TitleScreen.show()


func _on_play_button_mouse_entered():
	audio.stream = load(forwardSound) # Replace with function body.
	audio.play()

func _on_options_button_mouse_entered():
	audio.stream = load(forwardSound)# Replace with function body.
	audio.play() # Replace with function body.


func _on_quit_button_mouse_entered():
	audio.stream = load(forwardSound) # Replace with function body.
	audio.play()


func _on_host_button_mouse_entered():
	audio.stream = load(forwardSound) # Replace with function body.
	audio.play() # Replace with function body.


func _on_join_button_mouse_entered():
	audio.stream = load(forwardSound) # Replace with function body.
	audio.play() # Replace with function body.


func _on_start_button_mouse_entered():
	audio.stream = load(forwardSound) # Replace with function body.
	audio.play() # Replace with function body.


func _on_address_entry_mouse_entered():
	audio.stream = load(forwardSound) # Replace with function body.
	audio.play() # Replace with function body.


func _on_back_button_mouse_entered():
	audio.stream = load(forwardSound) # Replace with function body.
	audio.play() # Replace with function body.
