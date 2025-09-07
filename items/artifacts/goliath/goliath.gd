## goliath_artifact.gd
## An artifact that modifies player stats based on their current health percentage.
class_name GoliathArtifact
extends Node

# --- Configuration ---
var max_size_bonus: float = 0.50     # +50% size at full health
var max_damage_bonus: float = 0.50   # +50% damage at full health
var max_speed_penalty: float = 0.30  # -30% speed at full health

## Called by the Player to get the current damage multiplier from this artifact.
func get_damage_modifier(health_percentage: float) -> float:
	# Linearly interpolates from 1.0 (no bonus) at 0% health
	# to 1.5 (max bonus) at 100% health.
	var bonus = lerp(0.0, max_damage_bonus, health_percentage)
	return 1.0 + bonus

## Called by the Player to get the current speed multiplier.
func get_speed_modifier(health_percentage: float) -> float:
	# Linearly interpolates from 1.0 (no penalty) at 0% health
	# to 0.7 (max penalty) at 100% health.
	var penalty = lerp(0.0, max_speed_penalty, health_percentage)
	return 1.0 - penalty
	
## Called by the Player to get the current size multiplier.
func get_size_modifier(health_percentage: float) -> float:
	var bonus = lerp(0.0, max_size_bonus, health_percentage)
	return 1.0 + bonus
