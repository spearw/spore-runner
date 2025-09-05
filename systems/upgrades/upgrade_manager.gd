## upgrade_manager.gd
## Manages the pool of available upgrades, filters them based on player inventory,
## and applies selected upgrades.
extends Node

var active_upgrade_pool: Array[Upgrade] = []

var player_equipment: Node2D = null
var player_artifacts: Node2D = null
var player: Node2D = null

const RARITY_WEIGHTS = {
	Upgrade.Rarity.COMMON: 100,
	Upgrade.Rarity.RARE: 40,
	Upgrade.Rarity.EPIC: 15,
	Upgrade.Rarity.LEGENDARY: 5
}

func _ready():
	# Build pool from chosen upgrade packs.
	_build_active_upgrade_pool()
	
func _build_active_upgrade_pool():
	# Clear any old data.
	active_upgrade_pool.clear()
	
	# Get the list of selected pack paths from persistent data.
	var selected_pack_paths = CurrentRun.selected_pack_paths
	
	for pack_path in selected_pack_paths:
		var pack_resource: UpgradePack = load(pack_path)
		if pack_resource:
			# Add all upgrades from this pack into our active pool for this run.
			active_upgrade_pool.append_array(pack_resource.upgrades)
		else:
			printerr("Failed to load UpgradePack at path: ", pack_path)
			
	print("UpgradeManager pool built for this run. Total upgrades available: ", active_upgrade_pool.size())

## Store reference to the player's equipment and artifacts.
## @param player: Node - The player node instance that is registering itself.
func register_player(player: Node) -> void:
	# Check if the player and its children are valid before storing them.
	if is_instance_valid(player) and player.has_node("Equipment") and player.has_node("Artifacts"):
		self.player = player
		self.player_equipment = player.get_node("Equipment")
		self.player_artifacts = player.get_node("Artifacts")
		print("UpgradeManager: Player registered successfully.")
	else:
		printerr("UpgradeManager: Failed to register player or find required child nodes (Equipment/Artifacts).")
		
## Gathers the names of all items the player currently has.
## @return: Array[String] - An array of items names.
func get_player_inventory_names() -> Array[String]:
	var inventory: Array[String] = []
	for item in player_equipment.get_children():
		inventory.append(item.name)
	for item in player_artifacts.get_children():
		inventory.append(item.name)
	return inventory

## Returns a specified number of valid, random upgrade choices.
func get_upgrade_choices(count: int) -> Array[Dictionary]:
	# --- Filter the pool for currently valid upgrades ---
	var player_inventory = get_player_inventory_names()
	var filtered_pool: Array[Upgrade] = []
	for upgrade in active_upgrade_pool:
		var target_name = upgrade.target_class_name
		match upgrade.type:
			Upgrade.UpgradeType.UNLOCK_WEAPON, Upgrade.UpgradeType.UNLOCK_ARTIFACT:
				if not target_name in player_inventory:
					filtered_pool.append(upgrade)
			Upgrade.UpgradeType.UPGRADE:
				# Use upgrades that are stats buffs or they modify something in the inventorycan
				if target_name == "Player" or target_name in player_inventory:
					filtered_pool.append(upgrade)

	var final_choices: Array[Dictionary] = []
	for i in range(count):
		if filtered_pool.is_empty(): break

		# --- Weighted Rarity Selection ---
		var chosen_rarity_enum = _get_random_rarity_tier()

		# Find all upgrades that are valid candidates for this rarity roll.
		var potential_upgrades = filtered_pool.filter(func(upg):
			if upg.type == Upgrade.UpgradeType.UPGRADE:
				# For an UPGRADE type, its base rarity can be at or below the rolled rarity.
				# A common upgrade can be presented as an Epic version.
				return upg.rarity <= chosen_rarity_enum
			else: # For UNLOCK types
				# For an UNLOCK, its base rarity must exactly match the rolled rarity.
				# A common dagger unlock cannot be presented as Epic.
				return upg.rarity == chosen_rarity_enum
		)
		
		# --- Failsafe ---
		# If we rolled, say, LEGENDARY, but have no valid legendary unlocks or tiered upgrades...
		if potential_upgrades.is_empty():
			# ...don't fail. Just grab any available upgrade.
			# A more advanced system might try re-rolling, but this is robust.
			if not filtered_pool.is_empty():
				potential_upgrades = filtered_pool
			else:
				# No upgrades available at all.
				continue

		var chosen_upgrade = potential_upgrades.pick_random()
		# Ensure rarity value is correct even in case of fallback
		var rarity = chosen_rarity_enum
		if chosen_upgrade.type == Upgrade.UpgradeType.UNLOCK_WEAPON or chosen_upgrade.type == Upgrade.UpgradeType.UNLOCK_ARTIFACT:
			rarity = chosen_upgrade.rarity
		
		# Package the results
		final_choices.append({
			"upgrade": chosen_upgrade,
			"rarity": rarity
		})
		
		# Remove the choice from the pool for this round to avoid duplicates
		filtered_pool.erase(chosen_upgrade)
		
	return final_choices
	
