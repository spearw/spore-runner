## fire_behavior_component.gd
## A component that defines HOW a weapon fires its projectiles.
class_name FireBehaviorComponent
extends Node

# --- Define the different ways a weapon can fire ---
enum FirePattern {
	FORWARD,      # Fires all projectiles in a single targeted direction with optional spread
	NOVA,         # Fires all projectiles in an even arc without aim.
	AIMED_AOE,    # Spawns exactly on targeted enemy with variable delay
	MIRRORED_FORWARD, # Like forward but also creates projectile at 180 degrees.
	CONE, 		# Fires all projectiles in a set cone towards a target.
}
enum SpawnLocation {
	IN_WORLD,  # For normal, independent projectiles (bullets, fireballs).
	ON_USER    # For attached effects (melee swings, auras).
}

# --- Configurable Properties ---
@export var base_pattern: FirePattern = FirePattern.FORWARD
@export var spawn_location: SpawnLocation = SpawnLocation.IN_WORLD
@export var spread_angle_degrees: float = 30.0 # Only used for SPREAD pattern
@export var burst_delay: float = 0.08 # Delay between shots in a burst
@onready var burst_delay_timer: Timer = $BurstDelayTimer

# Only for AoE attacks
@export var aoe_warning_scene: PackedScene
@export var aoe_delay: float = 1.0
@onready var aoe_delay_timer: Timer = $AoeDelayTimer

# --- References (set at runtime) ---
var weapon # The parent weapon node
const GENERIC_PROJECTILE_SCENE = preload("res://systems/projectiles/projectile.tscn")
var stats_comp: WeaponStatsComponent;
var targeting_comp: TargetingComponent;
var pattern_override = -1 # -1 means no override
var fire_pattern = -1
var additional_multiplier = 1


func _ready():
	weapon = get_parent()
	stats_comp = weapon.get_node("WeaponStatsComponent")
	targeting_comp = weapon.get_node("TargetingComponent")

## The main public method called by the weapon's timer or AI.
func fire(damage_multiplier=1):
	additional_multiplier = damage_multiplier
	if not is_instance_valid(weapon): return
	
	if not stats_comp or not targeting_comp:
		printerr("FireBehaviorComponent on '%s' is missing required components!" % weapon.name)
		return
		
	var final_projectile_count = stats_comp.get_final_projectile_count()
	var allegiance = stats_comp.get_projectile_allegiance()
	var projectile_stats = weapon.projectile_stats
	
	fire_pattern = base_pattern # Use the default pattern
	if pattern_override != -1:
		fire_pattern = pattern_override # Or use the override
		pattern_override = -1 # Reset override
	
	# --- Main Firing Logic ---
	match fire_pattern:
		FirePattern.FORWARD, FirePattern.MIRRORED_FORWARD:
			_execute_burst_fire(final_projectile_count, projectile_stats, allegiance, targeting_comp)
		FirePattern.NOVA:
			_execute_nova_fire(final_projectile_count, projectile_stats, allegiance)
		FirePattern.CONE:
			_execute_cone_fire(final_projectile_count, projectile_stats, allegiance, targeting_comp)
		FirePattern.AIMED_AOE:
			# For AoE, the "projectile count" is how many meteors we drop.
			for i in range(final_projectile_count):
				# Get a target position. We can reuse our targeting component!
				# Find a target, but default to a random position near the owner if none are found.
				var target_node = targeting_comp.find_target(weapon.global_position, allegiance)
				var target_position = weapon.global_position + Vector2(randf_range(-150, 150), randf_range(-150, 150))
								
				if is_instance_valid(target_node):
					target_position = target_node.global_position
					
				_execute_aoe_strike(target_position, projectile_stats, allegiance)

## Helper function to handle the actual creation of a single projectile.
func _spawn_projectile(projectile_stats: ProjectileStats, projectile_allegiance: Projectile.Allegiance, projectile_direction: Vector2, p_position: Vector2 = weapon.global_position, user_override: Node2D = null):
	# The weapon is attached to the user, so its global_position is the user's position.
	var spawn_position = weapon.global_position
	
	# We need to instantiate the correct scene. Axe needs its custom scene.
	var projectile_scene = GENERIC_PROJECTILE_SCENE
	# We can add a property to the weapon to specify a custom projectile scene.
	if "custom_projectile_scene" in weapon and weapon.custom_projectile_scene:
		projectile_scene = weapon.custom_projectile_scene
	
	var projectile = projectile_scene.instantiate()

	projectile.stats = projectile_stats
	projectile.direction = projectile_direction
	projectile.allegiance = projectile_allegiance
	projectile.weapon = weapon
	
	# Determine projectile's user
	var user
	if user_override:
		user = user_override
	else:
		user = stats_comp.user
	projectile.user = user
	
	match spawn_location:
		SpawnLocation.IN_WORLD:
			# The old logic: spawn in the main world.
			projectile.direction = projectile_direction
			get_tree().current_scene.add_child(projectile)
			projectile.global_position = spawn_position
			projectile.rotation = projectile_direction.angle()
		
		SpawnLocation.ON_USER:
			# The new logic: spawn as a child of the user.
			user.add_child(projectile)
			# Its position will be (0,0) relative to the user, which is correct.
			projectile.position = Vector2.ZERO
			# The swing's rotation is set relative to the user's facing direction.
			projectile.rotation = projectile_direction.angle()

