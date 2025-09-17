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
@onready var proximity_detector: Area2D = $ProximityDetector
@onready var player_targeting_component = $TargetingComponent
@onready var player_fire_behavior_component = $FireBehaviorComponent

@onready var stats_panel: CanvasLayer = get_tree().get_root().get_node("World/StatsPanel")

var upgrade_manager: Node

var is_invulnerable: bool = false
var max_health: int
var current_health: int
var level: int = 1
var current_experience: int = 0
var experience_to_next_level: int = 10
var last_move_direction: Vector2 = Vector2.RIGHT

var is_dying = false

var knockback_velocity: Vector2 = Vector2.ZERO

# This dictionary will store the sum of all percentage-based bonuses collected during a run.
# Key: bonus_key (String, e.g., "move_speed_bonus"), Value: total bonus (float, e.g., 0.25 for +25%)
var in_run_bonuses: Dictionary = {}
# Same as above, but temporary.
var timed_bonuses: Dictionary = {}

# In-run unique effects
var unlocked_powers: Dictionary = {}

# Melee
var can_redirect_projectiles: bool = false
var undaunted_knockback_base: float = 200.0
var whirlwind_speed_buff_base: float = 0.30
var whirlwind_duration_base: float = 2.0
var fof_speed_per_enemy_base: float = 0.01

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
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.05)
	var move_speed = get_stat("move_speed")
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0:
		last_move_direction = direction.normalized()
	velocity = direction * move_speed
	velocity += knockback_velocity
	move_and_slide()
	
## Adds a percentage-based bonus to the player's stat tracker.
func add_bonus(key: String, value: float, is_additive: bool=false):
	var current_bonus = in_run_bonuses.get(key, 0.0)
	in_run_bonuses[key] = current_bonus + value

	Logs.add_message(["Player bonus '%s' updated. New total for this run: %.2f" % [key, in_run_bonuses[key]]])
	notify_stats_changed()

# --- Get stat multiplier based on key ---
func get_stat_multiplier(key: String) -> float:
	# Return 1 if stat does not exist
	var permanent_bonus = GameData.data["permanent_stats"].get(key, 0.0)
	if (key in ["firerate", "dot_damage_tick_rate"]):
		# Ra 90%
		return max(0.1, 1.0-(permanent_bonus + in_run_bonuses.get(key, 0.0)))
	else:
		# Return 1 + total multiplier
		return 1.0 + permanent_bonus + in_run_bonuses.get(key, 0.0)
		
