## game_data.gd
## A Singleton that manages persistent player data, like currency and unlocks.
extends Node

# The file path for our save data. user:// is a special Godot path
# that points to a safe, user-specific location on the computer.
const SAVE_PATH = "user://game_data.save"

# Signals
signal unlocked_characters_changed
signal unlocked_packs_changed

# --- Data To Save ---
# We use a dictionary to hold all our data. This makes saving/loading easy.
var starter_data = {
	"total_souls": 0,
	# The resource path of the currently selected character for the next run.
	"selected_character_path": "res://actors/player/characters/edgerunner/edgerunner_character.tres",
	# A list of resource paths for all characters the player has unlocked.
	"unlocked_character_paths": ["res://actors/player/characters/edgerunner/edgerunner_character.tres"],
	# A list of resource paths for all unlocked upgrade packs.
	"unlocked_pack_paths": ["res://systems/upgrades/packs/core_pack.tres"],
	"permanent_stats": {
		"move_speed_bonus": 0.0,
		"luck_bonus": 0.0,
	}
}
var data = starter_data.duplicate()

func _ready():
	load_data()

# --- Public API ---
func add_souls(amount: int):
	data["total_souls"] += amount
	Logs.add_message(["Souls collected! Total: ", data["total_souls"]])
	# TODO: emit a signal here for the UI to update.

## Sets the character to be used for the next run.
## @param character_data_path: String - The resource path of the CharacterData .tres file.
func set_selected_character(character_data_path: String):
	if character_data_path in data["unlocked_character_paths"]:
		data["selected_character_path"] = character_data_path
		Logs.add_message(["Selected character: ", character_data_path])
	else:
		printerr("Attempted to select a character that is not unlocked: ", character_data_path)

## Adds a new character to the list of unlocked characters.
## @param character_data_path: String - The resource path to unlock.
func unlock_character(character_data_path: String):
	if not character_data_path in data["unlocked_character_paths"]:
		data["unlocked_character_paths"].append(character_data_path)
		Logs.add_message(["Unlocked new character: ", character_data_path])
		# Emit signal that character was unlocked.
		unlocked_characters_changed.emit()
		
func unlock_pack(pack_path: String):
	if not pack_path in data["unlocked_pack_paths"]:
		data["unlocked_pack_paths"].append(pack_path)
		Logs.add_message(["Unlocked new pack: ", pack_path])
		unlocked_packs_changed.emit()

# --- Save/Load Logic ---
func save_data():
	# Open the file for writing.
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		# Convert the data dictionary to a JSON string.
		var json_string = JSON.stringify(data, "\t")
		# Write the string to the file.
		file.store_string(json_string)
		Logs.add_message("Game data saved successfully.")
	else:
		printerr("Failed to open save file for writing.")

func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			# Read the entire file as text.
			var json_string = file.get_as_text()
			# Parse the JSON string back into a Godot variant (our dictionary).
			var parse_result = JSON.parse_string(json_string)
			if parse_result:
				data = parse_result
				Logs.add_message("Game data loaded successfully.")
			else:
				printerr("Failed to parse save file JSON.")
		else:
			printerr("Failed to open save file for reading.")
	else:
		Logs.add_message("No save file found. Using default data.")
		
## Deletes the save file from the disk.
func clear_save_file():
	var dir = DirAccess.open("user://")
	# Reset active game data
	data = starter_data.duplicate()
	## TODO: Generalize signal to all components
	unlocked_characters_changed.emit()
	# Clear save file
	if dir.file_exists(SAVE_PATH):
		var err = dir.remove(SAVE_PATH.replace("user://", "")) # DirAccess.remove needs a relative path
		if err == OK:
			Logs.add_message("Save file deleted successfully.")
		else:
			printerr("Error deleting save file. Code: ", err)
	else:
		Logs.add_message("No save file to delete.")
