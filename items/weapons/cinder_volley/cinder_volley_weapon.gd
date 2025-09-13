## cinder_volley_weapon.gd
## Manages the unique transformations for the Cinder Volley.
class_name CinderVolleyWeapon
extends Weapon

var has_wild_magic: bool = false
var has_seeker_missiles: bool = false

func apply_transformation(id: String):
	super.apply_transformation(id)
	if id == "wild_magic":
		has_wild_magic = true
		self.base_projectile_count *= 1.5
		fire_behavior_component.fire_pattern = FireBehaviorComponent.FirePattern.RANDOM
		targeting_component.set_targeting_mode_override(TargetingComponent.TargetingMode.RANDOM)
		print("Cinder Volley gained Wild Magic!")
	if id == "seeker_missiles":
		has_seeker_missiles = true
		projectile_stats.is_phasing = true
		print("Cinder Volley gained Seeker Missiles!")
