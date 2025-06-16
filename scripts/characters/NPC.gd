extends CharacterBody2D
class_name NPC

@export var npc_name: String = "NPC"
@export var dialogue_id: String = ""
@export var can_interact: bool = true
@export var interaction_text: String = "Press E to talk"
@export var sprite_texture: Texture2D

@onready var sprite = $Sprite2D
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
	if sprite:
		if sprite_texture:
			# Use the assigned sprite texture
			sprite.texture = sprite_texture
			sprite.scale = Vector2(1.5, 1.5)  # Same scale as Shivaji for consistency
		else:
			# Fallback to placeholder colored rectangle
			var texture = ImageTexture.new()
			var image = Image.create(32, 48, false, Image.FORMAT_RGB8)
			image.fill(Color.BLUE)  # Blue for NPCs
			texture.set_image(image)
			sprite.texture = texture
	
	# Set up collision
	if collision_shape:
		var shape = RectangleShape2D.new()
		shape.size = Vector2(32, 48)
		collision_shape.shape = shape

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
	
	if player and sprite:
		var player_position = player.global_position
		var npc_position = global_position
		
		# Determine if player is to the left or right of NPC
		if player_position.x < npc_position.x:
			# Player is to the left, NPC should face left (flip sprite)
			sprite.flip_h = true
		else:
			# Player is to the right, NPC should face right (normal sprite)
			sprite.flip_h = false
		
		print("NPC ", npc_name, " turned to face player")

func set_npc_color(color: Color):
	if sprite and sprite.texture:
		sprite.modulate = color 
