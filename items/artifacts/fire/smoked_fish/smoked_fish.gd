## smoked_fish_artifact.gd
## An artifact that grants bonus XP from enemies that die while on fire.
class_name SmokedFishArtifact
extends Node

# The EXTRA XP multiplier to apply. 0.5 means +50%.
@export var bonus_xp_multiplier: float = 0.5

# This reference is set by the UpgradeManager when the artifact is equipped.
var user: Node = null

func _ready():
	# Listen for the global signal that announces any enemy's death.
	Events.enemy_killed.connect(_on_enemy_killed)

## Called by the global "enemy_killed" signal.
func _on_enemy_killed(enemy_node: Node):
	# First, ensure the enemy that died is a valid node.
	if not is_instance_valid(enemy_node): return
	
	# Find the enemy's StatusEffectManager.
	var status_manager = enemy_node.get_node_or_null("StatusEffectManager")
	if not is_instance_valid(status_manager): return

	# Check if the enemy has either the "burning" or "ignited" status.
	if status_manager.active_statuses.has("ignited"):
		
		print("Smoked Fish triggered! Spawning bonus XP.")
		
		# Call the global XPDropper to spawn bonus orbs.
		XpDropper.drop_xp_for_enemy(
			enemy_node.stats,
			enemy_node.global_position,
			self.bonus_xp_multiplier
		)
