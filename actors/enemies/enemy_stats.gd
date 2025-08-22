## enemy_stats.gd
## A Resource that holds all the defining data for a type of enemy.
class_name EnemyStats
extends Resource

# --- Core Stats ---
@export var max_health: int = 30
@export var speed: float = 120.0
@export var damage: int = 10

# --- Visuals ---
# The texture the enemy's sprite will use.
@export var texture: Texture2D
# The scale of the sprite.
@export var scale: Vector2 = Vector2(1.0, 1.0)
# A color to tint the sprite.
@export var modulate: Color = Color.WHITE
@export var behavior_scene: PackedScene
# The weapon scenes to automatically equip to this enemy on spawn.
@export var weapon_scenes: Array[PackedScene]

# --- Loot ---
# The stats for the gem this enemy drops.
@export var experience_gem_stats: ExperienceGemStats
