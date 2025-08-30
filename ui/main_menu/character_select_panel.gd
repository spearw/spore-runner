## character_select_panel.gd
extends Control

@export var character_list: CharacterList
@export var character_button_scene: PackedScene

@onready var character_grid: GridContainer = $HBoxContainer/GridContainer
@onready var details_panel: VBoxContainer = $HBoxContainer/VBoxContainer
@onready var name_label: Label = $HBoxContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $HBoxContainer/VBoxContainer/DescriptionLabel
@onready var back_button: Button = $BackButton
@onready var select_button: Button = $SelectButton

var selected_character: CharacterData

func _ready():
	GameData.unlocked_characters_changed.connect(populate_character_grid)
	populate_character_grid()
	# Select the default character initially
	var default_char_path = GameData.data["selected_character_path"]
	var default_char_data = load(default_char_path)
	update_details_panel(default_char_data)

func populate_character_grid():
	for child in character_grid.get_children():
		child.queue_free()
	var unlocked_paths = GameData.data["unlocked_character_paths"]
	for char_data in character_list.characters:
		var button = character_button_scene.instantiate()
		var is_unlocked = char_data.resource_path in unlocked_paths
		button.set_character(char_data, is_unlocked)
		button.character_selected.connect(update_details_panel)
		character_grid.add_child(button)

func update_details_panel(char_data: CharacterData):
	self.selected_character = char_data
	self.name_label.text = char_data.character_name
	self.description_label.text = char_data.character_description

func _on_select_and_start_button_pressed():
	# Save selected character to persisted data
	GameData.set_selected_character(selected_character.resource_path)
	
	# Populate current run data singleton
	CurrentRun.selected_character = self.selected_character
	
	# Change scene to game world.
	get_tree().change_scene_to_file("res://world/world.tscn")

func _on_back_button_pressed():
	self.hide()
	get_parent().get_node("MainMenuButtons").show()
