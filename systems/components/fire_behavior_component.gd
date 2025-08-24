## fire_behavior_component.gd
## A component that defines HOW a weapon fires its projectiles.
class_name FireBehaviorComponent
extends Node

# --- Define the different ways a weapon can fire ---
enum FirePattern {
	FORWARD,      # Fires all projectiles in a single targeted direction.
	SPREAD,       # Fires all projectiles in a cone towards a target.
	NOVA          # Fires all projectiles in a 360-degree circle (dumbfire).
}

# --- Configurable Properties ---
@export var pattern: FirePattern = FirePattern.FORWARD
@export var spread_angle_degrees: float = 30.0 # Only used for SPREAD pattern
@export var burst_delay: float = 0.08 # Delay between shots in a burst

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

## Helper function to handle the actual creation of a single projectile.
func _spawn_projectile(p_stats: ProjectileStats, p_allegiance: Projectile.Allegiance, p_direction: Vector2):
	var projectile = GENERIC_PROJECTILE_SCENE.instantiate()
	projectile.stats = p_stats
	projectile.allegiance = p_allegiance
	projectile.direction = p_direction
	projectile.rotation = p_direction.angle()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = weapon.global_position
