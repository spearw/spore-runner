## movement_behavior.gd
## Base class for movement-type enemy behaviors (chase, flee, reposition, find allies).
## Handles the common animation loop setup in on_enter().
class_name MovementBehavior
extends EnemyBehavior

## The animation to play when this movement behavior starts.
## Override in subclasses if needed (default is "move").
var movement_animation: String = "move"

## Called when this behavior becomes active.
## Automatically plays the movement animation loop.
func on_enter(host: Node, context: Dictionary = {}):
	super.on_enter(host, context)
	if is_instance_valid(host_anim_controller):
		host_anim_controller.play_loop(movement_animation)
