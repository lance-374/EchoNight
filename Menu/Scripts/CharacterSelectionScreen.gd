extends Control

const HUMAN = preload("res://PlayerControlledChars/Human/Scene/Human.tscn")
const ZOMBIE = preload("res://PlayerControlledChars/Zombie/Scene/Zombie.tscn")
var type: String
var my_peer_id: int

func _ready():
	my_peer_id = self.name.to_int()

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	print_tree_pretty()
	if !is_multiplayer_authority():
		self.hide()

#CharacterSelectionScreen
func _on_zombie_button_pressed():
	type = "zombie"
	$HumanSprite.show()
	$ZombieSprite.hide()
	$ConfirmButton.show()

func _on_human_button_pressed():
	type = "human"
	$HumanSprite.hide()
	$ZombieSprite.show()
	$ConfirmButton.show()

func _on_confirm_button_pressed():
	print(type)
	
	if type == "zombie":
		var zombie_player = ZOMBIE.instantiate()
		zombie_player.name = name
		self.hide()
		add_child(zombie_player)
	elif type == "human":
		var human_player = HUMAN.instantiate()
		human_player.name = name
		self.hide()
		add_child(human_player)
	else:
		print("No character selected")
