extends MenuBar

signal addressEntered(address)
signal hostWorldStart()
signal characterType(type)
var host = true
@onready var textBoxForCharSelection = $"MarginContainer/VBoxContainer/CharacterSelection/Display Currently Playing"
var type
# Called when the node enters the scene tree for the first time.
func _ready():
	$AddressEntry.hide()# Replace with function body.
	$MarginContainer/VBoxContainer/CharacterSelection.hide()
	textBoxForCharSelection.add_text("Please choose to play as a human or zombie")




func _on_join_button_pressed():
	host = false
	$MarginContainer/VBoxContainer/MainMenu.hide()
	$MarginContainer/VBoxContainer/CharacterSelection.show()



func _on_address_entry_text_submitted(address):
	emit_signal("addressEntered",address)
	emit_signal("characterType", type)




func _on_confirm_pressed():
	if host:
		emit_signal("hostWorldStart")
		emit_signal("characterType", type)
	else: 
		$MarginContainer/VBoxContainer/CharacterSelection.hide()
		$AddressEntry.show()
		
	

func _on_choose_zombie_pressed():
	type = "Zombie" # Replace with function body.
	textBoxForCharSelection.clear()
	textBoxForCharSelection.add_text("You are currently playing as a : " + type)


func _on_choose_human_pressed():
	type = "Human" 
	textBoxForCharSelection.clear()
	textBoxForCharSelection.add_text("You are currently playing as a : " + type)


func _on_host_button_pressed():
	$MarginContainer/VBoxContainer/MainMenu.hide()
	$MarginContainer/VBoxContainer/CharacterSelection.show()
