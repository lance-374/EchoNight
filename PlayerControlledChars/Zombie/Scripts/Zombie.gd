extends CharacterBody3D

@onready var camera = $PS1_Zombie/Armature/Skeleton3D/Camera3D
@onready var aniPlayer = $PS1_Zombie/AnimationPlayer2
@onready var ArtiSound = $AudioStreamPlayer3D_groaning
@onready var liReady = true
@onready var audio = $Audio
@onready var blood_heavy = $CanvasLayer/HUD/BloodHeavy
@onready var blood_light = $CanvasLayer/HUD/BloodLight

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
		if liReady == true:
			liReady = false
			spawnLight(camera.position)
			ArtiSound.play()
			await get_tree().create_timer(2).timeout
			removeLight()
			liReady = true
	if liReady == false:
		setLightPosition(camera.position)
		
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	print(name)
	print_tree_pretty()

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

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

	# Handle Jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor() and not is_paused and not dead:
		#velocity.y = JUMP_VELOCITY

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
