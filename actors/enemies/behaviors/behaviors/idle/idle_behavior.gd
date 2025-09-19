## idle_behavior.gd
## A simple behavior where the host enemy remains stationary.
class_name IdleBehavior
extends EnemyBehavior

func on_enter(host: Node, context: Dictionary = {}):
	super.on_enter(host, context)
	# When we become idle, play the idle animation.
	if is_instance_valid(host_anim_controller):
		host_anim_controller.play_loop("idle")

func process_behavior(delta: float, host: CharacterBody2D):
	# The core of this behavior: do nothing.
	host.velocity = Vector2.ZERO
