extends Node2D

@onready var player = $Player
@onready var dialogue_ui = $UI/DialogueUI
@onready var back_button = $UI/BackButton

func _ready():
	print("=== VEER SHIVAJI: PRATAPGAD CAMPAIGN ===")
	print("Main scene loaded successfully")
	print("All autoload systems initialized")
	
	# Add a small delay to ensure everything is loaded
	await get_tree().process_frame
	
	# Test autoload systems
	test_systems()
	
	# Run comprehensive system tests
	SystemTester.test_all_systems()
	
	# Connect back button
	back_button.pressed.connect(_on_back_button_pressed)
	
	print("=== SCENE SETUP COMPLETE ===")
	print("If you see this message, the scene is working!")
	print("Use WASD to move the brown rectangle (Shivaji)")
	print("Press ESC or click Main Menu to return to main menu")
	
func _input(event):
	# Test dialogue system with T key (only if not in dialogue)
	if event.is_action_pressed("ui_accept") and Input.is_key_pressed(KEY_T) and not DialogueManager.is_dialogue_active:
		test_dialogue_system()
	
	# Return to main menu with ESC
	if event.is_action_pressed("ui_cancel"):
		return_to_main_menu()

func test_systems():
	print("=== Testing Core Systems ===")
	print("GameManager: ", GameManager != null)
	print("SaveSystem: ", SaveSystem != null)  
	print("InputManager: ", InputManager != null)
	print("AudioManager: ", AudioManager != null)
	print("DialogueManager: ", DialogueManager != null)
	print("Player: ", player != null)
	print("=== Systems Test Complete ===")

func test_dialogue_system():
	print("Testing dialogue system...")
	DialogueManager.start_dialogue("test_dialogue")

func _on_player_interacted_with_object(object):
	print("Player interacted with: ", object)
	# This could trigger dialogue or other interactions

func _on_back_button_pressed():
	return_to_main_menu()

func return_to_main_menu():
	print("Returning to main menu...")
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn") 