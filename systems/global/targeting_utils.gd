extends Node

# --- HELPER FUNCTIONS for finding specific targets ---

func get_candidates(target_group):
	return get_tree().get_nodes_in_group(target_group).filter(func(element): return element is CharacterBody2D)

func find_nearest(origin_pos: Vector2, candidates: Array) -> Node2D:
	var best_target = null
	var closest_dist_sq = INF 
	for entity in candidates:
		if entity.is_dying:
			continue
		var dist_sq = origin_pos.distance_squared_to(entity.global_position)
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			best_target = entity
	return best_target

func find_farthest(origin_pos: Vector2, candidates: Array) -> Node2D:
	var best_target = null
	var farthest_dist_sq = 0
	for entity in candidates:
		if entity.is_dying:
			continue
		var dist_sq = origin_pos.distance_squared_to(entity.global_position)
		if dist_sq > farthest_dist_sq:
			farthest_dist_sq = dist_sq
			best_target = entity
	return best_target

func find_highest_health(candidates: Array) -> Node2D:
	var best_target = null
	var highest_health = -1
	for entity in candidates:
		if entity.is_dying:
			continue
		# Check if the entity has a 'current_health' property.
		if "current_health" in entity and entity.current_health > highest_health:
			highest_health = entity.current_health
			best_target = entity
	return best_target

func find_lowest_health(candidates: Array) -> Node2D:
	var best_target = null
	var lowest_health = INF
	for entity in candidates:
		if entity.is_dying:
			continue
		if "current_health" in entity and entity.current_health < lowest_health:
			lowest_health = entity.current_health
			best_target = entity
	return best_target
	
## Finds the nearest candidate that has at least one child in its "Equipment" node.
func find_nearest_ranged(origin_pos: Vector2, candidates: Array) -> Node2D:
	var best_target = null
	var closest_dist_sq = INF
	
	for entity in candidates:
		# Check if the entity has an Equipment node with children.
		var equipment_node = entity.get_node_or_null("Equipment")
		if equipment_node and equipment_node.get_child_count() > 0:
			# This is an "armed" entity. Consider it a valid target.
			var dist_sq = origin_pos.distance_squared_to(entity.global_position)
			if dist_sq < closest_dist_sq:
				closest_dist_sq = dist_sq
				best_target = entity
				
	return best_target
