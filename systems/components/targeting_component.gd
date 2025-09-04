## targeting_component.gd
## A component that provides targeting functionality to any parent node.
class_name TargetingComponent
extends Node

enum TargetingMode {
	NEAREST,
	FARTHEST,
	SELF,
	RANDOM,
	HIGHEST_HEALTH,
	LOWEST_HEALTH,
	LAST_MOVE_DIRECTION,
	NONE
}

@export var targeting_mode: TargetingMode = TargetingMode.NEAREST

## Finds the closest enemy node to a given position.
## @param origin_pos: Vector2 - The position to measure distance from.
## @return: Node2D - The closest enemy node, or null if none are found.
func find_closest_entity(origin_pos: Vector2, group: String) -> Node2D:
	var enemies = get_tree().get_nodes_in_group(group)
	if enemies.is_empty():
		return null

	var closest_enemy = null
	var closest_distance = INF 

	for enemy in enemies:
		var distance = origin_pos.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
			
	return closest_enemy
	
## Finds a target based on the current targeting mode.
## @param origin_pos: Vector2 - The position the projectile will fire from.
## @param weapon_allegiance - The allegiance of the weapon.
## @return: target - The found target.
func find_target(origin_pos: Vector2, weapon_allegiance: int):
	var target = null

	match targeting_mode:
		TargetingMode.NEAREST:
			# weapon_allegiance 0 is player weapon
			var target_group = "enemies" if weapon_allegiance == 0 else "player"
			target = find_closest_entity(origin_pos, target_group)
		TargetingMode.SELF:
			# weapon_allegiance 0 is player weapon
			var target_group = "player" if weapon_allegiance == 0 else "enemies"
			target = find_closest_entity(origin_pos, target_group)
		TargetingMode.NONE:
			pass
	return target

## Calculates a fire direction based on the current targeting mode.
## @param origin_pos: Vector2 - The position the projectile will fire from.
## @param fallback_direction: Vector2 - A direction to use if no target is found.
## @return: Vector2 - The calculated normalized direction vector.
func get_fire_direction(origin_pos: Vector2, fallback_direction: Vector2, weapon_allegiance: int) -> Vector2:
	var fire_direction = fallback_direction

	if targeting_mode == TargetingMode.LAST_MOVE_DIRECTION:
		# The weapon's user should have a 'last_move_direction' property.
		var user = get_parent().stats_component.user
		if is_instance_valid(user) and "last_move_direction" in user:
			# If the user isn't moving, use the fallback.
			if user.last_move_direction.length() > 0:
				fire_direction = user.last_move_direction
	else:
		var target = find_target(origin_pos, weapon_allegiance)	
		if is_instance_valid(target):
			fire_direction = (target.global_position - origin_pos).normalized()
	
	return fire_direction
