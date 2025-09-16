## encounter_director.gd
## A budget-based spawner. Acts as an "Encounter Director".
class_name EncounterDirector
extends Node

# --- CONFIGURATION ---
@export var enemy_scene: PackedScene
@export var difficulty_curve: Curve
@export var encounter_sets: Array[EncounterSet]
@export var spawn_radius: float = 1200.0

@onready var spawn_pulse_timer: Timer = $Timer

# --- RUNTIME STATE ---
var run_timer: float = 0.0
var budget_accumulator: float = 0.0
var player_node: Node2D


# --- THREAT TRACKING ---
# Key: Behavior Class Name (String), Value: Total Challenge Rating on screen (float)
var current_threat: Dictionary = {}
# A list of all encounter sets, which will shrink as they are processed.
var pending_encounter_sets: Array[EncounterSet]

# --- METAPROGRESSION ---
var threat_level: float = 1.0 # This will later be fetched from GameData as a player unlocks/increases difficulty

func _ready():
	# Validate that we have everything we need to function.
	if not enemy_scene or not difficulty_curve or encounter_sets.is_empty():
		printerr("DynamicSpawner is not fully configured! Disabling.")
		set_physics_process(false)
		return
	
	player_node = get_tree().get_first_node_in_group("player")
	# In the future, get this from GameData:
	# threat_level = GameData.data["permanent_stats"].get("threat_level", 1.0)
	spawn_pulse_timer.timeout.connect(_on_spawn_pulse_timer_timeout)
	# Sort the master list by time and create pending list.
	encounter_sets.sort_custom(func(a, b): return a.time_start < b.time_start)
	pending_encounter_sets = encounter_sets.duplicate()
	
func _physics_process(delta: float):
	if not is_instance_valid(player_node): return

	# Accumulate the budget.
	run_timer += delta
	var base_budget_per_sec = difficulty_curve.sample(run_timer)
	var current_frame_budget = base_budget_per_sec * threat_level * delta
	budget_accumulator += current_frame_budget
	
	# Check for any one-time "override" events that need to fire now.
	# While loop to handles multiple events triggering on the same frame.
	while not pending_encounter_sets.is_empty() and run_timer >= pending_encounter_sets[0].time_start:
		var event_to_check = pending_encounter_sets[0]
		
		if event_to_check.spawn_immediately_on_start:
			# It's a boss/burst event. Process it now.
			var event = pending_encounter_sets.pop_front() # Get and remove it from the list
			Logs.add_message("Director Override: Spawning immediate event '%s'" % event.resource_path)
			
			for enemy_stat in event.enemies:
				# Spawn the enemy and go into budget deficit.
				budget_accumulator -= enemy_stat.challenge_rating
				spawn_enemy(enemy_stat)
		else:
			# It's a normal, repeating set. Since the list is sorted,
			# we know no later "immediate" events are ready yet.
			break

func _on_spawn_pulse_timer_timeout():
	#Logs.add_message(["Director Budget:", budget_accumulator])
	var available_enemies = _get_currently_available_enemies()
	if available_enemies.is_empty(): return

	var theme_enemy_stats = _pick_theme_enemy(available_enemies, budget_accumulator)
	
	if not theme_enemy_stats: return

	while budget_accumulator >= theme_enemy_stats.challenge_rating:
		budget_accumulator -= theme_enemy_stats.challenge_rating
		spawn_enemy(theme_enemy_stats)


## Gathers all enemies from EncounterSets that are active at the current run_timer.
func _get_currently_available_enemies() -> Array[EnemyStats]:
	var available: Array[EnemyStats] = []
	for encounter_set in encounter_sets:
		var is_active = run_timer >= encounter_set.time_start and \
						(encounter_set.time_end == -1 or run_timer < encounter_set.time_end)
		
		if is_active:
			available.append_array(encounter_set.enemies)
			
	return available

## Selects a an enemy from the pool, weighted towards the lowest CR value active.
func _pick_theme_enemy(pool: Array[EnemyStats], budget: float) -> EnemyStats:
	var affordable_pool = pool.filter(func(es): return es.challenge_rating <= budget)
	if affordable_pool.is_empty(): return null

	# Find the behavior with the lowest total CR currently on screen.
	var lowest_cr = INF
	var least_represented_behavior = ""
	# We need a list of all unique behaviors in the affordable pool
	var affordable_behaviors = {}
	# TODO: Refactor to use tags
	#for enemy_stat in affordable_pool:
		#var behavior_scene = enemy_stat.behavior_scene.instantiate()
		#var behavior_class = behavior_scene.get_class()
		#behavior_scene.queue_free()
		#affordable_behaviors[behavior_class] = true
#
	#for behavior_class in affordable_behaviors:
		#var current_cr = current_threat.get(behavior_class, 0.0)
		#if current_cr < lowest_cr:
			#lowest_cr = current_cr
			#least_represented_behavior = behavior_class
			#
	## Now, filter our affordable pool to only enemies that have that least-represented behavior.
	#var priority_pool = affordable_pool.filter(func(es):
		#var behavior_scene = es.behavior_scene.instantiate()
		#var behavior_class = behavior_scene.get_class()
		#behavior_scene.queue_free()
		#return behavior_class == least_represented_behavior
	#)
	
	# If for some reason our priority pool is empty, fall back to the affordable pool.
	#if priority_pool.is_empty():
		#priority_pool = affordable_pool
		
	# Finally, pick a random enemy from the high-priority list.
	return affordable_pool.pick_random()

## Instantiates and positions a single enemy.
func spawn_enemy(stats: EnemyStats):
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.stats = stats
	
	var random_angle = randf_range(0, TAU)
	var spawn_offset = Vector2.RIGHT.rotated(random_angle) * spawn_radius
	var spawn_position = player_node.global_position + spawn_offset
	
	enemy_instance.global_position = spawn_position
	get_tree().current_scene.add_child(enemy_instance)
	# Update ledger with enemy stats
	enemy_instance.died.connect(_on_enemy_died)
	_update_threat_ledger(stats, 1)
	
## Signal handler for when any enemy dies.
func _on_enemy_died(enemy_stats: EnemyStats):
	_update_threat_ledger(enemy_stats, -1)
	
## Helper function to modify our internal threat tally.
func _update_threat_ledger(enemy_stats: EnemyStats, multiplier: int):
	#TODO: Update this function with tags
	return
	if not enemy_stats.behavior_scene: return
	
	# We need to get the class name from the behavior scene.
	# This is a bit tricky, but we only do it once per spawn/death.
	var behavior_instance = enemy_stats.behavior_scene.instantiate()
	var behavior_class = behavior_instance.get_class()
	behavior_instance.queue_free() # Clean up the temporary instance
	
	var current_cr = current_threat.get(behavior_class, 0.0)
	var cr_change = enemy_stats.challenge_rating * multiplier
	current_threat[behavior_class] = current_cr + cr_change
	
	# Logs.add_message(["Threat updated: ", on_screen_threat])

func _on_timer_timeout() -> void:
	pass # Replace with function body.
