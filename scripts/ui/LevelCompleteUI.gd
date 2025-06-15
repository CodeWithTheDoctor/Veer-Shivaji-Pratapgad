extends Control
class_name LevelCompleteUI

@onready var panel = $Panel
@onready var level_title = $Panel/VBox/LevelTitle
@onready var completion_text = $Panel/VBox/CompletionText
@onready var card_title = $Panel/VBox/CardSection/CardTitle
@onready var card_description = $Panel/VBox/CardSection/CardDescription
@onready var continue_button = $Panel/VBox/ButtonSection/ContinueButton
@onready var menu_button = $Panel/VBox/ButtonSection/MenuButton

signal continue_pressed
signal menu_pressed

func _ready():
    setup_ui()
    
    # Connect button signals
    if continue_button:
        continue_button.pressed.connect(_on_continue_pressed)
    if menu_button:
        menu_button.pressed.connect(_on_menu_pressed)

func setup_ui():
    # Center the panel on screen
    if panel:
        panel.position = Vector2(
            (get_viewport().size.x - 600) / 2,
            (get_viewport().size.y - 450) / 2
        )
        panel.size = Vector2(600, 450)
        
        # Create beautiful gradient background
        var style_box = StyleBoxFlat.new()
        style_box.bg_color = Color(0.05, 0.05, 0.15, 0.95)
        
        # Rich golden border
        style_box.border_width_left = 6
        style_box.border_width_right = 6
        style_box.border_width_top = 6
        style_box.border_width_bottom = 6
        style_box.border_color = Color(1.0, 0.8, 0.2, 1.0)  # Rich gold
        
        # Rounded corners
        style_box.corner_radius_top_left = 20
        style_box.corner_radius_top_right = 20
        style_box.corner_radius_bottom_left = 20
        style_box.corner_radius_bottom_right = 20
        
        # Add subtle shadow effect
        style_box.shadow_color = Color(0, 0, 0, 0.5)
        style_box.shadow_size = 10
        style_box.shadow_offset = Vector2(5, 5)
        
        panel.add_theme_stylebox_override("panel", style_box)

func setup_completion_screen(level_name: String, card_name: String, card_desc: String):
    if level_title:
        level_title.text = "🏆 " + level_name + " - Complete! 🏆"
        level_title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))  # Bright gold
        level_title.add_theme_font_size_override("font_size", 28)
        level_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        
        # Add text shadow effect
        level_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
        level_title.add_theme_constant_override("shadow_offset_x", 2)
        level_title.add_theme_constant_override("shadow_offset_y", 2)
    
    if completion_text:
        completion_text.text = "🎉 Excellent work, Shivaji Raje! You have successfully completed this mission.\n\nYour strategic wisdom and courage have guided you through the first challenge."
        completion_text.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0, 1.0))  # Light blue-white
        completion_text.add_theme_font_size_override("font_size", 16)
        completion_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        completion_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    
    if card_title:
        card_title.text = "📜 Shivkaari Card Unlocked: " + card_name + " 📜"
        card_title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))  # Rich yellow
        card_title.add_theme_font_size_override("font_size", 20)
        card_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        
        # Add glow effect
        card_title.add_theme_color_override("font_shadow_color", Color(1.0, 0.8, 0.2, 0.5))
        card_title.add_theme_constant_override("shadow_offset_x", 0)
        card_title.add_theme_constant_override("shadow_offset_y", 0)
    
    if card_description:
        card_description.text = "✨ " + card_desc + " ✨"
        card_description.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 1.0))  # Light cyan
        card_description.add_theme_font_size_override("font_size", 14)
        card_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        card_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _on_continue_pressed():
    continue_pressed.emit()

func _on_menu_pressed():
    menu_pressed.emit()
    get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func show_completion():
    visible = true

func hide_completion():
    visible = false 