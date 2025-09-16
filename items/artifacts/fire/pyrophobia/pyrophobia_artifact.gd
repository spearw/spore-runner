## pyrophobia_artifact.gd
## Makes Ignited enemies flee in terror.
class_name PyrophobiaArtifact
extends Node

var user: Node = null # Set by the UpgradeManager

func _ready():
	# Listen for the global signal from the Events bus.
	Events.status_applied_to_enemy.connect(_on_status_applied_to_enemy)

## Called whenever any enemy on screen gets any status effect.
func _on_status_applied_to_enemy(enemy_node: Node, status_id: String):
	# We only care if the status is "ignited".
	if status_id != "ignited":
		return

	# We need to find out how long the "ignited" status will last.
	var status_manager = enemy_node.get_node_or_null("StatusEffectManager")
	if not is_instance_valid(status_manager): return
	
	if status_manager.active_statuses.has("ignited"):
		var ignited_status_info = status_manager.active_statuses["ignited"]
		var ignited_duration = ignited_status_info["timer"].time_left
		
		# Now, tell the enemy to override its behavior.
		if is_instance_valid(enemy_node) and enemy_node.has_method("override_behavior"):
			print("Pyrophobia triggered on %s. Fleeing for %.2f seconds." % [enemy_node.name, ignited_duration])
			
			# The FleeBehavior expects a key named "target".
			var context = {
				"target": self.user # The player is the one to flee from.
			}
			
			# We tell it to switch to the state named "Flee" for the exact
			# remaining duration of the Ignited status.
			enemy_node.override_behavior("fleebehavior", ignited_duration, context)
