extends CharacterBody2D
class_name Player

# Platformer Physics Constants
@export var speed: float = 300.0
@export var jump_velocity: float = -450.0  # Increased jump height to reach platform 1 more easily
@export var gravity: float = 1200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Climbing Constants
@export var climb_speed: float = 150.0
@export var ledge_grab_distance: float = 35.0  # Increased from 20.0 for better detection
@export var ledge_check_height: float = 25.0   # Increased from 10.0 for better ledge detection

@onready var sprite = get_node_or_null("PlaceholderSprite")
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
	if collision and collision.shape == null:
		var shape = RectangleShape2D.new()
		shape.size = Vector2(32, 80)  # Even taller for new sprite proportions
		collision.shape = shape
	
	# Check sprite setup
	if sprite:
		print("Player sprite found: ", sprite.name, " (", sprite.get_class(), ")")
		if sprite is ColorRect:
			sprite.color = Color(0.4, 0.6, 0.2, 1)  # Ensure green messenger color
			print("Set player sprite to green messenger color")
	else:
		print("ERROR: PlaceholderSprite not found in Player scene!")
	
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
	
	# Configure detectors with better positioning
	# Wall detectors check horizontally at chest level
	wall_detector_right.target_position = Vector2(ledge_grab_distance, -10)  # Slightly above center
	wall_detector_left.target_position = Vector2(-ledge_grab_distance, -10)
	
	# Ledge detectors check above and to the side to detect platform tops
	ledge_detector_right.target_position = Vector2(ledge_grab_distance, -ledge_check_height)
	ledge_detector_left.target_position = Vector2(-ledge_grab_distance, -ledge_check_height)
	
	# Enable the detectors
	ledge_detector_right.enabled = true
	ledge_detector_left.enabled = true
	wall_detector_right.enabled = true
	wall_detector_left.enabled = true
	
	# Enable debug visualization (helpful for troubleshooting) - using correct Godot 4 approach
	if OS.is_debug_build():
		# Debug visualization is controlled by editor settings in Godot 4
		# The raycasts will show debug lines automatically when enabled in debug builds
		pass
	
	print("Climbing detectors setup complete:")
	print("- Ledge grab distance: ", ledge_grab_distance)
	print("- Ledge check height: ", ledge_check_height)
	print("- Wall detector positions: ", wall_detector_right.target_position, " / ", wall_detector_left.target_position)
	print("- Ledge detector positions: ", ledge_detector_right.target_position, " / ", ledge_detector_left.target_position)

func _physics_process(delta):
	# Update cooldowns
	if ledge_grab_cooldown > 0:
		ledge_grab_cooldown -= delta
		if ledge_grab_cooldown <= 0:
			can_grab_ledge = true
	
	if can_move and not DialogueManager.is_dialogue_active:
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
	elif DialogueManager.is_dialogue_active:
		# Stop all movement during dialogue
		velocity.x = 0
		
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
		# Just landed - play landing sound if we were falling
		if is_falling:
			AudioManager.play_sfx("land")
		is_falling = false
		is_jumping = false

func handle_jump():
	# Don't allow jumping during dialogue
	if DialogueManager.is_dialogue_active:
		return
		
	# Handle jump input (but not during dialogue or while hanging)
	if Input.is_action_just_pressed("jump") and is_on_floor() and climb_state == ClimbState.NORMAL:
		velocity.y = jump_velocity
		is_jumping = true
		# Play jump sound
		AudioManager.play_sfx("jump")
	
	# Manual ledge grab for testing (G key)
	if Input.is_action_just_pressed("ui_accept") and Input.is_key_pressed(KEY_G) and climb_state == ClimbState.NORMAL:
		print("Manual ledge grab triggered!")
		start_hanging()

func handle_horizontal_movement(delta):
	# Don't allow horizontal movement during dialogue
	if DialogueManager.is_dialogue_active:
		# Apply friction to stop movement
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		return
	
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
	# Check for ledge grab when falling OR jumping (more forgiving)
	if climb_state != ClimbState.NORMAL or not can_grab_ledge:
		return
	
	# Allow ledge grab when falling OR when jumping up towards a platform
	if not (is_falling or (is_jumping and velocity.y > -100)):  # Allow grab when jumping upward (more responsive)
		return
	
	# Only check if detectors exist
	if not wall_detector_right or not wall_detector_left or not ledge_detector_right or not ledge_detector_left:
		print("Ledge grab failed: Missing detectors")
		return
	
	# Check for platform edge grabbing - only grab platform edges, not walls
	var can_grab_right = false
	var can_grab_left = false
	
	# Check if there's a wall to the right AND no ledge above (indicating a platform edge)
	if (wall_detector_right.is_colliding() and 
		not ledge_detector_right.is_colliding() and
		is_valid_climbable_surface(wall_detector_right.get_collider())):
		can_grab_right = true
		
	# Check if there's a wall to the left AND no ledge above (indicating a platform edge)
	if (wall_detector_left.is_colliding() and 
		not ledge_detector_left.is_colliding() and
		is_valid_climbable_surface(wall_detector_left.get_collider())):
		can_grab_left = true
	
	# Debug output
	if wall_detector_right.is_colliding() or wall_detector_left.is_colliding():
		print("Wall detection - Right: ", wall_detector_right.is_colliding(), 
			  " Left: ", wall_detector_left.is_colliding())
		print("Ledge detection - Right: ", ledge_detector_right.is_colliding(), 
			  " Left: ", ledge_detector_left.is_colliding())
		print("Can grab - Right: ", can_grab_right, " Left: ", can_grab_left)
	
	if can_grab_right or can_grab_left:
		# Update facing direction based on which side we're grabbing
		if can_grab_right:
			facing_right = true
		else:
			facing_right = false
		start_hanging()

