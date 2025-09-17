## enemy_behavior.gd
## The abstract base class for all enemy AI behaviors.
class_name EnemyBehavior
extends Node

# Whether this behavior is active
var enabled: bool = false

## The main update function for the behavior, called by the host enemy every physics frame.
## @param delta: float - The time elapsed since the last physics frame.
## @param host: CharacterBody2D - A reference to the enemy node this behavior is controlling.
func process_behavior(delta: float, host: CharacterBody2D) -> void:
	# This function is meant to be overridden by child classes.
	pass
	
## Called by the AIController when this state becomes active.
## Can receive an optional context dictionary for setup.
func on_enter(host: Node = null, context: Dictionary = {}):
	pass
