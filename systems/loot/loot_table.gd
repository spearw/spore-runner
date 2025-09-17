## loot_table.gd
## A Resource that defines all possible drops for an enemy.
class_name LootTable
extends Resource

# --- XP ---
# If true, this enemy will drop XP based on its Challenge Rating.
@export var drops_xp: bool = true

# --- Pickups ---
@export_range(0.0, 1.0) var soul_drop_chance: float = 0.001
@export_range(0.0, 1.0) var heart_drop_chance: float = 0.01

# --- Special Drops ---
# A guaranteed special drop, like a boss's treasure chest.
@export var special_drop_scene: PackedScene
