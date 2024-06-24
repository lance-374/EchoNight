extends Node

@onready var main_menu = $MainMenu

#@onready var hud = $CanvasLayer/HUD
#@onready var health_bar = $CanvasLayer/HUD/HealthBar


const Human = preload("res://PlayerControlledChars/Human/Scene/Human.tscn")
const Zombie = preload("res://PlayerControlledChars/Zombie/Scene/Zombie.tscn")
const PORT = 3000
var enet_peer = ENetMultiplayerPeer.new()
var latestPlayerType
var hasHost = false
func _ready():
	main_menu.connect("addressEntered",  joinAdressEntered)
	main_menu.connect("hostWorldStart", startHost )
	main_menu.connect("characterType", playerType)




func playerType(type):
	print(type)
	latestPlayerType = type
	if(!hasHost):
		add_player(multiplayer.get_unique_id())
		hasHost = true


func _unhandled_input(_event):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func startHost():
	main_menu.hide()
	#hud.show()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_disconnected.connect(remove_player)
	
	
	
	#upnp_setup()

func joinAdressEntered(address):
	main_menu.hide()
	#hud.show()
	
	
	enet_peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = enet_peer


func add_player(peer_id):
	var player
	if (latestPlayerType == ("Zombie")):
		player= Zombie.instantiate()
		print("Player Zombie")
	elif(latestPlayerType == ("Human")):
		player = Human.instantiate()
		print("Player Human")
	player.name = str(peer_id)
	add_child(player)
	
	#if player.is_multiplayer_authority():
		#player.health_changed.connect(update_health_bar)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

#func update_health_bar(health_value):
	#health_bar.value = health_value

#func _on_multiplayer_spawner_spawned(node):
	#if node.is_multiplayer_authority():
		#node.health_changed.connect(update_health_bar)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())


