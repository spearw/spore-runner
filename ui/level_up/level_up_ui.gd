## level_up_ui.gd
## Manages the user interface for the level-up screen.
extends CanvasLayer

# An array to hold the upgrade choices currently being displayed.
var current_upgrades: Array[Dictionary]

# signal to announce when choice has been made
signal upgrade_chosen

@onready var stats_panel: CanvasLayer = get_tree().get_root().get_node("World/StatsPanel") # Update path


# Reference to player.
var player_node: Node2D

# References to UI elements for easier access.
@onready var upgrade_manager: Node = get_tree().get_root().get_node("World/UpgradeManager")
@onready var upgrade_buttons: Array[Button] = [
	$BackgroundColor/MarginContainer/VBoxContainer/UpgradeButton1,
	$BackgroundColor/MarginContainer/VBoxContainer/UpgradeButton2,
	$BackgroundColor/MarginContainer/VBoxContainer/UpgradeButton3
]

func _ready() -> void:
	self.hide()
	
	# Connect all button presses to a single handler.
	for i in range(upgrade_buttons.size()):
		# .bind(i) passes the index 'i' as an argument to the function.
		upgrade_buttons[i].pressed.connect(_on_upgrade_button_pressed.bind(i))
	Events.boss_reward_requested.connect(on_boss_reward_requested)
	
## Called by the global 'boss_reward_requested' signal.
func on_boss_reward_requested():
	print("UI received boss reward request. Granting free level-ups.")
	# For now, we'll just show the level up screen 3 times in a row.
	# A better system might have a dedicated multi-choice UI.
	# We need to use a loop that waits for the player to choose before showing the next.
	_show_reward_sequence(3)

func _on_show_stats_button_pressed():
	if stats_panel:
		stats_panel.toggle_visibility()

## Asynchronously shows the level-up screen multiple times.
func _show_reward_sequence(count: int):
	for i in range(count):
		# Manually trigger the level-up display logic.
		show_upgrade_screen()

		# Wait for signal that reward was chosen
		await self.upgrade_chosen
		await get_tree().process_frame
	
## Called when the player levels up. Fetches and displays upgrade choices.
func on_player_leveled_up(new_level: int):
	show_upgrade_screen()
	
func show_upgrade_screen():
	get_tree().paused = true
	self.show()
	current_upgrades = upgrade_manager.get_upgrade_choices(3)
	
	for i in range(upgrade_buttons.size()):
		var button = upgrade_buttons[i]
		if i < current_upgrades.size():
			var upgrade_package = current_upgrades[i]
			var upgrade: Upgrade = upgrade_package["upgrade"]
			var rarity_enum: Upgrade.Rarity = upgrade_package["rarity"]
			
			# Check if it has multiple rarities
			if upgrade.rarity_values.size() > 0:
				var value = upgrade.rarity_values[rarity_enum]
				# Dyanmic text and colors
				button.text = "%s\n%s (+%s)" % [upgrade.display_name, upgrade.description, value]
			else: 
				button.text = "%s\n%s" % [upgrade.display_name, upgrade.description]
				
			match rarity_enum:
				Upgrade.Rarity.COMMON:
					button.modulate = Color.WHITE
				Upgrade.Rarity.RARE:
					button.modulate = Color.BLUE
				Upgrade.Rarity.EPIC:
					button.modulate = Color.PURPLE
				Upgrade.Rarity.LEGENDARY:
					button.modulate = Color.YELLOW
				Upgrade.Rarity.MYTHIC:
					button.modulate = Color.ORANGE_RED
			button.visible = true
		else:
			button.visible = false

## Called when any of the upgrade buttons are pressed.
## @param choice_index: int - The index of the button that was pressed.
func _on_upgrade_button_pressed(choice_index: int) -> void:
	# Apply the selected upgrade.
	upgrade_manager.apply_upgrade(current_upgrades[choice_index])
	
	upgrade_chosen.emit()
		
	# Hide the UI and unpause the game.
	self.hide()
	get_tree().paused = false
