## entity_stats.gd
## Base resource for all living entities in the game.
class_name EntityStats
extends Resource

# --- Core Stats ---
@export var move_speed: float = 175.0
@export var display_name: String = "Entity"
@export var max_health: int = 100
@export var armor: int = 0

# --- Visuals ---
@export var sprite_frames: SpriteFrames
# A color to tint the sprite.
@export var modulate: Color = Color.WHITE
# The scale of the sprite.
@export var scale: Vector2 = Vector2(1.0, 1.0)
