extends Node

signal level_completed(level_name: String)
signal shivkaari_card_unlocked(card_data: Dictionary)

var current_level: int = 1
var unlocked_cards: Array[Dictionary] = []
var player_progress: Dictionary = {}
var is_continuing_game: bool = false
var game_settings: Dictionary = {
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"voice_volume": 1.0,
	"language": "english"
}

func _ready():
	load_game_data()
	
func complete_level(level_number: int, card_data: Dictionary = {}):
	player_progress[str(level_number)] = true
	if card_data.size() > 0:
		unlock_shivkaari_card(card_data)
	save_game_data()
	level_completed.emit("Level " + str(level_number))
	
func unlock_shivkaari_card(card_data: Dictionary):
	# Check if card is already unlocked to avoid duplicates
	var card_title = card_data.get("title", "")
	for existing_card in unlocked_cards:
		if existing_card.get("title", "") == card_title:
			print("Card already unlocked: ", card_title)
			return
	
	unlocked_cards.append(card_data)
	shivkaari_card_unlocked.emit(card_data)
	print("Shivkaari Card Unlocked: ", card_data.get("title", "Unknown"))

func get_unlocked_cards() -> Array:
	# Return array of card IDs for the UI system
	var card_ids: Array = []
	for card in unlocked_cards:
		var card_id = ""
		# Map card titles to IDs based on the cards data structure
		match card.get("title", ""):
			"Understanding the Enemy":
				card_id = "understanding_enemy"
			"Strategic Preparation":
				card_id = "strategic_preparation"
			"Choosing the Battlefield":
				card_id = "choosing_battlefield"
			"Diplomatic Deception":
				card_id = "diplomatic_deception"
			"Loyalty and Trust":
				card_id = "loyal_companions"
			"Courage in Crisis":
				card_id = "courage_in_crisis"
			"Swift Victory":
				card_id = "swift_victory"
			"Compassionate Leadership":
				card_id = "compassionate_leadership"
		
		if card_id != "":
			card_ids.append(card_id)
	
	return card_ids

func get_unlocked_cards_count() -> int:
	return unlocked_cards.size()
	
func save_game_data() -> bool:
	var save_data = {
		"progress": player_progress,
		"cards": unlocked_cards,
		"settings": game_settings
	}
	print("GameManager saving data: ", save_data)
	return SaveSystem.save_game(save_data)
	
func load_game_data():
	var save_data = SaveSystem.load_game()
	if save_data:
		player_progress = save_data.get("progress", {})
		
		# Handle the typed array properly
		var loaded_cards = save_data.get("cards", [])
		unlocked_cards.clear()
		for card in loaded_cards:
			if card is Dictionary:
				unlocked_cards.append(card)
		
		game_settings = save_data.get("settings", game_settings)

func is_level_completed(level_number: int) -> bool:
	return player_progress.has(str(level_number))

func get_last_completed_level() -> int:
	var last_level = 0
	for level_str in player_progress.keys():
		var level_num = int(level_str)
		if level_num > last_level:
			last_level = level_num
	return last_level

func reset_progress():
	player_progress.clear()
	unlocked_cards.clear()
	current_level = 1
	save_game_data() 
