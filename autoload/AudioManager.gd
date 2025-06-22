extends Node

@onready var music_player = AudioStreamPlayer.new()
@onready var sfx_player = AudioStreamPlayer.new()
@onready var voice_player = AudioStreamPlayer.new()

var music_tracks: Dictionary = {}
var sfx_sounds: Dictionary = {}
var voice_clips: Dictionary = {}

var current_music: String = ""
var music_fade_duration: float = 2.0

# Playlist functionality
var current_playlist: Array[String] = []
var current_playlist_index: int = 0
var is_playlist_playing: bool = false

func _ready():
	add_child(music_player)
	add_child(sfx_player)
	add_child(voice_player)
	
	# Set up audio players
	music_player.name = "MusicPlayer"
	sfx_player.name = "SFXPlayer"
	voice_player.name = "VoicePlayer"
	
	# Connect music player finished signal for playlist functionality
	music_player.finished.connect(_on_music_finished)
	
	load_audio_resources()
	apply_volume_settings()
	
func load_audio_resources():
	# Load music tracks
	music_tracks = {
		"main_menu_1": load_audio_resource("res://assets/audio/music/main-menu-1.mp3"),
		"main_menu_2": load_audio_resource("res://assets/audio/music/main-menu-2.mp3"),
		"main_theme": null, # load("res://assets/audio/music/main_theme.ogg"),
		"preparation": null, # load("res://assets/audio/music/preparation.ogg"),
		"combat": null, # load("res://assets/audio/music/combat.ogg"),
		"victory": null, # load("res://assets/audio/music/victory.ogg"),
		"javali_valley": null, # load("res://assets/audio/music/javali_valley.ogg")
		# Cutscene-specific music
		"bijapur_court_theme": load_audio_resource("res://assets/audio/cutscenes/bijapur_court_theme.ogg"),
		"temple_destruction_theme": load_audio_resource("res://assets/audio/cutscenes/temple_destruction_theme.ogg"),
		"rajgad_fort_theme": load_audio_resource("res://assets/audio/cutscenes/rajgad_fort_theme.ogg")
	}
	
	# Load SFX (will be populated when assets are available)
	sfx_sounds = {
		"menu_select": null, # load("res://assets/audio/sfx/menu_select.wav"),
		"jump": null, # load("res://assets/audio/sfx/jump.wav"),
		"land": null, # load("res://assets/audio/sfx/land.wav"),
		"footsteps": null, # load("res://assets/audio/sfx/footsteps.wav"),
		"climb_grab": null, # load("res://assets/audio/sfx/climb_grab.wav"),
		"climb_up": null, # load("res://assets/audio/sfx/climb_up.wav"),
		"interact": null, # load("res://assets/audio/sfx/interact.wav"),
		"sword_clash": null, # load("res://assets/audio/sfx/sword_clash.wav"),
		"waagh_nakha_strike": null, # load("res://assets/audio/sfx/waagh_nakha.wav"),
		"trumpet_signal": null, # load("res://assets/audio/sfx/trumpet.wav"),
		"cannon_fire": null # load("res://assets/audio/sfx/cannon.wav")
	}
	
	print("Audio resources initialized (assets to be loaded later)")
	
func play_music(track_name: String, fade_in: bool = true, volume_modifier: float = 1.0):
	if current_music == track_name:
		return
		
	if music_tracks.has(track_name) and music_tracks[track_name] != null:
		if fade_in and music_player.playing:
			fade_out_current_music()
			await get_tree().create_timer(music_fade_duration).timeout
			
		music_player.stream = music_tracks[track_name]
		music_player.play()
		current_music = track_name
		
		# Apply volume modifier (e.g., 0.8 for 20% reduction)
		var base_volume = linear_to_db(GameManager.game_settings.music_volume)
		var modified_volume = base_volume + linear_to_db(volume_modifier)
		music_player.volume_db = modified_volume
		
		if fade_in:
			fade_in_music(modified_volume)
			
		print("Playing music: ", track_name, " at volume: ", modified_volume, "db (modifier: ", volume_modifier, ")")
	else:
		print("Music track not found or not loaded: ", track_name)
		
func fade_out_current_music():
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80, music_fade_duration)
	
func fade_in_music(target_volume: float = 0.0):
	music_player.volume_db = -80
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", target_volume, music_fade_duration)
	
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

# Playlist functionality
func play_playlist(track_names: Array[String]):
	if track_names.size() == 0:
		print("Cannot play empty playlist")
		return
	
	current_playlist = track_names
	current_playlist_index = 0
	is_playlist_playing = true
	
	print("Starting playlist: ", track_names)
	_play_current_playlist_track()

func _play_current_playlist_track():
	if not is_playlist_playing or current_playlist.size() == 0:
		return
	
	var track_name = current_playlist[current_playlist_index]
	if music_tracks.has(track_name) and music_tracks[track_name] != null:
		music_player.stream = music_tracks[track_name]
		music_player.play()
		current_music = track_name
		print("Playing playlist track: ", track_name, " (", current_playlist_index + 1, "/", current_playlist.size(), ")")
	else:
		print("Playlist track not found: ", track_name)
		_advance_playlist()

func _on_music_finished():
	if is_playlist_playing:
		_advance_playlist()

func _advance_playlist():
	if not is_playlist_playing or current_playlist.size() == 0:
		return
	
	# Move to next track, loop back to start if at end
	current_playlist_index = (current_playlist_index + 1) % current_playlist.size()
	print("Advancing to next playlist track: ", current_playlist_index)
	
	# Small delay before playing next track
	await get_tree().create_timer(0.5).timeout
	_play_current_playlist_track()

func stop_playlist():
	is_playlist_playing = false
	current_playlist.clear()
	current_playlist_index = 0
	stop_music()
	print("Playlist stopped")

# Convenience function for main menu
func play_main_menu_music():
	play_playlist(["main_menu_1", "main_menu_2"]) 