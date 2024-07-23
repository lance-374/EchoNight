extends Node

@onready var main_menu = $Menu

const PORT = 3000
const PlayerSelection = preload("res://Menu/Scene/CharacterSelection.tscn")

var enet_peer = ENetMultiplayerPeer.new()
var latestPlayerType
var player_character_choices = {}
@export var humans_have_car_battery = false
@export var car_alarm_playing = false
@export var humans_have_key = false
@export var human_has_shotgun_1 = false
@export var human_has_shotgun_2 = false

func _ready():
	main_menu.connect("addressEntered", joinAddressEntered)
	main_menu.connect("hostWorldStart", startHost)

func startHost():
	main_menu.hide()
	enet_peer.create_server(PORT)
	#multiplayer is the name of the server variable
	multiplayer.multiplayer_peer = enet_peer
	add_player(multiplayer.get_unique_id())
	multiplayer.peer_disconnected.connect(remove_player)
	
	#when a new player connects run add_player
	multiplayer.peer_connected.connect(add_player)
	
	#upnp_setup()
	
func _process(_delta):
	if car_alarm_playing and not $Car/Alarm.is_playing():
		$Car/Alarm.play()
	elif not car_alarm_playing and $Car/Alarm.is_playing():
		$Car/Alarm.stop()

func joinAddressEntered(address):
	main_menu.hide()
	#hud.show()
	enet_peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = PlayerSelection.instantiate()
	print(peer_id)
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()



func _on_car_area_body_entered(body):
	print(body)
	if body.has_method("entered_car_area"):
		body.entered_car_area(self)

func _on_car_area_body_exited(body):
	print(body)
	if body.has_method("exited_car_area"):
		body.exited_car_area()

func toggle_car_alarm(mode):
	car_alarm_playing = mode
	
func _on_key_area_body_entered(body):
	print(body)
	if body.has_method("entered_key_area"):
		body.entered_key_area(self)

func _on_key_area_body_exited(body):
	print(body)
	if body.has_method("exited_key_area"):
		body.exited_key_area()
		
func get_key():
	humans_have_key = true
	$Key.queue_free()

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
