## shoot_behavior.gd
## A simple behavior that stops the host and fires its weapons.
class_name ShootBehavior
extends EnemyBehavior

# We use a timer to prevent firing every single frame.
@onready var fire_timer: Timer = Timer.new()

func _ready():
	add_child(fire_timer)
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)

### This is called by the AI when this state becomes active.
func on_enter(host: Node, context: Dictionary = {}):
	super.on_enter(host, context)
	if is_instance_valid(host_anim_controller):
		host_anim_controller.play_loop("idle")
	fire_timer.start(host_enemy.stats.firerate)
	
func on_exit():
	# On exit, play stop_idle and stop firing.
	fire_timer.stop()
	if is_instance_valid(host_anim_controller):
		host_anim_controller.play_exit_and_loop("stop_idle", "move")

func process_behavior(delta: float, host: CharacterBody2D):
	# The only job of this behavior is to stand still.
	if not is_instance_valid(host_enemy):
		host_enemy = host as Enemy
	host.velocity = Vector2.ZERO

func _fire():
	if is_instance_valid(host_enemy) and host_enemy.has_method("fire_weapons"):
		host_enemy.fire_weapons()
	fire_timer.start(host_enemy.stats.firerate)

func _on_fire_timer_timeout():
	# When the cooldown is done, try to fire again.
	_fire()
