## dev_console_ui.gd
## The UI for the developer console. Handles its own input for closing.
extends CanvasLayer

@onready var input_line: LineEdit = $ColorRect/MarginContainer/VBoxContainer/InputLine

func _ready():
	# Connect the LineEdit's signal to the global DevConsole singleton.
	input_line.text_submitted.connect(DevConsole._on_input_line_submitted)

# Process input to allow for closing while full game is paused.
func _input(event: InputEvent):
	# Check if the toggle action was just pressed.
	if event.is_action_pressed("ui_toggle_console"):
		# Tell the global DevConsole to handle the toggle logic.
		DevConsole._toggle_console_visibility()
		# Mark the event as handled so nothing else processes this key press.
		get_viewport().set_input_as_handled()
