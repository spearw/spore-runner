## enemy_stats.gd
## A Resource that holds all the defining data for a type of enemy. Inherits from EntityStats.
class_name EnemyStats
extends EntityStats

# --- Core Stats ---
@export var damage: int = 10
@export var armor_pen: int = 0

# --- Visuals ---
# If true, the sprite will automatically rotate to face its direction of movement.
@export var face_movement_direction: bool = false
# An angle in degrees to correct the sprite's base orientation.
@export var rotation_offset_degrees: float = 0.0
@export var is_flipped: bool = false

# --- Behaviors ---
@export var default_behavior_name: String = "chasebehavior"
@export var ai_scene: PackedScene = load("res://actors/enemies/behaviors/ai/enemy_ai.tscn")

# The weapon scenes to automatically equip to this enemy on spawn.
@export var weapon_scenes: Array[PackedScene]

# The cost of this enemy for the dynamic spawner. Higher is tougher.
@export var challenge_rating: float = 1.0

# --- Loot ---
@export var loot_table: LootTable = load("res://systems/loot/loot_tables/default_loot.tres")
