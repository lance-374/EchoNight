extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $PS1_Zombie/Armature/Camera3D
@onready var aniPlayer = $PS1_Zombie/AnimationPlayer
@onready var ArtiSound = $AudioStreamPlayer3D_groaning
@onready var liReady = true
@onready var audio = $Audio
@onready var materialHandler = get_node("/root/Level/Level1/Map").mesh_library
@onready var airCon = get_node("/root/Level/Level1/AudioStreamPlayer3D")
@onready var shaderMaterial = "res://PlayerControlledChars/Shaders/shaderMaterial.tres"
@onready var enviromentalFog = "res://Map/Scene/WorlEnviromentalBlack.tres"
@onready var worldEnvirmentNode = get_node("/root/Level/Level1/WorldEnvironment")
var health = 3
var is_paused = false
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var players;
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@export var reveal_threshold = -100.0  # dB (adjust as needed)
@export var reveal_duration = 1.0      # Seconds


var reveal_timer = 0.0


@rpc("call_local")
func playWalk():
	aniPlayer.play("WalkZ")

@rpc("call_local")
func playIdle():
	aniPlayer.play("IdleZ")


func toggle_pause():
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
		if liReady == true:
			liReady = false
			ArtiSound.play()
			await get_tree().create_timer(2).timeout
			liReady = true
	
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	
	
var i = 0;
func _ready():
	if not is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	seen = []
	worldEnvirmentNode.set_environment(load(enviromentalFog))
	for mesh in materialHandler.get_item_list():
		var shader_material = ShaderMaterial.new()
		shader_material.set_shader(load("res://PlayerControlledChars/Zombie/Scene/Zombie.gdshader"))
		materialHandler.get_item_mesh(mesh).surface_set_material(0, shader_material)


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if not is_paused:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * .005)
			camera.rotate_x(event.relative.y * .005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/4.6, PI/9)
	
	if Input.is_action_just_pressed("escape"):
		toggle_pause()
	#if Input.is_action_just_pressed("shoot") \
			#and anim_player.current_animation != "shoot":
		#play_shoot_effects.rpc()
		#if raycast.is_colliding():
			#var hit_player = raycast.get_collider()
			#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
@onready var amountOfPlayers =  get_node("/root/Level").listOfPlayers.size()
@onready var checkPlayers = 0
var seen = []




func setAllShadersOnPlayers(player):
			
				var formatted = "/root/Level/%s/%s/Sprite/Armature/Skeleton3D" % [player, player] 
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

func _physics_process(delta):  
	if not is_multiplayer_authority(): return
	var peak_volume = AudioServer.get_bus_peak_volume_left_db((AudioServer.get_bus_index("enviromentalBus")), 0) + 40
	var playerList = multiplayer.get_peers()
	for player in playerList:
		if !seen.has(player):
			setAllShadersOnPlayers(player)
		updateshader(player,peak_volume)
	if not is_on_floor():
		velocity.y -= gravity * delta
	for mesh in materialHandler.get_item_list():
		materialHandler.get_item_mesh(mesh).surface_get_material(0).set_shader_parameter("audio_intensity", peak_volume)
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_paused:
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and not is_paused:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		playWalk.rpc()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		playIdle.rpc()
		makeSound.rpc()
	#if anim_player.current_animation == "shoot":
		#pass
	#elif input_dir != Vector2.ZERO and is_on_floor():
		#anim_player.play("move")
	#else:
		#anim_player.play("idle")
	
	move_and_slide()

#@rpc("call_local")
#func play_shoot_effects():
	#anim_player.stop()
	#anim_player.play("shoot")
	#muzzle_flash.restart()
	#muzzle_flash.emitting = true

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)

#func _on_animation_player_animation_finished(anim_name):
	#if anim_name == "shoot":
		#anim_player.play("idle")

