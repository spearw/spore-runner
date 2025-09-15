## trail_projectile_stats.gd
## A resource for projectiles that leave a persistent trail of effects behind them.
class_name TrailProjectileStats
extends ProjectileStats

# --- Trail Properties ---
# The scene for the trail segment (should be a PersistentDamageEffect).
@export var trail_scene: PackedScene
# The stats for the trail segments (defines their damage, duration, etc.).
@export var trail_stats: PersistentEffectStats
# How often to drop a segment of the trail, in seconds.
@export var time_between_trail_drops: float = 0.2
 
