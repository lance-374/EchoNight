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
	$MarginContainer/VBoxContainer/MainMenu.hide()
	$AddressEntry.show()



func _on_address_entry_text_submitted(address):
	emit_signal("addressEntered",address)
	emit_signal("characterType", type)





func _on_host_button_pressed():
	emit_signal("hostWorldStart")
