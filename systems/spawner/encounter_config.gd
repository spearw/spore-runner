## encounter_config.gd
## A Resource that defines tag weights for encounter generation.
## Used by the encounter director to weight enemy selection.
class_name EncounterConfig
extends Resource

## Display name shown to players (e.g., "Swarm Infestation").
@export var display_name: String = ""

## Description shown to players (e.g., "Large groups of small enemies").
@export var description: String = ""

## Biome weights - enemies with matching biome tags get higher spawn priority.
## Dictionary mapping EnemyTags.Biome -> float weight (default 1.0)
## Example: {EnemyTags.Biome.FRESHWATER: 2.0, EnemyTags.Biome.CAVE: 1.5}
@export var biome_weights: Dictionary = {}

## Type weights - enemies with matching type tags get higher spawn priority.
## Dictionary mapping EnemyTags.Type -> float weight (default 1.0)
@export var type_weights: Dictionary = {}

## Behavior weights - enemies with matching behavior tags get higher spawn priority.
## Dictionary mapping EnemyTags.Behavior -> float weight (default 1.0)
@export var behavior_weights: Dictionary = {}

## Size weights - affects which sizes are more likely to spawn.
## Dictionary mapping EnemyTags.Size -> float weight (default 1.0)
## Note: This modifies the random size selection, not whether an enemy can spawn.
@export var size_weights: Dictionary = {}

## Calculates the spawn weight for an enemy based on its tags.
## Higher weight = more likely to be selected by the encounter director.
func calculate_enemy_weight(enemy_stats: EnemyStats) -> float:
	var weight = 1.0

	# Multiply by biome tag matches
	for tag in enemy_stats.biome_tags:
		weight *= biome_weights.get(tag, 1.0)

	# Multiply by type tag matches
	for tag in enemy_stats.type_tags:
		weight *= type_weights.get(tag, 1.0)

	# Multiply by behavior tag matches
	for tag in enemy_stats.behavior_tags:
		weight *= behavior_weights.get(tag, 1.0)

	return weight

## Picks a size from the enemy's allowed sizes, weighted by this config.
## Returns the chosen size, or the first available if weights don't match.
func pick_weighted_size(enemy_stats: EnemyStats) -> EnemyTags.Size:
	if enemy_stats.size_tags.is_empty():
		return EnemyTags.Size.MEDIUM

	if size_weights.is_empty():
		return enemy_stats.size_tags.pick_random()

	# Build weighted array
	var weighted_sizes: Array = []
	var total_weight = 0.0

	for size in enemy_stats.size_tags:
		var w = size_weights.get(size, 1.0)
		total_weight += w
		weighted_sizes.append({"size": size, "weight": w})

	# Pick based on weight
	var roll = randf() * total_weight
	var cumulative = 0.0
	for entry in weighted_sizes:
		cumulative += entry.weight
		if roll <= cumulative:
			return entry.size

	return enemy_stats.size_tags[0]
