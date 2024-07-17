extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $Camera3D_human
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D_human/Shotgun/MuzzleFlash
@onready var raycast = $Camera3D_human/RayCast3D
@onready var sound = $Camera3D_human/Shotgun/Sound
@onready var ArtiSound = $AudioStreamPlayer3D_human_whistle
@onready var audio = $Audio
@onready var humanModelAniPlayer = $Human72/AnimationPlayer
@onready var lightNode = preload("res://Map/Scene/light_spawn.tscn")

var liReady = true
var is_paused = false
var instance
var has_shotgun = false
var has_battery = false
var is_in_car_area = false
var level

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
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_paused = true

var health = 3

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority() or is_paused: return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if not is_paused:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * .005)
			camera.rotate_x(-event.relative.y * .005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if Input.is_action_just_pressed("escape"):
		toggle_pause()
	
	if Input.is_action_just_pressed("shoot") and not sound.playing and not is_paused and has_shotgun:
		play_shoot_effects.rpc()
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
	
	#if Input.is_action_just_pressed("shoot") \
			#and anim_player.current_animation != "shoot":
		#play_shoot_effects.rpc()
		#if raycast.is_colliding():
			#var hit_player = raycast.get_collider()
			#hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

@rpc("call_local")
func aniIdel():
	humanModelAniPlayer.play("Idle")

@rpc("call_local")
func aniWalk():
	humanModelAniPlayer.play("Walk")

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_paused:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_paused:
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			aniWalk.rpc()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			aniIdel.rpc()

	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")
		

	move_and_slide()
	
	#car battery objective
	if not has_battery:
		if Input.is_action_just_pressed("action") and is_in_car_area and not level.humans_have_car_battery:
			$BatteryTimer.start()
			level.toggle_car_alarm(true)
			print("Player started getting car battery")
		if $BatteryTimer.time_left > 0 and (Input.is_action_just_released("action") or not is_in_car_area):
			$BatteryTimer.stop()
			print("Player cancelled getting car battery")

func _on_battery_timer_timeout():
	print("Player got car battery")
	level.toggle_car_alarm(false)
	level.humans_have_car_battery = true
	$BatteryTimer.stop()
	has_battery = true

func entered_car_area(node):
	print("Player entered car area")
	level = node
	is_in_car_area = true

func exited_car_area(node):
	print("Player exited car area")
	level = node
	is_in_car_area = false



@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)
	
@rpc("any_peer")
func lighting():
	if Input.is_action_just_pressed("clap"):
		if liReady == true:
			liReady = false
			GlobalSound.spawnLight(camera.global_position)
			ArtiSound.play()
			await get_tree().create_timer(0.5).timeout
			GlobalSound.removeLight()
			liReady = true
	if liReady == false:
		GlobalSound.setLightPosition(camera.global_position)

@rpc("call_local")
func play_shoot_effects():
	if not is_multiplayer_authority(): return
	anim_player.stop()
	anim_player.play("shoot")
	sound.play(0.5)
	spawnLight($Camera3D_human/Shotgun/Sound.position)
	await get_tree().create_timer(1.15).timeout
	removeLight()
	muzzle_flash.restart()
	muzzle_flash.emitting = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")
