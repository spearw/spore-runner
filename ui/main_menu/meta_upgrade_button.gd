## meta_upgrade_button.gd
class_name MetaUpgradeButton
extends Control

var upgrade_data: MetaUpgrade
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var desc_label: Label = $VBoxContainer/DescriptionLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var cost_label: Label = $VBoxContainer/CostLabel
@onready var purchase_button: Button = $VBoxContainer/PurchaseButton

# Signals
signal purchased_upgrade

func _ready():
	pass

func set_upgrade_data(data: MetaUpgrade):
	self.upgrade_data = data
	update_display()

func update_display():
	var current_level = GameData.data["permanent_stats"].get(upgrade_data.stat_key, 0) / upgrade_data.value_per_level
	var cost = calculate_cost(current_level)
	
	name_label.text = upgrade_data.display_name
	desc_label.text = upgrade_data.description
	level_label.text = "Level %d / %d" % [current_level, upgrade_data.max_level]
	cost_label.text = "Cost: %d Souls" % cost
	
	purchase_button.disabled = GameData.data["total_souls"] < cost or current_level >= upgrade_data.max_level

func calculate_cost(current_level: int) -> int:
	return floori(upgrade_data.base_cost * pow(upgrade_data.cost_scaling_factor, current_level))

func _on_purchase_button_pressed():
	var current_level = GameData.data["permanent_stats"].get(upgrade_data.stat_key, 0) / upgrade_data.value_per_level
	var cost = calculate_cost(current_level)
	
	if GameData.data["total_souls"] >= cost:
		GameData.data["total_souls"] -= cost
		GameData.data["permanent_stats"][upgrade_data.stat_key] += upgrade_data.value_per_level
		print("Purchased '%s'. New value: %s" % [upgrade_data.display_name, GameData.data["permanent_stats"][upgrade_data.stat_key]])
		update_display()
		# We need to tell the main menu to update the soul count and other buttons
		purchased_upgrade.emit()
