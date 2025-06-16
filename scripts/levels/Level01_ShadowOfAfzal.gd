extends Node2D

# Level 1: The Shadow of Afzal Khan
# Story: Player is a messenger bringing urgent news to Shivaji about Afzal Khan's appointment
# Based on story-plan.md structure

@onready var player = $Player
@onready var objectives_ui = $UI/ObjectivesUI
@onready var dialogue_ui = $UI/DialogueUI
@onready var level_complete_ui = $UI/LevelCompleteUI
@onready var camera = $PlatformerCamera

var level_data: Dictionary = {}
var current_objectives: Array = []
var npcs: Array = []
var areas: Array = []

var level_started: bool = false
var cutscene_playing: bool = false
var current_story_beat: int = 0

# Story progression states
enum StoryBeat {
	OPENING_CUTSCENE,      # Bijapur court + temple destruction
	VILLAGE_NAVIGATION,    # Messenger travels through village
	STEALTH_SECTION,       # Avoiding Afzal Khan's scouts
	VILLAGER_INTERACTIONS, # Talk to worried villagers and priest
	REACHING_RAJGAD,       # Arrive at Shivaji's fort
	ENDING_CUTSCENE        # Deliver message to Shivaji
}

func _ready():
	load_level_data()
	setup_level()
	start_level()

func load_level_data():
	# Create Level 1 data based on story-plan.md
	level_data = {
		"name": "The Shadow of Afzal Khan",
		"objectives": [
			{
				"id": "watch_appointment",
				"text": "Watch Afzal Khan's appointment ceremony",
				"completed": false
			},
			{
				"id": "navigate_village", 
				"text": "Navigate through the village as messenger",
				"completed": false
			},
			{
				"id": "avoid_scouts",
				"text": "Avoid Afzal Khan's scouts using stealth",
				"completed": false
			},
			{
				"id": "talk_to_villagers",
				"text": "Speak with worried villagers and priest",
				"completed": false
			},
			{
				"id": "reach_shivaji",
				"text": "Deliver urgent news to Shivaji Maharaj",
				"completed": false
			}
		],
		"npcs": [
			{
				"id": "worried_villager",
				"name": "Worried Villager",
				"position": {"x": 200, "y": 470},  # Ground level (550 - 80 for character height)
				"dialogue_id": "villager_fear",
				"interaction_text": "Press E to talk to villager"
			},
			{
				"id": "priest",
				"name": "Village Priest", 
				"position": {"x": 600, "y": 240},  # Platform2 level (320 - 80 for character height)
				"dialogue_id": "priest_temples",
				"interaction_text": "Press E to talk to priest"
			},
			{
				"id": "shivaji",
				"name": "Chhatrapati Shivaji Maharaj",
				"position": {"x": 900, "y": 140},  # Platform3 level (220 - 80 for character height)
				"dialogue_id": "shivaji_receives_news",
				"interaction_text": "Press E to deliver message"
			}
		],
		"cutscenes": [
			{
				"id": "opening_bijapur_court",
				"trigger": "level_start",
				"dialogue_id": "bijapur_appointment"
			},
			{
				"id": "ending_rajgad_fort",
				"trigger": "reach_shivaji",
				"dialogue_id": "messenger_delivers_news"
			}
		]
	}
	
	current_objectives = level_data.get("objectives", [])

func setup_level():
	# Create NPCs based on story
	create_story_npcs()
	
	# Create stealth areas (scout patrol zones)
	create_stealth_areas()
	
	# Connect dialogue manager signals
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# Setup UI
	if objectives_ui:
		objectives_ui.visible = true
		update_objectives_display()
	
	if level_complete_ui:
		level_complete_ui.visible = false
	
	# Set player as messenger character
	if player:
		player.character_name = "Messenger"
		print("Player is now: Messenger bringing urgent news to Shivaji")

