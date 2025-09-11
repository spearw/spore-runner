## projectile_stats.gd
## A Resource that holds all the defining data for a type of projectile.
class_name ProjectileStats
extends Resource

@export var base_damage: int = 10
var damage = base_damage
@export var base_critical_hit_rate: float = .05
var critical_hit_rate = base_critical_hit_rate
@export var base_critical_hit_damage: float = .5
var critical_hit_damage = base_critical_hit_damage
@export var speed: float = 300.0
# How long the projectile lives before disappearing, in seconds. -1 means forever.
@export var lifetime: float = 5.0 
# How many enemies this projectile can hit before being destroyed.
# 0 = hits one target. -1 = infinite hits.
@export var pierce: int = 0
@export var status_to_apply: StatusEffect
# Armor pen. Reduces armor by % before damage is calculated.
@export_range(0.0, 1.0) var armor_penetration: float = 0.0
# How much force the weapon knocks back its target
@export var knockback_force: float = 0.0


# --- Visuals ---
@export var texture: Texture2D
@export var scale: Vector2 = Vector2(1.0, 1.0)


# --- AoE Properties ---
# If true, this projectile is an area-of-effect explosion, not a moving bullet.
@export var is_aoe: bool = false
# The visual effect to play for the explosion animation.
@export var aoe_effect_sprite: Texture2D
@export var aoe_effect_scale: Vector2 = Vector2(1.5, 1.5)
@export var aoe_effect_duration: float = 0.4
