## spear_weapon.gd
## A specialized weapon that adds unique transformation logic for the Spear.
class_name SpearWeapon
extends Weapon

# --- Transformation Flags ---
var has_hedgehog	 = false # Multiple cones/points
var has_defensive_stance	 = false # Reduce damage to player when hit in melee
var has_couch = true # Damage increases with speed.

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
	if has_defensive_stance:
		if user.has_method("apply_timed_bonus"):
			# Apply timed bonus
			user.apply_timed_bonus("armor", defensive_stance_armor_buff, defensive_stance_duration)
	# Increase damage based on speed of character
	elif has_couch:
		# Get the player's current speed.
		# TODO: Set bonus to direction of fire?
		var current_speed = user.velocity.length()
		# Calculate the bonus damage multiplier.
		speed_bonus = current_speed * (couch_damage_per_speed / 100)
		print("Couch bonus:", speed_bonus)
	
	# Call fire with potential multiplier
	super.fire(1 + speed_bonus)

func apply_transformation(id: String):
	if id == "hedgehog":
		# Increase base projectiles and create cone pattern.
		fire_behavior_component.fire_pattern = fire_behavior_component.FirePattern.CONE
		self.base_projectile_count = 3
		has_hedgehog = true
		print("Spear has gained Hedgehog!")
	if id == "defensive_stance":
		has_defensive_stance = true
		print("Spear has gained Defensive Stance!")
	if id == "couch":
		has_couch = true
		print("Spear has gained Couch!")
