extends Node2D

# Level 1: The Shadow of Afzal Khan
# This level introduces the player to the story and demonstrates intelligence gathering

@onready var player = $Player
@onready var objectives_ui = $UI/ObjectivesUI
@onready var dialogue_ui = $UI/DialogueUI
@onready var level_complete_ui = $UI/LevelCompleteUI

var level_data: Dictionary = {}
var current_objectives: Array = []
var npcs: Array = []
var areas: Array = []

var level_started: bool = false
var cutscene_playing: bool = false

func _ready():
	load_level_data()
	setup_level()
	start_level()

func load_level_data():
	var file = FileAccess.open("res://data/level_data/level01_data.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			level_data = json.data["level_01"]
		file.close()
	else:
		print("Failed to load level 1 data")

func setup_level():
	# Initialize objectives
	current_objectives = level_data.get("objectives", [])
	
	# Create NPCs
	create_npcs()
	
	# Create interaction areas
	create_areas()
	
	# Connect dialogue manager signals
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# Setup UI
	if objectives_ui:
		objectives_ui.visible = true
		update_objectives_display()
	
	if level_complete_ui:
		level_complete_ui.visible = false

func create_npcs():
	var npc_scene = preload("res://scenes/shared/characters/NPC.tscn")
	
	for npc_data in level_data.get("npcs", []):
		var npc = npc_scene.instantiate()
		npc.position = Vector2(npc_data.position.x, npc_data.position.y)
		npc.npc_name = npc_data.name
		npc.dialogue_id = npc_data.dialogue_id
		npc.interaction_text = npc_data.interaction_text
		# Store the NPC ID in the NPC for later reference
		npc.set_meta("npc_id", npc_data.id)
		npc.npc_interacted.connect(_on_npc_interacted)
		add_child(npc)
		npcs.append(npc)

func create_areas():
	for area_data in level_data.get("areas", []):
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		
		shape.size = Vector2(area_data.size.width, area_data.size.height)
		collision.shape = shape
		area.add_child(collision)
		
		area.position = Vector2(area_data.position.x, area_data.position.y)
		area.name = area_data.id
		area.body_entered.connect(_on_area_entered.bind(area_data.id))
		
		add_child(area)
		areas.append(area)

func start_level():
	level_started = true
	
	# Show help text
	print("=== LEVEL 1: THE SHADOW OF AFZAL KHAN ===")
	print("CONTROLS: A/D or Arrow Keys to move, SPACE/W/Up to jump, E to interact (start dialogue)")
	print("DIALOGUE: SPACE to advance dialogue, E to start conversations, ESC to return to menu")
	print("GOAL: Jump between platforms, talk to NPCs, and complete all objectives")
	
	# Load and restore previous progress ONLY if continuing (not for new game)
	if GameManager.is_continuing_game:
		restore_saved_progress()
	else:
		print("=== STARTING NEW GAME - FRESH START ===")
	
	# Only play opening cutscene if starting fresh
	if should_play_opening_cutscene():
		# Disable player movement during opening cutscene
		if player:
			player.disable_movement()
		play_cutscene("bijapur_court")
	else:
		# Enable movement immediately if continuing
		if player:
			player.enable_movement()
		print("=== CONTINUING FROM SAVED PROGRESS ===")

func should_play_opening_cutscene() -> bool:
	# Check if any objectives are already completed (means we're continuing)
	for objective in current_objectives:
		if objective.completed:
			return false
	return true

func restore_saved_progress():
	print("=== RESTORING SAVED PROGRESS ===")
	
	# Check if there's saved progress for this level
	if GameManager.player_progress.has("level_01_partial"):
		var saved_data = GameManager.player_progress["level_01_partial"]
		var completed_objectives = saved_data.get("completed_objectives", [])
		var saved_position = saved_data.get("player_position", {"x": 100, "y": 500})
		
		print("Found saved progress with completed objectives: ", completed_objectives)
		print("Saved player position: ", saved_position)
		
		# Restore completed objectives
		for objective_id in completed_objectives:
			var objective = get_objective_by_id(objective_id)
			if objective:
				objective.completed = true
				print("Restored objective: ", objective_id)
		
		# Restore player position
		if player and saved_position:
			var restore_pos = Vector2(saved_position.x, saved_position.y)
			player.global_position = restore_pos
			print("Restored player position to: ", restore_pos)
		
		# Update objectives display
		update_objectives_display()
		
		print("Progress restoration complete!")
	else:
		print("No saved progress found - starting fresh")
	
	print("=== END PROGRESS RESTORATION ===")



func play_cutscene(cutscene_id: String):
	cutscene_playing = true
	
	# Find cutscene data
	var cutscene_data = null
	for cutscene in level_data.get("cutscenes", []):
		if cutscene.id == cutscene_id:
			cutscene_data = cutscene
			break
	
	if cutscene_data:
		DialogueManager.start_dialogue(cutscene_data.dialogue_id)

func _on_dialogue_ended():
	cutscene_playing = false
	
	# Re-enable player movement after cutscene
	if player:
		player.enable_movement()

func _on_area_entered(body: Node, area_id: String):
	if body != player:
		return
	
	# Areas are disabled for platformer version
	# All objectives now handled through NPC interactions

func _on_npc_interacted(npc: Node):
	var npc_id = npc.get_meta("npc_id", "")
	print("NPC interacted: ", npc_id)  # Debug print
	match npc_id:
		"advisor":
			if not get_objective_by_id("learn_threat").completed:
				print("Completing learn_threat objective")
				complete_objective("learn_threat")
		"spy_merchant":
			if not get_objective_by_id("gather_intelligence").completed:
				print("Completing gather_intelligence objective")
				complete_objective("gather_intelligence")
		"netaji_palkar":
			if not get_objective_by_id("consult_netaji").completed:
				print("Completing consult_netaji objective")
				complete_objective("consult_netaji")

func complete_objective(objective_id: String):
	var objective = get_objective_by_id(objective_id)
	if objective:
		objective.completed = true
		update_objectives_display()
		
		# Check if all objectives are complete
		check_level_completion()

func get_objective_by_id(objective_id: String) -> Dictionary:
	for objective in current_objectives:
		if objective.id == objective_id:
			return objective
	return {}

func check_level_completion():
	var all_complete = true
	for objective in current_objectives:
		if not objective.completed:
			all_complete = false
			break
	
	if all_complete:
		complete_level()

func complete_level():
	# Play completion cutscene
	play_cutscene("level_completion")
	
	# Award Shivkaari card
	var card_data = level_data.completion_reward.shivkaari_card
	GameManager.complete_level(1, card_data)
	
	# Show level complete UI
	if level_complete_ui:
		level_complete_ui.visible = true
		level_complete_ui.setup_completion_screen(
			level_data.name,
			card_data.title,
			card_data.description
		)

func update_objectives_display():
	if not objectives_ui:
		return
	
	var objective_texts = []
	for objective in current_objectives:
		var status = "✓" if objective.completed else "○"
		objective_texts.append(status + " " + objective.text)
	
	objectives_ui.update_objectives(objective_texts)

func _input(event):
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		if not cutscene_playing:
			# Save current progress before returning to menu
			save_current_progress()
			print("Returning to main menu (Press ESC or P)")
			get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func save_current_progress():
	# Save the current state of objectives for mid-level continuation
	var completed_objectives = []
	for objective in current_objectives:
		if objective.completed:
			completed_objectives.append(objective.id)
	
	# Save player position
	var player_position = Vector2(100, 500)  # Default start position
	if player:
		player_position = player.global_position
	
	var save_data = {
		"current_level": 1,
		"completed_objectives": completed_objectives,
		"player_position": {"x": player_position.x, "y": player_position.y},
		"timestamp": Time.get_unix_time_from_system()
	}
	
	GameManager.player_progress["level_01_partial"] = save_data
	print("Saving progress: ", save_data)
	
	var success = GameManager.save_game_data()
	if success:
		print("Progress saved successfully for Level 1")
	else:
		print("Failed to save progress!")

func _on_level_complete_continue():
	# For now, return to main menu. Later, advance to next level
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn") 
