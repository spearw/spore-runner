## fireball_staff_weapon.gd
## Manages the unique transformations for the Fireball Staff.
class_name FireballStaffWeapon
extends TransformableWeapon

@export var wall_of_fire_stats: TrailProjectileStats
@export var trail_projectile_scene: TrailProjectile

func _on_transformation_acquired(id: String):
	if id == "living_flame":
		projectile_stats.pierce = -1 # Infinite
		projectile_stats.speed *= 0.5 # Slower
		projectile_stats.lifetime *= 2 # Lasts a long time
		projectile_stats.can_retarget = true
		projectile_stats.is_scaling = true
	if id == "wall_of_fire":
		self.projectile_stats = self.wall_of_fire_stats
		self.custom_projectile_scene = load("res://systems/projectiles/trail_projectile/trail_projectile.tscn")
