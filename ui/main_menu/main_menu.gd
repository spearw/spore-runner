## main_menu.gd
extends Control

@onready var meta_shop_panel: PanelContainer = $MetaShopPanel
@onready var main_menu_buttons: VBoxContainer = $MainMenuButtons
@onready var character_select_panel: Control = $CharacterSelectPanel

func _ready():
	# Make sure the shop is hidden initially
	meta_shop_panel.hide()
	# Connect the back signal from the meta shop panel
	meta_shop_panel.back_pressed.connect(_on_back_button_pressed)

# --- Signal Handlers for Buttons ---
func _on_meta_shop_button_pressed():
	meta_shop_panel.refresh_all()
	meta_shop_panel.show()
	main_menu_buttons.hide()

func _on_back_button_pressed():
	meta_shop_panel.hide()
	main_menu_buttons.show()

func _on_start_run_button_pressed():
	character_select_panel.show()
	main_menu_buttons.hide()

func _on_quit_button_pressed():
	GameData.save_data()
	get_tree().quit()
