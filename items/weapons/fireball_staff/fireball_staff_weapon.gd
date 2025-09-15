## fireball_staff_weapon.gd
## Manages the unique transformations for the Fireball Staff.
class_name FireballStaffWeapon
extends Weapon

# --- Transformation Flags ---
var has_living_flame: bool = false
var has_wall_of_fire: bool = false
@export var wall_of_fire_stats: TrailProjectileStats
@export var trail_projectile_scene: TrailProjectile

# The transformation function sets the flags.
func apply_transformation(id: String):
	super.apply_transformation(id)
	if id == "living_flame":
		projectile_stats.pierce = -1 # Infinite
		projectile_stats.speed *= 0.5 # Slower
		projectile_stats.lifetime *= 2 # Lasts a long time
		projectile_stats.can_retarget = true 
		projectile_stats.is_scaling = true
		has_living_flame = true
	if id == "wall_of_fire":
		has_wall_of_fire = true
		self.projectile_stats = self.wall_of_fire_stats
		self.custom_projectile_scene = load("res://systems/projectiles/trail_projectile/trail_projectile.tscn")
		print("Fireball Staff gained Wall of Fire!")