## Returns the final, calculated value for any player stat.
## @param key: String - The key for the stat (e.g., "move_speed", "damage").
func get_stat(key: String):
	# TODO: Add timed bonuses for all stats
	# TODO: Add projectile range (this will increase 'lifetime' value
	# TODO: Refactor to return 1 + x for all multiplicative values - keep logic in here.
	# TODO: Decide whether to use catch-all for simple values or leave as is for clarity
	match key:
		"move_speed":
			var move_speed = stats.base_move_speed * get_stat_multiplier(key)
			if unlocked_powers.has("fight_or_flight"):
				var fof_level = unlocked_powers["fight_or_flight"]
				var final_speed_per_enemy = fof_speed_per_enemy_base * (1 + (0.5 * (fof_level - 1)))
				var nearby_enemies = proximity_detector.get_overlapping_bodies().size()
				var fof_bonus = 1.0 + (nearby_enemies * final_speed_per_enemy)
				move_speed *= fof_bonus
				for artifact in artifacts_node.get_children():
					if artifact.has_method("get_speed_modifier"):
						move_speed *= artifact.get_speed_modifier()
			return move_speed
		"luck":
			var luck = stats.base_luck * get_stat_multiplier(key)
			for artifact in artifacts_node.get_children():
				if artifact.has_method("get_luck_modifier"):
					luck *= artifact.get_luck_modifier()
			return luck
		"critical_hit_rate":
			var critical_hit_rate = stats.base_critical_chance * get_stat_multiplier(key)
			for artifact in artifacts_node.get_children():
				if artifact.has_method("get_crit_rate_modifier"):
					critical_hit_rate *= artifact.get_crit_rate_modifier()
			return critical_hit_rate
		"critical_hit_damage":
			return stats.base_critical_damage * get_stat_multiplier(key)
		"damage_increase":
			var value = get_stat_multiplier(key)
			for artifact in artifacts_node.get_children():
				if artifact.has_method("get_damage_modifier"):
					value *= artifact.get_damage_modifier()
			return value
		"firerate":
			# Fire rate is also just a multiplier.
			return get_stat_multiplier(key)
		"projectile_speed":
			return get_stat_multiplier(key)
		"area_size":
			return get_stat_multiplier(key)
		"size":
			var base_size = 1.0
			var size = base_size
			for artifact in artifacts_node.get_children():
				if artifact.has_method("get_size_modifier"):
					size *= artifact.get_size_modifier()
			return size
		"projectile_count_multiplier":
			# Percentage, floored.
			return stats.base_projectile_count_multiplier * get_stat_multiplier(key)
		"armor":
			# Armor is a flat stat, so just add bonuses. Multiplier doesn't apply.
			var permanent_bonus = GameData.data["permanent_stats"].get("armor", 0)
			var in_run_bonus = in_run_bonuses.get("armor", 0)
			var timed_bonus = timed_bonuses.get("armor", 0)
			return stats.base_armor + permanent_bonus + in_run_bonus + timed_bonus
		"max_health":
			var base_hp = stats.base_max_health 
			var permanent_bonus = GameData.data["permanent_stats"].get("max_health", 0)
			var in_run_bonus = in_run_bonuses.get("max_health", 0)
			return base_hp + permanent_bonus + in_run_bonus
		"dot_damage_bonus":
			return 1 * get_stat_multiplier(key)
		"dot_damage_tick_rate":
			return 1 * get_stat_multiplier(key)
		"status_chance_bonus":
			return 1 * get_stat_multiplier(key)
		"status_duration":
			return 1 * get_stat_multiplier(key)
		"xp_multiplier":
			return 1 * get_stat_multiplier(key)
		_:
			printerr("get_stat: Requested unknown stat key: '", key, "'")
			return 1.0 # Return a safe default
		
	
## Adds experience to the player and checks for level-up conditions.
## @param amount: int - The amount of experience to add.
func add_experience(amount: int, force_level = false) -> void:
	current_experience += amount
	experience_changed.emit(current_experience, experience_to_next_level)
	
	# Check for flag to force level up
	if current_experience >= experience_to_next_level or force_level:
		# Subtract the cost of the level up.
		current_experience -= experience_to_next_level
		
		# Increase level and calculate the XP required for the next one.
		level += 1
		# A simple scaling formula for required XP.
		experience_to_next_level = int(experience_to_next_level * 1.2)
		
		# Announce the level up.
		leveled_up.emit(level)
		# Re-emit the experience_changed signal to update the UI with the new values.
		experience_changed.emit(current_experience, experience_to_next_level)
		
## Public function to apply a temporary, flat bonus to a stat.
func apply_timed_bonus(stat_key: String, value: float, duration: float):
	var current_bonus = timed_bonuses.get(stat_key, 0.0)
	timed_bonuses[stat_key] = current_bonus + value
	Logs.add_message(["Applied timed bonus: +%s %s for %.1fs" % [value, stat_key, duration]])
	
	# Create a one-shot timer to remove the bonus after the duration.
	var timer = get_tree().create_timer(duration)
	# Use a lambda function to pass arguments to the timeout signal.
	timer.timeout.connect(func(): remove_timed_bonus(stat_key, value))
	
	notify_stats_changed()

## Removes a temporary bonus. Called by the timer.
func remove_timed_bonus(stat_key: String, value: float):
	var current_bonus = timed_bonuses.get(stat_key, 0.0)
	timed_bonuses[stat_key] = current_bonus - value
	Logs.add_message(["Timed bonus expired: -%s %s" % [value, stat_key]])
	notify_stats_changed()

