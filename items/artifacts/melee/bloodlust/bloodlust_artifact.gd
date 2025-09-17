## bloodlust_artifact.gd
## On enemy kill, has a chance (modified by Luck) to reduce weapon cooldowns.
class_name BloodlustArtifact
extends Node

# --- Configuration ---
# The base probability of this effect activating.
@export var base_proc_chance: float = 0.20 # 20% chance
# The amount of time to reduce cooldowns by.
@export var cooldown_reduction: float = 1.0 # 1 second

# This reference is set by the UpgradeManager when the artifact is equipped.
var user: Node = null

func _ready():
	# Listen for global signal
	Events.enemy_died.connect(_on_enemy_killed)

func _on_enemy_killed():
	# First, we need a valid reference to the user to get their Luck stat.
	if not is_instance_valid(user): return
	
	# Calculate the final activation chance based on player's Luck.
	# The get_stat("luck") will return 1.0 for base, 1.2 for +20% luck, etc.
	var final_proc_chance = base_proc_chance * user.get_stat("luck")
	
	# Roll the dice.
	if randf() > final_proc_chance:
		return # The roll failed. Do nothing.

	Logs.add_message(["Bloodlust Activated! (Final Chance: %.2f)" % final_proc_chance])
	
	# Find the user's equipment and reduce the cooldown of all weapons.
	var equipment_node = user.get_node_or_null("Equipment")
	if equipment_node:
		for weapon in equipment_node.get_children():
			if weapon.has_method("reduce_cooldown"):
				weapon.reduce_cooldown(cooldown_reduction)
