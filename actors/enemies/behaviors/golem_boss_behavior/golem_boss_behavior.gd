## boss_golem_behavior.gd
## A reactive AI for a Golem boss that chooses attacks based on player distance.
class_name BossGolemBehavior
extends EnemyBehavior

# --- Simplified State Machine ---
enum State {
	CHASING,
	ATTACKING
}
var current_state: State = State.CHASING

# --- Node References ---
@onready var chase_timer: Timer = $ChaseTimer

# --- Configurable AI Properties ---
@export var close_range_threshold: float = 400.0 # Distance to be considered "close"

# --- Weapon References ---
var spike_ring_weapon: Weapon = null
var meteor_slam_weapon: Weapon = null

func _ready():
	chase_timer.wait_time = 4.0 # Chase for 4 seconds before choosing an attack
	chase_timer.one_shot = true
	chase_timer.timeout.connect(_on_chase_timer_timeout)
	chase_timer.start()

func initialize_behavior(host: Node):
	var equipment = host.get_node_or_null("Equipment")
	if equipment:
		spike_ring_weapon = equipment.get_node_or_null("SpikeRingWeapon")
		spike_ring_weapon.base_projectile_count = 20
		meteor_slam_weapon = equipment.get_node_or_null("MeteorWeapon")

func process_behavior(delta: float, host: CharacterBody2D) -> void:
	if not is_instance_valid(host.player_node):
		host.velocity = Vector2.ZERO
		return

	if current_state == State.CHASING:
		var direction = (host.player_node.global_position - host.global_position).normalized()
		host.velocity = direction * host.stats.speed
	else:
		host.velocity = Vector2.ZERO
		
	host.move_and_slide()

# --- Core AI Logic ---

func _on_chase_timer_timeout():
	# Chase time is over. Stop and choose an attack.
	current_state = State.ATTACKING

	var host = get_parent()
	if not is_instance_valid(host): return

	# Check the host's visibility flag before attacking.
	if host.is_on_screen:
		# If we are on screen, proceed with the attack logic.
		_choose_and_execute_attack()
	else:
		# If we are off-screen, don't attack. Just reset to chasing.
		Logs.add_message("Boss AI: Off-screen, skipping attack and resuming chase.")
		current_state = State.CHASING
		chase_timer.start()

## The main decision-making function for the boss.
func _choose_and_execute_attack():
	var host = get_parent()
	if not is_instance_valid(host) or not is_instance_valid(host.player_node): return

	var distance_to_player = host.global_position.distance_to(host.player_node.global_position)
	
	# --- Define Attack Weights ---
	# We start with base weights for each attack.
	var attack_weights = {
		"spike_nova": 10,
		"meteor_slam": 10
	}
	
	# --- Adjust Weights Based on Distance ---
	if distance_to_player <= close_range_threshold:
		# Player is close. Heavily favor Spike Nova.
		attack_weights["spike_nova"] += 30 # A large bonus
		Logs.add_message("Boss AI: Player is close, favoring Spike Nova.")
	else:
		# Player is far. Heavily favor Meteor Slam.
		attack_weights["meteor_slam"] += 30
		Logs.add_message("Boss AI: Player is far, favoring Meteor Slam.")

	# --- Perform Weighted Random Selection ---
	var chosen_attack = _weighted_random_choice(attack_weights)
	
	# --- Execute the Chosen Attack ---
	match chosen_attack:
		"spike_nova":
			_execute_spike_nova()
		"meteor_slam":
			_execute_meteor_slam()
	
	# After the attack is complete, go back to chasing.
	# We place this here because the attack functions are now async.
	current_state = State.CHASING
	chase_timer.start()

## Helper function to pick a key from a dictionary based on integer weights.
func _weighted_random_choice(weights: Dictionary) -> String:
	var total_weight = 0
	for key in weights:
		total_weight += weights[key]
	
	var roll = randi_range(1, total_weight)
	var cumulative_weight = 0
	for key in weights:
		cumulative_weight += weights[key]
		if roll <= cumulative_weight:
			return key
			
	return weights.keys()[0] # Fallback

# --- Asynchronous Attack Execution Functions ---

## Executes the multi-shot Spike Nova attack.
func _execute_spike_nova():
	if not is_instance_valid(spike_ring_weapon): return
	
	var spike_burst_count = 3
	var delay_between_bursts = 1
	
	for i in range(spike_burst_count):
		spike_ring_weapon.fire()
		if i < spike_burst_count - 1:
			await get_tree().create_timer(delay_between_bursts).timeout

## Executes the Meteor Slam attack.
func _execute_meteor_slam():
	if not is_instance_valid(meteor_slam_weapon): return
	meteor_slam_weapon.fire()
