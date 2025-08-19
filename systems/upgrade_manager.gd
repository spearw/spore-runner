## upgrade_manager.gd
## Manages the pool of available upgrades, filters them based on player inventory,
## and applies selected upgrades.
extends Node

@export var upgrade_pool: Array[Upgrade]

var player_equipment: Node2D = null
var player_artifacts: Node2D = null

## Store reference to the player's equipment and artifacts.
## @param player: Node - The player node instance that is registering itself.
func register_player(player: Node) -> void:
	# Check if the player and its children are valid before storing them.
	if is_instance_valid(player) and player.has_node("Equipment") and player.has_node("Artifacts"):
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
	# Do not attempt to apply an upgrade if the player hasn't been registered yet.
	if not player_equipment or not player_artifacts:
		printerr("UpgradeManager: Cannot apply upgrade, player has not been registered.")
		return
	match upgrade.id:
		"daggers_unlock":
			var scene = load("res://items/weapons/dagger/daggers.tscn")
			var new_equipment = scene.instantiate()
			new_equipment.name = upgrade.target_class_name
			player_equipment.add_child(new_equipment)
			
		"player_speed_1":
			var scene = load("res://items/artifacts/running_shoes/running_shoes.tscn")
			var new_artifact = scene.instantiate()
			new_artifact.name = upgrade.target_class_name
			player_artifacts.add_child(new_artifact)
			
		"spike_ring_unlock":
			var scene = load("res://items/weapons/spike_ring/spike_ring_weapon.tscn")
			var new_equipment = scene.instantiate()
			new_equipment.name = upgrade.target_class_name
			player_equipment.add_child(new_equipment)

		"spike_ring_count_1":
			var weapon = player_equipment.get_node(upgrade.target_class_name)
			if weapon:
				weapon.projectile_count += 4
		
		_:
			printerr("UpgradeManager: Unknown upgrade ID: ", upgrade.id)