## Public method to apply damage to the player.
## @param amount: int - The amount of damage to inflict.
func take_damage(amount: int, armor_pen: float, is_crit: bool, source_node: Node = null) -> void:
	if is_invulnerable:
		return
		
	if unlocked_powers.has("undaunted") and source_node is Enemy:
		var undaunted_level = unlocked_powers["undaunted"]
		# The knockback now scales with the power's level.
		var final_knockback = undaunted_knockback_base * (1 + (0.5 * (undaunted_level - 1))) # +50% per level
		source_node.apply_knockback(final_knockback, self.global_position)

	
	# --- Armor Calculation ---
	var effective_armor = self.get_stat("armor") * (1.0 - armor_pen)
	var damage_taken = max(0, amount - effective_armor)
	
	# Take damage.
	Logs.add_message(["Taking Damage:", damage_taken])
	current_health = max(0, current_health - damage_taken)
	
	# Emit the signal to notify listeners (like the UI) of the health change.
	Logs.add_message(["Current Health:", current_health])
	Logs.add_message(["Max Health:", current_health])
	health_changed.emit(current_health, max_health)
	took_damage.emit()
		
	# TODO: refactor unique flags into unlocked_powers
	if can_redirect_projectiles and source_node is Projectile:
		var redirect_direction = player_targeting_component.get_fire_direction(self.global_position, Vector2.RIGHT, Projectile.Allegiance.PLAYER)
		player_fire_behavior_component._spawn_projectile(source_node.stats, Projectile.Allegiance.PLAYER, redirect_direction, self.global_position, self)
	
	# Check for death condition.
	if current_health <= 0:
		die()
		
## Applies a knockback force away from a given point.
## @param force: float - The strength of the knockback.
## @param from_position: Vector2 - The world position the knockback originates from.
func apply_knockback(force: float, from_position: Vector2):
	# Calculate the direction vector away from the damage source.
	# Logs.add_message(["Applying knockback:", force])
	var direction = (self.global_position - from_position).normalized()
	# Apply the force to the velocity. This will be handled by move_and_slide.
	knockback_velocity = direction * force
		
func notify_stats_changed():
	stats_changed.emit()
	proximity_detector.scale.x = 1 * get_stat("area_size")
	proximity_detector.scale.y = 1 * get_stat("area_size")
	self.scale = Vector2.ONE * get_stat("size")
	
# Heal
func heal(amount: int):
	current_health = min(get_stat("max_health"), current_health + amount)
	# Emit the health_changed signal so the UI updates.
	health_changed.emit(current_health, get_stat("max_health"))

## Handles the player's death sequence.
func die() -> void:
	# Emit the died signal for other nodes to react to.
	died.emit()
	
	# For now, simply remove the player from the game.
	# This will stop movement and further interactions.
	queue_free()
	
func set_invulnerability(active: bool):
	is_invulnerable = active
	if active:
		 # Make the player flash white or semi-transparent to show they are immune.
		sprite.modulate = Color(1, 1, 1, 0.5) # Semi-transparent white
	else:
		# Return to normal.
		sprite.modulate = Color.WHITE
		
# --- Transformations ---
func _on_enemy_killed(enemy: Node): 
	if unlocked_powers.has("whirlwind"):
		var whirlwind_level = unlocked_powers["whirlwind"]
		var speed_buff = whirlwind_speed_buff_base * (1 + (0.5 * (whirlwind_level - 1))) # +50% per level
		var attack_speed_buff = whirlwind_speed_buff_base * (1 + (0.5 * (whirlwind_level - 1))) # +50% per level
		var duration = whirlwind_duration_base
		apply_timed_bonus("move_speed", speed_buff, duration)
		apply_timed_bonus("firerate", attack_speed_buff, duration)
		
func set_redirect_ability(can_redirect: bool):
	can_redirect_projectiles = can_redirect
	if can_redirect:
		Logs.add_message(["Player gained redirect ability!"])

## Finds a power by its key, adds levels to it, and initializes it if it's the first time.
func add_power_level(power_key: String, levels_to_add: int):
	# Get the current level, defaulting to 0 if the power doesn't exist yet.
	var current_level = unlocked_powers.get(power_key, 0)
	
	# If this is the first time, "unlock" it with one time setups.
	if current_level == 0:
		_unlock_power(power_key)
		Logs.add_message(["Player unlocked power: ", power_key])

	unlocked_powers[power_key] = current_level + levels_to_add
	Logs.add_message(["Upgraded power '%s' to level %d" % [power_key, unlocked_powers[power_key]]])
	
	notify_stats_changed()

## A private helper to handle one-time setup for new powers.
func _unlock_power(power_key: String):
	if power_key == "whirlwind":
		# Connect signal
		Events.enemy_killed.connect(_on_enemy_killed)
