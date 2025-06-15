extends Node

const SAVE_FILE = "user://shivaji_game_save.dat"
const SETTINGS_FILE = "user://game_settings.dat"

func save_game(data: Dictionary) -> bool:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file == null:
		print("Failed to open save file for writing")
		return false
		
	var json_string = JSON.stringify(data)
	file.store_string(json_string)
	file.close()
	print("Game saved successfully")
	return true
	
func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE):
		print("No save file found")
		return {}
		
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file == null:
		print("Failed to open save file for reading")
		return {}
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Failed to parse save file")
		return {}
		
	print("Game loaded successfully")
	return json.data
	
func has_save_data() -> bool:
	return FileAccess.file_exists(SAVE_FILE)
	
func delete_save_data() -> bool:
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
		print("Save data deleted")
		return true
	return false
	
func save_settings(settings: Dictionary) -> bool:
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file == null:
		print("Failed to open settings file for writing")
		return false
		
	var json_string = JSON.stringify(settings)
	file.store_string(json_string)
	file.close()
	print("Settings saved successfully")
	return true
	
func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_FILE):
		print("No settings file found")
		return {}
		
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if file == null:
		print("Failed to open settings file for reading")
		return {}
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Failed to parse settings file")
		return {}
		
	print("Settings loaded successfully")
	return json.data 