extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $PS1_Zombie/Camera3D_zombie
@onready var aniPlayer = $PS1_Zombie/AnimationPlayer
@onready var ArtiSound = $AudioStreamPlayer3D_groaning
@onready var liReady = true
@onready var audio = $Audio
@onready var shaderHandler = $SubViewportContainer/SubViewport/ColorRect
@onready var airCon = get_node("/root/Level/Level1/AudioStreamPlayer3D")
var health = 3
var is_paused = false
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8


@export var reveal_threshold = -100.0  # dB (adjust as needed)
@export var reveal_duration = 1.0      # Seconds

@onready var viewport = $SubViewportContainer/SubViewport/ColorRect        
var reveal_timer = 0.0


@rpc("call_local")
func playWalk():
	aniPlayer.play("WalkZ")

@rpc("call_local")
func playIdle():
	aniPlayer.play("IdleZ")


func _on_sound_detected(detected):
	if detected:
		shaderHandler.material.set_shader_param("reveal_amount", 1.0) 
	else:
		shaderHandler.material.set_shader_param("reveal_amount", 0.0)

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
	
	

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	




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

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	var peak_volume = AudioServer.get_bus_peak_volume_left_db((AudioServer.get_bus_index("enviromentalBus")), 0)
	print(peak_volume)
	if peak_volume > reveal_threshold:
		reveal_timer = reveal_duration  # Trigger reveal effect
		print("I HEAR THINGS")
	if reveal_timer > 0.0:
		var reveal_amount = reveal_timer / reveal_duration 
		var sound_x = airCon.position.x
		var sound_y =airCon.position.y
		var sound_z =airCon.position.z
		viewport.get_material().set_shader_parameter("reveal_amount", reveal_amount)
		viewport.get_material().set_shader_parameter("sound_source_pos", Vector2(sound_x, sound_y))
		viewport.get_material().set_shader_parameter("sound_source_pos", Vector2(position.x, position.y))
		viewport.get_material().set_shader_parameter("simulated_depth", float(sound_z))
		
		reveal_timer -= delta
	else:
		viewport.get_material().set_shader_parameter("reveal_amount", 0)
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
