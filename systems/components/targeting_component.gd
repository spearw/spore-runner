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
	var candidates = TargetingUtils.get_candidates(target_group)
	
	if candidates.is_empty():
		return null

	var best_target: Node2D = null
	
	# Force specific targeting.
	if targeting_mode_override:
		targeting_mode = targeting_mode_override

	match targeting_mode:
		TargetingMode.NEAREST:
			best_target = TargetingUtils.find_nearest(origin_pos, candidates)
		
		TargetingMode.FARTHEST:
			best_target = TargetingUtils.find_farthest(origin_pos, candidates)
			
		TargetingMode.RANDOM:
			best_target = candidates.pick_random()
			
		TargetingMode.HIGHEST_HEALTH:
			best_target = TargetingUtils.find_highest_health(candidates)
			
		TargetingMode.LOWEST_HEALTH:
			best_target = TargetingUtils.find_lowest_health(candidates)
		
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



## Public function to permanently lock the targeting mode for this run.
func set_targeting_mode_override(targeting_mode):
	targeting_mode_override = targeting_mode
	print("TargetingComponent: Mode has been locked to ", targeting_mode_override)
