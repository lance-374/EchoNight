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
const HUMAN = true
const ZOMBIE = false
var liReady = true
var is_paused = false
var instance
var has_shotgun = false
var has_battery = false
var has_key = false
var is_in_key_area = false
var is_in_car_area = false
var is_in_shotgun_1_area = false
var is_in_shotgun_2_area = false
var is_in_terminals_area = false
var is_in_keyhole_area = false
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

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if not is_paused and not dead:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * .005)
			camera.rotate_x(-event.relative.y * .005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if Input.is_action_just_pressed("escape") and not dead:
		toggle_pause()
	
	if Input.is_action_just_pressed("shoot") and not shotgun_sound.playing and not is_paused and has_shotgun and not dead and not $AudioStreamPlayer3D_human_whistle.is_playing():
		play_shoot_effects.rpc()
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			print(hit_player)
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

	#key objective and guns
	if Input.is_action_just_pressed("action") and not dead:
		if is_in_key_area:
			level.get_key()
			has_key = true
			print("Player got key")
		if is_in_shotgun_1_area and not has_shotgun:
			pick_up_shotgun()
			level.get_shotgun_1()
		elif is_in_shotgun_2_area and not has_shotgun:
			pick_up_shotgun()
			level.get_shotgun_2()
		if is_in_terminals_area and has_battery:
			level.connect_battery()
			has_battery = false
		if is_in_keyhole_area and has_key:
			level.insert_key()
			has_key = false

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

func exited_car_area():
	print("Player exited car area")
	is_in_car_area = false
	
func entered_terminals_area(node):
	print("Player entered terminals area")
	level = node
	is_in_terminals_area = true

func exited_terminals_area():
	print("Player exited terminals area")
	is_in_terminals_area = false

func entered_keyhole_area(node):
	print("Player entered keyhole area")
	level = node
	is_in_keyhole_area = true

func exited_keyhole_area():
	print("Player exited keyhole area")
	is_in_keyhole_area = false

func entered_key_area(node):
	print("Player entered key area")
	level = node
	is_in_key_area = true

func exited_key_area():
	print("Player exited key area")
	is_in_key_area = false
	
func entered_shotgun_1_area(node):
	print("Player entered shotgun 1 area")
	level = node
	is_in_shotgun_1_area = true

func exited_shotgun_1_area():
	print("Player exited shotgun 1 area")
	is_in_shotgun_1_area = false

func entered_shotgun_2_area(node):
	level = node
	print("Player entered shotgun 2 area")
	is_in_shotgun_2_area = true

func exited_shotgun_2_area():
	print("Player exited shotgun 2 area")
	is_in_shotgun_2_area = false
	
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
	if Input.is_action_just_pressed("clap") and not is_paused and not dead and not shotgun_sound.is_playing():
		ArtiSound.play()

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
	elif health <= 0:
		health = 0
		blood_light.show()
		blood_heavy.show()
		kill_player()

func kill_player():
	dead = true
	print("Killed human")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#TODO: change rotation or animation of player so it is lying down

#health bar
#func update_health_bar(health_value):
	#health_bar.value = health_value

#func _on_multiplayer_spawner_spawned(node):
	#if node.is_multiplayer_authority():
		#node.health_changed.connect(update_health_bar)
