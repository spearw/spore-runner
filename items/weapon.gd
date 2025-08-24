## weapon.gd
## A generic weapon data container. All logic is in its components.
class_name Weapon
extends Node2D

# --- Data ---
@export var projectile_stats: ProjectileStats
@export var base_projectile_count: int = 1
@export var base_fire_rate: float = 2;

# --- State ---
var last_fire_direction: Vector2 = Vector2.RIGHT

# --- Component References ---
@onready var fire_behavior_component: FireBehaviorComponent = $FireBehaviorComponent
@onready var fire_rate_timer: Timer = $FireRateTimer

func _ready():
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)

func _on_fire_rate_timer_timeout():
	# Delegate the actual firing to the component.
	fire_behavior_component.fire()

## Public method for manual firing (e.g., by enemy AI).
func fire():
	fire_behavior_component.fire()
