extends Control

var host: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_back_button_pressed():
	$MultiplayerScreen.hide()
	$TitleScreen.show()

func _on_play_button_pressed():
	$TitleScreen.hide()
	$MultiplayerScreen.show()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_host_button_pressed():
	host = true
	$MultiplayerScreen/AddressEntry.hide()
	$MultiplayerScreen/StartButton.text = "START SERVER"
	$MultiplayerScreen/StartButton.show()

func _on_join_button_pressed():
	host = false
	$MultiplayerScreen/AddressEntry.show()
	$MultiplayerScreen/StartButton.text = "JOIN SERVER"
	$MultiplayerScreen/StartButton.show()
