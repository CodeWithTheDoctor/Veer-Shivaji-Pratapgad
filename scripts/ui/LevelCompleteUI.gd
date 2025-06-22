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
    # Create a magnificent Maratha-style panel
    if panel:
        # Much larger, more imposing size for royal presentation
        var screen_size = get_viewport().size
        var panel_width = min(1000, screen_size.x * 0.95)  # Increased from 800
        var panel_height = min(750, screen_size.y * 0.9)   # Increased from 600
        
        panel.position = Vector2(
            (screen_size.x - panel_width) / 2,
            (screen_size.y - panel_height) / 2
        )
        panel.size = Vector2(panel_width, panel_height)
        
        # Create royal Maratha-style background with rich textures
        var style_box = StyleBoxFlat.new()
        
        # Deep royal blue-purple gradient background like Maratha banners
        style_box.bg_color = Color(0.06, 0.1, 0.22, 0.98)  # Slightly darker for contrast
        
        # Rich saffron/gold border representing Maratha colors - thicker!
        style_box.border_width_left = 12  # Increased from 8
        style_box.border_width_right = 12
        style_box.border_width_top = 12
        style_box.border_width_bottom = 12
        style_box.border_color = Color(1.0, 0.7, 0.1, 1.0)  # Brighter saffron gold
        
        # Elegant rounded corners like traditional Indian architecture
        style_box.corner_radius_top_left = 30    # Increased from 25
        style_box.corner_radius_top_right = 30
        style_box.corner_radius_bottom_left = 30
        style_box.corner_radius_bottom_right = 30
        
        # More dramatic shadow for depth and grandeur
        style_box.shadow_color = Color(0, 0, 0, 0.8)  # Darker shadow
        style_box.shadow_size = 20                    # Increased from 15
        style_box.shadow_offset = Vector2(10, 10)     # Increased from (8,8)
        
        panel.add_theme_stylebox_override("panel", style_box)

func setup_completion_screen(level_name: String, card_name: String, card_desc: String):
    setup_royal_title(level_name)
    setup_completion_message()
    setup_shivkaari_card_section(card_name, card_desc)
    setup_royal_buttons()

func setup_royal_title(level_name: String):
    if level_title:
        # Majestic title with elegant royal styling - no emojis for cleaner look
        level_title.text = "✦ विजय! " + level_name + " - पूर्ण! ✦"
        
        # Rich golden color like temple decorations - brighter!
        level_title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
        level_title.add_theme_font_size_override("font_size", 52)  # Slightly reduced for better balance
        level_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        
        # Add proper line spacing for better readability
        level_title.add_theme_constant_override("line_spacing", 8)
        
        # Use magnificent EB Garamond ExtraBold for royal impact
        var eb_garamond_extra_bold = load("res://assets/fonts/EB_Garamond/static/EBGaramond-ExtraBold.ttf")
        if eb_garamond_extra_bold:
            level_title.add_theme_font_override("font", eb_garamond_extra_bold)
        
        # Enhanced shadow layers for depth and richness
        level_title.add_theme_color_override("font_shadow_color", Color(0.8, 0.4, 0.0, 1.0))
        level_title.add_theme_constant_override("shadow_offset_x", 4)
        level_title.add_theme_constant_override("shadow_offset_y", 4)
        
        # Add stronger outline effect for royal grandeur
        level_title.add_theme_color_override("font_outline_color", Color(0.5, 0.25, 0.0, 1.0))
        level_title.add_theme_constant_override("outline_size", 3)

func setup_completion_message():
    if completion_text:
        # Royal congratulatory message with traditional Indian respect and better formatting
        completion_text.text = "॥ धन्यवाद, वीर योद्धा! ॥\n\n~ Your strategic wisdom and unwavering courage have guided you ~\n~ through this sacred mission with the blessing of Bhavani Mata ~\n\n~ The legacy of Chhatrapati Shivaji Maharaj flows through your actions ~"
        
        # Brighter cream color like ancient manuscripts
        completion_text.add_theme_color_override("font_color", Color(0.98, 0.95, 0.9, 1.0))
        completion_text.add_theme_font_size_override("font_size", 28)  # Balanced size for readability
        completion_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        completion_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        
        # Add proper line spacing for elegant text flow
        completion_text.add_theme_constant_override("line_spacing", 12)
        
        # Use elegant EB Garamond Medium for readability with style
        var eb_garamond_medium = load("res://assets/fonts/EB_Garamond/static/EBGaramond-Medium.ttf")
        if eb_garamond_medium:
            completion_text.add_theme_font_override("font", eb_garamond_medium)
        
        # Enhanced shadow for manuscript effect
        completion_text.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
        completion_text.add_theme_constant_override("shadow_offset_x", 2)  # Increased from 1
        completion_text.add_theme_constant_override("shadow_offset_y", 2)

