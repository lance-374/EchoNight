extends CharacterBody3D

@onready var camera = $PS1_Zombie/Armature/Skeleton3D/Camera3D
@onready var aniPlayer = $PS1_Zombie/AnimationPlayer2
@onready var ArtiSound = $AudioStreamPlayer3D_groaning

@onready var audio = $Audio
@onready var blood_heavy = $CanvasLayer/HUD/BloodHeavy
@onready var blood_light = $CanvasLayer/HUD/BloodLight
@onready var materialHandler = get_node("/root/Level/Level1/Map").mesh_library
@onready var airCon = get_node("/root/Level/Level1/AudioStreamPlayer3D")
@onready var shaderMaterial = "res://PlayerControlledChars/Shaders/shaderMaterial.tres"
@onready var enviromentalFog = "res://Map/Scene/WorlEnviromentalBlack.tres"
@onready var worldEnvirmentNode = get_node("/root/Level/Level1/WorldEnvironment")
var health = 3
var is_paused = false
var dead = false
var ready_to_attack = false
var player_to_attack
var attacking = false
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const HUMAN = false
const ZOMBIE = true


@export var reveal_threshold = -100.0  # dB (adjust as needed)
@export var reveal_duration = 1.0      # Seconds




var gravity = 9.8
@rpc("call_local")
func playWalk():
	aniPlayer.play("WalkZ")

@rpc("call_local")
func playIdle():
	aniPlayer.play("IdleZ")

@rpc("call_local")
func playAttack():
	aniPlayer.play("GrabBiteZ")

@onready var lightNode = preload("res://Map/Scene/light_spawn.tscn")
var instance

func spawnLight(pos):
	instance = lightNode.instantiate()
	instance.position = pos
	add_child(instance)

func removeLight():
	instance.queue_free()
	instance = load("res://Map/Scene/light_spawn.tscn")
	
func setLightPosition(pos):
	instance.position = pos

func toggle_pause():
	if dead:
		return
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_paused = true

@rpc("call_local")
func makeSound():
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed("clap") and not is_paused:
			ArtiSound.play()
		
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	print(name)
	print_tree_pretty()

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
	worldEnvirmentNode.set_environment(load(enviromentalFog))
	for mesh in materialHandler.get_item_list():
		var shader_material = ShaderMaterial.new()
		shader_material.set_shader(load("res://PlayerControlledChars/Zombie/Scene/Zombie.gdshader"))
		materialHandler.get_item_mesh(mesh).surface_set_material(0, shader_material)


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if not is_paused and not dead:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * .005)
			camera.rotate_x(event.relative.y * .005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/4.6, PI/9)
	
	if Input.is_action_just_pressed("escape"):
		toggle_pause()
	
	if Input.is_action_just_pressed("left_click"):
		if ready_to_attack and not attacking:
			attacking = true
			playAttack.rpc()
			player_to_attack.receive_damage.rpc_id(player_to_attack.get_multiplayer_authority())

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	var peak_volume = AudioServer.get_bus_peak_volume_left_db((AudioServer.get_bus_index("enviromentalBus")), 0) + 40
	var playerList = multiplayer.get_peers()
	for player in playerList:
		if !seen.has(player):
			setAllShadersOnPlayers(player)
		updateshader(player,peak_volume)
	# Handle Jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor() and not is_paused and not dead:
		#velocity.y = JUMP_VELOCITY
	for mesh in materialHandler.get_item_list():
		materialHandler.get_item_mesh(mesh).surface_get_material(0).set_shader_parameter("audio_intensity", peak_volume)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and not is_paused and not dead:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if not attacking:
			playWalk.rpc()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if not attacking:
			playIdle.rpc()
		makeSound.rpc()
	
	move_and_slide()

@rpc("any_peer")
func receive_damage():
	update_health(health-1)

func update_health(new_health):
	print("Health")
	print(new_health)
	health = new_health
	if health > 3:
		health = 3
	if health == 3:
		blood_light.hide()
		blood_heavy.hide()
	elif health == 2:
		blood_light.show()
		blood_heavy.hide()
	elif health == 1:
		blood_light.hide()
		blood_heavy.show()
	else:
		health = 0
		blood_light.show()
		blood_heavy.show()
		kill_player()

func kill_player():
	dead = true
	print("Killed zombie")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#TODO: change rotation or animation of player so it is lying down

func _on_area_3d_body_entered(body):
	if body.has_method("receive_damage") and body.HUMAN:
		print("Human entered zombie attack area")
		ready_to_attack = true
		player_to_attack = body

func _on_area_3d_body_exited(body):
	if body.has_method("receive_damage") and body.HUMAN:
		print("Human exited zombie attack area")
		ready_to_attack = false
		player_to_attack = null


func _on_animation_player_2_animation_finished(anim_name):
	if anim_name == "GrabBiteZ":
		attacking = false

var seen = []
func setAllShadersOnPlayers(player):
			
				var formatted = "/root/Level/%s/%s/Human72/Armature/Skeleton3D" % [player, player] 
				var skele_node = get_node_or_null(formatted)
				if get_node_or_null(formatted) == null:
					formatted =  "/root/Level/%s/%s/PS1_Zombie/Armature/Skeleton3D" % [player, player] 
					skele_node = get_node_or_null(formatted)
				if skele_node:
					for children in skele_node.get_children():
							for surface in children.get_surface_override_material_count():
								var shader_material = ShaderMaterial.new()
								shader_material.set_shader(load("res://PlayerControlledChars/Zombie/Scene/Zombie.gdshader"))
								children.set_surface_override_material(surface, shader_material)
								children.get_surface_override_material(surface).set_shader_parameter("isHuman", true)
								children.get_surface_override_material(surface).set_shader_parameter("pluse_thickness", 2000)
								children.get_surface_override_material(surface).set_shader_parameter("wave_speed", 2000)
					seen.append(player)
					
					
					
					
					
					
					
func updateshader(player, peak_volume):
	var formatted = "/root/Level/%s/%s/Sprite/Armature/Skeleton3D" % [player, player] 
	var skele_node = get_node_or_null(formatted)
	if get_node_or_null(formatted) == null:
		formatted =  "/root/Level/%s/%s/PS1_Zombie/Armature/Skeleton3D" % [player, player] 
		skele_node = get_node_or_null(formatted)
	if skele_node:
		for children in skele_node.get_children():
				for surface in children.get_surface_override_material_count():
						children.get_surface_override_material(surface).set_shader_parameter("audio_intensity", peak_volume)
