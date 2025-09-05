## axe_weapon.gd
## A specialized weapon that adds unique transformation logic for the Axe.
class_name AxeWeapon
extends Weapon

# --- Transformation Flags ---
var has_berserker: bool = false
var has_charge: bool = false
var charge_speed: float = 600.0
var max_charge_distance: float = 300.0

# This function replaces the fire() method from weapon.gd.
func fire(damage_multiplier=1):
	var user = stats_component.user
	if not is_instance_valid(user): return
	
	# --- Attack Priority ---
	if has_charge:
		# If we have Charge, it's always our primary attack.
		_execute_charge_attack(user)
	elif has_berserker and user.velocity.length() < 1:
		# If no charge, check for Berserker.
		fire_behavior_component.override_pattern_for_next_shot(FireBehaviorComponent.FirePattern.MIRRORED_FORWARD)
		fire_behavior_component.fire()
	else:
		# Default is the normal swing.
		super.fire()


## Executes the charge and attack.
func _execute_charge_attack(user: Node):
	var user_allegiance = stats_component.get_projectile_allegiance()
	
	# Find a target.
	var target_enemy = targeting_component.find_target(user.global_position, user_allegiance)
	if not is_instance_valid(target_enemy):
		super.fire()
		return
		
	# Calculate distance and determine the final destination.
	var charge_direction = (target_enemy.global_position - user.global_position).normalized()
	var distance_to_enemy = user.global_position.distance_to(target_enemy.global_position)
	
	# Stop slightly in front of enemy
	var stopping_offset = 100.0 
	
	# Calculate the actual distance to travel.
	var travel_distance = min(distance_to_enemy - stopping_offset, max_charge_distance)
	
	# Check if enemy is too close.
	if travel_distance <= 0:
		# Enemy is too close to charge, just do a normal swing.
		super.fire()
		return
		
	var final_position = user.global_position + charge_direction * travel_distance

	# Calculate the duration of the charge.
	var dynamic_duration = travel_distance / charge_speed
	
	# Grant invulnerability.
	user.set_invulnerability(true)
	
	# Execute the dash.
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(user, "global_position", final_position, dynamic_duration)
	
	# 6. Wait for the dash to complete.
	await tween.finished
	
	# Call fire to deal damage.
	super.fire()
	
	# Remove invulnerability.
	user.set_invulnerability(false)
	
func apply_transformation(id: String):
	if id == "berserker":
		has_berserker = true
		print("Axe has gained Berserker!")
	if id == "charge":
		has_charge = true
		print("Axe has gained Charge!")
