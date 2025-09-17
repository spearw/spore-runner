## stop_and_shoot_behavior.gd
## A behavior where the enemy chases, stops at a range, fires, and repeats.
class_name MoveAndShootBehavior
extends EnemyBehavior

enum State { CHASING, SHOOTING }
var current_state: State = State.CHASING
var host_enemy: Enemy

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
	if not is_instance_valid(host_enemy):
		host_enemy = host as Enemy
	
	match current_state:
		State.CHASING:
			var distance_to_player = host_enemy.global_position.distance_to(host_enemy.player_node.global_position)
			
			if distance_to_player <= shooting_range:
				# We are in range. Stop and switch to shooting state.
				host_enemy.velocity = Vector2.ZERO
				current_state = State.SHOOTING
				fire_rate_timer.start()
			else:
				# Not in range yet, continue chasing.
				var direction = (host_enemy.player_node.global_position - host_enemy.global_position).normalized()
				host_enemy.velocity = direction * host_enemy.stats.move_speed
		
		State.SHOOTING:
			# Do nothing while waiting for the timer to fire.
			host_enemy.velocity = Vector2.ZERO

func _on_firerate_timer_timeout():
	host_enemy
	if not is_instance_valid(host_enemy): return
	
	# Play fire animation, if it has one
	# TODO: read do this once we have enemies that need this behavior and move eel out of here.
	#if host.has_method("play_one_shot_animation"):
		#if host.animation_player.has_animation("fire"):
			#host.play_one_shot_animation("fire")
	# Tell the host to fire whatever weapons it has.
	if host_enemy.has_method("fire_weapons"):
		host_enemy.fire_weapons()
	
	# Switch back to chasing state.
	current_state = State.CHASING
		
