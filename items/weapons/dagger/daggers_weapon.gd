## daggers_weapon.gd
class_name DaggersWeapon
extends Node2D

# --- Base Properties ---
@export var projectile_scene: PackedScene
var base_projectile_count: int = 1
var base_projectile_damage: int = 10
var base_interval: float = 1.5

# --- Component References ---
@onready var targeting_component: TargetingComponent = $TargetingComponent
@onready var stats_component: WeaponStatsComponent = $WeaponStatsComponent
@onready var fire_rate_timer: Timer = $FireRateTimer

var last_fire_direction = Vector2.RIGHT

func _ready():
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)

func _on_fire_rate_timer_timeout():
	if not projectile_scene: return
	
	var fire_direction = targeting_component.get_fire_direction(self.global_position, last_fire_direction)
	var final_projectile_count = stats_component.get_final_projectile_count()
	
	for i in range(final_projectile_count):
		var projectile = projectile_scene.instantiate()
		projectile.damage = self.base_projectile_damage
		projectile.direction = fire_direction
		projectile.rotation = fire_direction.angle()
		
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = self.global_position
		
		if i < final_projectile_count - 1:
			await get_tree().create_timer(0.08).timeout
			
	last_fire_direction = fire_direction
