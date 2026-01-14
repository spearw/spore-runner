## cinder_volley_weapon.gd
## Manages the unique transformations for the Cinder Volley.
class_name CinderVolleyWeapon
extends TransformableWeapon

func _on_transformation_acquired(id: String):
	if id == "wild_magic":
		self.base_projectile_count *= 1.5
		fire_behavior_component.fire_pattern = FireBehaviorComponent.FirePattern.RANDOM
		targeting_component.set_targeting_mode_override(TargetingComponent.TargetingMode.RANDOM)
	if id == "seeker_missiles":
		projectile_stats.is_phasing = true
