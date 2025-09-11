## A Resource to hold the player's base statistics.
class_name CharacterData
extends Resource

# --- Display Info ---
@export var character_name: String
@export_multiline var character_description: String
@export var character_sprite_frames: SpriteFrames

# --- Base Gameplay Stats ---
@export var base_move_speed: float = 150.0
@export var base_max_health: int = 100
@export var base_pickup_radius: float = 100.0
@export var base_luck: float = 1.0 
@export var base_firerate_modifier: float = 1.0 
@export var base_projectile_count_multiplier: float = 1.0
@export var base_critical_chance: float = 0.0
@export var base_critical_damage: float = 0.0
@export var base_armor: int = 0


# --- Starting Loadout ---
# Defines the character's unique starting weapon(s) and artifact(s).
# This should contain UNLOCK type Upgrade resources.
@export var starting_upgrades: Array[Upgrade]
