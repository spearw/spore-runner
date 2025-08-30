## meta_upgrade.gd
## A Resource that defines a single, permanent upgrade available in the meta shop.
class_name MetaUpgrade
extends Resource

# The key in the GameData.data["permanent_stats"] dictionary that this upgrade affects.
# e.g., "move_speed_bonus"
@export var stat_key: String

# --- Display Properties ---
@export var display_name: String
@export_multiline var description: String # e.g., "Increases starting move speed by 2%."

# --- Cost and Progression ---
# The base cost in souls for the first level of this upgrade.
@export var base_cost: int = 100
# How much the cost increases per level (e.g., 1.5 = 50% more expensive each time).
@export var cost_scaling_factor: float = 1.5
# The maximum number of times this upgrade can be purchased.
@export var max_level: int = 10

# The value this upgrade provides per level.
@export var value_per_level: float = 0.02 # e.g., for a 2% bonus