func create_story_npcs():
	var npc_scene = preload("res://scenes/shared/characters/NPC.tscn")
	
	for npc_data in level_data.get("npcs", []):
		var npc = npc_scene.instantiate()
		npc.position = Vector2(npc_data.position.x, npc_data.position.y)
		npc.npc_name = npc_data.name
		npc.dialogue_id = npc_data.dialogue_id
		npc.interaction_text = npc_data.interaction_text
		
		# Assign sprites based on story characters
		match npc_data.id:
			"worried_villager":
				# PLACEHOLDER: Need taller villager sprite
				npc.set_npc_color(Color(0.8, 0.6, 0.4, 1))  # Brown for villager
				print("Created worried villager NPC (using placeholder - need taller villager sprite)")
			"priest":
				# PLACEHOLDER: Need taller priest sprite  
				npc.set_npc_color(Color(1, 1, 0.8, 1))  # Light yellow/cream for priest
				print("Created village priest NPC (using placeholder - need taller priest sprite)")
			"shivaji":
				# Use actual Shivaji idle sprite with full animation
				var shivaji_sheet = load("res://assets/art/characters/shivaji/shivaji_idle.png")
				npc.sprite_texture = shivaji_sheet
				npc.use_animation = true  # Enable animation for Shivaji
				print("Created Shivaji NPC with animated idle sprite (4x3 grid, 5 FPS) at Rajgad Fort")
		
		npc.set_meta("npc_id", npc_data.id)
		npc.npc_interacted.connect(_on_npc_interacted)
		add_child(npc)
		npcs.append(npc)

func create_stealth_areas():
	# Create scout patrol areas where player must use stealth
	var scout_area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	shape.size = Vector2(200, 100)
	collision.shape = shape
	scout_area.add_child(collision)
	
	scout_area.position = Vector2(550, 450)  # Between villager and priest
	scout_area.name = "ScoutPatrolArea"
	scout_area.body_entered.connect(_on_scout_area_entered)
	scout_area.body_exited.connect(_on_scout_area_exited)
	
	add_child(scout_area)
	
	# Add subtle visual indicator for stealth area
	var stealth_indicator = ColorRect.new()
	stealth_indicator.size = Vector2(200, 100)
	stealth_indicator.position = Vector2(-100, -50)
	stealth_indicator.color = Color(1, 0.5, 0, 0.15)  # Very subtle orange tint
	scout_area.add_child(stealth_indicator)
	
	# Add smaller, less intrusive warning label
	var warning_label = Label.new()
	warning_label.text = "Stealth Zone"
	warning_label.position = Vector2(-35, -10)
	warning_label.add_theme_color_override("font_color", Color(1, 0.8, 0, 0.7))
	warning_label.add_theme_font_size_override("font_size", 12)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scout_area.add_child(warning_label)
	
	print("Created scout patrol area with clear visual indicators")

func start_level():
	level_started = true
	current_story_beat = StoryBeat.OPENING_CUTSCENE
	
	print("=== LEVEL 1: THE SHADOW OF AFZAL KHAN ===")
	print("STORY: You are a messenger bringing urgent news about Afzal Khan to Shivaji Maharaj")
	print("CONTROLS: A/D to move, SPACE to jump, E to interact")
	print("GOAL: Navigate through the village, avoid scouts, talk to villagers, reach Shivaji")
	
	# Start with opening cutscene
	play_opening_cutscene()

func play_opening_cutscene():
	cutscene_playing = true
	current_story_beat = StoryBeat.OPENING_CUTSCENE
	
	# Disable player movement during cutscene
	if player:
		player.disable_movement()
	
	# Create dialogue for Bijapur court scene
	var bijapur_dialogue = [
		{
			"speaker": "Narrator",
			"text": "In the year 1659, the Adilshahi kingdom faced a growing threat. A young warrior named Shivaji had begun to challenge their authority..."
		},
		{
			"speaker": "Mohammad Adil Shah",
			"text": "Mother, this Shivaji grows bolder by the day. Our territories shrink while his influence spreads."
		},
		{
			"speaker": "Badi Sahiba", 
			"text": "Fear not, my son. We have the perfect weapon. Summon Afzal Khan."
		},
		{
			"speaker": "Afzal Khan",
			"text": "Your Majesty commands, and I obey."
		},
		{
			"speaker": "Mohammad Adil Shah",
			"text": "Afzal Khan, you are appointed our war general. Bring me Shivaji's head, or his submission."
		},
		{
			"speaker": "Afzal Khan",
			"text": "Who is this Shivaji? I will not even need to dismount my horse to arrest him!"
		},
		{
			"speaker": "Narrator",
			"text": "Afzal Khan's seal bore the words 'Killer of Infidels, Destroyer of Deities.' His reputation preceded him..."
		}
	]
	
	# Start dialogue sequence
	DialogueManager.start_dialogue_sequence(bijapur_dialogue)

