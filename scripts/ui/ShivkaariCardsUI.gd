extends Control

@onready var grid_container = $MainContainer/ContentContainer/CardsGrid/GridContainer
@onready var card_title = $MainContainer/ContentContainer/CardDetails/DetailsContainer/CardTitle
@onready var card_category = $MainContainer/ContentContainer/CardDetails/DetailsContainer/CardCategory
@onready var card_description = $MainContainer/ContentContainer/CardDetails/DetailsContainer/CardDescription
@onready var historical_value = $MainContainer/ContentContainer/CardDetails/DetailsContainer/HistoricalValue
@onready var detailed_explanation = $MainContainer/ContentContainer/CardDetails/DetailsContainer/DetailedExplanation
@onready var related_character = $MainContainer/ContentContainer/CardDetails/DetailsContainer/RelatedCharacter
@onready var close_button = $MainContainer/Header/CloseButton

var cards_data: Dictionary = {}
var unlocked_cards: Array = []
var card_buttons: Array = []

signal cards_ui_closed

func _ready():
	load_cards_data()
	close_button.pressed.connect(_on_close_button_pressed)
	setup_cards_grid()
	
func load_cards_data():
	var file_path = "res://data/educational_content/shivkaari_cards.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				cards_data = json.data
				print("Shivkaari cards data loaded successfully")
			file.close()
	else:
		print("Shivkaari cards data file not found")

func setup_cards_grid():
	# Clear existing cards
	for child in grid_container.get_children():
		child.queue_free()
	
	card_buttons.clear()
	
	# Get unlocked cards from GameManager
	unlocked_cards = GameManager.get_unlocked_cards()
	
	# Create card buttons for all cards (locked and unlocked)
	var all_cards = cards_data.get("shivkaari_cards", [])
	
	for card_data in all_cards:
		var card_button = create_card_button(card_data)
		grid_container.add_child(card_button)
		card_buttons.append(card_button)

func create_card_button(card_data: Dictionary) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(180, 120)
	
	# Check if card is unlocked
	var is_unlocked = is_card_unlocked(card_data.id)
	
	if is_unlocked:
		# Unlocked card - show title and category
		button.text = card_data.title + "\n[" + card_data.category + "]"
		button.modulate = Color.WHITE
	else:
		# Locked card - show as mystery
		button.text = "???\n[Locked]"
		button.modulate = Color(0.5, 0.5, 0.5, 1)
		button.disabled = false  # Still clickable to show "locked" message
	
	# Style the button
	var style_box = StyleBoxFlat.new()
	if is_unlocked:
		style_box.bg_color = Color(0.2, 0.3, 0.5, 0.8)
		style_box.border_color = Color(0.9, 0.8, 0.6, 1)
	else:
		style_box.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		style_box.border_color = Color(0.5, 0.5, 0.5, 1)
	
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	
	button.add_theme_stylebox_override("normal", style_box)
	
	# Connect button press
	button.pressed.connect(_on_card_button_pressed.bind(card_data, is_unlocked))
	
	return button

func is_card_unlocked(card_id: String) -> bool:
	return card_id in unlocked_cards

func _on_card_button_pressed(card_data: Dictionary, is_unlocked: bool):
	if is_unlocked:
		display_card_details(card_data)
	else:
		display_locked_card_message(card_data)

func display_card_details(card_data: Dictionary):
	card_title.text = card_data.title
	card_category.text = "[" + card_data.category + "]"
	card_description.text = card_data.description
	historical_value.text = "\"" + card_data.historical_value + "\""
	detailed_explanation.text = card_data.detailed_explanation
	related_character.text = "- " + card_data.related_character

func display_locked_card_message(card_data: Dictionary):
	card_title.text = "Locked Card"
	card_category.text = "[Complete Level " + str(card_data.unlock_level) + " to unlock]"
	card_description.text = "This card contains valuable historical insights about the Pratapgad campaign."
	historical_value.text = "Complete more levels to discover the wisdom within."
	detailed_explanation.text = "Progress through the story to unlock this educational content and learn about the values and strategies that made Chhatrapati Shivaji Maharaj a legendary leader."
	related_character.text = "- ???"

func show_cards_ui():
	visible = true
	setup_cards_grid()  # Refresh in case new cards were unlocked
	
	# Show first unlocked card by default
	if unlocked_cards.size() > 0:
		var first_unlocked_id = unlocked_cards[0]
		for card_data in cards_data.get("shivkaari_cards", []):
			if card_data.id == first_unlocked_id:
				display_card_details(card_data)
				break

func hide_cards_ui():
	visible = false
	cards_ui_closed.emit()

func _on_close_button_pressed():
	hide_cards_ui()

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		hide_cards_ui()

# Function to refresh the UI when new cards are unlocked
func refresh_cards():
	setup_cards_grid() 