extends CharacterBody2D
class_name Player

# Platformer Physics Constants
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0  # Reduced jump height for more realistic traversal
@export var gravity: float = 1200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Climbing Constants
@export var climb_speed: float = 150.0
@export var ledge_grab_distance: float = 20.0
@export var ledge_check_height: float = 10.0

@onready var sprite = $PlaceholderSprite
@onready var collision = $CollisionShape2D
@onready var interaction_area = $InteractionArea

# Climbing detection areas (optional - will be created if not found)
var ledge_detector_right: RayCast2D
var ledge_detector_left: RayCast2D
var wall_detector_right: RayCast2D
var wall_detector_left: RayCast2D

var can_move: bool = true
var facing_right: bool = true
var is_jumping: bool = false
var is_falling: bool = false
var character_name: String = "Player"

# Climbing states
enum ClimbState {
	NORMAL,
	HANGING,
	CLIMBING_UP,
	WALL_SLIDING
}

var climb_state: ClimbState = ClimbState.NORMAL
var hanging_position: Vector2
var can_grab_ledge: bool = true
var ledge_grab_cooldown: float = 0.0

signal interacted_with_object(object: Node)

func _ready():
	setup_character()
	setup_climbing_detectors()
	# Add player to group so NPCs can find it easily
	add_to_group("player")
	
func setup_character():
	# Set up basic collision shape if not already set
	if collision.shape == null:
		var shape = RectangleShape2D.new()
		shape.size = Vector2(32, 80)  # Even taller for new sprite proportions
		collision.shape = shape
	
	# Connect to InputManager for control mode changes
	InputManager.input_mode_changed.connect(_on_input_mode_changed)
	
	print("Player character initialized: ", character_name, " (configured for taller sprites)")

func setup_climbing_detectors():
	# Try to find existing detectors first
	ledge_detector_right = get_node_or_null("LedgeDetectorRight")
	ledge_detector_left = get_node_or_null("LedgeDetectorLeft")
	wall_detector_right = get_node_or_null("WallDetectorRight")
	wall_detector_left = get_node_or_null("WallDetectorLeft")
	
	# Create detectors if they don't exist
	if not ledge_detector_right:
		ledge_detector_right = RayCast2D.new()
		ledge_detector_right.name = "LedgeDetectorRight"
		add_child(ledge_detector_right)
	
	if not ledge_detector_left:
		ledge_detector_left = RayCast2D.new()
		ledge_detector_left.name = "LedgeDetectorLeft"
		add_child(ledge_detector_left)
	
	if not wall_detector_right:
		wall_detector_right = RayCast2D.new()
		wall_detector_right.name = "WallDetectorRight"
		add_child(wall_detector_right)
	
	if not wall_detector_left:
		wall_detector_left = RayCast2D.new()
		wall_detector_left.name = "WallDetectorLeft"
		add_child(wall_detector_left)
	
	# Configure detectors
	ledge_detector_right.target_position = Vector2(ledge_grab_distance, -ledge_check_height)
	ledge_detector_left.target_position = Vector2(-ledge_grab_distance, -ledge_check_height)
	wall_detector_right.target_position = Vector2(ledge_grab_distance, 0)
	wall_detector_left.target_position = Vector2(-ledge_grab_distance, 0)
	
	# Enable the detectors
	ledge_detector_right.enabled = true
	ledge_detector_left.enabled = true
	wall_detector_right.enabled = true
	wall_detector_left.enabled = true
	
func _physics_process(delta):
	# Update cooldowns
	if ledge_grab_cooldown > 0:
		ledge_grab_cooldown -= delta
		if ledge_grab_cooldown <= 0:
			can_grab_ledge = true
	
	if can_move:
		match climb_state:
			ClimbState.NORMAL:
				handle_normal_movement(delta)
			ClimbState.HANGING:
				handle_hanging_movement(delta)
			ClimbState.CLIMBING_UP:
				handle_climbing_up()
			ClimbState.WALL_SLIDING:
				handle_wall_sliding()
		
		handle_interactions()
		
	move_and_slide()
	update_animation_state()

func handle_normal_movement(delta):
	handle_gravity(delta)
	handle_jump()
	handle_horizontal_movement(delta)
	check_ledge_grab()

