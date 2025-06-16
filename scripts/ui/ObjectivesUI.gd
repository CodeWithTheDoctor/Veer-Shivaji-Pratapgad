extends Control
class_name ObjectivesUI

@onready var objectives_panel = $Panel
@onready var objectives_list = $Panel/VBox/ObjectivesList
@onready var title_label = $Panel/VBox/TitleLabel

var objective_labels: Array[Label] = []

func _ready():
    setup_ui()

func setup_ui():
    # Set up title
    if title_label:
        title_label.text = "Objectives"
        title_label.add_theme_color_override("font_color", Color.YELLOW)
        title_label.add_theme_font_size_override("font_size", 24)
        
        # Add EB Garamond font
        var eb_garamond_bold = load("res://assets/fonts/EB_Garamond/static/EBGaramond-Bold.ttf")
        if eb_garamond_bold:
            title_label.add_theme_font_override("font", eb_garamond_bold)
    
    # Position panel in top-left corner
    if objectives_panel:
        objectives_panel.position = Vector2(10, 10)
        objectives_panel.size = Vector2(400, 250)
        
        # Style the panel
        var style_box = StyleBoxFlat.new()
        style_box.bg_color = Color(0.1, 0.1, 0.2, 0.8)
        style_box.border_width_left = 2
        style_box.border_width_right = 2
        style_box.border_width_top = 2
        style_box.border_width_bottom = 2
        style_box.border_color = Color.GOLD
        objectives_panel.add_theme_stylebox_override("panel", style_box)

func update_objectives(objective_texts: Array):
    # Clear existing labels
    for label in objective_labels:
        if is_instance_valid(label):
            label.queue_free()
    objective_labels.clear()
    
    # Create labels for each objective
    for text in objective_texts:
        var label = Label.new()
        label.text = text
        label.add_theme_color_override("font_color", Color.WHITE)
        label.add_theme_font_size_override("font_size", 20)
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        label.custom_minimum_size = Vector2(360, 0)
        
        # Color completed objectives green
        if text.begins_with("✓"):
            label.add_theme_color_override("font_color", Color.GREEN)
        
        objectives_list.add_child(label)
        objective_labels.append(label)

func show_objectives():
    visible = true

func hide_objectives():
    visible = false 