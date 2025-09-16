## flee_behavior.gd
## A simple behavior that moves the host enemy directly away from the player.
class_name FleeBehavior
extends EnemyBehavior

# This can be configured to flee from a specific target.
var flee_target: Node2D

func process_behavior(delta: float, host: CharacterBody2D):
	if not is_instance_valid(flee_target):
		# Stand still if no target from which to flee.
		host.velocity = Vector2.ZERO
		return
		
	# Calculate the direction vector AWAY from the target.
	var direction = (host.global_position - flee_target.global_position).normalized()
	host.velocity = direction * host.stats.speed # Flee at normal speed

func on_enter(context: Dictionary = {}):
	# Look for a "target" key in the context provided by the caller.
	if context.has("target"):
		self.flee_target = context["target"]
