## stats_panel.gd
## Displays the player's current stats, weapons, and artifacts.
extends CanvasLayer

# --- Node References ---
@onready var weapons_grid: GridContainer = $PanelContainer/MarginContainer/HBoxContainer/ItemsContainer/WeaponsGridContainer
@onready var artifacts_grid: GridContainer = $PanelContainer/MarginContainer/HBoxContainer/ItemsContainer/ArtifactsGridContainer
@export var weapon_button_scene: PackedScene;
# Labels
@onready var move_speed_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/MoveSpeedLabel
@onready var luck_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/LuckLabel
@onready var pickup_radius_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/PickupRadiusLabel
@onready var critical_chance_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/CriticalChanceLabel
@onready var critical_damage_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/CriticalDamageLabel
@onready var damage_increase_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/DamageMultiplierLabel
@onready var firerate_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/FirerateLabel
@onready var projectile_speed_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/ProjectileSpeedLabel
@onready var area_size_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/AreaSizeLabel
@onready var armor_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/ArmorLabel
# Targeting Picker
@onready var targeting_picker: PanelContainer = $TargetingPicker

var player: Node
var is_open: bool = false

func _ready():
	targeting_picker.hide()

func _unhandled_input(event: InputEvent):
	# The toggle can be handled here because this panel will be in the World scene.
	if event.is_action_pressed("ui_inventory"):
		# This panel only exists in the game world, so we can get the player.
		player = get_tree().get_first_node_in_group("player")
		# Connect to the player's signal to know when to refresh if we're already open.
		if is_instance_valid(player):
			player.stats_changed.connect(refresh_all_stats)
		toggle_visibility()
		get_viewport().set_input_as_handled()

func toggle_visibility():
	is_open = not is_open
	visible = is_open
	get_tree().paused = is_open
	if is_open:
		refresh_all_stats()

## Fetches all current data from the player and updates the entire UI.
func refresh_all_stats():
	if not is_instance_valid(player): return
	
	_refresh_player_stats()
	_refresh_weapon_icons()
	_refresh_artifact_icons()

func _refresh_player_stats():
	move_speed_label.text = "Move Speed: %.0f" % player.get_stat("move_speed")
	luck_label.text = "Luck: %.2f" % player.get_stat("luck")
	pickup_radius_label.text = "Pickup Size: %.0f" % player.get_stat("pickup_radius")
	critical_chance_label.text = "Critical Hit Rate: %.0f%%" % (100 * player.get_stat("critical_hit_rate"))
	critical_damage_label.text = "Critical Hit Damage: %.0f%%" % (100 * player.get_stat("critical_hit_damage"))
	damage_increase_label.text = "Damage Increase: %.0f%%" % (100 * player.get_stat("damage_increase") - 100)
	firerate_label.text = "Fire Rate Interval: %.0f%%" % (100 * player.get_stat("firerate"))
	projectile_speed_label.text = "Projectile Speed Increase: %.0f%%" % (100 * player.get_stat("projectile_speed") - 100)
	projectile_speed_label.text = "Projectile Count Increase: %.0f%%" % (100 * player.get_stat("projectile_count"))
	area_size_label.text = "Area Increase: %.0f%%" % (100 * player.get_stat("area_size") - 100)
	var armor = player.get_stat("armor")
	var speed_penalty = armor * player.ARMOR_SPEED_PENALTY * 100
	armor_label.text = "Armor: %d (-%0.f%% speed)" % [armor, speed_penalty]

func _refresh_weapon_icons():
	for child in weapons_grid.get_children(): child.queue_free()
	
	var equipment = player.get_node("Equipment")
	for weapon in equipment.get_children():
		
		# Create targeting button for each weapon
		var button = weapon_button_scene.instantiate()
		button.weapon_node = weapon
		# Configure the button's icon.
		# TODO: Weapon icons
		var icon_rect = button.get_node("Icon")
		if weapon.projectile_stats:
			icon_rect.texture = weapon.projectile_stats.texture
		
		# Pass the weapon node reference directly with the signal.
		button.pressed.connect(_on_weapon_button_pressed.bind(weapon))
		
		weapons_grid.add_child(button)

func _refresh_artifact_icons():
	for child in artifacts_grid.get_children(): child.queue_free()
	
	var artifacts = player.get_node("Artifacts")
	# This loop is ready for when we add true artifacts.
	for artifact in artifacts.get_children():
		var icon = TextureRect.new()
		# We'll need a way to get an icon from our true artifacts later.
		# if artifact.has_method("get_icon"): icon.texture = artifact.get_icon()
		icon.custom_minimum_size = Vector2(48, 48)
		artifacts_grid.add_child(icon)
		
## Called when any weapon button in the grid is clicked.
func _on_weapon_button_pressed(weapon_node: Node):
	Logs.add_message(["Player clicked on weapon: ", weapon_node.name])
	# Tell the picker to open and configure itself for the selected weapon.
	targeting_picker.open_for_weapon(weapon_node)
