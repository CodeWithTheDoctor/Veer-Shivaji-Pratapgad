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

# Speaker highlighting
var normal_portrait_scale: Vector2 = Vector2(1.0, 1.0)
var highlighted_portrait_scale: Vector2 = Vector2(1.15, 1.15)
var portrait_tween: Tween

signal cutscene_finished(next_scene: String)

func _ready():
	# Ensure cutscene covers entire screen and is on top
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 1000  # Very high z-index to be above everything
	visible = true  # Ensure cutscene is visible
	modulate = Color.WHITE  # Ensure full opacity
	
	# Add a black background to completely cover the screen
	var black_bg = ColorRect.new()
	black_bg.color = Color.BLACK
	black_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black_bg.z_index = -1  # Behind other cutscene elements
	add_child(black_bg)
	move_child(black_bg, 0)  # Move to front as first child
	
	# Start with fade overlay visible
	fade_overlay.color = Color(0, 0, 0, 1)
	fade_overlay.visible = true
	
	# Connect dialogue signals (check if not already connected)
	if DialogueManager:
		if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
			DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		if not DialogueManager.speaker_changed.is_connected(_on_speaker_changed):
			DialogueManager.speaker_changed.connect(_on_speaker_changed)
	
	# Hide portraits initially
	left_portrait.visible = false
	right_portrait.visible = false
	
	# Set initial portrait scales
	left_portrait.scale = normal_portrait_scale
	right_portrait.scale = normal_portrait_scale

func _unhandled_input(event):
	if can_skip and event.is_action_pressed("ui_cancel"):  # ESC key
		skip_cutscene()
		get_viewport().set_input_as_handled()  # Prevent other handlers from processing ESC

