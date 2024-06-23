extends MenuBar

signal addressEntered(address)
signal hostWorldStart()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_join_button_pressed():
	$MarginContainer/VBoxContainer.hide()
	$MarginContainer/AddressEntry.show() 
	


func _on_address_entry_text_submitted(address):
	emit_signal("addressEntered",address) # Replace with function body.


func _on_host_button_pressed():
	emit_signal("hostWorldStart") # Replace with function body.