func _on_dialogue_ended():
	cutscene_playing = false
	
	match current_story_beat:
		StoryBeat.OPENING_CUTSCENE:
			# Opening cutscene finished, start village navigation
			complete_objective("watch_appointment")
			current_story_beat = StoryBeat.VILLAGE_NAVIGATION
			
			# Enable player movement
			if player:
				player.enable_movement()
			
			print("=== VILLAGE NAVIGATION BEGINS ===")
			print("Navigate through the village to reach Shivaji at Rajgad Fort")
			
		StoryBeat.REACHING_RAJGAD:
			# Ending cutscene finished, complete level
			complete_level()

func _on_npc_interacted(npc: Node):
	var npc_id = npc.get_meta("npc_id", "")
	
	match npc_id:
		"worried_villager":
			current_story_beat = StoryBeat.VILLAGER_INTERACTIONS
			# Dialogue handled by DialogueManager
			
		"priest":
			current_story_beat = StoryBeat.VILLAGER_INTERACTIONS
			# Dialogue handled by DialogueManager
			
		"shivaji":
			current_story_beat = StoryBeat.REACHING_RAJGAD
			complete_objective("reach_shivaji")
			play_ending_cutscene()

func play_ending_cutscene():
	cutscene_playing = true
	
	# Disable player movement
	if player:
		player.disable_movement()
	
	# Create dialogue for Rajgad Fort scene
	var rajgad_dialogue = [
		{
			"speaker": "Messenger",
			"text": "Shivaji Maharaj, Afzal Khan has been appointed. He comes with over 20,000 men!"
		},
		{
			"speaker": "Shivaji",
			"text": "So, the butcher of temples seeks to add my head to his collection. We shall see who the hunter truly is."
		},
		{
			"speaker": "Netoji Palkar",
			"text": "My lord, his reputation is fearsome. Even the stones speak of his cruelty."
		},
		{
			"speaker": "Shivaji",
			"text": "Netoji, a reputation built on fear is like a palace built on sand. Gather our advisors. We have preparations to make."
		}
	]
	
	DialogueManager.start_dialogue_sequence(rajgad_dialogue)

func _on_scout_area_entered(body: Node):
	if body == player:
		print("=== STEALTH SECTION ===")
		print("You've entered a scout patrol area! Move carefully to avoid detection.")
		current_story_beat = StoryBeat.STEALTH_SECTION
		# Could add stealth mechanics here (crouching, slower movement, etc.)

func _on_scout_area_exited(body: Node):
	if body == player:
		print("Scout area cleared! Well done avoiding detection.")
		complete_objective("avoid_scouts")

func complete_objective(objective_id: String):
	for objective in current_objectives:
		if objective.id == objective_id and not objective.completed:
			objective.completed = true
			print("✅ Objective completed: ", objective.text)
			update_objectives_display()
			break

func update_objectives_display():
	if not objectives_ui:
		return
	
	# Clear existing objective labels
	var objectives_list = objectives_ui.get_node("Panel/VBox/ObjectivesList")
	for child in objectives_list.get_children():
		child.queue_free()
	
	# Add current objectives
	for objective in current_objectives:
		var label = Label.new()
		if objective.completed:
			label.text = "✅ " + objective.text
			label.modulate = Color.GREEN
		else:
			label.text = "◯ " + objective.text
			label.modulate = Color.WHITE
		
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		objectives_list.add_child(label)

func complete_level():
	print("=== LEVEL 1 COMPLETED ===")
	
	# Show level complete UI with Shivkaari card
	var card_data = {
		"title": "Understanding the Enemy",
		"description": "Shivaji's wisdom in gathering intelligence before acting",
		"value": "Information is the foundation of strategy",
		"explanation": "Before facing Afzal Khan, Shivaji spent months gathering intelligence through spies and messengers. This careful preparation was key to his victory."
	}
	
	# Award the card and mark level as complete
	GameManager.complete_level(1, card_data)
	
	# Show completion UI
	if level_complete_ui:
		level_complete_ui.show_completion(card_data)

func _input(event):
	# Handle level-specific inputs
	if event.is_action_pressed("ui_cancel") and not cutscene_playing:
		# Return to main menu
		get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn") 