# This is a public function the weapon script can now call to override the pattern for a single shot.
func override_pattern_for_next_shot(new_pattern: FirePattern):
	pattern_override = new_pattern

func _execute_burst_fire(p_count: int, p_stats: ProjectileStats, p_allegiance: Projectile.Allegiance, targeting_comp: TargetingComponent):
	# Get a single base direction from the targeting component.
	var base_direction = targeting_comp.get_fire_direction(weapon.global_position, weapon.last_fire_direction, p_allegiance)
	var final_projectile_count = stats_comp.get_final_projectile_count()
	
	# If the pattern is MIRRORED_FORWARD, it doubles the current projectile count (to fire behind).
	if fire_pattern == FirePattern.MIRRORED_FORWARD:
		final_projectile_count *= 2
		
	for i in range(final_projectile_count):
		var fire_direction = base_direction
		if fire_pattern == FirePattern.FORWARD or fire_pattern == FirePattern.MIRRORED_FORWARD:
			fire_direction = base_direction.rotated(
				deg_to_rad(randf_range(-spread_angle_degrees / 2.0, spread_angle_degrees / 2.0))
			)
		var should_delay = true
		if fire_pattern == FirePattern.MIRRORED_FORWARD:
			# Fire behind every odd shot (index 1, 3, etc.)
			if i % 2 == 1:
				fire_direction = fire_direction.rotated(PI)
			if i % 2 == 0:
				should_delay = false
		
		_spawn_projectile(p_stats, p_allegiance, fire_direction)
		
		# Delay burst
		if i < final_projectile_count - 1 and burst_delay > 0 and should_delay:
			burst_delay_timer.wait_time = burst_delay
			burst_delay_timer.start()
			await burst_delay_timer.timeout
			
			
	weapon.last_fire_direction = base_direction
	
func _execute_nova_fire(p_count: int, p_stats: ProjectileStats, p_allegiance: Projectile.Allegiance):
	var angle_step = TAU / p_count
	for i in range(p_count):
		var fire_direction = Vector2.RIGHT.rotated(angle_step * i)
		_spawn_projectile(p_stats, p_allegiance, fire_direction)
		
		# Add burst delay to NOVA for a ripple effect.
		if i < p_count - 1 and burst_delay > 0:
			burst_delay_timer.wait_time = burst_delay
			burst_delay_timer.start()
			await burst_delay_timer.timeout
			
func _execute_cone_fire(p_count: int, p_stats: ProjectileStats, p_allegiance: Projectile.Allegiance, targeting_comp: TargetingComponent):
	# Get a single base direction from the targeting component.
	var base_direction = targeting_comp.get_fire_direction(weapon.global_position, weapon.last_fire_direction, p_allegiance)
	var final_projectile_count = stats_comp.get_final_projectile_count()
	# Projectile angle is 45 degrees / projectile count
	var angle_step = PI / 4 / p_count
	for i in range(p_count):
		# Projectile arc is -22.5 degrees + current step value evenly spaced
		var fire_direction = base_direction.rotated(-(PI/8) + (angle_step * i))
		_spawn_projectile(p_stats, p_allegiance, fire_direction)
	
## Handles the sequence for a single AoE strike.
func _execute_aoe_strike(target_pos: Vector2, p_stats: ProjectileStats, p_allegiance: Projectile.Allegiance):
	# Spawn the warning indicator.
	if aoe_warning_scene:
		var warning = aoe_warning_scene.instantiate()
		get_tree().current_scene.add_child(warning)
		warning.global_position = target_pos
		
	# Configure and start our pause-respecting timer.
	aoe_delay_timer.wait_time = aoe_delay
	aoe_delay_timer.start()
	
	# Wait for the timer's timeout signal.
	await aoe_delay_timer.timeout
	
	# Spawn the configured "projectile" that will act as the explosion.
	_spawn_projectile(p_stats, p_allegiance, Vector2.ZERO, target_pos)
