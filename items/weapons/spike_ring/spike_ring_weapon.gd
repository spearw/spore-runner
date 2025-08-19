## A weapon that fires a ring of spike projectiles around the player.
class_name SpikeRingWeapon extends Node2D

@export var projectile_scene: PackedScene

# --- Base Properties ---
var base_projectile_count: int = 8
var base_projectile_damage: int = 15
var base_interval: float = 4.0

# --- Component References ---
@onready var stats_component: WeaponStatsComponent = $WeaponStatsComponent
@onready var fire_rate_timer: Timer = $FireRateTimer

func _ready():
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)

## Called by the timer to fire a volley of spikes.
func _on_fire_rate_timer_timeout():
	if not projectile_scene:
		return

	# Calculate the angle between each spike. TAU is a full circle in radians (2 * PI).
	var final_projectile_count = stats_component.get_final_projectile_count()
	var angle_step = TAU / final_projectile_count
	
	for i in range(final_projectile_count):
		var current_angle = angle_step * i
		var projectile = projectile_scene.instantiate()
		
		# Set the projectile's stats from the weapon's stats.
		projectile.damage = self.base_projectile_damage
		projectile.direction = Vector2.RIGHT.rotated(current_angle)
		
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = self.global_position
