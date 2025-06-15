extends Node

signal dialogue_started
signal dialogue_ended
signal dialogue_line_changed(speaker: String, text: String)

var dialogue_data: Dictionary = {}
var current_dialogue: Array = []
var current_line: int = 0
var is_dialogue_active: bool = false

func _ready():
	load_dialogue_data()
	
func load_dialogue_data():
	var file_path = "res://data/dialogue/dialogue_data.json"
	if not FileAccess.file_exists(file_path):
		print("Dialogue data file not found, creating placeholder")
		create_placeholder_dialogue_data()
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			dialogue_data = json.data
			print("Dialogue data loaded successfully")
		else:
			print("Failed to parse dialogue data")
		file.close()
	else:
		print("Failed to open dialogue data file")
		create_placeholder_dialogue_data()

func create_placeholder_dialogue_data():
	# Create some placeholder dialogue for testing
	dialogue_data = {
		"test_dialogue": [
			{
				"speaker": "Narrator",
				"text": "Welcome to Veer Shivaji: Pratapgad Campaign. This is a test dialogue.",
				"voice_file": ""
			},
			{
				"speaker": "Shivaji",
				"text": "The shadow of Afzal Khan grows long across our lands. We must prepare for what is to come.",
				"voice_file": ""
			},
			{
				"speaker": "Narrator",
				"text": "Press E or Space to continue dialogue. This system will be expanded with more content.",
				"voice_file": ""
			}
		],
		"shivaji_intro": [
			{
				"speaker": "Shivaji",
				"text": "I am Chhatrapati Shivaji Maharaj. The protector of Swarajya and the Marathi people.",
				"voice_file": ""
			}
		]
	}
	print("Placeholder dialogue data created")
		
func start_dialogue(dialogue_id: String):
	if dialogue_data.has(dialogue_id):
		current_dialogue = dialogue_data[dialogue_id]
		current_line = 0
		is_dialogue_active = true
		dialogue_started.emit()
		show_current_line()
		print("Started dialogue: ", dialogue_id)
		print("First line: ", current_dialogue[0].text if current_dialogue.size() > 0 else "No lines")
	else:
		print("Dialogue not found: ", dialogue_id)
		print("Available dialogues: ", dialogue_data.keys())
		
func next_line():
	if not is_dialogue_active:
		return
		
	if current_line < current_dialogue.size() - 1:
		current_line += 1
		show_current_line()
	else:
		end_dialogue()
		
func show_current_line():
	if current_line < current_dialogue.size():
		var line_data = current_dialogue[current_line]
		dialogue_line_changed.emit(line_data.speaker, line_data.text)
		
		# Play voice if available
		if line_data.has("voice_file") and line_data.voice_file != "":
			AudioManager.play_voice(line_data.voice_file)
		
		print("Dialogue: [", line_data.speaker, "] ", line_data.text)
		
func end_dialogue():
	is_dialogue_active = false
	dialogue_ended.emit()
	print("Dialogue ended")
	
func _input(event):
	if is_dialogue_active:
		# Both E and Space advance dialogue when dialogue is active
		if event.is_action_pressed("interact") or event.is_action_pressed("jump"):
			next_line()

func skip_dialogue():
	if is_dialogue_active:
		end_dialogue()

# Helper function to check if dialogue exists
func has_dialogue(dialogue_id: String) -> bool:
	return dialogue_data.has(dialogue_id)

# Function to add dialogue dynamically (for testing or dynamic content)
func add_dialogue(dialogue_id: String, dialogue_lines: Array):
	dialogue_data[dialogue_id] = dialogue_lines
	print("Added dialogue: ", dialogue_id) 