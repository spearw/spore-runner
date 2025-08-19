## A custom Resource that defines a single player upgrade.
## This acts as a data container for upgrade properties.
class_name Upgrade
extends Resource

# Define the types of upgrades the player can have
enum UpgradeType {
	UNLOCK_WEAPON,    # Grants a new weapon the player doesn't have.
	UNLOCK_ARTIFACT,  # Grants a new artifact the player doesn't have.
	UPGRADE           # Enhances an existing weapon or artifact.
}

# A unique identifier for this upgrade (e.g., "spike_weapon", "spike_damage").
@export var id: String
# The user-facing name of the upgrade.
@export var display_name: String
# A description of what the upgrade does.
@export_multiline var description: String
# The type of this upgrade, chosen from the enum above.
@export var type: UpgradeType
# For UNLOCK types, this is the class name of the item to check for duplicates.
# For UPGRADE types, this is the class name of the item this upgrade applies to.
@export var target_class_name: String
# For UNLOCK types, this is the scene that should be instanced.
@export var scene_to_unlock: PackedScene

# For UPGRADE types, these fields describe the change.
@export var property_to_modify: String # e.g., "base_projectile_count"
@export var value_modifier: float # e.g., 4.0 or 5.0
