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
var current_story_beat: int = 0
var pending_objective_completion: String = ""

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
	
	# Start with opening cutscene
	play_opening_cutscene()
	print("CONTROLS: A/D to move, SPACE to jump, E to interact")
	print("GOAL: Navigate through the village, avoid scouts, talk to villagers, reach Shivaji")

func play_opening_cutscene():
	print("Starting opening cutscene...")
	
	# Load and instantiate cutscene player
	var cutscene_scene = preload("res://scenes/cutscenes/CutscenePlayer.tscn")
	var cutscene_player = cutscene_scene.instantiate()
	
	# Add to scene tree
	get_tree().current_scene.add_child(cutscene_player)
	
	# Connect signal
	cutscene_player.cutscene_finished.connect(_on_opening_cutscene_finished)
	
	# Start the cutscene
	cutscene_player.play_cutscene("opening_bijapur_court")
	
	# Pause gameplay during cutscene
	set_gameplay_active(false)

func play_ending_cutscene():
	print("Starting ending cutscene...")
	
	# Load and instantiate cutscene player
	var cutscene_scene = preload("res://scenes/cutscenes/CutscenePlayer.tscn")
	var cutscene_player = cutscene_scene.instantiate()
	
	# Add to scene tree
	get_tree().current_scene.add_child(cutscene_player)
	
	# Connect signal
	cutscene_player.cutscene_finished.connect(_on_ending_cutscene_finished)
	
	# Start the cutscene
	cutscene_player.play_cutscene("ending_rajgad_fort")
	
	# Pause gameplay during cutscene
	set_gameplay_active(false)

func _on_opening_cutscene_finished(next_scene: String):
	print("Opening cutscene finished, transitioning to: ", next_scene)
	
	# Remove cutscene player
	var cutscene_player = get_tree().get_nodes_in_group("cutscene_player")
	if cutscene_player.size() > 0:
		cutscene_player[0].queue_free()
	
	# Resume gameplay
	set_gameplay_active(true)
	current_story_beat = StoryBeat.VILLAGE_NAVIGATION
	
	# Update objectives
	complete_objective("watch_appointment")

func _on_ending_cutscene_finished(next_scene: String):
	print("Ending cutscene finished, transitioning to: ", next_scene)
	
	# Remove cutscene player
	var cutscene_player = get_tree().get_nodes_in_group("cutscene_player")
	if cutscene_player.size() > 0:
		cutscene_player[0].queue_free()
	
	# Complete level
	complete_level()

func set_gameplay_active(active: bool):
	# Enable/disable player input and camera
	if player:
		player.set_physics_process(active)
		player.set_process_input(active)
	
	if camera:
		camera.enabled = active
	
	# Hide/show UI during cutscenes
	if objectives_ui:
		objectives_ui.visible = active

func _on_dialogue_ended():
	# Handle pending objective completion after dialogue ends
	if pending_objective_completion != "":
		complete_objective(pending_objective_completion)
		pending_objective_completion = ""
		
		# Check if all objectives are complete
		var all_complete = true
		for objective in current_objectives:
			if not objective.completed:
				all_complete = false
				break
		
		if all_complete:
			print("All objectives completed! Level finished.")
			complete_level()

func _on_npc_interacted(npc: Node):
	var npc_id = npc.get_meta("npc_id", "")
	print("Player interacted with NPC: ", npc_id)
	
	# Handle story progression based on NPC
	match npc_id:
		"worried_villager":
			if not is_objective_completed("talk_to_villagers"):
				pending_objective_completion = "talk_to_villagers"
				print("Talked to worried villager - will complete objective after dialogue")
		"priest":
			if not is_objective_completed("talk_to_villagers"):
				pending_objective_completion = "talk_to_villagers"
				print("Talked to priest - will complete objective after dialogue")
		"shivaji":
			if not is_objective_completed("reach_shivaji"):
				# Skip regular dialogue and go straight to ending cutscene
				print("Reached Shivaji - starting ending cutscene")
				play_ending_cutscene()
				return

func is_objective_completed(objective_id: String) -> bool:
	for objective in current_objectives:
		if objective.id == objective_id:
			return objective.completed
	return false

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
	if event.is_action_pressed("ui_cancel"):
		# Return to main menu
		get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn") 
