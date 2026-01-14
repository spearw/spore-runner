## spear_weapon.gd
## A specialized weapon that adds unique transformation logic for the Spear.
class_name SpearWeapon
extends TransformableWeapon

# --- Config for Transformations ---
# For Defensive Stance: a quick, temporary armor buff.
var defensive_stance_armor_buff: int = 10
var defensive_stance_duration: float = 0.5
# For Couch: how much damage is gained per unit of speed.
var couch_damage_per_speed: float = 0.5 # 50% extra damage per 100 speed

# This function replaces the fire() method from weapon.gd.
func fire(damage_multiplier=1):
	var user = stats_component.user
	if not is_instance_valid(user): return
	var speed_bonus = 0.0

	# --- Attack Priority ---
	# Spear grants temporary armor
	if has_transformation("defensive_stance"):
		if user.has_method("apply_timed_bonus"):
			# Apply timed bonus
			user.apply_timed_bonus("armor", defensive_stance_armor_buff, defensive_stance_duration)
	# Increase damage based on speed of character
	elif has_transformation("couch"):
		# Get the player's current speed.
		var current_speed = user.velocity.length()
		# Calculate the bonus damage multiplier.
		speed_bonus = current_speed * (couch_damage_per_speed / 100)
		Logs.add_message(["Couch bonus:", speed_bonus])

	# Call fire with potential multiplier
	super.fire(1 + speed_bonus)

func _on_transformation_acquired(id: String):
	if id == "hedgehog":
		# Increase base projectiles and create cone pattern.
		fire_behavior_component.fire_pattern = fire_behavior_component.FirePattern.CONE
		self.base_projectile_count = 3
