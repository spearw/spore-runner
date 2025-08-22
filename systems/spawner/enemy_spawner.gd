## enemy_spawner.gd
## Manages the entire enemy spawn timeline for a run.
extends Node


@export var enemy_scene: PackedScene

# --- The full timeline for the run, sorted by time. ---
@export var spawn_timeline: Array[SpawnEvent]

# --- Runtime variables ---
var run_timer: float = 0.0
# A dictionary to track the cooldown for each active, repeating event.
var active_event_cooldowns: Dictionary = {}
# A copy of the timeline that can safely remove events as they are processed.
var pending_events: Array[SpawnEvent]
var spawn_radius: float = 1024.0
# Get number generator for enemy stat variance
var rng = RandomNumberGenerator.new()

var player_node: Node2D

func _ready():
	if not enemy_scene or spawn_timeline.is_empty():
		printerr("EnemySpawner not configured. Disabling.")
		set_physics_process(false)
		return
	
	player_node = get_tree().get_first_node_in_group("player")
	# Init randomizer
	rng.randomize()
	
	# Sort the timeline by start time to ensure we process it in order.
	spawn_timeline.sort_custom(func(a, b): return a.time_start < b.time_start)
	pending_events = spawn_timeline.duplicate()

func _physics_process(delta: float):
	if not is_instance_valid(player_node): return

	run_timer += delta
	
	while not pending_events.is_empty() and run_timer >= pending_events[0].time_start:
		var event = pending_events.pop_front() # Get and remove the next event
		if event.is_burst:
			spawn_group(event) # Spawn immediately and forget.
		else:
			# It's a repeating event. Add it to our active dictionary.
			active_event_cooldowns[event] = 0.0 # Start ready to spawn.

	# Process all active, repeating events.
	for event in active_event_cooldowns.keys():
		# Check for event expiring and remove
		if event.time_end != -1 and run_timer >= event.time_end:
			active_event_cooldowns.erase(event)
			continue
			
		# Decrease cooldown.
		active_event_cooldowns[event] -= delta
		if active_event_cooldowns[event] <= 0:
			spawn_group(event)
			active_event_cooldowns[event] = event.interval

## Spawns a group of enemies based on a SpawnEvent's data.
func spawn_group(event: SpawnEvent):
	# Calculate a single random spawn point for the group.
	var random_angle = randf_range(0, TAU)
	var spawn_offset = Vector2.RIGHT.rotated(random_angle) * spawn_radius
	var base_spawn_position = player_node.global_position + spawn_offset

	# Set stat variances
	var stat_variances = {
		"max_health": 0.15,
		"speed": 0.10,
		"damage": 0.20
	}
	
	for i in range(event.quantity):
		var enemy_instance = enemy_scene.instantiate()
		var unique_stats = event.enemy_stats.duplicate()
		
		# Apply enemy stat variance
		for stat_name in stat_variances:
			# Calculate variance for this stat.
			var variance = stat_variances[stat_name]
			var random_multiplier = 1.0 + randf_range(-variance, variance)
			
			# Calculate the final stat.
			var final_value = unique_stats.get(stat_name) * random_multiplier
			
			# Round.
			final_value = roundi(final_value)
			
			# Set the modified value back onto the stats object.
			unique_stats.set(stat_name, final_value)
		
		# Assign stats
		enemy_instance.stats = unique_stats
		
		# Spawn enemy.
		enemy_instance.global_position = base_spawn_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		
		get_tree().current_scene.add_child(enemy_instance)
