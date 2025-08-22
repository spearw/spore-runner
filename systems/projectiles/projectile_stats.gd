## projectile_stats.gd
## A Resource that holds all the defining data for a type of projectile.
class_name ProjectileStats
extends Resource

@export var damage: int = 10
@export var speed: float = 300.0

# How long the projectile lives before disappearing, in seconds. -1 means forever.
@export var lifetime: float = 5.0 

# --- Visuals ---
@export var texture: Texture2D
@export var scale: Vector2 = Vector2(1.0, 1.0)
