## upgrade_manager.gd
## Manages the pool of available upgrades, filters them based on player inventory,
## and applies selected upgrades.
extends Node

@export var upgrade_pool: Array[Upgrade]

var player_equipment: Node2D = null
var player_artifacts: Node2D = null
var player: Node2D = null

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
func get_upgrade_choices(count: int) -> Array[Upgrade]:
	var player_inventory = get_player_inventory_names()
	var filtered_pool: Array[Upgrade] = []

	for upgrade in upgrade_pool:
		# Filter into valid choice pool.
		var target_name = upgrade.target_class_name
		
		match upgrade.type:
			Upgrade.UpgradeType.UNLOCK_WEAPON, Upgrade.UpgradeType.UNLOCK_ARTIFACT:
				# Offer this unlock only if an item with this name is NOT in the inventory.
				if not target_name in player_inventory:
					filtered_pool.append(upgrade)
			
			Upgrade.UpgradeType.UPGRADE:
				# Offer this upgrade only if an item with this name IS in the inventory.
				if target_name in player_inventory:
					filtered_pool.append(upgrade)

	filtered_pool.shuffle()
	var choices: Array[Upgrade] = []
	var num_choices = min(count, filtered_pool.size())
	for i in range(num_choices):
		choices.append(filtered_pool[i])
		
	return choices

## Applies the logic for a given upgrade.
func apply_upgrade(upgrade: Upgrade) -> void:
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

		Upgrade.UpgradeType.UPGRADE:
			# Find the target item based on its name.
			var target_item = player_equipment.get_node_or_null(upgrade.target_class_name)
			if not target_item:
				target_item = player_artifacts.get_node_or_null(upgrade.target_class_name)

			if target_item:
				# Use set() to modify the property by its string name.
				var current_value = target_item.get(upgrade.property_to_modify)
				target_item.set(upgrade.property_to_modify, current_value + upgrade.value_modifier)
			else:
				printerr("Upgrade failed: Could not find item '%s' to upgrade." % upgrade.target_class_name)

	# Notify the player that stats may have changed.
	if is_instance_valid(player):
		player.notify_stats_changed()
			
func create_weapon(weapon, upgrade):
	weapon.name = upgrade.target_class_name
	weapon.get_node("WeaponStatsComponent").player = self.player
	weapon.get_node("FireRateTimer").set_meta("base_wait_time", 2.0)
	return weapon
	
func create_artifact(artifact, upgrade):
	artifact.name = upgrade.target_class_name
	return artifact
