## fire_behavior_component.gd
## A component that defines HOW a weapon fires its projectiles.
class_name FireBehaviorComponent
extends Node

# --- Define the different ways a weapon can fire ---
enum FirePattern {
	FORWARD,      # Fires all projectiles in a single targeted direction.
	SPREAD,       # Fires all projectiles in a cone towards a target.
	NOVA,         # Fires all projectiles in a 360-degree circle (dumbfire).
	AIMED_AOE,    # Fires exactly on targeted enemy with small delay
}

# --- Configurable Properties ---
@export var pattern: FirePattern = FirePattern.FORWARD
@export var spread_angle_degrees: float = 30.0 # Only used for SPREAD pattern
@export var burst_delay: float = 0.08 # Delay between shots in a burst

# Only for AoE attacks
@export var aoe_warning_scene: PackedScene
@export var aoe_delay: float = 1.0
@onready var aoe_delay_timer: Timer = $AoeDelayTimer

# --- References (set at runtime) ---
var weapon # The parent weapon node
const GENERIC_PROJECTILE_SCENE = preload("res://systems/projectiles/projectile.tscn")

func _ready():
	weapon = get_parent()

## The main public method called by the weapon's timer or AI.
func fire():
	if not is_instance_valid(weapon): return

	var stats_comp: WeaponStatsComponent = weapon.get_node("WeaponStatsComponent")
	var targeting_comp: TargetingComponent = weapon.get_node("TargetingComponent")
	
	if not stats_comp or not targeting_comp:
		printerr("FireBehaviorComponent on '%s' is missing required components!" % weapon.name)
		return
		
	var final_projectile_count = stats_comp.get_final_projectile_count()
	var allegiance = stats_comp.get_projectile_allegiance()
	var projectile_stats = weapon.projectile_stats

	# --- Main Firing Logic ---
	match pattern:
		FirePattern.FORWARD, FirePattern.SPREAD:
			# Get a single base direction from the targeting component.
			var base_direction = targeting_comp.get_fire_direction(weapon.global_position, weapon.last_fire_direction, allegiance)
			
			for i in range(final_projectile_count):
				var fire_direction = base_direction
				if pattern == FirePattern.SPREAD:
					fire_direction = base_direction.rotated(
						deg_to_rad(randf_range(-spread_angle_degrees / 2.0, spread_angle_degrees / 2.0))
					)
				
				_spawn_projectile(projectile_stats, allegiance, fire_direction)
				
				if i < final_projectile_count - 1 and burst_delay > 0:
					await get_tree().create_timer(burst_delay).timeout
					
			weapon.last_fire_direction = base_direction

		FirePattern.NOVA:
			var angle_step = TAU / final_projectile_count
			for i in range(final_projectile_count):
				var fire_direction = Vector2.RIGHT.rotated(angle_step * i)
				_spawn_projectile(projectile_stats, allegiance, fire_direction)
				
				# Add burst delay to NOVA for a ripple effect.
				if i < final_projectile_count - 1 and burst_delay > 0:
					await get_tree().create_timer(burst_delay).timeout
					
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
func _spawn_projectile(p_stats: ProjectileStats, p_allegiance: Projectile.Allegiance, p_direction: Vector2, p_position: Vector2 = weapon.global_position):
	var projectile = GENERIC_PROJECTILE_SCENE.instantiate()
	projectile.stats = p_stats
	projectile.allegiance = p_allegiance
	projectile.direction = p_direction
	projectile.rotation = p_direction.angle()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = p_position # On firing entity, unless AoE attack
	
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
