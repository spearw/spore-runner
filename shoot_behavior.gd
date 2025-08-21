## stop_and_shoot_behavior.gd
## A behavior where the enemy chases, stops at a range, fires, and repeats.
class_name StopAndShootBehavior
extends EnemyBehavior

enum State { CHASING, SHOOTING }
var current_state: State = State.CHASING

@export var shooting_range: float = 250.0
@export var enemy_projectile_scene: PackedScene
@onready var fire_rate_timer: Timer = $FireRateTimer

func _ready():
	fire_rate_timer.wait_time = 2.0 # Cooldown between shots
	fire_rate_timer.one_shot = true
	fire_rate_timer.timeout.connect(_on_firerate_timer_timeout)

func process_behavior(delta: float, host: CharacterBody2D) -> void:
	if not is_instance_valid(host.player_node):
		host.velocity = Vector2.ZERO
		return
	
	match current_state:
		State.CHASING:
			var distance_to_player = host.global_position.distance_to(host.player_node.global_position)
			
			if distance_to_player <= shooting_range:
				# We are in range. Stop and switch to shooting state.
				host.velocity = Vector2.ZERO
				current_state = State.SHOOTING
				fire_rate_timer.start()
			else:
				# Not in range yet, continue chasing.
				var direction = (host.player_node.global_position - host.global_position).normalized()
				host.velocity = direction * host.stats.speed
		
		State.SHOOTING:
			# Do nothing while waiting for the timer to fire.
			host.velocity = Vector2.ZERO
			
	host.move_and_slide()

func _on_firerate_timer_timeout():
	# This function needs the 'host' reference, which we don't have in a signal callback.
	# So we get it from the parent.
	var host = get_parent()
	if not is_instance_valid(host) or not is_instance_valid(host.player_node): return
	
	# Fire the projectile
	var projectile = enemy_projectile_scene.instantiate()
	var fire_direction = (host.player_node.global_position - host.global_position).normalized()
	projectile.rotation = fire_direction.angle()
	projectile.direction = fire_direction
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = host.global_position
	
	# Switch back to chasing state.
	current_state = State.CHASING
		
