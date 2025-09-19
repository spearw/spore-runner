## enemy_behavior.gd
## The abstract base class for all enemy AI behaviors.
class_name EnemyBehavior
extends Node

# Whether this behavior is active
var enabled: bool = false
var host_enemy: Node
var host_anim_controller: AnimationController

## The main update function for the behavior, called by the host enemy every physics frame.
## @param delta: float - The time elapsed since the last physics frame.
## @param host: CharacterBody2D - A reference to the enemy node this behavior is controlling.
func process_behavior(delta: float, host: CharacterBody2D) -> void:
	# This function is meant to be overridden by child classes.
	pass
	
## Called by the AIController when this state becomes active.
## This base implementation handles caching the references.
func on_enter(host: Node, context: Dictionary = {}):
	self.host_enemy = host
	if is_instance_valid(host_enemy):
		self.host_anim_controller = host_enemy.get_node_or_null("AnimationController")
	else:
		self.host_anim_controller = null

func update_context(context: Dictionary = {}):
	# This function is meant to be overridden by child classes.
	pass
