## chase_behavior.gd
## A simple behavior that moves the host enemy directly towards the player.
class_name ChaseBehavior
extends EnemyBehavior

func on_enter(host: Node, context: Dictionary = {}):
	super.on_enter(host, context)
	if is_instance_valid(host_anim_controller):
		host_anim_controller.play_loop("move")

# This overrides the base class function.
func process_behavior(delta: float, host: CharacterBody2D) -> void:
	if is_instance_valid(host.player_node):
		var direction = (host.player_node.global_position - host.global_position).normalized()
		host.velocity = direction * host.stats.move_speed
	else:
		host.velocity = Vector2.ZERO