func start_hanging():
	climb_state = ClimbState.HANGING
	velocity = Vector2.ZERO
	hanging_position = global_position
	can_grab_ledge = false
	ledge_grab_cooldown = 0.5  # Prevent immediate re-grabbing
	
	# Play climbing grab sound
	AudioManager.play_sfx("climb_grab")
	print("Started hanging on ledge")

func handle_hanging_movement(delta):
	# First, check if we're still near a valid wall - if not, drop automatically
	if not is_still_near_wall():
		print("No longer near wall, dropping from ledge")
		drop_from_ledge()
		return
	
	# Player can move left/right slightly while hanging, or climb up
	var direction = Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("jump"):
		# Climb up
		start_climbing_up()
	elif Input.is_action_just_pressed("move_down"):
		# Drop down
		drop_from_ledge()
	elif direction != 0:
		# Move along ledge (limited movement) but check for valid wall
		var old_position = global_position
		global_position.x += direction * climb_speed * 0.5 * delta
		facing_right = direction > 0
		
		# If movement would take us away from wall, revert and drop
		if not is_still_near_wall():
			global_position = old_position
			drop_from_ledge()

func start_climbing_up():
	climb_state = ClimbState.CLIMBING_UP
	velocity = Vector2.ZERO
	
	# Play climbing up sound
	AudioManager.play_sfx("climb_up")
	
	# Find the platform we're climbing onto
	var wall_detector = wall_detector_right if facing_right else wall_detector_left
	
	if wall_detector and wall_detector.is_colliding():
		var platform = wall_detector.get_collider()
		if platform and platform is StaticBody2D:
			# Calculate target position on top of the platform
			var platform_top = platform.global_position.y - 20  # Adjust for platform height
			var target_x = global_position.x + (20 if facing_right else -20)  # Move slightly onto platform
			var target_position = Vector2(target_x, platform_top - 40)  # Above platform surface
			
			# Create tween for smooth climb up animation
			var tween = create_tween()
			tween.tween_property(self, "global_position", target_position, 0.8)
			tween.tween_callback(finish_climbing_up)
			
			print("Climbing up to platform at: ", target_position)
		else:
			# Fallback to original method
			var tween = create_tween()
			var target_position = global_position + Vector2(0, -60)  # Increased climb height
			tween.tween_property(self, "global_position", target_position, 0.8)
			tween.tween_callback(finish_climbing_up)
			print("Climbing up ledge (fallback method)")
	else:
		print("No platform detected for climbing up")

func finish_climbing_up():
	climb_state = ClimbState.NORMAL
	velocity = Vector2.ZERO
	# Ensure player is on solid ground after climbing up
	if is_on_floor():
		print("Successfully climbed up onto platform")
	else:
		# If not on floor, do a small upward adjustment
		global_position.y -= 10
		print("Adjusted position after climbing up")
	print("Finished climbing up")

func drop_from_ledge():
	climb_state = ClimbState.NORMAL
	velocity.y = 100  # Small downward velocity
	print("Dropped from ledge")

func is_still_near_wall() -> bool:
	# Check if we're still near a valid wall for hanging
	if not wall_detector_right or not wall_detector_left:
		return false
	
	# Check the appropriate wall detector based on facing direction
	if facing_right:
		return wall_detector_right.is_colliding() and is_valid_climbable_surface(wall_detector_right.get_collider())
	else:
		return wall_detector_left.is_colliding() and is_valid_climbable_surface(wall_detector_left.get_collider())

func is_valid_climbable_surface(collider: Node) -> bool:
	# Only allow climbing on static bodies (platforms, walls) and TileMaps
	# Exclude NPCs, Player, and other dynamic objects
	if not collider:
		print("Invalid climbable surface: null collider")
		return false
	
	# Check if it's an NPC
	if collider.has_method("interact") or collider.is_in_group("npcs") or collider is NPC:
		print("Cannot climb on NPC: ", collider.name)
		return false
	
	# Check if it's the player themselves (shouldn't happen but just in case)
	if collider == self or collider.is_in_group("player"):
		print("Cannot climb on player: ", collider.name)
		return false
	
	# Allow climbing on StaticBody2D (platforms, walls) and TileMap
	if collider is StaticBody2D or collider is TileMap:
		print("Valid climbable surface: ", collider.name, " (", collider.get_class(), ")")
		return true
	
	# For other types, check if it has a specific "climbable" group or meta
	if collider.is_in_group("climbable") or collider.has_meta("climbable"):
		print("Valid climbable surface (marked): ", collider.name, " (", collider.get_class(), ")")
		return true
	
	print("Invalid climbable surface: ", collider.name, " (", collider.get_class(), ") - not StaticBody2D or marked climbable")
	return false

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
					sprite.color = Color(0.4, 0.6, 0.2, 1)  # Green when walking (messenger color)
				else:
					sprite.color = Color(0.4, 0.6, 0.2, 1)  # Green when idle (messenger color)
	elif not sprite:
		print("WARNING: PlaceholderSprite not found - player may not be visible")
	
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
