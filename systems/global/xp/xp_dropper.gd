## xp_dropper.gd
## A global utility for handling XP orb drops.
extends Node

# The data for different orb denominations, sorted from LARGEST to SMALLEST.
@export var orb_types: Array[ExperienceOrbStats]
# The scene for the generic orb/gem pickup.
const ORB_SCENE = preload("res://items/pickups/experience_gem/xp_orb.tscn")

# How much XP is granted per point of Challenge Rating.
const XP_PER_CHALLENGE_RATING = 2.0

## The main public function. Calculates and spawns XP orbs.
## @param enemy_stats: The stats of the defeated enemy.
## @param position: The world position to spawn the orbs at.
## @param xp_multiplier: Any bonus multipliers.
func drop_xp_for_enemy(enemy_stats: EnemyStats, position: Vector2, xp_multiplier: float = 1.0):
	# Calculate the total XP value to drop.
	var total_xp_value = enemy_stats.challenge_rating * XP_PER_CHALLENGE_RATING * xp_multiplier
	total_xp_value = roundi(total_xp_value) # Round to the nearest whole number
	
	if total_xp_value <= 0: return

	# Distribute that value into the largest possible orb denominations.
	var xp_remaining = total_xp_value
	for orb_stat in orb_types:
		var orb_value = orb_stat.experience_value
		if xp_remaining < orb_value:
			continue # This orb is too expensive, try the next smallest.
			
		var num_to_spawn = floori(xp_remaining / orb_value)
		for i in range(num_to_spawn):
			_spawn_orb(orb_stat, position)
			
		xp_remaining %= orb_value # Get the remainder

## Helper to spawn a single orb instance.
func _spawn_orb(stats: ExperienceOrbStats, position: Vector2):
	var orb = ORB_SCENE.instantiate()
	orb.stats = stats
	get_tree().current_scene.add_child(orb)
	# Spawn in a small random cluster.
	orb.global_position = position + Vector2(randf_range(-16, 16), randf_range(-16, 16))
