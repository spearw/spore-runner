## weapon_stats_component.gd
## Connects a weapon to its user (Player or Enemy) and handles stat updates.
class_name WeaponStatsComponent
extends Node

var weapon # Reference to the parent weapon node
var user: Node: # The entity that owns this weapon (Player or Enemy)
	set(new_user):
		# Disconnect from old user's signals if they exist
		if is_instance_valid(user) and user.has_signal("stats_changed"):
			user.stats_changed.disconnect(update_stats)
		
		user = new_user
		
		# Connect to new user's signals if they exist (only players have this)
		if is_instance_valid(user) and user.has_signal("stats_changed"):
			user.stats_changed.connect(update_stats)

func _ready():
	weapon = get_parent()

func update_stats():
	if not is_instance_valid(user) or not is_instance_valid(weapon): return

	# Only players have global modifiers, so we check for the method.
	if user.has_method("get_stat"):
		if weapon.has_node("FireRateTimer"):
			var timer = weapon.get_node("FireRateTimer")
			var base_wait_time = timer.get_meta("base_wait_time", 2.0)
			var firerate_modifier = user.get_stat("firerate")
			timer.wait_time = base_wait_time * firerate_modifier
			#Logs.add_message(weapon.name, "stats updated! Fire rate:", timer.wait_time)
	else:
		Logs.add_message("%s stats not updated!")
	

# This function also needs to check if the user is a player
func get_final_projectile_count() -> int:
	if not is_instance_valid(weapon) or not "base_projectile_count" in weapon: return 1

	var final_count = weapon.base_projectile_count
	if is_instance_valid(user) and user.has_method("get_stat"):
		final_count = final_count * user.get_stat("projectile_count_multiplier")
	return final_count
	
## Determines the allegiance of projectiles based on the weapon's user.
## @return: Projectile.Allegiance - The allegiance enum value.
func get_projectile_allegiance() -> Projectile.Allegiance:
	if is_instance_valid(user):
		# If the user is in the "player" group, allegiance is PLAYER.
		if user.is_in_group("player"):
			return Projectile.Allegiance.PLAYER
		# If the user is in the "enemies" group, allegiance is ENEMY.
		if user.is_in_group("enemies"):
			return Projectile.Allegiance.ENEMY
	
	# Default fallback. This projectile won't hit anything important.
	printerr("WeaponStatsComponent: Could not determine allegiance for user!")
	return Projectile.Allegiance.NONE 
