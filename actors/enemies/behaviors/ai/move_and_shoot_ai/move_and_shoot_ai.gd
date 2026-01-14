## move_and_shoot_ai.gd
## An AI brain that chases the player, then stops to shoot when in range.
class_name MoveAndShoot
extends AIController

@export var shooting_range: float = 300.0
@export var hysteresis_margin: float = 50.0  # Prevents rapid state flickering at range boundary

# Cache squared range values (avoid sqrt every frame)
var _shooting_range_sq: float
var _exit_range_sq: float

func _ready():
	super._ready()
	# Pre-calculate squared ranges for distance checks
	_shooting_range_sq = shooting_range * shooting_range
	_exit_range_sq = (shooting_range + hysteresis_margin) * (shooting_range + hysteresis_margin)

func _physics_process(delta):
	if not is_instance_valid(host.player_node):
		super._physics_process(delta)
		return

	# Use squared distance to avoid sqrt calculation
	var distance_sq = host.global_position.distance_squared_to(host.player_node.global_position)

	# Hysteresis: use different thresholds for entering vs exiting shoot state
	var is_shooting = current_state == states.get("shootbehavior")

	if is_shooting:
		# Currently shooting - only exit when beyond shooting_range + margin
		if distance_sq > _exit_range_sq:
			set_state(states["chasebehavior"])
	else:
		# Currently chasing - only enter shoot when within shooting_range
		if distance_sq <= _shooting_range_sq:
			set_state(states["shootbehavior"])

	super._physics_process(delta) # This calls current_state.process_behavior()
