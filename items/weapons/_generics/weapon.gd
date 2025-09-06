## weapon.gd
## A generic weapon data container. All logic is in its components.
class_name Weapon
extends Node2D

# --- Data ---
@export var projectile_stats: ProjectileStats
# This optionally overrides the generic projectile scene with a custom one.
@export var custom_projectile_scene: PackedScene
@export var base_projectile_count: int = 1
@export var base_fire_rate: float = 2;

# --- State ---
var last_fire_direction: Vector2 = Vector2.RIGHT

# --- Component References ---
@onready var fire_behavior_component: FireBehaviorComponent = $FireBehaviorComponent
@onready var stats_component: WeaponStatsComponent = $WeaponStatsComponent
@onready var fire_rate_timer: Timer = $FireRateTimer
@onready var targeting_component: TargetingComponent = $TargetingComponent

func _ready():
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)
	fire()
	
# Update internal stats whenever the user's stats change.
func update_stats():
	var user = stats_component.user
	if not is_instance_valid(user): return

	# Get fire rate from the user
	var firerate_multiplier = user.get_stat("firerate")
	fire_rate_timer.wait_time = base_fire_rate * firerate_multiplier

func _on_fire_rate_timer_timeout():
	# Delegate the actual firing to the component.
	fire()

## Public method for manual firing (e.g., by enemy AI).
func fire(damage_multiplier=1):
	fire_behavior_component.fire(damage_multiplier)