## Helper function to perform a weighted random roll for a rarity tier.
func _get_random_rarity_tier() -> Upgrade.Rarity:
	var total_weight = 0
	var modified_weights = {}
	var luck = player.get_modified_luck()
	
	for rarity_enum in RARITY_WEIGHTS:
		var weight = RARITY_WEIGHTS[rarity_enum]
		# Modify weights for higher rarities based on player luck.
		if rarity_enum > Upgrade.Rarity.COMMON:
			weight *= luck
		modified_weights[rarity_enum] = weight
		total_weight += weight
		
	var roll = randf() * total_weight
	var cumulative_weight = 0
	for rarity_enum in modified_weights:
		cumulative_weight += modified_weights[rarity_enum]
		if roll < cumulative_weight:
			return rarity_enum
			
	# Fallback
	return Upgrade.Rarity.COMMON

## Applies the logic for a given upgrade.
func apply_upgrade(upgrade_package: Dictionary) -> void:
	var upgrade: Upgrade = upgrade_package["upgrade"]
	var chosen_rarity_enum: Upgrade.Rarity = upgrade_package["rarity"]
	if not player_equipment or not player_artifacts:
		printerr("UpgradeManager: Cannot apply upgrade, player has not been registered.")
		return

	match upgrade.type:
		Upgrade.UpgradeType.UNLOCK_WEAPON:
			if upgrade.scene_to_unlock:
				var new_weapon = create_weapon(upgrade.scene_to_unlock.instantiate(), upgrade)
				player_equipment.add_child(new_weapon)
			else:
				printerr("Unlock upgrade '%s' is missing a scene!" % upgrade.id)

		Upgrade.UpgradeType.UNLOCK_ARTIFACT:
			if upgrade.scene_to_unlock:
				var new_artifact = create_artifact(upgrade.scene_to_unlock.instantiate(), upgrade)
				player_artifacts.add_child(new_artifact)
			else:
				printerr("Unlock upgrade '%s' is missing a scene!" % upgrade.id)
		Upgrade.UpgradeType.TRANSFORMATION:
			var target_weapon = player_equipment.get_node_or_null(upgrade.target_class_name)
			if target_weapon and target_weapon.has_method("apply_transformation"):
				target_weapon.apply_transformation(upgrade.key)
			else:
				printerr("Failed to apply transformation: could not find weapon '%s'" % upgrade.target_class_name)
		Upgrade.UpgradeType.UPGRADE:
			var target_item: Node = null
			# Get upgrade target
			if upgrade.target_class_name == "Player":
				target_item = self.player
			else:
				target_item = player_equipment.get_node_or_null(upgrade.target_class_name)
				if not target_item:
					target_item = player_artifacts.get_node_or_null(upgrade.target_class_name)
			# Apply upgrade
			if target_item:
				var value_from_rarity = upgrade.rarity_values[chosen_rarity_enum]
				
				if target_item == self.player:
					player.add_bonus(upgrade.stat_key, value_from_rarity)
				else:
					# This is a flat bonus, or a buff for a weapon/artifact. 
					# TODO: May be depricated with current upgrade system
					var property_path = upgrade.key
					var current_value = get_nested_property(target_item, property_path)
					if current_value == null: return
					var new_value = 0.0
					if upgrade.modifier_type == Upgrade.ModifierType.MULTIPLICATIVE:
						new_value = current_value * (1.0 + value_from_rarity)
					else: # ADDITIVE
						new_value = current_value + value_from_rarity
					
					set_nested_property(target_item, property_path, new_value)
			else:
				printerr("Upgrade failed: Could not find item '%s' to upgrade." % upgrade.target_class_name)
				
	# Notify the player that stats may have changed.
	if is_instance_valid(player):
		player.notify_stats_changed()
			
func create_weapon(weapon, upgrade):
	weapon.name = upgrade.target_class_name
	var stats_comp = weapon.get_node("WeaponStatsComponent")
	stats_comp.user = self.player
	var timer = weapon.get_node_or_null("FireRateTimer")
	if timer:
		# Set its base fire rate.
		timer.set_meta("base_wait_time", weapon.base_fire_rate)
		timer.wait_time = weapon.base_fire_rate
		# autostart starts timer the instant its in the world. 
		# start() does not work until after in the world.
		timer.autostart = true

	return weapon
	
func create_artifact(artifact, upgrade):
	artifact.name = upgrade.target_class_name
	return artifact

## Sets a property on an object, supporting nested paths like "resource/property".
## @param target_object: Object - The root object to modify (e.g., the weapon node).
## @param property_path: String - The path to the property (e.g., "projectile_stats/damage").
## @param value: Variant - The new value to set.
func set_nested_property(target_object: Object, property_path: String, value):
	# Split the path into parts. e.g., "projectile_stats/damage" becomes ["projectile_stats", "damage"]
	var path_parts = property_path.split("/")
	
	var current_object = target_object
	
	# Loop through the path parts, descending into nested objects.
	# We stop at the second-to-last part.
	for i in range(path_parts.size() - 1):
		var part = path_parts[i]
		if current_object.has_method("get") and current_object.get(part):
			current_object = current_object.get(part)
		else:
			printerr("Invalid path '%s' on object %s" % [property_path, target_object])
			return
			
	# The final part of the path is the property we want to set.
	var final_property = path_parts[path_parts.size() - 1]
	current_object.set(final_property, value)

## Gets a property from an object, supporting nested paths.
func get_nested_property(target_object: Object, property_path: String):
	var path_parts = property_path.split("/")
	var current_object = target_object
	
	for part in path_parts:
		if current_object and current_object.has_method("get") and current_object.get(part) != null:
			current_object = current_object.get(part)
		else:
			printerr("Invalid path part '%s' in '%s' on object %s" % [part, property_path, target_object])
			return null
			
	# After the loop, current_object holds the final value.
	return current_object
