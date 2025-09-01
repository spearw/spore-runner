## main_menu.gd
extends Control

@export var meta_upgrades: Array[MetaUpgrade]
@export var upgrade_button_scene: PackedScene

@onready var meta_shop_panel: PanelContainer = $MetaShopPanel
@onready var upgrade_grid: GridContainer = $MetaShopPanel/VBoxContainer/GridContainer
@onready var souls_label: Label = $MetaShopPanel/VBoxContainer/SoulsCount
@onready var main_menu_buttons: VBoxContainer = $MainMenuButtons
@onready var character_select_panel: Control = $CharacterSelectPanel

func _ready():
	# Make sure the shop is hidden initially
	meta_shop_panel.hide()
	populate_shop()

func populate_shop():
	# Clear any old buttons
	for child in upgrade_grid.get_children():
		child.queue_free()

	# Create a button for each upgrade
	for upgrade_data in meta_upgrades:
		var button_instance = upgrade_button_scene.instantiate()
		upgrade_grid.add_child(button_instance)
		# Tell the button to configure itself with the data
		button_instance.set_upgrade_data(upgrade_data)
		# Connect signal
		button_instance.purchased_upgrade.connect(update_souls_display)

func update_souls_display():
	souls_label.text = "Souls: %s" % GameData.data["total_souls"]

# --- Signal Handlers for Buttons ---
func _on_meta_shop_button_pressed():
	meta_shop_panel.show()
	main_menu_buttons.hide()
	update_souls_display()
	
func _on_back_button_pressed():
	meta_shop_panel.hide()
	main_menu_buttons.show()
	update_souls_display()
	
func _on_start_run_button_pressed():
	character_select_panel.show()
	main_menu_buttons.hide()

func _on_quit_button_pressed():
	GameData.save_data()
	get_tree().quit()
