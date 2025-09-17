## player_stats.gd
## A Resource to hold the player's base statistics. Inherits from EntityStats.
class_name PlayerStats
extends EntityStats

# --- Display Info ---
@export_multiline var character_description: String

# --- Base Gameplay Stats ---
@export var pickup_radius: float = 150.0
@export var luck: float = 1.0
@export var firerate_modifier: float = 1.0
@export var projectile_count_multiplier: float = 1.0
@export var critical_chance: float = 0.0
@export var critical_damage: float = 0.0

# --- Starting Loadout ---
# Defines the character's unique starting weapon(s) and artifact(s).
@export var starting_upgrades: Array[Upgrade]
