## upgrade_pack.gd
## A Resource that represents a synergistic "deck" of available upgrades.
class_name UpgradePack
extends Resource

@export var pack_name: String
@export_multiline var pack_description: String
# An icon for the pack to be displayed in the UI.
@export var pack_icon: Texture2D
## Cost in souls to unlock this pack in the meta shop. 0 = already unlocked.
@export var unlock_cost: int = 100

# The list of all Upgrade resources contained within this pack.
@export var upgrades: Array[Upgrade]
