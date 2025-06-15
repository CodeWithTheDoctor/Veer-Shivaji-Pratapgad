extends Camera2D
class_name PlatformerCamera

@export var follow_speed: float = 5.0
@export var look_ahead_distance: float = 100.0
@export var vertical_offset: float = -50.0
@export var camera_zoom: float = 1.5

var target: Node2D
var target_position: Vector2

func _ready():
	# Set camera zoom for more focused platformer view
	zoom = Vector2(camera_zoom, camera_zoom)
	
	# Find the player
	target = get_parent().find_child("Player")
	if target:
		# Set initial position
		global_position = target.global_position + Vector2(0, vertical_offset)
		target_position = global_position

func _process(delta):
	if not target:
		return
	
	# Calculate target position with look-ahead
	var input_dir = Input.get_axis("move_left", "move_right")
	var look_ahead = input_dir * look_ahead_distance
	
	target_position.x = target.global_position.x + look_ahead
	target_position.y = target.global_position.y + vertical_offset
	
	# Smooth follow
	global_position = global_position.lerp(target_position, follow_speed * delta)
	
	# Respect camera limits
	global_position.x = clamp(global_position.x, limit_left, limit_right)
	global_position.y = clamp(global_position.y, limit_top, limit_bottom) 