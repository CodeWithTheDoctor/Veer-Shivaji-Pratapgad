extends Control

@onready var start_button = $TitleContainer/MenuContainer/StartButton
@onready var continue_button = $TitleContainer/MenuContainer/ContinueButton
@onready var cards_button = $TitleContainer/MenuContainer/CardsButton
@onready var settings_button = $TitleContainer/MenuContainer/SettingsButton
@onready var credits_button = $TitleContainer/MenuContainer/CreditsButton
@onready var quit_button = $TitleContainer/MenuContainer/QuitButton

@onready var shivaji_portrait = $ShivajiPortrait
@onready var fade_overlay = $FadeOverlay
@onready var title_animation = $TitleAnimation
@onready var background_animation = $BackgroundAnimation

func _ready():
	setup_menu()
	play_intro_animation()
	start_main_menu_music()

func setup_menu():
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	cards_button.pressed.connect(_on_cards_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Show continue button only if save exists
	var has_save = SaveSystem.has_save_data()
	print("Main Menu: Save data exists = ", has_save)
	continue_button.visible = has_save
	
	# Enable focus for keyboard navigation
	start_button.grab_focus()

func play_intro_animation():
	# Start with everything hidden behind black overlay
	fade_overlay.color = Color(0, 0, 0, 1)
	shivaji_portrait.modulate.a = 0.0
	
	# Create comprehensive fade-in sequence
	var tween = create_tween()
	tween.set_parallel(true)  # Allow multiple animations to run simultaneously
	
	# Fade out the black overlay (fade in from black)
	tween.tween_property(fade_overlay, "color:a", 0.0, 2.0)
	
	# Fade in Shivaji portrait with slight delay for dramatic effect
	tween.tween_property(shivaji_portrait, "modulate:a", 1.0, 1.5).set_delay(0.5)
	
	# Add subtle slide-in effect for the portrait
	shivaji_portrait.position.x = -150  # Start slightly more to the left
	tween.tween_property(shivaji_portrait, "position:x", -100, 1.5).set_delay(0.5)
	
	print("Main menu fade-in animation started")

func start_main_menu_music():
	# Start the main menu playlist with fade-in effect
	AudioManager.play_main_menu_music()
	
	# Fade in the music volume
	AudioManager.music_player.volume_db = -20  # Start quieter
	var music_tween = create_tween()
	music_tween.tween_property(AudioManager.music_player, "volume_db", 0, 2.0).set_delay(1.0)
	
	print("Main menu music playlist started with fade-in")

func _on_start_pressed():
	AudioManager.play_sfx("menu_select")
	start_new_game()

func _on_continue_pressed():
	AudioManager.play_sfx("menu_select")
	continue_game()

func _on_cards_pressed():
	AudioManager.play_sfx("menu_select")
	open_cards_collection()

func _on_settings_pressed():
	AudioManager.play_sfx("menu_select")
	open_settings()

func _on_credits_pressed():
	AudioManager.play_sfx("menu_select")
	show_credits()

func _on_quit_pressed():
	AudioManager.play_sfx("menu_select")
	quit_game()

func start_new_game():
	print("Starting new game...")
	# Stop main menu music
	AudioManager.stop_playlist()
	
	GameManager.current_level = 1
	# Clear any existing progress for fresh start
	GameManager.reset_progress()
	# Set flag to indicate this is a fresh start
	GameManager.is_continuing_game = false
	# Start with Level 1: The Shadow of Afzal Khan
	get_tree().change_scene_to_file("res://scenes/levels/Level01_ShadowOfAfzal.tscn")

func continue_game():
	print("Continuing game...")
	# Stop main menu music
	AudioManager.stop_playlist()
	
	GameManager.load_game_data()
	# Set flag to indicate this is continuing from save
	GameManager.is_continuing_game = true
	# For now, always continue to Level 1 since it's the only level implemented
	print("Loading Level 1...")
	get_tree().change_scene_to_file("res://scenes/levels/Level01_ShadowOfAfzal.tscn")

func get_next_level_to_play() -> int:
	# Check GameManager progress to determine next level
	var highest_completed = 0
	for level_key in GameManager.player_progress.keys():
		var level_num = int(level_key)
		if GameManager.player_progress[level_key] and level_num > highest_completed:
			highest_completed = level_num
	
	return highest_completed + 1

func load_level(level_number: int):
	var level_file = "res://scenes/levels/Level%02d_*.tscn" % level_number
	# For now, fallback to main scene
	print("Would load level: ", level_file)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func open_cards_collection():
	print("Opening Shivkaari Cards collection...")
	# TODO: Implement cards collection scene
	show_placeholder_message("Shivkaari Cards collection coming soon!")

func open_settings():
	print("Opening settings...")
	# TODO: Implement settings scene
	show_placeholder_message("Settings menu coming soon!")

func show_credits():
	print("Showing credits...")
	# TODO: Implement credits scene
	show_placeholder_message("Credits coming soon!")

func show_placeholder_message(message: String):
	# Simple popup for features not yet implemented
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()
	await dialog.confirmed
	dialog.queue_free()

func quit_game():
	print("Quitting game...")
	get_tree().quit()

func _input(event):
	# Handle keyboard navigation
	if event.is_action_pressed("ui_cancel"):
		quit_game() 
