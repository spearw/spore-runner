## molotov_cocktail_weapon.gd
## Manages the unique transformations for the Molotov Cocktail.
class_name MolotovCocktailWeapon
extends TransformableWeapon

func _on_transformation_acquired(id: String):
	# Get a reference to the nested stats resource for the ground fire effect.
	var multi_stage_stats = self.projectile_stats as MultiStageProjectileStats
	if not multi_stage_stats: return

	var ground_fire_stats = multi_stage_stats.on_death_effect_stats as PersistentEffectStats
	if not ground_fire_stats: return

	# --- Apply the transformation logic ---
	if id == "scorched_earth":
		# Increase the size and duration of the ground fire patch.
		ground_fire_stats.scale *= 2   # Double area
		ground_fire_stats.duration *= 2 # Double duration

	if id == "volatile_fumes":
		# Create new status based on burning.
		var new_status = ground_fire_stats.status_to_apply.duplicate(true) as DotStatusEffect
		if new_status:
			# Greatly increase the chance for enemies that get caught on fire
			new_status.additional_status_chance *= 2 # Double ignite chance.
			ground_fire_stats.status_to_apply = new_status
