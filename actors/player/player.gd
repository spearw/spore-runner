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

@export var stats: PlayerStats
@onready var artifacts_node: Node = $Artifacts
@onready var upgrade_manager: Node = get_tree().get_root().get_node("World/UpgradeManager")
@onready var pickup_area_shape: CollisionShape2D = $PickupArea/CollisionShape2D

var max_health: int
var current_health: int
var level: int = 1
var current_experience: int = 0
var experience_to_next_level: int = 100

## Called once when the node enters the scene tree.
func _ready() -> void:
	# Initialize health at the start of the game.
	max_health = stats.max_health
	current_health = max_health
	# Register player with upgrade manager
	if is_instance_valid(upgrade_manager):
		upgrade_manager.register_player(self)
	# Grant starting items
	if stats and stats.starting_upgrades:
		for upgrade in stats.starting_upgrades:
			# Apply base rarity to starting upgrades to manager can infer type
			var upgrade_package = {
				"upgrade": upgrade,
				"rarity": upgrade.rarity 
			}
			upgrade_manager.apply_upgrade(upgrade_package)

	# Initial stats update.
	notify_stats_changed()

## Called every physics frame for movement updates.
## @param delta: float - The time elapsed since the last physics frame.
func _physics_process(delta: float) -> void:
	var move_speed = get_modified_move_speed()
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()

	
## Calculates the final move speed after applying all artifact modifiers.
## @return: float - The final calculated move speed.
func get_modified_move_speed() -> float:
	var final_speed = stats.base_move_speed
	# Iterate over all equipped artifacts.
	for artifact in artifacts_node.get_children():
		# Check if the artifact has a speed modifier method/property.
		if artifact.has_method("modify_speed"):
			final_speed = artifact.modify_speed(final_speed)
	return final_speed
	
## Calculates the final pickup radius after applying all artifact modifiers.
func get_modified_pickup_radius() -> float:
	var final_radius = stats.base_pickup_radius
	for artifact in artifacts_node.get_children():
		if artifact.has_method("modify_pickup_radius"):
			final_radius = artifact.modify_pickup_radius(final_radius)
	return final_radius
	
## Calculates the final luck after applying all artifact modifiers.
func get_modified_luck() -> float:
	var final_luck = stats.base_luck
	for artifact in artifacts_node.get_children():
		if artifact.has_method("modify_luck"):
			final_luck = artifact.modify_pickup_radius(final_luck)
	return final_luck
	
## Calculates the total projectile bonus from all equipped artifacts.
## @return: int - The number of extra projectiles to add.
func get_global_projectile_bonus() -> int:
	var bonus = 0
	for artifact in artifacts_node.get_children():
		if artifact.has_method("get_projectile_bonus"):
			bonus += artifact.get_projectile_bonus()
	return bonus

## Calculates the total fire rate multiplier from all equipped artifacts.
## @return: float - The final multiplier for timer wait_time (e.g., 0.8 for 20% faster).
func get_global_firerate_modifier() -> float:
	var modifier = 1.0 # Start with no modification
	for artifact in artifacts_node.get_children():
		if artifact.has_method("get_firerate_modifier"):
			modifier *= artifact.get_firerate_modifier()
	return modifier
	
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
