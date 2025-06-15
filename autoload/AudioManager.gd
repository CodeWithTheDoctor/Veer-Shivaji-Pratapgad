extends Node

@onready var music_player = AudioStreamPlayer.new()
@onready var sfx_player = AudioStreamPlayer.new()
@onready var voice_player = AudioStreamPlayer.new()

var music_tracks: Dictionary = {}
var sfx_sounds: Dictionary = {}
var voice_clips: Dictionary = {}

var current_music: String = ""
var music_fade_duration: float = 2.0

func _ready():
	add_child(music_player)
	add_child(sfx_player)
	add_child(voice_player)
	
	# Set up audio players
	music_player.name = "MusicPlayer"
	sfx_player.name = "SFXPlayer"
	voice_player.name = "VoicePlayer"
	
	load_audio_resources()
	apply_volume_settings()
	
func load_audio_resources():
	# Load music tracks (will be populated when assets are available)
	music_tracks = {
		"main_theme": null, # load("res://assets/audio/music/main_theme.ogg"),
		"preparation": null, # load("res://assets/audio/music/preparation.ogg"),
		"combat": null, # load("res://assets/audio/music/combat.ogg"),
		"victory": null, # load("res://assets/audio/music/victory.ogg"),
		"javali_valley": null # load("res://assets/audio/music/javali_valley.ogg")
	}
	
	# Load SFX (will be populated when assets are available)
	sfx_sounds = {
		"menu_select": null, # load("res://assets/audio/sfx/menu_select.wav"),
		"footsteps": null, # load("res://assets/audio/sfx/footsteps.wav"),
		"sword_clash": null, # load("res://assets/audio/sfx/sword_clash.wav"),
		"waagh_nakha_strike": null, # load("res://assets/audio/sfx/waagh_nakha.wav"),
		"trumpet_signal": null, # load("res://assets/audio/sfx/trumpet.wav"),
		"cannon_fire": null # load("res://assets/audio/sfx/cannon.wav")
	}
	
	print("Audio resources initialized (assets to be loaded later)")
	
func play_music(track_name: String, fade_in: bool = true):
	if current_music == track_name:
		return
		
	if music_tracks.has(track_name) and music_tracks[track_name] != null:
		if fade_in and music_player.playing:
			fade_out_current_music()
			await get_tree().create_timer(music_fade_duration).timeout
			
		music_player.stream = music_tracks[track_name]
		music_player.play()
		current_music = track_name
		
		if fade_in:
			fade_in_music()
			
		print("Playing music: ", track_name)
	else:
		print("Music track not found or not loaded: ", track_name)
		
func fade_out_current_music():
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80, music_fade_duration)
	
func fade_in_music():
	music_player.volume_db = -80
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0, music_fade_duration)
	
func play_sfx(sound_name: String, volume_modifier: float = 1.0):
	if sfx_sounds.has(sound_name) and sfx_sounds[sound_name] != null:
		sfx_player.stream = sfx_sounds[sound_name]
		sfx_player.volume_db = linear_to_db(GameManager.game_settings.sfx_volume * volume_modifier)
		sfx_player.play()
		print("Playing SFX: ", sound_name)
	else:
		print("SFX not found or not loaded: ", sound_name)
		
func play_voice(clip_name: String):
	if voice_clips.has(clip_name) and voice_clips[clip_name] != null:
		voice_player.stream = voice_clips[clip_name]
		voice_player.volume_db = linear_to_db(GameManager.game_settings.voice_volume)
		voice_player.play()
		print("Playing voice: ", clip_name)
	else:
		print("Voice clip not found or not loaded: ", clip_name)
		
func apply_volume_settings():
	var settings = GameManager.game_settings
	music_player.volume_db = linear_to_db(settings.music_volume)
	sfx_player.volume_db = linear_to_db(settings.sfx_volume)
	voice_player.volume_db = linear_to_db(settings.voice_volume)

func stop_music():
	music_player.stop()
	current_music = ""

func stop_all_audio():
	music_player.stop()
	sfx_player.stop()
	voice_player.stop()
	current_music = ""

# Helper function to load audio resource safely
func load_audio_resource(path: String) -> AudioStream:
	if FileAccess.file_exists(path):
		return load(path)
	else:
		print("Audio file not found: ", path)
		return null 