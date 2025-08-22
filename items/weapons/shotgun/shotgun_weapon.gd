## shotgun_weapon.gd
class_name ShotgunWeapon
extends Node2D

# --- Base Properties ---
@export var projectile_stats: ProjectileStats
# Generic projectile scene
const GENERIC_PROJECTILE_SCENE = preload("res://systems/projectiles/projectile.tscn")
var base_projectile_count: int = 8
@export var base_fire_rate: float = 3.0
var spread_angle_degrees: float = 30.0

# --- Component References ---
@onready var targeting_component: TargetingComponent = $TargetingComponent
@onready var stats_component: WeaponStatsComponent = $WeaponStatsComponent
@onready var fire_rate_timer: Timer = $FireRateTimer

var last_fire_direction = Vector2.RIGHT

func _ready():
	fire_rate_timer.timeout.connect(fire)

func fire():
	if not projectile_stats: return
	
	var fire_direction = targeting_component.get_fire_direction(self.global_position, last_fire_direction)
	var final_projectile_count = stats_component.get_final_projectile_count()
	
	for i in range(final_projectile_count):
		# Instantiate the GENERIC scene.
		var projectile = GENERIC_PROJECTILE_SCENE.instantiate()
		
		projectile.stats = self.projectile_stats
		projectile.allegiance = stats_component.get_projectile_allegiance()
		projectile.direction = fire_direction
		
		# Apply accuracy
		var final_direction = fire_direction.rotated(
		deg_to_rad(randf_range(-spread_angle_degrees / 2.0, spread_angle_degrees / 2.0)))
		projectile.direction = final_direction
		projectile.rotation = final_direction.angle()
		
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = self.global_position
			
	last_fire_direction = fire_direction
