## axe_weapon.gd
## A specialized weapon that adds unique transformation logic for the Axe.
class_name AxeWeapon
extends Weapon

# --- Transformation Flags ---
var has_berserker: bool = true
# var has_charge: bool = false # For the future "Charge" upgrade

# This function replaces the simple fire() method from weapon.gd.
func fire():
	var user = stats_component.user
	if not is_instance_valid(user): return

	# Check forBerserker condition.
	if not has_berserker or user.velocity.length() > 1:
		# If not berserking, just do the normal fire.
		super.fire()
		return
		
	# If we are berserking (stationary), use the override.
	fire_behavior_component.override_pattern_for_next_shot(FireBehaviorComponent.FirePattern.MIRRORED_FORWARD)
	fire_behavior_component.fire()


## This new function is unique to the AxeWeapon.
func apply_transformation(id: String):
	if id == "berserker":
		has_berserker = true
		print("Axe has gained Berserker!")
	# if id == "charge":
	# 	has_charge = true
