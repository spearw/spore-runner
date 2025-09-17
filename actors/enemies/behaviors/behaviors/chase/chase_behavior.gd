## chase_behavior.gd
## A simple behavior that moves the host enemy directly towards the player.
class_name ChaseBehavior
extends EnemyBehavior

# This overrides the base class function.
func process_behavior(delta: float, host: CharacterBody2D) -> void:
	if is_instance_valid(host.player_node):
		var direction = (host.player_node.global_position - host.global_position).normalized()
		host.velocity = direction * host.stats.move_speed
	else:
		host.velocity = Vector2.ZERO