func play_cutscene(cutscene_id: String):
	print("Playing cutscene: ", cutscene_id)
	print("CutscenePlayer visibility: ", visible)
	print("CutscenePlayer z_index: ", z_index)
	print("CutscenePlayer size: ", size)
	print("CutscenePlayer position: ", position)
	
	current_cutscene_data = get_cutscene_data(cutscene_id)
	current_scene_index = 0
	cutscene_completed = false
	
	if current_cutscene_data.is_empty():
		print("No cutscene data found for: ", cutscene_id)
		finish_cutscene()
		return
	
	# Force the cutscene to be visible and on top
	visible = true
	z_index = 1000
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	print("Forced cutscene visibility and positioning")
	
	# Ensure dialogue signals are connected (but don't duplicate connections)
	if DialogueManager:
		if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
			DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
			print("Connected dialogue_ended signal")
		if not DialogueManager.speaker_changed.is_connected(_on_speaker_changed):
			DialogueManager.speaker_changed.connect(_on_speaker_changed)
			print("Connected speaker_changed signal")
	
	# Stop any existing music - per-scene music will be handled in play_current_scene()
	AudioManager.stop_playlist()  # Stop any playlist that might be running
	print("Cutscene starting, stopped existing music")
	
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
						"right_portrait": "res://assets/art/cutscenes/portraits/afzal_khan_portrait.png",
						"music": "bijapur_court_theme"
					},
					{
						"background": "res://assets/art/cutscenes/backgrounds/temple_destruction_bg.png",
						"dialogue_id": "temple_destruction",
						"left_portrait": "res://assets/art/cutscenes/portraits/worried_villager_level1_portrait.png",
						"right_portrait": "res://assets/art/cutscenes/portraits/temple_priest_level1_portrait.png",
						"music": "temple_destruction_theme"
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
						"right_portrait": "res://assets/art/cutscenes/portraits/SHIVAJI_PORTRAIT.png",
						"music": "rajgad_fort_theme"
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
	print("Playing cutscene scene ", current_scene_index, " with data: ", scene_data)
	
	# Ensure nodes are ready
	if not background or not left_portrait or not right_portrait:
		print("Cutscene nodes not ready, waiting...")
		# Check if we're in the tree before trying to access it
		var current_tree = get_tree()
		if current_tree:
			await current_tree.process_frame
		else:
			# If not in tree, wait for ready signal
			print("CutscenePlayer not in scene tree, waiting for ready...")
			await ready
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
	
	# Set music for this specific scene
	if scene_data.has("music"):
		print("Starting scene-specific music: ", scene_data.music)
		# Reduce volume by 40% total for Afzal Khan and court advisor cutscenes (20% + 20% more)
		var volume_modifier = 1.0
		if scene_data.music == "bijapur_court_theme":
			volume_modifier = 0.6  # 40% total reduction (was 0.8, now 0.6)
			print("Reducing cutscene volume by 40% total for: ", scene_data.music)
		AudioManager.play_music(scene_data.music, true, volume_modifier)
	else:
		print("No music specified for this scene")
	
	# Fade in
	fade_in()
	
	# Start dialogue after fade in - reduced delay for second part of cutscene
	var dialogue_delay = 1.0
	if current_scene_index > 0:  # For second and subsequent scenes, start dialogue sooner
		dialogue_delay = 0.3
	
	# Ensure we're in the tree before creating timer
	var scene_tree = get_tree()
	if scene_tree:
		await scene_tree.create_timer(dialogue_delay).timeout
		if scene_data.has("dialogue_id"):
			DialogueManager.start_dialogue(scene_data.dialogue_id)
	else:
		print("Warning: CutscenePlayer not in scene tree, cannot start dialogue")

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
	
	# Only fade out if there are more scenes to play
	if current_scene_index < current_cutscene_data.scenes.size():
		# Fade out before next scene
		await fade_out()
		# Play next scene
		play_current_scene()
	else:
		# No more scenes - finish cutscene without extra fade
		finish_cutscene()

func skip_cutscene():
	print("Skipping cutscene")
	
	# Stop any active dialogue immediately
	if DialogueManager.is_dialogue_active:
		DialogueManager.end_dialogue()
	
	# Disconnect signals to prevent any further processing
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	if DialogueManager.speaker_changed.is_connected(_on_speaker_changed):
		DialogueManager.speaker_changed.disconnect(_on_speaker_changed)
	
	# Force finish cutscene
	finish_cutscene()

func finish_cutscene():
	print("Cutscene finished")
	cutscene_completed = true
	
	# Stop cutscene music immediately
	AudioManager.stop_music()
	print("Stopped cutscene music immediately")
	
	# Fade out (only once)
	await fade_out()
	
	# Emit signal with next scene info
	var next_scene = current_cutscene_data.get("next_scene", "gameplay")
	cutscene_finished.emit(next_scene)

func _on_speaker_changed(speaker_name: String):
	print("Speaker changed to: ", speaker_name)
	
	# Determine which portrait should be highlighted based on speaker
	var highlight_left = false
	var highlight_right = false
	
	# Check for narrator or system speakers - don't highlight any portrait
	if speaker_name.to_lower().contains("narrator") or speaker_name.to_lower().contains("system"):
		# Don't highlight any portrait for narrator/system speakers
		highlight_left = false
		highlight_right = false
	# Specific character logic based on actual dialogue data
	elif speaker_name.to_lower().contains("afzal") and speaker_name.to_lower().contains("khan"):
		highlight_right = true  # Afzal Khan on right
	elif speaker_name.to_lower().contains("court") and speaker_name.to_lower().contains("official"):
		highlight_left = true   # Court Official on left
	elif speaker_name.to_lower().contains("worried") and speaker_name.to_lower().contains("villager"):
		highlight_left = true   # Worried Villager on left
	elif speaker_name.to_lower().contains("temple") and speaker_name.to_lower().contains("priest"):
		highlight_right = true  # Temple Priest on right
	elif speaker_name.to_lower().contains("shivaji") or speaker_name.to_lower().contains("maharaj"):
		highlight_right = true  # Shivaji on right
	elif speaker_name.to_lower().contains("messenger"):
		highlight_left = true   # Messenger on left
	else:
		# For unknown speakers, don't highlight any portrait by default
		print("Unknown speaker, no portrait highlighting: ", speaker_name)
		highlight_left = false
		highlight_right = false
	
	# Apply highlighting
	highlight_speaker_portrait(highlight_left, highlight_right)

func highlight_speaker_portrait(highlight_left: bool, highlight_right: bool):
	# Clean up existing tween
	if portrait_tween:
		portrait_tween.kill()
	
	portrait_tween = create_tween()
	portrait_tween.set_parallel(true)  # Allow multiple tweens to run simultaneously
	
	# Scale left portrait
	if highlight_left and left_portrait.visible:
		portrait_tween.tween_property(left_portrait, "scale", highlighted_portrait_scale, 0.3)
	else:
		portrait_tween.tween_property(left_portrait, "scale", normal_portrait_scale, 0.3)
	
	# Scale right portrait
	if highlight_right and right_portrait.visible:
		portrait_tween.tween_property(right_portrait, "scale", highlighted_portrait_scale, 0.3)
	else:
		portrait_tween.tween_property(right_portrait, "scale", normal_portrait_scale, 0.3) 
