extends Node
class_name SystemTester

# Call this from the main scene to test all systems
static func test_all_systems():
	print("=== VEER SHIVAJI SYSTEM TESTING ===")
	
	var all_passed = true
	
	# Test GameManager
	all_passed = test_game_manager() and all_passed
	
	# Test SaveSystem
	all_passed = test_save_system() and all_passed
	
	# Test InputManager
	all_passed = test_input_manager() and all_passed
	
	# Test AudioManager
	all_passed = test_audio_manager() and all_passed
	
	# Test DialogueManager
	all_passed = test_dialogue_manager() and all_passed
	
	print("=== SYSTEM TESTING COMPLETE ===")
	print("Overall result: ", "✅ ALL SYSTEMS PASS" if all_passed else "❌ SOME SYSTEMS FAILED")
	
	return all_passed

static func test_game_manager() -> bool:
	print("Testing GameManager...")
	if GameManager == null:
		print("❌ GameManager not found")
		return false
		
	# Test basic functionality
	var initial_level = GameManager.current_level
	GameManager.complete_level(1, {"title": "Test Card", "description": "Test description"})
	
	if GameManager.is_level_completed(1):
		print("✅ GameManager level completion works")
	else:
		print("❌ GameManager level completion failed")
		return false
		
	if GameManager.unlocked_cards.size() > 0:
		print("✅ GameManager card unlocking works")
	else:
		print("❌ GameManager card unlocking failed")
		return false
		
	print("✅ GameManager tests passed")
	return true

static func test_save_system() -> bool:
	print("Testing SaveSystem...")
	if SaveSystem == null:
		print("❌ SaveSystem not found")
		return false
		
	# Test save/load functionality
	var test_data = {"test": "data", "number": 42}
	var save_result = SaveSystem.save_game(test_data)
	
	if not save_result:
		print("❌ SaveSystem save failed")
		return false
		
	var loaded_data = SaveSystem.load_game()
	if loaded_data.get("test") == "data" and loaded_data.get("number") == 42:
		print("✅ SaveSystem save/load works")
	else:
		print("❌ SaveSystem save/load failed")
		return false
		
	print("✅ SaveSystem tests passed")
	return true

static func test_input_manager() -> bool:
	print("Testing InputManager...")
	if InputManager == null:
		print("❌ InputManager not found")
		return false
		
	# Test input actions setup
	if InputMap.has_action("move_up") and InputMap.has_action("interact"):
		print("✅ InputManager input actions are set up")
	else:
		print("❌ InputManager input actions missing")
		return false
		
	print("✅ InputManager tests passed")
	return true

static func test_audio_manager() -> bool:
	print("Testing AudioManager...")
	if AudioManager == null:
		print("❌ AudioManager not found")
		return false
		
	# Test basic audio functionality
	AudioManager.apply_volume_settings()
	print("✅ AudioManager basic functionality works")
	return true

static func test_dialogue_manager() -> bool:
	print("Testing DialogueManager...")
	if DialogueManager == null:
		print("❌ DialogueManager not found")
		return false
		
	# Test dialogue data
	if DialogueManager.has_dialogue("test_dialogue"):
		print("✅ DialogueManager has test dialogue")
	else:
		print("❌ DialogueManager missing test dialogue")
		return false
		
	print("✅ DialogueManager tests passed")
	return true 
