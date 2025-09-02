## stats_panel.gd
## Displays the player's current stats, weapons, and artifacts.
extends CanvasLayer

# --- Node References (Update these paths to match your scene!) ---
@onready var move_speed_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/MoveSpeedLabel
@onready var luck_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/LuckLabel
@onready var pickup_radius_label: Label = $PanelContainer/MarginContainer/HBoxContainer/StatsContainer/PickupRadiusLabel
@onready var weapons_grid: GridContainer = $PanelContainer/MarginContainer/HBoxContainer/ItemsContainer/WeaponsGridContainer
@onready var artifacts_grid: GridContainer = $PanelContainer/MarginContainer/HBoxContainer/ItemsContainer/ArtifactsGridContainer

var player: Node
var is_open: bool = false

func _ready():
	# This panel only exists in the game world, so we can get the player.
	player = get_tree().get_first_node_in_group("player")
	# Connect to the player's signal to know when to refresh if we're already open.
	if is_instance_valid(player):
		player.stats_changed.connect(refresh_all_stats)

func _unhandled_input(event: InputEvent):
	# The toggle can be handled here because this panel will be in the World scene.
	if event.is_action_pressed("ui_inventory"):
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
	pickup_radius_label.text = "Pickup Radius: %.0f" % player.get_stat("pickup_radius")
	pickup_radius_label.text = "Critical Hit Chance: %.0f" % player.get_stat("crit_chance")
	pickup_radius_label.text = "Critical Hit Damage: %.0f" % player.get_stat("crit_damage")
	pickup_radius_label.text = "Damage Multiplier: %.0f" % player.get_stat("damage_multiplier")
	pickup_radius_label.text = "Fire Rate Modifier: %.0f" % player.get_stat("firerate")
	pickup_radius_label.text = "Projectile Speed: %.0f" % player.get_stat("projectile_speed")
	pickup_radius_label.text = "Area Size: %.0f" % player.get_stat("area_size")

func _refresh_weapon_icons():
	for child in weapons_grid.get_children(): child.queue_free()
	
	var equipment = player.get_node("Equipment")
	for weapon in equipment.get_children():
		var icon = TextureRect.new()
		if weapon.has_method("projectile_stats") and weapon.get("projectile_stats"):
			icon.texture = weapon.get("projectile_stats").texture
		
		# Basic styling for the icon
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(64, 64)
		weapons_grid.add_child(icon)
		# In the next phase, this 'icon' will be a more complex button scene.

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
