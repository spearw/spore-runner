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
var upgrade_manager: Node

var max_health: int
var current_health: int
var level: int = 1
var current_experience: int = 0
var experience_to_next_level: int = 100

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
	var move_speed = get_modified_move_speed()
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()
	
## Calculates the final value of a stat after applying permanent and artifact modifiers.
## @param base_stat_name: String - The name of the property on the PlayerStats resource (e.g., "base_move_speed").
## @param permanent_bonus_key: String - The key for the bonus in the GameData dictionary (e.g., "move_speed_bonus").
## @param artifact_modifier_method: String - The name of the method to call on artifacts (e.g., "modify_speed").
func get_modified_stat(base_stat_name: String, permanent_bonus_key: String, artifact_modifier_method: String) -> float:
	# 1. Get the base value from the PlayerStats resource using its string name.
	var final_value = stats.get(base_stat_name)
	
	# 2. Apply the permanent bonus from GameData using its string key.
	var permanent_bonus = GameData.data["permanent_stats"].get(permanent_bonus_key, 0.0)
	final_value *= (1.0 + permanent_bonus)
	
	# 3. Apply artifact modifiers from the current run.
	for artifact in artifacts_node.get_children():
		# Check if the artifact has the specified modifier method.
		if artifact.has_method(artifact_modifier_method):
			# Call the method by its string name, passing the current value.
			final_value = artifact.call(artifact_modifier_method, final_value)
			
	return final_value
	
## Calculates the final move speed after applying all artifact modifiers.
## @return: float - The final calculated move speed.
func get_modified_move_speed() -> float:
	return get_modified_stat("base_move_speed", "move_speed_bonus", "modify_speed")
	
## Calculates the final pickup radius after applying all artifact modifiers.
func get_modified_pickup_radius() -> float:
	return get_modified_stat("base_pickup_radius", "pickup_radius_bonus", "modify_pickup_radius")
	
## Calculates the final luck after applying all artifact modifiers.
func get_modified_luck() -> float:
	return get_modified_stat("base_luck", "luck_bonus", "modify_luck")
	
## Calculates the total projectile bonus from all equipped artifacts.
## @return: int - The number of extra projectiles to add.
func get_global_projectile_bonus() -> int:
	return get_modified_stat("base_projectile_bonus", "projectile_bonus", "modify_projectile_count")


## Calculates the total fire rate multiplier from all equipped artifacts.
## @return: float - The final multiplier for timer wait_time (e.g., 0.8 for 20% faster).
func get_global_firerate_modifier() -> float:
	return get_modified_stat("base_firerate_modifier", "firerate_modifier", "modify_firerate")
	
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
	pickup_area_shape.shape.radius = get_modified_pickup_radius()

## Handles the player's death sequence.
func die() -> void:
	# Emit the died signal for other nodes to react to.
	died.emit()
	
	# For now, simply remove the player from the game.
	# This will stop movement and further interactions.
	queue_free()
