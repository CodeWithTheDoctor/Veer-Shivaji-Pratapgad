extends Control
class_name CutscenePlayer

@onready var background = $Background
@onready var left_portrait = $CharacterPortraits/LeftPortrait
@onready var right_portrait = $CharacterPortraits/RightPortrait
@onready var dialogue_ui = $DialogueUI
@onready var fade_overlay = $FadeOverlay
@onready var skip_prompt = $SkipPrompt

var current_cutscene_data: Dictionary = {}
var current_scene_index: int = 0
var cutscene_completed: bool = false
var can_skip: bool = true

signal cutscene_finished(next_scene: String)

func _ready():
	# Start with fade overlay visible
	fade_overlay.color = Color(0, 0, 0, 1)
	fade_overlay.visible = true
	
	# Connect dialogue signals
	if DialogueManager:
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# Hide portraits initially
	left_portrait.visible = false
	right_portrait.visible = false

func _input(event):
	if can_skip and event.is_action_pressed("ui_cancel"):  # ESC key
		skip_cutscene()

func play_cutscene(cutscene_id: String):
	print("Playing cutscene: ", cutscene_id)
	current_cutscene_data = get_cutscene_data(cutscene_id)
	current_scene_index = 0
	cutscene_completed = false
	
	if current_cutscene_data.is_empty():
		print("No cutscene data found for: ", cutscene_id)
		finish_cutscene()
		return
	
	# Start the cutscene
	play_current_scene()

func get_cutscene_data(cutscene_id: String) -> Dictionary:
	# Define cutscene data for Level 1
	match cutscene_id:
		"opening_bijapur_court":
			return {
				"scenes": [
					{
						"background": "res://assets/art/cutscenes/backgrounds/bijapur_court_bg.png",
						"dialogue_id": "bijapur_appointment",
						"left_portrait": "res://assets/art/cutscenes/portraits/bijapur_court_official_portrait.png",
						"right_portrait": "res://assets/art/cutscenes/portraits/afzal_khan_portrait.png"
					},
					{
						"background": "res://assets/art/cutscenes/backgrounds/temple_destruction_bg.png",
						"dialogue_id": "temple_destruction",
						"left_portrait": "res://assets/art/cutscenes/portraits/worried_villager_level1_portrait.png",
						"right_portrait": "res://assets/art/cutscenes/portraits/temple_priest_level1_portrait.png"
					}
				],
				"next_scene": "gameplay"
			}
		"ending_rajgad_fort":
			return {
				"scenes": [
					{
						"background": "res://assets/art/cutscenes/backgrounds/rajgad_fort_bg.png",
						"dialogue_id": "messenger_delivers_news",
						"left_portrait": "res://assets/art/cutscenes/portraits/marathi_messenger_portait.png",
						"right_portrait": "res://assets/art/cutscenes/portraits/SHIVAJI_PORTRAIT.png"
					}
				],
				"next_scene": "level_complete"
			}
		_:
			return {}

func play_current_scene():
	if current_scene_index >= current_cutscene_data.scenes.size():
		finish_cutscene()
		return
	
	var scene_data = current_cutscene_data.scenes[current_scene_index]
	
	# Ensure nodes are ready
	if not background or not left_portrait or not right_portrait:
		print("Cutscene nodes not ready, waiting...")
		await get_tree().process_frame
		return
	
	# Set background
	if scene_data.has("background") and background:
		var bg_texture = load(scene_data.background)
		if bg_texture:
			background.texture = bg_texture
			print("Set background: ", scene_data.background)
		else:
			print("Failed to load background: ", scene_data.background)
	
	# Set portraits
	if scene_data.has("left_portrait") and left_portrait:
		var left_texture = load(scene_data.left_portrait)
		if left_texture:
			left_portrait.texture = left_texture
			left_portrait.visible = true
			print("Set left portrait: ", scene_data.left_portrait)
		else:
			print("Failed to load left portrait: ", scene_data.left_portrait)
	elif left_portrait:
		left_portrait.visible = false
	
	if scene_data.has("right_portrait") and right_portrait:
		var right_texture = load(scene_data.right_portrait)
		if right_texture:
			right_portrait.texture = right_texture
			right_portrait.visible = true
			print("Set right portrait: ", scene_data.right_portrait)
		else:
			print("Failed to load right portrait: ", scene_data.right_portrait)
	elif right_portrait:
		right_portrait.visible = false
	
	# Fade in
	fade_in()
	
	# Start dialogue after fade in
	await get_tree().create_timer(1.0).timeout
	if scene_data.has("dialogue_id"):
		DialogueManager.start_dialogue(scene_data.dialogue_id)

func fade_in():
	if not fade_overlay:
		return
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 0), 1.0)
	await tween.finished
	fade_overlay.visible = false

func fade_out():
	if not fade_overlay:
		return
	fade_overlay.visible = true
	fade_overlay.color = Color(0, 0, 0, 0)
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 1.0)
	await tween.finished

func _on_dialogue_ended():
	print("Dialogue ended for scene ", current_scene_index)
	
	# Move to next scene
	current_scene_index += 1
	
	# Fade out before next scene
	await fade_out()
	
	# Play next scene or finish
	play_current_scene()

func skip_cutscene():
	print("Skipping cutscene")
	finish_cutscene()

func finish_cutscene():
	print("Cutscene finished")
	cutscene_completed = true
	
	# Fade out
	await fade_out()
	
	# Emit signal with next scene info
	var next_scene = current_cutscene_data.get("next_scene", "gameplay")
	cutscene_finished.emit(next_scene) 