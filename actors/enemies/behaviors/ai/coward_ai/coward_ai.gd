## coward_ai.gd
## An AI that attacks when healthy but flees when damaged.
class_name CowardAI
extends EnemyAI

@export var flee_health_threshold: float = 0.4 # Flee at 40% health


func _ready():
	default_state = states["chase"]
	super._ready()

func _physics_process(delta):
	var health_percent = float(host.current_health) / host.stats.max_health
	
	if health_percent <= flee_health_threshold:
		# If health is low, our ONLY state is Fleeing.
		if current_state != states.get("flee"):
			set_state(states["flee"])
	else:
		# If health is high, use the default attack behavior.
		if current_state != default_state:
			restore_default_state()
	
	# --- Execute Active Behavior ---
	if is_instance_valid(current_state):
		current_state.process_behavior(delta, host)
