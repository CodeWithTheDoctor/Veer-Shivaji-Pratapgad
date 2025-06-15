extends CharacterBody2D
class_name NPC

@export var npc_name: String = "NPC"
@export var dialogue_id: String = ""
@export var can_interact: bool = true
@export var interaction_text: String = "Press E to talk"

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
	
	# Set up basic appearance (placeholder colored rectangle)
	if sprite:
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
	if dialogue_id != "":
		DialogueManager.start_dialogue(dialogue_id)
	npc_interacted.emit(self)

func set_npc_color(color: Color):
	if sprite and sprite.texture:
		sprite.modulate = color 
