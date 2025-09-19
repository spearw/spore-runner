## shoot_behavior.gd
## A behavior that stops the host, plays an attack animation, fires its weapons,
## and then waits for a cooldown before repeating.
class_name ShootBehavior
extends EnemyBehavior

# --- State & Timers ---
# This timer controls the cooldown *after* an attack has finished.
@onready var cooldown_timer: Timer = Timer.new()
# A flag to prevent re-triggering the attack while an animation is playing.
var is_attacking: bool = false

# --- Setup ---
func _ready():
	# Configure the timer once. It will be started and stopped by our logic.
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_finished)

func on_enter(host: Node, context: Dictionary = {}):
	super.on_enter(host, context)
	
	# When entering this state, immediately start the attack process.
	_start_attack_sequence()

func on_exit():
	# When we leave this state (e.g., player moves out of range),
	# ensure we clean up and stop any pending timers.
	if is_instance_valid(host_anim_controller):
		host_anim_controller.play_exit_and_loop("stop_idle", "move")
	cooldown_timer.stop()
	is_attacking = false

func process_behavior(delta: float, host: CharacterBody2D):
	# The core of this behavior is to stand still. All logic is event-driven.
	host.velocity = Vector2.ZERO

# --- The Core Attack Loop ---

## This is the entry point for an attack attempt.
func _start_attack_sequence():
	# Don't start a new attack if we're already in the middle of one.
	if is_attacking: return

	is_attacking = true
	
	# Check if the host has a dedicated "attack" animation.
	if is_instance_valid(host_anim_controller) and host_anim_controller.has_animation("attack"):
		# --- PATH A: Animation-Driven Attack ---
		# Connect to the animator's signal for this single attack.
		# The 'CONNECT_ONE_SHOT' flag is crucial.
		host_anim_controller.animation_lock_released.connect(_fire_payload, CONNECT_ONE_SHOT)
		# Play the attack animation. The signal will trigger the actual firing.
		host_anim_controller.play_once("attack")
	else:
		# --- PATH B: Immediate Attack (No Animation) ---
		# This enemy has no special animation, so fire immediately.
		if is_instance_valid(host_anim_controller):
			host_anim_controller.play_loop("idle")
		_fire_payload()

## This function contains the actual "fire" event.
## It's called either immediately or after an animation finishes.
func _fire_payload():
	if not is_instance_valid(host_enemy): return

	# Fire the weapons.
	if host_enemy.has_method("fire_weapons"):
		host_enemy.fire_weapons()
		
	# Start the cooldown timer.
	# The enemy needs a 'firerate' stat in its EnemyStats resource.
	var cooldown_duration = host_enemy.stats.firerate
	cooldown_timer.start(cooldown_duration)

## This is called after the cooldown period is over.
func _on_cooldown_finished():
	is_attacking = false
	# The cooldown is over. We can now start a new attack sequence.
	# The AI brain (e.g., SkirmisherAI) is still active and will
	# keep us in this ShootBehavior state as long as conditions are met.
	# So we can just try to attack again.
	_start_attack_sequence()
