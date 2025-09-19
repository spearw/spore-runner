## move_and_shoot_ai.gd
## An AI brain that chases the player, then stops to shoot when in range.
class_name MoveAndShoot
extends AIController

@export var shooting_range: float = 300.0

func _physics_process(delta):
	# Decide whether to move or shoot
	var distance_to_player = host.global_position.distance_to(host.player_node.global_position)
	
	if distance_to_player <= shooting_range:
		# If in range, switch to the Shoot state.
		set_state(states["shootbehavior"])
	else:
		# If out of range, switch to the Chase state.
		set_state(states["chasebehavior"])
			
	super._physics_process(delta) # This calls current_state.process_behavior()
