## bug_reporter.gd
## A global Singleton that handles capturing and saving bug reports.
extends Node

const REPORT_DIR = "user://bug_reports/"

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
## Signal handler for manual button press
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("report_bug"):
		generate_bug_report("MANUAL")
		# Mark as handled so the game doesn't process input for anything else.
		get_viewport().set_input_as_handled()

func generate_bug_report(report_type: String, exception_info = null):
	Logs.add_message("Generating bug report...")
	
	# Create the directory if it doesn't exist.
	DirAccess.make_dir_absolute(REPORT_DIR)
	
	# Create a unique filename based on the current date and time.
	var time = Time.get_datetime_string_from_system(false, true).replace(":", "-")
	var report_basename = "report_%s" % time
	
	# Capture the screenshot.
	var screenshot_path = "%s%s.png" % [REPORT_DIR, report_basename]
	var img = get_viewport().get_texture().get_image()
	var err = img.save_png(screenshot_path)
	if err != OK:
		printerr("Failed to save screenshot.")
		return
	Logs.add_message(["Screenshot saved to: ", screenshot_path])

	# Gather log data.
	var log_data = _gather_log_data()
	var log_path = "%s%s.txt" % [REPORT_DIR, report_basename]
	var file = FileAccess.open(log_path, FileAccess.WRITE)
	if file:
		file.store_string(log_data)
		Logs.add_message("Log data saved.")
	else:
		printerr("Failed to save log data.")
	file.close()
	# Create a ZIPPacker instance
	var zip_path = "%s%s.zip" % [REPORT_DIR, report_basename]
	var zipper = ZIPPacker.new()

	# Open the zip file for writing
	var error = zipper.open(zip_path)
	if error != OK:
		print("Error opening zip file: ", error)
		return

	# Add the image file
	
	error = zipper.start_file("%s.png" % [report_basename])
	if error != OK:
		print("Error starting file 'my_image.png': ", error)
		zipper.close()
		return
	var image_data = FileAccess.get_file_as_bytes(screenshot_path)
	error = zipper.write_file(image_data)
	if error != OK:
		print("Error writing 'my_image.png': ", error)
		zipper.close()
		return

	# Add the text file
	error = zipper.start_file("%s.txt" % [report_basename]) 
	if error != OK:
		print("Error starting file 'my_text.txt': ", error)
		zipper.close()
		return
	var text_data = FileAccess.get_file_as_bytes(log_path)
	error = zipper.write_file(text_data)
	if error != OK:
		print("Error writing 'my_text.txt': ", error)
		zipper.close()
		return

	# Close the zip file
	zipper.close()
	print("Zip file created successfully at: ", zip_path)
	
	print("Bug report successfully zipped to: ", log_path)

	# Clean up the original files
	var dir = DirAccess.open(REPORT_DIR)
	dir.remove(report_basename + ".txt")
	dir.remove(report_basename + ".png")
	
	# Open the folder for the user.
	if report_type != "CRASH":
		OS.shell_open(ProjectSettings.globalize_path(REPORT_DIR))
	print("Bug report generated in: ", REPORT_DIR)
	

## Gathers game state information into a string.
func _gather_log_data() -> String:
	var log_string = "BUG REPORT - %s\n" % Time.get_datetime_string_from_system()
	log_string += "=========================\n\n"
	
	# --- GameData (Metaprogression) ---
	log_string += "--- Game Data ---\n"
	log_string += "Total Souls: %d\n" % GameData.data.get("total_souls", 0)
	log_string += "Selected Character: %s\n" % GameData.data.get("selected_character_path", "N/A")
	log_string += "Unlocked Characters: %s\n" % str(GameData.data.get("unlocked_character_paths", []))
	log_string += "Selected Packs: %s\n" % str(GameData.data.get("selected_pack_paths", [])) # Using the old path for now
	log_string += "\n"
	
	# --- Current Run State ---
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		log_string += "--- Current Run ---\n"
		log_string += "Player Health: %d / %d\n" % [player.current_health, player.get_stat("max_health")]
		log_string += "Player Position: %s\n" % str(player.global_position)
		log_string += "Run Time: %.2f seconds\n" % get_tree().get_root().get_node("World").game_time # Example path
		
		# Log equipped weapons
		log_string += "Weapons:\n"
		for weapon in player.get_node("Equipment").get_children():
			log_string += " - %s\n" % weapon.name
			
		# Log equipped artifacts
		log_string += "Artifacts:\n"
		for artifact in player.get_node("Artifacts").get_children():
			log_string += " - %s\n" % artifact.name
			
		log_string += "\n"
		# Log event history
		log_string += "--- RECENT EVENT LOG ---\n"
		log_string += Logs.get_history_as_string()
		log_string += "\n"

	# --- Console History ---
	# TODO: store dev console history
	
	log_string += "--- End of Report ---"
	return log_string
