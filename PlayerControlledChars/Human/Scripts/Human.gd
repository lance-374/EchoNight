extends CharacterBody3D

@onready var camera = $Camera3D_human
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D_human/Shotgun/MuzzleFlash
@onready var raycast = $Camera3D_human/RayCast3D
@onready var shotgun_sound = $Camera3D_human/Shotgun/Sound
@onready var ArtiSound = $AudioStreamPlayer3D_human_whistle
@onready var audio = $Audio
@onready var humanModelAniPlayer = $Human72/AnimationPlayer
@onready var lightNode = preload("res://Map/Scene/light_spawn.tscn")
@onready var hud = $CanvasLayer/HUD
@onready var crosshair = $CanvasLayer/HUD/Crosshair
@onready var blood_light = $CanvasLayer/HUD/BloodLight
@onready var blood_heavy = $CanvasLayer/HUD/BloodHeavy

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var liReady = true
var is_paused = false
var instance
var has_shotgun = false
var has_battery = false
var is_in_car_area = false
var level
var health = 3
var gravity = 9.8
var dead = false

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority() or is_paused: return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

func toggle_pause():
	audio.stream = load("res://Assets/Menu/Audio/Menu_Sound_Pause.wav") # Replace with function body.
	audio.play()
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_paused = true

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if not is_paused:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * .005)
			camera.rotate_x(-event.relative.y * .005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if Input.is_action_just_pressed("escape"):
		toggle_pause()
	
	if Input.is_action_just_pressed("shoot") and not shotgun_sound.playing and not is_paused and has_shotgun and not dead:
		play_shoot_effects.rpc()
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
	
	if Input.is_action_just_pressed("action") and not dead:
		pick_up_shotgun()
	
	#if Input.is_action_just_pressed("shoot") and anim_player.current_animation != "shoot":
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
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_paused and not dead:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_paused and not dead:
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
		
	makeSound.rpc()
	move_and_slide()
	
	#car battery objective
	if not has_battery and not dead:
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
	
#shader stuff
func spawnLight(pos):
	instance = lightNode.instantiate()
	instance.position = pos
	add_child(instance)

func removeLight():
	instance.queue_free()
	instance = load("res://Map/Scene/light_spawn.tscn")

func setLightPosition(pos):
	instance.position = pos

@rpc("call_local")
func makeSound():
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed("clap") and not is_paused and not dead:
		if liReady == true:
			liReady = false
			spawnLight($Camera3D_human.position)
			ArtiSound.play()
			await get_tree().create_timer(0.5).timeout
			removeLight()
			liReady = true
	if liReady == false:
		setLightPosition($Camera3D_human.position)

@rpc("any_peer")
func receive_damage():
	update_health(health-1)

@rpc("call_local")
func play_shoot_effects():
	if not is_multiplayer_authority(): return
	anim_player.stop()
	anim_player.play("shoot")
	shotgun_sound.play(0.5)
	spawnLight($Camera3D_human/Shotgun/Sound.position)
	await get_tree().create_timer(1.15).timeout
	removeLight()
	muzzle_flash.restart()
	muzzle_flash.emitting = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")

func pick_up_shotgun():
	$Camera3D_human/Shotgun.show()
	$Camera3D_human/RayCast3D.show()
	crosshair.show()
	has_shotgun = true

func update_health(new_health):
	health = new_health
	if health > 3:
		health = 3
		print("ERROR: Invalid health value")
	elif health == 3:
		blood_light.hide()
		blood_heavy.hide()
	elif health == 2:
		blood_light.show()
		blood_heavy.hide()
	elif health == 1:
		blood_light.hide()
		blood_heavy.show()
	else:
		blood_light.show()
		blood_heavy.show()
		kill_player()

func kill_player():
	dead = true
	#TODO: change rotation or animation of player so it is lying down

#health bar
#func update_health_bar(health_value):
	#health_bar.value = health_value

#func _on_multiplayer_spawner_spawned(node):
	#if node.is_multiplayer_authority():
		#node.health_changed.connect(update_health_bar)
