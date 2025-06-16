extends CharacterBody2D
class_name Player

# Platformer Physics Constants
@export var speed: float = 300.0
@export var jump_velocity: float = -550.0
@export var gravity: float = 1200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var interaction_area = $InteractionArea

var can_move: bool = true
var facing_right: bool = true
var is_jumping: bool = false
var is_falling: bool = false

signal interacted_with_object(object: Node)

func _ready():
	setup_character()
	
func setup_character():
	# Set up basic collision shape if not already set
	if collision.shape == null:
		var shape = RectangleShape2D.new()
		shape.size = Vector2(32, 48)  # Adjust based on sprite size
		collision.shape = shape
	
	# Connect to InputManager for control mode changes
	InputManager.input_mode_changed.connect(_on_input_mode_changed)
	
	print("Player character initialized")
	
func _physics_process(delta):
	if can_move:
		handle_gravity(delta)
		handle_jump()
		handle_horizontal_movement(delta)
		handle_interactions()
		
	move_and_slide()
	update_animation_state()

func handle_gravity(delta):
	# Add gravity when not on floor
	if not is_on_floor():
		velocity.y += gravity * delta
		is_falling = velocity.y > 0
		is_jumping = velocity.y < 0
	else:
		is_falling = false
		is_jumping = false

func handle_jump():
	# Handle jump input (but not during dialogue)
	if Input.is_action_just_pressed("jump") and is_on_floor() and not DialogueManager.is_dialogue_active:
		velocity.y = jump_velocity
		is_jumping = true

func handle_horizontal_movement(delta):
	# Get horizontal input
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		# Apply acceleration
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		# Update facing direction
		facing_right = direction > 0
	else:
		# Apply friction
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
func update_animation_state():
	# Update sprite direction
	if sprite:
		sprite.flip_h = not facing_right
	
	# Play appropriate animation based on state
	if not sprite or sprite.sprite_frames == null:
		return
		
	if is_jumping:
		play_animation_if_exists("jump")
	elif is_falling:
		# Use jump animation for falling if fall doesn't exist
		if sprite.sprite_frames.has_animation("fall"):
			play_animation_if_exists("fall")
		else:
			play_animation_if_exists("jump")
	elif abs(velocity.x) > 10:
		play_animation_if_exists("walk")
	else:
		play_animation_if_exists("idle")

func play_animation_if_exists(animation_name: String):
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name:
			sprite.play(animation_name)
	
func handle_interactions():
	# Use E for interactions, Space for dialogue advancement when active
	if Input.is_action_just_pressed("interact"):
		interact_with_nearby_objects()
	elif Input.is_action_just_pressed("jump") and DialogueManager.is_dialogue_active:
		# Space advances dialogue when dialogue is active
		pass  # Let DialogueManager handle this
		
func interact_with_nearby_objects():
	# This will be expanded when interaction system is implemented
	print("Player attempting to interact")
	interacted_with_object.emit(self)
	
func enable_movement():
	can_move = true
	print("Player movement enabled")
	
func disable_movement():
	can_move = false
	velocity = Vector2.ZERO
	print("Player movement disabled")

func _on_input_mode_changed(mode: String):
	print("Player input mode changed to: ", mode) 
