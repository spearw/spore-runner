## enemy_stats.gd
## A Resource that holds all the defining data for a type of enemy.
class_name EnemyStats
extends Resource

# --- Core Stats ---
@export var display_name: String = "Enemy"
@export var max_health: int = 30
@export var speed: float = 120.0
@export var damage: int = 10
@export var armor: int = 0
@export var armor_pen: int = 0

# --- Visuals ---
@export var sprite_frames: SpriteFrames
# The scale of the sprite.
@export var scale: Vector2 = Vector2(1.0, 1.0)
# A color to tint the sprite.
@export var modulate: Color = Color.WHITE
# If true, the sprite will automatically rotate to face its direction of movement.
@export var face_movement_direction: bool = false
# An angle in degrees to correct the sprite's base orientation.
# (e.g., if the art points up, set this to 90 to make it face right).
@export var rotation_offset_degrees: float = 0.0
@export var is_flipped: bool = false

# Behaviors
@export var default_behavior_name: String = "chasebehavior"
@export var ai_scene: PackedScene = load("res://actors/enemies/behaviors/ai/enemy_ai.tscn")


# The weapon scenes to automatically equip to this enemy on spawn.
@export var weapon_scenes: Array[PackedScene]

# The cost of this enemy for the dynamic spawner. Higher is tougher.
@export var challenge_rating: float = 1.0

# --- Loot ---
@export var loot_table: LootTable = load("res://systems/loot/loot_tables/default_loot.tres")
