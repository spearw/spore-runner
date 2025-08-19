## weapon_stats_component.gd
## A component that connects a weapon to the player and handles stat updates.
class_name WeaponStatsComponent
extends Node

# --- References ---
var weapon # A reference to the parent weapon node
var timer # Reference to weapon timer
var player: Node:
	set(new_player):
		if is_instance_valid(player) and player.has_signal("stats_changed"):
			player.stats_changed.disconnect(update_stats)
		player = new_player
		if is_instance_valid(player) and player.has_signal("stats_changed"):
			player.stats_changed.connect(update_stats)

func _ready():
	# Get a reference to the parent node this component is attached to.
	weapon = get_parent()
	timer = weapon.get_node("FireRateTimer")
	timer.set_meta("base_wait_time", weapon.base_interval)

## This function is the heart of the component. It updates the parent weapon's stats.
func update_stats():
	if not is_instance_valid(player) or not is_instance_valid(weapon):
		return
	print("%s stats" % weapon.name)

	# Update Fire Rate (if the weapon has a timer)
	if weapon.has_node("FireRateTimer"):
		var base_wait_time = timer.get_meta("base_wait_time")
		var modifier = player.get_global_firerate_modifier()
		timer.wait_time = base_wait_time * modifier
		print("Fire rate: %s seconds" % timer.wait_time)

	
	

## Public function for the weapon to get its final projectile count
func get_final_projectile_count() -> int:
	if not is_instance_valid(player) or not "base_projectile_count" in weapon:
		return 1 # Return a safe default

	var final_count = weapon.base_projectile_count
	final_count += player.get_global_projectile_bonus()
	return final_count
