## loot_manager.gd
## A global utility for handling all enemy loot drops.
extends Node

# --- Configuration ---
@export var orb_types: Array[ExperienceOrbStats]
@export var soul_scene: PackedScene
@export var heart_scene: PackedScene
@export var magnet_scene: PackedScene

# The scene for the generic orb pickup.
const ORB_SCENE = preload("res://items/pickups/experience_gem/xp_orb.tscn")
# How much XP is granted per point of Challenge Rating.
const XP_PER_CHALLENGE_RATING = 2.0

## The main public function. Processes a loot table and spawns all drops.
func process_loot_drop(enemy_stats: EnemyStats, position: Vector2, player_ref: Node):
	if not enemy_stats.loot_table:
		printerr("Enemy %s has no loot table assigned." % enemy_stats.name)
		return

	var loot_table: LootTable = enemy_stats.loot_table
	
	# --- Handle XP ---
	if loot_table.drops_xp:
		var xp_multiplier = 1
		if is_instance_valid(player_ref):
			xp_multiplier = player_ref.get_stat("xp_multiplier")
		drop_xp(enemy_stats, position, xp_multiplier)
		
	# --- Handle Pickups ---
	if randf() < loot_table.soul_drop_chance:
		_spawn_pickup(soul_scene, position)
	
	if randf() < loot_table.heart_drop_chance:
		_spawn_pickup(heart_scene, position)
		
	if randf() < loot_table.magnet_drop_chance:
		_spawn_pickup(magnet_scene, position)

	# --- Handle Special Drops ---
	if loot_table.special_drop_scene:
		_spawn_pickup(loot_table.special_drop_scene, position)

func drop_xp(enemy_stats, position, xp_multiplier):
	var total_xp_value = roundi(enemy_stats.challenge_rating * XP_PER_CHALLENGE_RATING * xp_multiplier)
	_drop_xp_value(total_xp_value, position)

## Distributes an XP value into orb denominations.
func _drop_xp_value(xp_value: int, position: Vector2):
	if xp_value <= 0: return
	var xp_remaining = xp_value
	for orb_stat in orb_types:
		var orb_value = orb_stat.experience_value
		if xp_remaining >= orb_value:
			var num_to_spawn = floori(xp_remaining / orb_value)
			for i in range(num_to_spawn):
				_spawn_orb(orb_stat, position)
			xp_remaining %= orb_value

## Helper to spawn a single XP orb.
func _spawn_orb(stats: ExperienceOrbStats, position: Vector2):
	var orb = ORB_SCENE.instantiate()
	orb.stats = stats
	get_tree().current_scene.add_child(orb)
	orb.global_position = position + Vector2(randf_range(-16, 16), randf_range(-16, 16))

## Generic helper to spawn any other pickup.
func _spawn_pickup(scene: PackedScene, position: Vector2):
	if not scene: return
	var instance = scene.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = position + Vector2(randf_range(-16, 16), randf_range(-16, 16))
