## enemy_stats.gd
## A Resource that holds all the defining data for a type of enemy.
class_name EnemyStats
extends Resource

# --- Core Stats ---
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
# (e.g., if the art points 'up', set this to 90 to make it face 'right').
@export var rotation_offset_degrees: float = 0.0
@export var is_flipped: bool = false
@export var behavior_scene: PackedScene
# The weapon scenes to automatically equip to this enemy on spawn.
@export var weapon_scenes: Array[PackedScene]

# The "cost" of this enemy for the dynamic spawner. Higher is tougher.
@export var challenge_rating: float = 1.0

# --- Loot ---
@export var experience_gem_stats: ExperienceGemStats
@export var special_drop_scene: PackedScene
@export_range(0.0, 1.0) var soul_drop_chance: float = 0.01
@export_range(0.0, 1.0) var heart_drop_chance: float = 0.05