func handle_gravity(delta):
	# Add gravity when not on floor and not hanging
	if not is_on_floor() and climb_state != ClimbState.HANGING:
		velocity.y += gravity * delta
		is_falling = velocity.y > 0
		is_jumping = velocity.y < 0
	else:
		is_falling = false
		is_jumping = false

func handle_jump():
	# Handle jump input (but not during dialogue or while hanging)
	if Input.is_action_just_pressed("jump") and is_on_floor() and not DialogueManager.is_dialogue_active and climb_state == ClimbState.NORMAL:
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

func check_ledge_grab():
	# Only check for ledge grab when falling and able to grab
	if not is_falling or not can_grab_ledge or climb_state != ClimbState.NORMAL:
		return
	
	# Only check if detectors exist
	if not wall_detector_right or not wall_detector_left or not ledge_detector_right or not ledge_detector_left:
		return
	
	var can_grab_right = facing_right and wall_detector_right.is_colliding() and not ledge_detector_right.is_colliding()
	var can_grab_left = not facing_right and wall_detector_left.is_colliding() and not ledge_detector_left.is_colliding()
	
	if can_grab_right or can_grab_left:
		start_hanging()

func start_hanging():
	climb_state = ClimbState.HANGING
	velocity = Vector2.ZERO
	hanging_position = global_position
	can_grab_ledge = false
	ledge_grab_cooldown = 0.5  # Prevent immediate re-grabbing
	
	print("Started hanging on ledge")

func handle_hanging_movement(delta):
	# Player can move left/right slightly while hanging, or climb up
	var direction = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("jump"):
		# Climb up
		start_climbing_up()
	elif Input.is_action_just_pressed("move_down"):
		# Drop down
		drop_from_ledge()
	elif direction != 0:
		# Move along ledge (limited movement)
		global_position.x += direction * climb_speed * 0.5 * delta
		facing_right = direction > 0

func start_climbing_up():
	climb_state = ClimbState.CLIMBING_UP
	velocity = Vector2.ZERO
	
	# Create tween for smooth climb up animation
	var tween = create_tween()
	var target_position = global_position + Vector2(0, -48)  # Climb up by character height
	tween.tween_property(self, "global_position", target_position, 0.8)
	tween.tween_callback(finish_climbing_up)
	
	print("Climbing up ledge")

func finish_climbing_up():
	climb_state = ClimbState.NORMAL
	velocity = Vector2.ZERO
	print("Finished climbing up")

func drop_from_ledge():
	climb_state = ClimbState.NORMAL
	velocity.y = 100  # Small downward velocity
	print("Dropped from ledge")

func handle_climbing_up():
	# Movement is handled by tween, just wait
	velocity = Vector2.ZERO

func handle_wall_sliding():
	# Future feature: sliding down walls
	pass

func update_animation_state():
	# Update sprite direction for ColorRect placeholder
	if sprite and sprite is ColorRect:
		# For ColorRect, we can change color to indicate state
		match climb_state:
			ClimbState.HANGING:
				sprite.color = Color.ORANGE  # Orange when hanging
			ClimbState.CLIMBING_UP:
				sprite.color = Color.YELLOW  # Yellow when climbing
			ClimbState.NORMAL:
				if is_jumping:
					sprite.color = Color.LIGHT_BLUE  # Light blue when jumping
				elif is_falling:
					sprite.color = Color.CYAN  # Cyan when falling
				elif abs(velocity.x) > 10:
					sprite.color = Color.GREEN  # Green when walking
				else:
					sprite.color = Color(0.545098, 0.270588, 0.0745098, 1)  # Brown when idle
	
	# If we have an AnimatedSprite2D (for future sprite integration)
	elif sprite and sprite.has_method("play"):
		# Update sprite direction
		sprite.flip_h = not facing_right
		
		# Play appropriate animation based on state
		if sprite.sprite_frames == null:
			return
		
		match climb_state:
			ClimbState.HANGING:
				play_animation_if_exists("hang")
			ClimbState.CLIMBING_UP:
				play_animation_if_exists("climb")
			ClimbState.NORMAL:
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
	if sprite and sprite.has_method("play") and sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
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
	climb_state = ClimbState.NORMAL  # Reset climbing state
	print("Player movement disabled")

func _on_input_mode_changed(mode: String):
	print("Player input mode changed to: ", mode) 
