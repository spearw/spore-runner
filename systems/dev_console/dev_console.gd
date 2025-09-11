## dev_console.gd
## A global Singleton for handling developer commands.
extends Node

# --- References ---
var console_ui_scene = preload("res://systems/dev_console/dev_console_ui.tscn")
var console_instance: CanvasLayer = null

# --- Command Registry ---
# A dictionary where Key = command name, Value = dictionary of command info.
var commands = {}

func _ready():
	_register_command("help", "Lists all available commands.", self, "_execute_help")
	_register_command("add_souls", "Adds souls. Usage: add_souls [amount]", self, "_execute_add_souls")
	_register_command("add_xp", "Adds xp. Usage: add_xp [amount]", self, "_execute_add_xp")
	_register_command("unlock_all", "Unlocks all characters.", self, "_execute_unlock_all")
	_register_command("kill_all", "Kills all enemies in the current scene.", self, "_execute_kill_all")
	_register_command("delete_save", "Deletes the save file and reloads the current scene.", self, "_execute_clear_save")


# --- Command Execution ---

## Adds a command to our registry.
func _register_command(name: String, description: String, target: Object, method_name: String):
	commands[name.to_lower()] = {
		"description": description,
		"target": target,
		"method_name": method_name 
	}

## Parses and executes a command string from the user.
func _execute_command(command_string: String):
	if command_string.is_empty(): return
	
	var parts = command_string.split(" ", false)
	var command_name = parts[0].to_lower()
	var args = parts.slice(1)
	
	if command_name in commands:
		var command_info = commands[command_name]
		var target = command_info["target"]
		var method_name = command_info["method_name"] 
		
		# Call the method by its string name, and pass the 'args' array as a single argument.
		target.call(method_name, args)
	else:
		_log_to_console("Error: Command not found: '%s'" % command_name)

# --- UI Management ---

func _toggle_console_visibility():
	if not console_instance is CanvasLayer:
		console_instance = console_ui_scene.instantiate()
		# Add it to the root, but outside the main scene tree's pause group.
		get_tree().get_root().add_child(console_instance)
		# The connection is now done inside the UI's _ready() function.
	
	var is_opening = not console_instance.visible
	console_instance.visible = is_opening
	get_tree().paused = is_opening
	
	if is_opening:
		console_instance.get_node("ColorRect/MarginContainer/VBoxContainer/InputLine").grab_focus()

func _log_to_console(text: String):
	if console_instance is CanvasLayer:
		var log = console_instance.get_node("ColorRect/MarginContainer/VBoxContainer/ScrollContainer/OutputLog")
		log.text = log.text + text + "\n"
		# Give the engine one frame to process the new text and update the scrollbar's max value.
		await get_tree().process_frame
		# Now, set the scrollbar's value to its maximum to scroll to the bottom.
		var scroll_container = log.get_parent()
		scroll_container.get_v_scroll_bar().value = scroll_container.get_v_scroll_bar().max_value

func _on_input_line_submitted(text: String):
	_log_to_console("> " + text) # Echo the command
	_execute_command(text)
	var input_line = console_instance.get_node("ColorRect/MarginContainer/VBoxContainer/InputLine")
	input_line.clear()
	input_line.grab_focus()
	
func _unhandled_input(event: InputEvent):
	# Only listen if the console is NOT visible
	if not console_instance or not console_instance.visible:
		if event.is_action_pressed("ui_toggle_console"):
			_toggle_console_visibility()

# --- Command Implementations ---
# These are the actual functions that do the work.

func _execute_help(_args: Array):
	_log_to_console("Available Commands:")
	for command_name in commands:
		_log_to_console("- %s: %s" % [command_name, commands[command_name]["description"]])

func _execute_add_souls(args: Array):
	if args.is_empty():
		_log_to_console("Usage: add_souls [amount]")
		return
	var amount = args[0].to_int()
	GameData.add_souls(amount)
	_log_to_console("Added %d souls." % amount)
	
func _execute_add_xp(args: Array):
	if args.is_empty():
		_log_to_console("Usage: add_xp [amount]")
		return
	var amount = args[0].to_int()
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.add_experience(amount)
		_log_to_console("Added %d xp." % amount)
	else:
		Logs.add_message("Nothing to give xp to!")
		
func _execute_unlock_all(_args: Array):
	_execute_unlock_all_characters(_args)
	_execute_unlock_all_decks(_args)

func _execute_unlock_all_characters(_args: Array):
	var character_list = load("res://systems/global/lists/master_character_list.tres") # Load the master list
	for char_data in character_list.characters:
		GameData.unlock_character(char_data.resource_path)
	_log_to_console("All characters unlocked. Changes will appear on the next character screen visit.")
	
func _execute_unlock_all_decks(_args: Array):
	var pack_list = load("res://systems/global/lists/master_pack_list.tres") # Load the master list
	for pack_data in pack_list.packs:
		GameData.unlock_pack(pack_data.resource_path)
	_log_to_console("All packs unlocked. Changes will appear on the next character screen visit.")

func _execute_kill_all(_args: Array):
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	if all_enemies.is_empty():
		_log_to_console("No enemies to kill.")
		return
	for enemy in all_enemies:
		if is_instance_valid(enemy) and enemy.has_method("die"):
			enemy.die()
	_log_to_console("Killed %d enemies." % all_enemies.size())

func _execute_clear_save(_args: Array):
	_log_to_console("Deleting save file...")
	GameData.clear_save_file()
	_log_to_console("Reloading scene to apply changes...")
	# Reloading the scene is the best way to see the "fresh start" immediately.
	# We wait a very short moment to ensure the log message appears before the reload happens.
	await get_tree().create_timer(0.1).timeout
	get_tree().reload_current_scene()
