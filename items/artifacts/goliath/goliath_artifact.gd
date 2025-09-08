## goliath_artifact.gd
## An artifact that grants bonuses based on bonus max health.
class_name GoliathArtifact
extends Node

# --- Configuration ---
# How much of each stat we get per point of BONUS max HP.
const SIZE_PER_HP = 0.005      # +0.5% size per bonus HP
const DAMAGE_PER_HP = 0.01     # +1% damage per bonus HP
const SPEED_PENALTY_PER_HP = -0.01 # -1% speed per bonus HP

# --- Runtime State ---
var user: Node = null # Set by the UpgradeManager

# --- Public API for the Player to query ---

## Calculates and returns the size modifier provided by this artifact.
func get_size_modifier() -> float:
	if not is_instance_valid(user): return 1.0 # Default: no change
	
	var base_hp = user.stats.base_max_health
	var current_max_hp = user.get_stat("max_health")
	var bonus_hp = max(0, current_max_hp - base_hp)
	
	return 1.0 + (bonus_hp * SIZE_PER_HP)

## Calculates and returns the damage modifier.
func get_damage_modifier() -> float:
	if not is_instance_valid(user): return 1.0
	
	var base_hp = user.stats.base_max_health
	var current_max_hp = user.get_stat("max_health")
	var bonus_hp = max(0, current_max_hp - base_hp)
	
	return 1.0 + (bonus_hp * DAMAGE_PER_HP)
	
## Calculates and returns the speed modifier.
func get_speed_modifier() -> float:
	if not is_instance_valid(user): return 1.0
	
	var base_hp = user.stats.base_max_health
	var current_max_hp = user.get_stat("max_health")
	var bonus_hp = max(0, current_max_hp - base_hp)
	
	return 1.0 + (bonus_hp * SPEED_PENALTY_PER_HP)
