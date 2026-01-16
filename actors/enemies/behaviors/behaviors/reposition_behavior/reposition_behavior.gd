## reposition_behavior.gd
## A behavior that moves the host to a specific target position in the world.
class_name RepositionBehavior
extends MovementBehavior

# The world coordinate to move towards.
var target_position: Vector2

# The distance at which the behavior considers its goal reached.
var stopping_distance: float = 5.0

func on_enter(host: Node, context: Dictionary = {}):
	super.on_enter(host, context)  # MovementBehavior handles animation

	# Get the target position from the context provided by the AI brain.
	if context.has("target_position"):
		self.target_position = context["target_position"]
	else:
		# If no position is given, default to the host's current position (do nothing).
		self.target_position = host_enemy.global_position

func process_behavior(delta: float, host: CharacterBody2D):
	# Calculate the distance to the target position.
	var distance_to_target = host.global_position.distance_to(target_position)
	
	# Check if we have arrived.
	if distance_to_target <= stopping_distance:
		host.velocity = Vector2.ZERO
		# The AI brain is responsible for switching us out of this state.
		# We just stop moving.
		return
		
	# If not yet at the target, move towards it.
	var direction = (target_position - host.global_position).normalized()
	host.velocity = direction * host.get_effective_move_speed()
