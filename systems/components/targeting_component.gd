## targeting_component.gd
## A component that provides targeting functionality to any parent node.
class_name TargetingComponent
extends Node

enum TargetingMode {
	NONE,
	NEAREST
	# Add more modes here later
}

@export var targeting_mode: TargetingMode = TargetingMode.NEAREST

## Finds the closest enemy node to a given position.
## @param origin_pos: Vector2 - The position to measure distance from.
## @return: Node2D - The closest enemy node, or null if none are found.
func find_closest_enemy(origin_pos: Vector2) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
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

## Calculates a fire direction based on the current targeting mode.
## @param origin_pos: Vector2 - The position the projectile will fire from.
## @param fallback_direction: Vector2 - A direction to use if no target is found.
## @return: Vector2 - The calculated normalized direction vector.
func get_fire_direction(origin_pos: Vector2, fallback_direction: Vector2) -> Vector2:
	var fire_direction = fallback_direction
	var target_enemy = null

	match targeting_mode:
		TargetingMode.NEAREST:
			target_enemy = find_closest_enemy(origin_pos)
			if is_instance_valid(target_enemy):
				fire_direction = (target_enemy.global_position - origin_pos).normalized()
		
		TargetingMode.NONE:
			# In this case, the weapon's own logic provides the fallback.
			pass
	
	return fire_direction
