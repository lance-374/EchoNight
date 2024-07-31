extends Control

signal addressEntered(address)
signal hostWorldStart()
signal characterType(type)
var host: bool
var type
@onready var audio = $AudioStreamPlayer


#TitleScreen
func _on_play_button_pressed():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	$TitleScreen.hide()
	$MultiplayerScreen.show()

func _on_options_button_pressed():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()

func _on_quit_button_pressed():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	get_tree().quit()



#MultiplayerScreen
func _on_host_button_pressed():
	host = true
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	$MultiplayerScreen/AddressEntry.hide()
	$MultiplayerScreen/StartButton.text = "START SERVER"
	$MultiplayerScreen/StartButton.show()
	
	


func _on_join_button_pressed():
	host = false
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	$MultiplayerScreen/AddressEntry.show()
	$MultiplayerScreen/StartButton.text = "JOIN SERVER"
	$MultiplayerScreen/StartButton.show()
	
	




func _on_start_button_pressed():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	if not host:
		var address = $MultiplayerScreen/AddressEntry.text
		if address == "":
			address = "localhost"
		emit_signal("addressEntered", address)
	else:
		emit_signal("hostWorldStart")
	emit_signal("characterType", type)
	$TitleScreen/CanvasLayer.hide()
	$MultiplayerScreen.hide()

func _on_back_button_pressed():
	$MultiplayerScreen.hide()
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	$TitleScreen.show()


func _on_play_button_mouse_entered():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Forward.wav") # Replace with function body.
	audio.play()

func _on_options_button_mouse_entered():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Forward.wav")# Replace with function body.
	audio.play() # Replace with function body.


func _on_quit_button_mouse_entered():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Forward.wav") # Replace with function body.
	audio.play()
