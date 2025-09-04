## player.gd
## Manages player state, including movement and health.
extends CharacterBody2D

# Signal emitted when health changes. Passes current and max health.
signal health_changed(current_health, max_health)
# Signal emitted when the player's health reaches zero.
signal died
signal experience_changed(current_xp, required_xp)
signal leveled_up(new_level)
signal stats_changed
signal took_damage

@export var stats: CharacterData
@onready var artifacts_node: Node = $Artifacts
@onready var pickup_area_shape: CollisionShape2D = $PickupArea/CollisionShape2D
@onready var sprite = $AnimatedSprite2D

@onready var stats_panel: CanvasLayer = get_tree().get_root().get_node("World/StatsPanel")

var upgrade_manager: Node

var max_health: int
var current_health: int
var level: int = 1
var current_experience: int = 0
var experience_to_next_level: int = 100
var last_move_direction: Vector2 = Vector2.RIGHT

# This dictionary will store the sum of all percentage-based bonuses collected during a run.
# Key: bonus_key (String, e.g., "move_speed_bonus"), Value: total bonus (float, e.g., 0.25 for +25%)
var in_run_bonuses: Dictionary = {}

## initialize_character is called by world.tscn.
func _ready() -> void:
	# Announce that the initial stats are ready.
	notify_stats_changed()
	
## Configures the player node using data from a CharacterData resource.
## This is called by the World scene right after the player is instanced.
func initialize_character(character_data: CharacterData, world_upgrade_manager: Node):
	upgrade_manager = world_upgrade_manager
	self.stats = character_data
	# Apply visual data

	sprite.sprite_frames = stats.character_sprite_frames
		
	# Apply base stats
	max_health = stats.base_max_health
	current_health = max_health
	
	# Register with the UpgradeManager
	if is_instance_valid(upgrade_manager):
		upgrade_manager.register_player(self)
		
	# Grant starting items
	if stats and stats.starting_upgrades:
		for upgrade_resource in stats.starting_upgrades:
			var upgrade_package = {
				"upgrade": upgrade_resource,
				"rarity": upgrade_resource.rarity
			}
			upgrade_manager.apply_upgrade(upgrade_package)


## Called every physics frame for movement updates.
## @param delta: float - The time elapsed since the last physics frame.
func _physics_process(delta: float) -> void:
	var move_speed = get_stat("move_speed")
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0:
		last_move_direction = direction.normalized()
	velocity = direction * move_speed
	move_and_slide()
	
## Adds a percentage-based bonus to the player's stat tracker.
func add_multiplier(key: String, value: float):
	var current_multiplier = in_run_bonuses.get(key, 0.0)
	in_run_bonuses[key] = current_multiplier + value
	print("Player bonus '%s' updated. New total for this run: %.2f" % [key, in_run_bonuses[key]])
	notify_stats_changed()

# --- Get stat multiplier based on key ---
func get_stat_multiplier(key: String) -> float:
	var permanent_bonus = GameData.data["permanent_stats"].get(key, 0.0)
	if (key in ["firerate"]):
		# Fire rate is subtractive and caps at 90%
		return max(0.1, 1.0-(permanent_bonus + in_run_bonuses.get(key, 0.0)))
	else:
		# Return 1 + total multiplier
		return 1.0 + permanent_bonus + in_run_bonuses.get(key, 0.0)
		
## Returns the final, calculated value for any player stat.
## @param key: String - The key for the stat (e.g., "move_speed", "damage").
func get_stat(key: String):
	match key:
		"move_speed":
			return stats.base_move_speed * get_stat_multiplier(key)
		"luck":
			return stats.base_luck * get_stat_multiplier(key)
		"pickup_radius":
			# base pickup radius is enhanced by area size
			return stats.base_pickup_radius * get_stat_multiplier("area_size")
		"crit_chance":
			return stats.base_critical_chance * get_stat_multiplier(key)
		"crit_damage":
			return stats.base_critical_damage * get_stat_multiplier(key)
		"damage_increase":
			# Damage doesn't have a base value on the player, it's just a multiplier.
			return get_stat_multiplier(key)
		"firerate":
			# Fire rate is also just a multiplier.
			return get_stat_multiplier(key)
		"projectile_speed":
			return get_stat_multiplier(key)
		"area_size":
			return get_stat_multiplier(key)
		"projectile_count_multiplier":
			# Percentage, floored.
			return stats.base_projectile_count_multiplier * get_stat_multiplier(key)
		"armor":
			# Armor is a flat stat, so just add bonuses. Multiplier doesn't apply.
			var permanent_bonus = GameData.data["permanent_stats"].get("armor", 0)
			var in_run_bonus = in_run_bonuses.get("armor", 0)
			return stats.base_armor + permanent_bonus + in_run_bonus
		_:
			printerr("get_stat: Requested unknown stat key: '", key, "'")
			return 1.0 # Return a safe default
	
## Adds experience to the player and checks for level-up conditions.
## @param amount: int - The amount of experience to add.
func add_experience(amount: int) -> void:
	current_experience += amount
	experience_changed.emit(current_experience, experience_to_next_level)
	
	# Use a while loop in case of gaining multiple levels from one gem.
	while current_experience >= experience_to_next_level:
		# Subtract the cost of the level up.
		current_experience -= experience_to_next_level
		
		# Increase level and calculate the XP required for the next one.
		level += 1
		# A simple scaling formula for required XP.
		experience_to_next_level = int(experience_to_next_level * 1.4)
		
		# Announce the level up.
		leveled_up.emit(level)
		# Re-emit the experience_changed signal to update the UI with the new values.
		experience_changed.emit(current_experience, experience_to_next_level)

## Public method to apply damage to the player.
## @param amount: int - The amount of damage to inflict.
func take_damage(amount: int) -> void:
		# --- Armor Calculation ---
	var armor = get_stat("armor")
	var final_damage = max(0, amount - armor)
	# Reduce current health, ensuring it does not go below zero.
	current_health = max(0, current_health - amount)
	
	# Emit the signal to notify listeners (like the UI) of the health change.
	health_changed.emit(current_health, max_health)
	took_damage.emit()
	
	# Check for death condition.
	if current_health <= 0:
		die()
		
func notify_stats_changed():
	stats_changed.emit()
	pickup_area_shape.shape.radius = get_stat("pickup_radius")

## Handles the player's death sequence.
func die() -> void:
	# Emit the died signal for other nodes to react to.
	died.emit()
	
	# For now, simply remove the player from the game.
	# This will stop movement and further interactions.
	queue_free()
