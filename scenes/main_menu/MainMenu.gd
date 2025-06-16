extends Control

@onready var start_button = $TitleContainer/MenuContainer/StartButton
@onready var continue_button = $TitleContainer/MenuContainer/ContinueButton
@onready var cards_button = $TitleContainer/MenuContainer/CardsButton
@onready var settings_button = $TitleContainer/MenuContainer/SettingsButton
@onready var credits_button = $TitleContainer/MenuContainer/CreditsButton
@onready var quit_button = $TitleContainer/MenuContainer/QuitButton

@onready var title_label = $TitleContainer/TitleLabel
@onready var subtitle_label = $TitleContainer/SubtitleLabel
@onready var menu_container = $TitleContainer/MenuContainer

@onready var shivaji_portrait = $ShivajiPortrait
@onready var fade_overlay = $FadeOverlay
@onready var title_animation = $TitleAnimation
@onready var background_animation = $BackgroundAnimation

# Shivkaari Cards UI
var cards_ui_scene = preload("res://scenes/ui/cards/ShivkaariCardsUI.tscn")
var cards_ui_instance = null

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
	
	# Update cards button text to show unlocked count
	update_cards_button_text()
	
	# Enable focus for keyboard navigation
	start_button.grab_focus()

func update_cards_button_text():
	var unlocked_count = GameManager.get_unlocked_cards_count()
	if unlocked_count > 0:
		cards_button.text = "Cards (" + str(unlocked_count) + "/8)"
	else:
		cards_button.text = "Cards (0/8)"

func play_intro_animation():
	# Start with everything hidden behind black overlay
	fade_overlay.color = Color(0, 0, 0, 1)
	shivaji_portrait.modulate.a = 0.0
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	menu_container.modulate.a = 0.0
	
	# Create comprehensive fade-in sequence
	var tween = create_tween()
	tween.set_parallel(true)  # Allow multiple animations to run simultaneously
	
	# Fade out the black overlay (fade in from black)
	tween.tween_property(fade_overlay, "color:a", 0.0, 2.0)
	
	# Hide the overlay completely after fade-in to ensure no mouse blocking
	tween.tween_callback(func(): fade_overlay.visible = false).set_delay(2.1)
	
	# Fade in Shivaji portrait with slight delay for dramatic effect
	tween.tween_property(shivaji_portrait, "modulate:a", 1.0, 1.5).set_delay(0.5)
	
	# Add subtle slide-in effect for the portrait
	shivaji_portrait.offset_left = -30  # Start slightly more to the left
	tween.tween_property(shivaji_portrait, "offset_left", 0, 1.5).set_delay(0.5)
	
	# Fade in title and subtitle after portrait starts appearing
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0).set_delay(1.0)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 1.0).set_delay(1.2)
	
	# Fade in menu options after title and subtitle are visible
	tween.tween_property(menu_container, "modulate:a", 1.0, 1.0).set_delay(2.5)
	
	print("Main menu fade-in animation started with sequential title/menu effects")

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
	
	# Create cards UI if it doesn't exist
	if not cards_ui_instance:
		cards_ui_instance = cards_ui_scene.instantiate()
		add_child(cards_ui_instance)
		cards_ui_instance.cards_ui_closed.connect(_on_cards_ui_closed)
	
	# Show the cards UI
	cards_ui_instance.show_cards_ui()
	
	# Disable menu interaction while cards UI is open
	set_menu_interaction(false)

func _on_cards_ui_closed():
	# Re-enable menu interaction
	set_menu_interaction(true)
	
	# Update cards button text in case new cards were unlocked
	update_cards_button_text()

func set_menu_interaction(enabled: bool):
	# Enable/disable all menu buttons
	start_button.disabled = not enabled
	continue_button.disabled = not enabled
	cards_button.disabled = not enabled
	settings_button.disabled = not enabled
	credits_button.disabled = not enabled
	quit_button.disabled = not enabled

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
