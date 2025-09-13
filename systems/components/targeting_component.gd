## targeting_component.gd
## A component that provides targeting functionality to any parent node.
class_name TargetingComponent
extends Node

enum TargetingMode {
	NEAREST,
	FARTHEST,
	RANDOM,
	HIGHEST_HEALTH,
	LOWEST_HEALTH,
	LAST_MOVE_DIRECTION,
	NONE
}

@export var targeting_mode: TargetingMode = TargetingMode.NEAREST

var targeting_mode_override: int

## The main public function to find a target.
func find_target(origin_pos: Vector2, weapon_allegiance: Projectile.Allegiance) -> Node2D:
	var target_group = "enemies" if weapon_allegiance == Projectile.Allegiance.PLAYER else "player"
	var candidates = get_tree().get_nodes_in_group(target_group)
	
	if candidates.is_empty():
		return null

	var best_target: Node2D = null
	
	# Force specific targeting.
	if targeting_mode_override:
		targeting_mode = targeting_mode_override

	match targeting_mode:
		TargetingMode.NEAREST:
			best_target = _find_nearest(origin_pos, candidates)
		
		TargetingMode.FARTHEST:
			best_target = _find_farthest(origin_pos, candidates)
			
		TargetingMode.RANDOM:
			best_target = candidates.pick_random()
			
		TargetingMode.HIGHEST_HEALTH:
			best_target = _find_highest_health(candidates)
			
		TargetingMode.LOWEST_HEALTH:
			best_target = _find_lowest_health(candidates)
		
		# LAST_MOVE_DIRECTION is handled in get_fire_direction.
		TargetingMode.LAST_MOVE_DIRECTION, TargetingMode.NONE:
			pass
			
	return best_target

## Calculates a fire direction based on the current targeting mode.
func get_fire_direction(origin_pos: Vector2, fallback_direction: Vector2, weapon_allegiance: Projectile.Allegiance) -> Vector2:
	# Handle special cases that don't need a target node first.
	if targeting_mode == TargetingMode.LAST_MOVE_DIRECTION:
		var user = get_parent().stats_component.user
		if is_instance_valid(user) and "last_move_direction" in user:
			if user.last_move_direction.length() > 0:
				return user.last_move_direction
	
	# For all other modes, find a target and aim at it.
	var target = find_target(origin_pos, weapon_allegiance)	
	if is_instance_valid(target):
		return (target.global_position - origin_pos).normalized()
	else:
		# If no target is found, use the fallback.
		return fallback_direction

# --- HELPER FUNCTIONS for finding specific targets ---

func _find_nearest(origin_pos: Vector2, candidates: Array) -> Node2D:
	var best_target = null
	var closest_dist_sq = INF 
	for entity in candidates:
		var dist_sq = origin_pos.distance_squared_to(entity.global_position)
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			best_target = entity
	return best_target

func _find_farthest(origin_pos: Vector2, candidates: Array) -> Node2D:
	var best_target = null
	var farthest_dist_sq = 0
	for entity in candidates:
		var dist_sq = origin_pos.distance_squared_to(entity.global_position)
		if dist_sq > farthest_dist_sq:
			farthest_dist_sq = dist_sq
			best_target = entity
	return best_target

func _find_highest_health(candidates: Array) -> Node2D:
	var best_target = null
	var highest_health = -1
	for entity in candidates:
		# Check if the entity has a 'current_health' property.
		if "current_health" in entity and entity.current_health > highest_health:
			highest_health = entity.current_health
			best_target = entity
	return best_target

func _find_lowest_health(candidates: Array) -> Node2D:
	var best_target = null
	var lowest_health = INF
	for entity in candidates:
		if "current_health" in entity and entity.current_health < lowest_health:
			lowest_health = entity.current_health
			best_target = entity
	return best_target

## Public function to permanently lock the targeting mode for this run.
func set_targeting_mode_override(targeting_mode):
	targeting_mode_override = targeting_mode
	print("TargetingComponent: Mode has been locked to ", targeting_mode_override)
