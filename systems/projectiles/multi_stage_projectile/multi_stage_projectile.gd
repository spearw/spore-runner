## multi_stage_projectile_stats.gd
## A resource for projectiles that have a primary form and a secondary "on-death" effect.
class_name MultiStageProjectileStats
extends ProjectileStats

# The stats for the explosion or other effect that spawns when this projectile dies.
@export var on_death_effect_stats: ExplosionStats
