## character_select_panel.gd
extends Control


# Character Select
@export var character_list: CharacterList
@export var character_button_scene: PackedScene

@onready var character_grid: GridContainer = $HBoxContainer/CharactersContainer/GridContainer
@onready var details_panel: VBoxContainer = $HBoxContainer/CharactersContainer/VBoxContainer
@onready var name_label: Label = $HBoxContainer/CharactersContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $HBoxContainer/CharactersContainer/VBoxContainer/DescriptionLabel

# Navigation Buttons
@onready var back_button: Button = $HBoxContainer/CharactersContainer/VBoxContainer/HBoxContainer/BackButton
@onready var select_button: Button = $HBoxContainer/CharactersContainer/VBoxContainer/HBoxContainer/SelectAndStartButton

# Upgrade packs
@export var all_packs: PackList
@export var upgrade_pack_button_scene: PackedScene
@export var max_packs_allowed: int = 3 # 3 including core pack

@onready var pack_grid: GridContainer = $HBoxContainer/PacksContainer/GridContainer

# Biomes
@export var all_biomes: BiomeList
@export var biome_button_scene: PackedScene

@onready var biome_grid: GridContainer = $HBoxContainer/BiomesContainer/GridContainer

var selected_character: PlayerStats
var selected_packs: Array[UpgradePackButton] = []
var selected_biome_button: BiomeButton = null

func _ready():
	GameData.unlocked_characters_changed.connect(populate_character_grid)
	populate_character_grid()

	# Select current character initially
	var default_char_path = GameData.data["selected_character_path"]
	var default_char_data = load(default_char_path)
	update_details_panel(default_char_data)

	# Populate packs
	GameData.unlocked_packs_changed.connect(populate_pack_grid)
	populate_pack_grid()

	# Populate biomes
	populate_biome_grid()
	

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

func update_details_panel(char_data: PlayerStats):
	self.selected_character = char_data
	self.name_label.text = char_data.display_name
	self.description_label.text = char_data.character_description

func _on_select_and_start_button_pressed():
	# Save selected character to persisted data
	GameData.set_selected_character(selected_character.resource_path)

	# Populate current run data singleton
	CurrentRun.selected_character = self.selected_character
	CurrentRun.selected_pack_paths = get_currently_selected_pack_paths_from_ui()
	CurrentRun.selected_biome = get_selected_biome()

	# Change scene to game world.
	get_tree().change_scene_to_file("res://world/world.tscn")

func _on_back_button_pressed():
	self.hide()
	get_parent().get_node("MainMenuButtons").show()
	
func populate_pack_grid():
	for child in pack_grid.get_children():
		child.queue_free()
	var unlocked_paths = GameData.data["unlocked_pack_paths"]
	for pack_data in all_packs.packs:
		var button: UpgradePackButton = upgrade_pack_button_scene.instantiate()
		var is_unlocked = pack_data.resource_path in unlocked_paths
		button.set_pack_data(pack_data, is_unlocked)
		button.selection_toggled.connect(_on_pack_selection_toggled)
		pack_grid.add_child(button)
		
		# Set the initial state based on the last run's selection (or defaults).
		if pack_data.resource_path in GameData.data.get("selected_pack_paths", []):
			button.set_selected(true)
			selected_packs.append(button)
			
func _on_pack_selection_toggled(button_instance: UpgradePackButton):
	if button_instance.is_selected():
		# The button was just checked.
		if not button_instance in selected_packs:
			selected_packs.append(button_instance)
		
		# Enforce the selection limit.
		if selected_packs.size() > max_packs_allowed:
			# Too many selected. Deselect the oldest one.
			var oldest_selection = selected_packs.pop_front()
			oldest_selection.set_selected(false)
	else:
		# The button was just unchecked.
		if button_instance in selected_packs:
			selected_packs.erase(button_instance)

# Get current selection
func get_currently_selected_pack_paths_from_ui() -> Array[String]:
	var paths: Array[String] = []
	for button in selected_packs:
		paths.append(button.pack_data.resource_path)
	return paths

# --- Biome Selection ---

func populate_biome_grid():
	if not biome_grid or not all_biomes or not biome_button_scene:
		return

	for child in biome_grid.get_children():
		child.queue_free()

	# For now, all biomes are unlocked (can add unlock system later)
	for biome_data in all_biomes.biomes:
		var button: BiomeButton = biome_button_scene.instantiate()
		button.set_biome_data(biome_data, true)  # All unlocked for now
		button.biome_selected.connect(_on_biome_selected)
		biome_grid.add_child(button)

		# Select first biome by default
		if selected_biome_button == null:
			_select_biome_button(button)

func _on_biome_selected(button_instance: BiomeButton):
	_select_biome_button(button_instance)

func _select_biome_button(button: BiomeButton):
	# Deselect previous
	if selected_biome_button:
		selected_biome_button.set_selected(false)

	# Select new
	selected_biome_button = button
	selected_biome_button.set_selected(true)

func get_selected_biome() -> BiomeDefinition:
	if selected_biome_button:
		return selected_biome_button.biome_data
	return null
