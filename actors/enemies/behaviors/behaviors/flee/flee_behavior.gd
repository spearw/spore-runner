## flee_behavior.gd
## A simple behavior that moves the host enemy directly away from the player.
class_name FleeBehavior
extends EnemyBehavior

# This can be configured to flee from a specific target.
var flee_target: Node2D
# How much of an agle the flee can happen
@export var strafe_intensity: float = 0.7
var strafe_direction: int = 1 # 1 for right, -1 for left

func on_enter(host: Node, context: Dictionary = {}):
	super.on_enter(host, context)
	if is_instance_valid(host_anim_controller):
		host_anim_controller.play_loop("move")
	if context.has("target"):
		self.flee_target = context["target"]
	# Set strafe
	if randf() < 0.5:
		strafe_direction = 1
	else:
		strafe_direction = -1

func process_behavior(delta: float, host: CharacterBody2D):
	if not is_instance_valid(flee_target):
		# Stand still if no target from which to flee.
		host.velocity = Vector2.ZERO
		return
		
	# Calculate the primary direction away from the target.
	var away_direction = (host.global_position - flee_target.global_position).normalized()
	# Calculate the perpendicular "strafe" direction.
	var strafe_vector = away_direction.orthogonal() * strafe_direction
	# Combine them.
	var final_direction = away_direction.lerp(strafe_vector, strafe_intensity).normalized()
	# Set velocity.
	host.velocity = final_direction * host.stats.move_speed
