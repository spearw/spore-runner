## level_up_ui.gd
## Manages the user interface for the level-up screen.
extends CanvasLayer

# An array to hold the upgrade choices currently being displayed.
var current_upgrades: Array[Upgrade]

# References to UI elements for easier access.
@onready var upgrade_manager: Node = get_tree().get_root().get_node("World/UpgradeManager")
@onready var upgrade_buttons: Array[Button] = [
	$BackgroundColor/MarginContainer/VBoxContainer/UpgradeButton1,
	$BackgroundColor/MarginContainer/VBoxContainer/UpgradeButton2,
	$BackgroundColor/MarginContainer/VBoxContainer/UpgradeButton3
]

func _ready() -> void:
	self.hide()
	# Connect to the player's level up signal.
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.leveled_up.connect(on_player_leveled_up)
	
	# Connect all button presses to a single handler.
	for i in range(upgrade_buttons.size()):
		# .bind(i) passes the index 'i' as an argument to the function.
		upgrade_buttons[i].pressed.connect(_on_upgrade_button_pressed.bind(i))

## Called when the player levels up. Fetches and displays upgrade choices.
func on_player_leveled_up(new_level: int) -> void:
	get_tree().paused = true
	self.show()
	
	# Get 3 upgrade choices from the manager.
	current_upgrades = upgrade_manager.get_upgrade_choices(3)
	
	# Configure the buttons based on the choices.
	for i in range(upgrade_buttons.size()):
		var button = upgrade_buttons[i]
		if i < current_upgrades.size():
			var upgrade = current_upgrades[i]
			button.text = "%s\n%s" % [upgrade.display_name, upgrade.description]
			button.visible = true
		else:
			button.visible = false # Hide buttons if we have fewer than 3 choices.

## Called when any of the upgrade buttons are pressed.
## @param choice_index: int - The index of the button that was pressed.
func _on_upgrade_button_pressed(choice_index: int) -> void:
	# Apply the selected upgrade.
	upgrade_manager.apply_upgrade(current_upgrades[choice_index])
	
	# Hide the UI and unpause the game.
	self.hide()
	get_tree().paused = false