func setup_shivkaari_card_section(card_name: String, card_desc: String):
    if card_title:
        # Magnificent card title with traditional Indian manuscript styling - elegant symbols
        card_title.text = "╔══ शिवकारी पत्र प्राप्त! ══╗\n\n✦ " + card_name + " ✦"
        
        # Brilliant saffron gold like temple decorations - brighter!
        card_title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))
        card_title.add_theme_font_size_override("font_size", 38)  # Balanced for better visual hierarchy
        card_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        
        # Add proper line spacing for card section
        card_title.add_theme_constant_override("line_spacing", 10)
        
        # Use bold EB Garamond for importance
        var eb_garamond_bold = load("res://assets/fonts/EB_Garamond/static/EBGaramond-Bold.ttf")
        if eb_garamond_bold:
            card_title.add_theme_font_override("font", eb_garamond_bold)
        
        # Enhanced shadow and outline for card importance
        card_title.add_theme_color_override("font_shadow_color", Color(0.6, 0.3, 0.0, 1.0))
        card_title.add_theme_constant_override("shadow_offset_x", 3)  # Increased from 2
        card_title.add_theme_constant_override("shadow_offset_y", 3)
        card_title.add_theme_color_override("font_outline_color", Color(0.4, 0.2, 0.0, 0.8))
        card_title.add_theme_constant_override("outline_size", 2)  # Increased from 1
    
    if card_description:
        # Beautiful description with traditional wisdom styling and elegant formatting
        card_description.text = "~ " + card_desc + " ~\n\n╰─ \"ज्ञानं परमं बलम्\" - Knowledge is the ultimate strength ─╯"
        
        # Brighter golden-white like illuminated manuscripts
        card_description.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8, 1.0))
        card_description.add_theme_font_size_override("font_size", 24)  # Balanced for readability
        card_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        card_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        
        # Add proper line spacing for description
        card_description.add_theme_constant_override("line_spacing", 8)
        
        # Use elegant italic for wisdom quotes
        var eb_garamond_italic = load("res://assets/fonts/EB_Garamond/static/EBGaramond-Italic.ttf")
        if eb_garamond_italic:
            card_description.add_theme_font_override("font", eb_garamond_italic)
        
        # Enhanced shadow for depth
        card_description.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
        card_description.add_theme_constant_override("shadow_offset_x", 2)  # Increased from 1
        card_description.add_theme_constant_override("shadow_offset_y", 2)

func setup_royal_buttons():
    # Style the Continue button with royal Maratha colors
    if continue_button:
        continue_button.text = "आगे बढ़ें (Continue)"
        
        var continue_style = StyleBoxFlat.new()
        continue_style.bg_color = Color(0.85, 0.55, 0.15, 0.95)  # Richer golden brown
        continue_style.border_width_left = 4     # Increased from 3
        continue_style.border_width_right = 4
        continue_style.border_width_top = 4
        continue_style.border_width_bottom = 4
        continue_style.border_color = Color(1.0, 0.85, 0.4, 1.0)  # Brighter gold border
        continue_style.corner_radius_top_left = 20      # Increased from 15
        continue_style.corner_radius_top_right = 20
        continue_style.corner_radius_bottom_left = 20
        continue_style.corner_radius_bottom_right = 20
        
        # Add button shadow for depth
        continue_style.shadow_color = Color(0, 0, 0, 0.6)
        continue_style.shadow_size = 8
        continue_style.shadow_offset = Vector2(4, 4)
        
        continue_button.add_theme_stylebox_override("normal", continue_style)
        continue_button.add_theme_color_override("font_color", Color(1.0, 1.0, 0.95, 1.0))
        continue_button.add_theme_font_size_override("font_size", 32)  # MASSIVELY increased from 24
        
        # Use semi-bold for button importance
        var eb_garamond_semi_bold = load("res://assets/fonts/EB_Garamond/static/EBGaramond-SemiBold.ttf")
        if eb_garamond_semi_bold:
            continue_button.add_theme_font_override("font", eb_garamond_semi_bold)
        
        # Add button text shadow
        continue_button.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
        continue_button.add_theme_constant_override("shadow_offset_x", 2)
        continue_button.add_theme_constant_override("shadow_offset_y", 2)
    
    # Style the Menu button with complementary colors
    if menu_button:
        menu_button.text = "मुख्य मेनू (Main Menu)"
        
        var menu_style = StyleBoxFlat.new()
        menu_style.bg_color = Color(0.35, 0.45, 0.65, 0.9)  # Richer royal blue
        menu_style.border_width_left = 4     # Increased from 3
        menu_style.border_width_right = 4
        menu_style.border_width_top = 4
        menu_style.border_width_bottom = 4
        menu_style.border_color = Color(0.6, 0.7, 0.9, 1.0)  # Brighter blue border
        menu_style.corner_radius_top_left = 20      # Increased from 15
        menu_style.corner_radius_top_right = 20
        menu_style.corner_radius_bottom_left = 20
        menu_style.corner_radius_bottom_right = 20
        
        # Add button shadow for depth
        menu_style.shadow_color = Color(0, 0, 0, 0.6)
        menu_style.shadow_size = 8
        menu_style.shadow_offset = Vector2(4, 4)
        
        menu_button.add_theme_stylebox_override("normal", menu_style)
        menu_button.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0, 1.0))
        menu_button.add_theme_font_size_override("font_size", 32)  # MASSIVELY increased from 24
        
        # Use semi-bold for consistency
        var eb_garamond_semi_bold = load("res://assets/fonts/EB_Garamond/static/EBGaramond-SemiBold.ttf")
        if eb_garamond_semi_bold:
            menu_button.add_theme_font_override("font", eb_garamond_semi_bold)
        
        # Add button text shadow
        menu_button.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
        menu_button.add_theme_constant_override("shadow_offset_x", 2)
        menu_button.add_theme_constant_override("shadow_offset_y", 2)

func _on_continue_pressed():
    continue_pressed.emit()

func _on_menu_pressed():
    menu_pressed.emit()
    get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func show_completion():
    visible = true
    
    # Add a magnificent entrance animation with more drama
    modulate.a = 0.0
    scale = Vector2(0.7, 0.7)  # Start smaller for more dramatic effect
    
    var tween = create_tween()
    tween.set_parallel(true)
    
    # Fade in with royal grandeur - slower for more impact
    tween.tween_property(self, "modulate:a", 1.0, 1.2)  # Increased from 0.8
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 1.2)
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)

func hide_completion():
    visible = false 