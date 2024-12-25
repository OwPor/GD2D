extends CharacterBody2D

# Constants
const WALK_SPEED = 300
const JUMP_FORCE = -500.0
const DUCK_SCALE = Vector2(1, 0.5)
const ACCELERATION = 500

func _ready():
	$PlayerLabel.text = str(name)
# Variables
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_ducking = false

var player_id = "PlayerID"  # Replace this with the actual player ID or username

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _physics_process(delta: float):
	if !is_multiplayer_authority():
		return

	$Camera2D.enabled = true

	process_gravity(delta)
	process_movement(delta)
	process_animation()
	move_and_slide()

func process_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta

func process_movement(delta: float):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, direction * WALK_SPEED, ACCELERATION * delta)
	flip(direction)

	# Ducking
	if Input.is_action_pressed("duck") and not is_ducking:
		is_ducking = true
		$CollisionShape2D.scale.y = -.99
	elif not Input.is_action_pressed("duck") and is_ducking:
		is_ducking = false
		$AnimatedSprite2D.scale.y = 1
		$CollisionShape2D.scale.y = 1

func process_animation():
	var is_moving = velocity.x != 0 and is_on_floor()
	var is_jumping = velocity.y < 0 and !is_on_floor()
	var is_idle = velocity.x == 0 and is_on_floor()
	var is_falling = velocity.y > 0 and !is_on_floor()

	if is_ducking:
		$AnimatedSprite2D.play("Duck")
	elif is_moving:
		$AnimatedSprite2D.play("Walk")
	elif is_idle:
		$AnimatedSprite2D.play("Idle")
	elif is_jumping:
		$AnimatedSprite2D.play("Jump")
	elif is_falling:
		$AnimatedSprite2D.play("Fall")

func flip(dir):
	if dir < 0:
		$AnimatedSprite2D.flip_h = true
	elif dir > 0:
		$AnimatedSprite2D.flip_h = false
