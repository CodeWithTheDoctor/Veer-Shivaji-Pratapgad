extends CharacterBody2D
class_name NPC

@export var npc_name: String = "NPC"
@export var dialogue_id: String = ""
@export var can_interact: bool = true
@export var interaction_text: String = "Press E to talk"
@export var sprite_texture: Texture2D
@export var use_animation: bool = false

@onready var placeholder_sprite = $PlaceholderSprite
@onready var actual_sprite = $ActualSprite
@onready var animated_sprite = $AnimatedSprite
@onready var npc_label = $PlaceholderSprite/NPCLabel
@onready var interaction_prompt = $InteractionPrompt
@onready var detection_area = $DetectionArea
@onready var collision_shape = $CollisionShape2D

var player_nearby: bool = false
var animation_check_timer: float = 0.0  # Add timer to prevent excessive animation checking

signal npc_interacted(npc: NPC)

func _ready():
	# Add NPCs to the "npcs" group so player can't climb on them
	add_to_group("npcs")
	setup_npc()

func _process(delta):
	# Only check animated sprite health occasionally to prevent flickering
	if use_animation and animated_sprite and sprite_texture:
		# Update timer and only check every 0.5 seconds to prevent flicker loops
		animation_check_timer += delta
		if animation_check_timer < 0.5:
			return
		animation_check_timer = 0.0
		
		# Check visibility (less frequently to prevent flicker)
		if not animated_sprite.visible:
			animated_sprite.visible = true
			print("Restored animated sprite visibility for ", npc_name)
		
		# Only check animation status if sprite_frames exist and we're not already playing
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("idle"):
			# Only restart if animation is genuinely stopped (not just between frames)
			if not animated_sprite.is_playing():
				var frame_count = animated_sprite.sprite_frames.get_frame_count("idle")
				if frame_count > 0:
					animated_sprite.play("idle")
					print("Restarted animation for ", npc_name, " (", frame_count, " frames)")
				else:
					print("WARNING: No frames available for animation: ", npc_name)
		
		# Ensure other sprites are hidden when using animation (only once)
		if placeholder_sprite and placeholder_sprite.visible:
			placeholder_sprite.visible = false
		if actual_sprite and actual_sprite.visible:
			actual_sprite.visible = false

func setup_npc():
	# Set up interaction prompt
	if interaction_prompt:
		interaction_prompt.visible = false
		interaction_prompt.text = interaction_text
	
	# Set up detection area
	if detection_area:
		detection_area.body_entered.connect(_on_player_entered)
		detection_area.body_exited.connect(_on_player_exited)
	
	# Set up sprite appearance
	if sprite_texture:
		if use_animation:
			# Use animated sprite with sprite frames
			setup_animated_sprite()
			# Ensure only animated sprite is visible
			if actual_sprite:
				actual_sprite.visible = false
		else:
			# Use static sprite texture
			if actual_sprite:
				actual_sprite.texture = sprite_texture
				actual_sprite.visible = true
			if animated_sprite:
				animated_sprite.visible = false
		if placeholder_sprite:
			placeholder_sprite.visible = false
		print("NPC ", npc_name, " using actual sprite texture (animated: ", use_animation, ")")
	else:
		# Use placeholder ColorRect
		if placeholder_sprite:
			placeholder_sprite.color = Color(0, 0.5, 1, 1)  # Blue for NPCs
			placeholder_sprite.visible = true
		if actual_sprite:
			actual_sprite.visible = false
		if animated_sprite:
			animated_sprite.visible = false
		if npc_label:
			npc_label.text = npc_name.to_upper() if npc_name != "NPC" else "NPC"
		print("NPC ", npc_name, " using placeholder sprite")
	
	# Set up collision - make NPCs walkable by using Area2D instead of solid collision
	if collision_shape:
		var shape = RectangleShape2D.new()
		if sprite_texture:
			# Smaller collision for actual sprites to allow walking past
			shape.size = Vector2(20, 30)  # Much smaller - only for interaction detection
		else:
			# Smaller collision for placeholder - allows walking past
			shape.size = Vector2(20, 40)
		collision_shape.shape = shape
		
		# Make NPCs non-solid by changing collision layer/mask
		# NPCs should be on a different layer that doesn't block player movement
		set_collision_layer(2)  # Layer 2 for NPCs
		set_collision_mask(0)   # Don't collide with anything

