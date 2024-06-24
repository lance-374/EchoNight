extends MenuBar


const Human = preload("res://PlayerControlledChars/Human/Scene/Human.tscn")
const Zombie = preload("res://PlayerControlledChars/Zombie/Scene/Zombie.tscn")
var player
@onready var textBoxForCharSelection = $"MarginContainer/VBoxContainer/CharacterSelection/Display Currently Playing"
var type
var my_peer_id
# Called when the node enters the scene tree for the first time.
func _ready():
	my_peer_id = self.name.to_int()
	

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	print_tree_pretty()
	if !is_multiplayer_authority():
		self.hide()


func _on_confirm_pressed():
	print(type)
	if type == "Zombie":
		
		var Zombieplayer = Zombie.instantiate()
		Zombieplayer.name = name
		$MarginContainer.hide()
		add_child(Zombieplayer)

	if type == "Human":
		var Humanplayer = Human.instantiate()
		Humanplayer.name = name
		$MarginContainer.hide()
		add_child(Humanplayer)
		
	
	

func _on_choose_zombie_pressed():
	type = "Zombie" # Replace with function body.
	textBoxForCharSelection.clear()
	textBoxForCharSelection.add_text("You are currently playing as a : " + type)


func _on_choose_human_pressed():
	type = "Human" 
	textBoxForCharSelection.clear()
	textBoxForCharSelection.add_text("You are currently playing as a : " + type)


