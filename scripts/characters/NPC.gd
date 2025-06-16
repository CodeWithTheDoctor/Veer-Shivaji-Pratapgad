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

signal npc_interacted(npc: NPC)

func _ready():
	setup_npc()
	
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
	
	# Set up collision
	if collision_shape:
		var shape = RectangleShape2D.new()
		if sprite_texture:
			# Collision for actual sprites (1.0x scale of 67x100 sprite)
			shape.size = Vector2(34, 50)  # Adjusted for 1.0x scale of 67x100 sprite
		else:
			# Standard collision for placeholder
			shape.size = Vector2(32, 80)
		collision_shape.shape = shape

func setup_animated_sprite():
	if not animated_sprite or not sprite_texture:
		return
	
	# Create SpriteFrames for animation
	var sprite_frames = SpriteFrames.new()
	
	# Create idle animation with multiple frames from the sprite sheet
	sprite_frames.add_animation("idle")
	sprite_frames.set_animation_loop("idle", true)
	sprite_frames.set_animation_speed("idle", 5.0)  # 5 FPS as requested
	
	# Add frames from the 4x3 sprite sheet (67x100 per frame)
	for row in range(3):  # 3 rows
		for col in range(4):  # 4 columns
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = sprite_texture
			atlas_texture.region = Rect2(col * 67, row * 100, 67, 100)
			sprite_frames.add_frame("idle", atlas_texture)
	
	# Apply to animated sprite
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.animation = "idle"
	animated_sprite.visible = true
	animated_sprite.play("idle")
	
	print("Created animated sprite with ", sprite_frames.get_frame_count("idle"), " frames at 5 FPS")

func _input(event):
	if player_nearby and can_interact and event.is_action_pressed("interact"):
		# Only start dialogue if dialogue system is not already active
		if not DialogueManager.is_dialogue_active:
			interact()

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
