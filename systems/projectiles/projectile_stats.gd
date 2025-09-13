## projectile_stats.gd
## The BASE RESOURCE for moving projectiles.
class_name ProjectileStats
extends Resource

# --- Core Stats ---
@export var damage: int = 10
@export var speed: float = 300.0
@export var lifetime: float = 5.0 
@export var pierce: int = 0
@export var knockback_force: float = 0.0
@export_range(0.0, 1.0) var armor_penetration: float = 0.0
@export var critical_hit_rate: float = 0.05
@export var critical_hit_damage: float = .50 
@export var homing_strength: float = 0.0 # How much this projectile follows a target
@export var is_scaling: bool = false # Whether this projectile scales with area_size stat

# --- Stats set in runtime ---
var is_phasing: bool = false
var can_retarget: bool = false


# --- Effects ---
@export var status_to_apply: StatusEffect

# --- Visuals ---
@export var texture: Texture2D
@export var scale: Vector2 = Vector2(1.0, 1.0)
