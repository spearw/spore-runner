## meta_upgrade_button.gd
class_name MetaUpgradeButton
extends PanelContainer

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
	if not upgrade_data:
		return
	var current_level = get_current_level()
	var cost = calculate_cost(current_level)
	var is_maxed = current_level >= upgrade_data.max_level

	name_label.text = upgrade_data.display_name
	desc_label.text = upgrade_data.description
	level_label.text = "Level %d / %d" % [current_level, upgrade_data.max_level]

	if is_maxed:
		cost_label.text = "MAXED"
	else:
		cost_label.text = "Cost: %d Souls" % cost

	purchase_button.disabled = GameData.get_souls() < cost or is_maxed

func get_current_level() -> int:
	return GameData.get_permanent_stat_level(upgrade_data.stat_key, upgrade_data.value_per_level)

func calculate_cost(current_level: int) -> int:
	return floori(upgrade_data.base_cost * pow(upgrade_data.cost_scaling_factor, current_level))

func _on_purchase_button_pressed():
	var current_level = get_current_level()
	var cost = calculate_cost(current_level)

	if GameData.spend_souls(cost):
		GameData.upgrade_permanent_stat(upgrade_data.stat_key, upgrade_data.value_per_level)
		GameData.save_data()
		update_display()
		purchased_upgrade.emit()
