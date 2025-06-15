extends Control

@onready var dialogue_panel = $DialoguePanel
@onready var speaker_label = $DialoguePanel/VBoxContainer/SpeakerLabel
@onready var dialogue_text = $DialoguePanel/VBoxContainer/DialogueText
@onready var continue_hint = $DialoguePanel/VBoxContainer/ContinueHint

var is_visible: bool = false

func _ready():
	# Start hidden
	visible = false
	is_visible = false
	
	# Connect to DialogueManager signals
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.dialogue_line_changed.connect(_on_dialogue_line_changed)
	
	print("DialogueUI initialized")

func _on_dialogue_started():
	show_dialogue_ui()
	
func _on_dialogue_ended():
	hide_dialogue_ui()
	
func _on_dialogue_line_changed(speaker: String, text: String):
	update_dialogue_content(speaker, text)

func show_dialogue_ui():
	visible = true
	is_visible = true
	
	# Create a nice fade-in effect
	var tween = create_tween()
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	print("Dialogue UI shown")

func hide_dialogue_ui():
	# Create a fade-out effect
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): 
		visible = false
		is_visible = false
	)
	
	print("Dialogue UI hidden")

func update_dialogue_content(speaker: String, text: String):
	speaker_label.text = speaker
	dialogue_text.text = text
	
	# Animate text appearance (simple version)
	dialogue_text.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(dialogue_text, "modulate:a", 1.0, 0.2)

func _input(event):
	# Let DialogueManager handle input - don't interfere with it
	pass

# Helper function to test dialogue system
func test_dialogue():
	DialogueManager.start_dialogue("test_dialogue") 
