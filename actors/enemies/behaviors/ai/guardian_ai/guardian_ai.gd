## guardian_ai.gd
class_name GuardianAI
extends AIController

@export var aggro_radius: float = 500.0
@export var melee_range: float = 100.0
@export var attack_cooldown: float = 2.0

var guard_position: Vector2
@onready var attack_cooldown_timer: Timer = Timer.new()

# Cache squared range values (avoid sqrt every frame)
var _aggro_radius_sq: float
var _melee_range_sq: float
const HOME_THRESHOLD_SQ: float = 25.0  # 5^2

func _ready():
	super._ready()
	guard_position = host.global_position
	add_child(attack_cooldown_timer)
	attack_cooldown_timer.one_shot = true
	# Pre-calculate squared ranges
	_aggro_radius_sq = aggro_radius * aggro_radius
	_melee_range_sq = melee_range * melee_range

func _physics_process(delta):
	# The parent _physics_process runs the active behavior's logic.
	# We run our decision logic FIRST, then call the parent.

	if not is_instance_valid(host.player_node):
		if current_state != states["repositionbehavior"]:
			set_state(states["repositionbehavior"], {"target_position": guard_position})
		super._physics_process(delta)
		return

	# Use squared distances to avoid sqrt calculation
	var distance_to_player_sq = host.global_position.distance_squared_to(host.player_node.global_position)
	var distance_to_guard_post_sq = host.global_position.distance_squared_to(guard_position)
	
	var desired_state_node = current_state # Assume we stay in the same state
	var context = {}

	# --- Decision Logic (using squared distances) ---
	if distance_to_player_sq > _aggro_radius_sq:
		if distance_to_guard_post_sq < HOME_THRESHOLD_SQ:
			# Player is out of range AND we are home. Go idle.
			desired_state_node = states["idlebehavior"]
		else:
			# Player is out of range but we are not home. Retreat to post.
			desired_state_node = states["repositionbehavior"]
			context = {"target_position": guard_position}
	elif distance_to_player_sq <= _melee_range_sq and attack_cooldown_timer.is_stopped():
		# Player is in melee range AND our attack is ready. Attack!
		desired_state_node = states["shootbehavior"]
		attack_cooldown_timer.start(attack_cooldown) # Start the cooldown
	elif distance_to_player_sq > _melee_range_sq and attack_cooldown_timer.is_stopped():
		# Player is in aggro range, not melee range, and we're not on cooldown. Chase.
		desired_state_node = states["chasebehavior"]

	# --- State Transition ---
	if desired_state_node != current_state:
		set_state(desired_state_node, context)

	super._physics_process(delta)