func setup_animated_sprite():
	if not animated_sprite or not sprite_texture:
		print("Cannot setup animated sprite - missing components")
		return
	
	# Stop any existing animation first
	if animated_sprite.is_playing():
		animated_sprite.stop()
	
	# Create SpriteFrames for animation
	var sprite_frames = SpriteFrames.new()
	
	# Create idle animation with multiple frames from the sprite sheet
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_loop("idle", true)
	sprite_frames.set_animation_speed("idle", 5.0)  # 5 FPS as requested
	
	# Get sprite texture size to determine frame dimensions
	var texture_size = sprite_texture.get_size()
	print("Sprite texture size for ", npc_name, ": ", texture_size)
	
	# For the 100x150 Shivaji sprite, use correct grid layout
	# The sprite is actually 4x3 grid: 100/4 = 25px wide, 150/3 = 50px tall per frame
	var cols = 4
	var rows = 3
	
	# Special handling for Shivaji sprite sheet (268x300 total, 67x100 per frame)
	if texture_size.x == 268 and texture_size.y == 300:
		cols = 4  # 4 columns = 67px per frame
		rows = 3  # 3 rows = 100px per frame
		print("Using 4x3 grid for 268x300 Shivaji sprite sheet (67x100 per frame)")
	else:
		# For other sprite sizes, keep 4x3 as default
		cols = 4
		rows = 3
	
	var frame_width = texture_size.x / cols
	var frame_height = texture_size.y / rows
	
	print("Calculated frame size for ", npc_name, ": ", frame_width, "x", frame_height, " (", cols, "x", rows, " grid)")
	
	# Add frames from the sprite sheet (but limit to 12 frames max to prevent issues)
	var frame_count = 0
	var max_frames = min(cols * rows, 12)  # Limit to 12 frames maximum
	
	for row in range(rows):
		for col in range(cols):
			if frame_count >= max_frames:
				break
				
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = sprite_texture
			atlas_texture.region = Rect2(col * frame_width, row * frame_height, frame_width, frame_height)
			sprite_frames.add_frame("idle", atlas_texture)
			frame_count += 1
		
		if frame_count >= max_frames:
			break
	
	# Ensure we have frames before applying
	if frame_count == 0:
		print("ERROR: No frames created for animated sprite - check sprite dimensions")
		return
	
	# Apply to animated sprite with more robust setup
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.animation = "idle"
	animated_sprite.frame = 0  # Start at frame 0
	animated_sprite.visible = true
	animated_sprite.scale = Vector2(1.0, 1.0)  # Ensure proper scale
	animated_sprite.offset = Vector2(0, 10)    # Adjust position to align with ground
	
	# Start animation immediately but ensure it's properly initialized
	animated_sprite.play("idle")
	
	print("SUCCESS: Created animated sprite with ", frame_count, " frames at 5 FPS for ", npc_name)
	print("Frame dimensions: ", frame_width, "x", frame_height)
	print("Animation playing: ", animated_sprite.is_playing())
	print("Total frames in animation: ", animated_sprite.sprite_frames.get_frame_count("idle"))

func _unhandled_input(event):
	if player_nearby and can_interact and event.is_action_pressed("interact"):
		# Only start dialogue if dialogue system is not already active
		if not DialogueManager.is_dialogue_active:
			print("NPC ", npc_name, " starting interaction with dialogue ID: ", dialogue_id)
			interact()
			get_viewport().set_input_as_handled()  # Prevent other nodes from processing this input
		else:
			print("Dialogue already active - ignoring interaction with ", npc_name)
			# Don't handle the input if dialogue is active to prevent conflicts
			return

func _on_player_entered(body):
	if body.name == "Player":
		player_nearby = true
		show_interaction_prompt()

func _on_player_exited(body):
	if body.name == "Player":
		player_nearby = false
		hide_interaction_prompt()

func show_interaction_prompt():
	if interaction_prompt:
		interaction_prompt.visible = true

func hide_interaction_prompt():
	if interaction_prompt:
		interaction_prompt.visible = false

func interact():
	# Make NPC face the player when interacting
	face_player()
	
	# Play interaction sound
	AudioManager.play_sfx("interact")
	
	if dialogue_id != "":
		DialogueManager.start_dialogue(dialogue_id)
	npc_interacted.emit(self)

func face_player():
	# Find the player and turn to face them
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		# Fallback: try to find by name
		player = get_parent().get_node_or_null("Player")
	
	if player:
		var player_position = player.global_position
		var npc_position = global_position
		
		if sprite_texture:
			if use_animation and animated_sprite and animated_sprite.visible:
				# For animated sprite, flip horizontally to face player
				if player_position.x < npc_position.x:
					animated_sprite.flip_h = true
				else:
					animated_sprite.flip_h = false
			elif actual_sprite and actual_sprite.visible:
				# For static sprite, flip horizontally to face player
				if player_position.x < npc_position.x:
					actual_sprite.flip_h = true
				else:
					actual_sprite.flip_h = false
		elif placeholder_sprite and placeholder_sprite.visible:
			# For ColorRect placeholder, change color slightly to indicate facing
			if player_position.x < npc_position.x:
				# Player is to the left, darken color slightly
				placeholder_sprite.color = Color(0, 0.4, 0.8, 1)
			else:
				# Player is to the right, normal color
				placeholder_sprite.color = Color(0, 0.5, 1, 1)
		
		print("NPC ", npc_name, " turned to face player")

func set_npc_color(color: Color):
	if sprite_texture and actual_sprite:
		actual_sprite.modulate = color
	elif placeholder_sprite:
		placeholder_sprite.color = color 
