## A weapon that fires a burst of projectiles horizontally.
class_name DaggersWeapon extends Node2D

@export var projectile_scene: PackedScene

# Number of projectiles to fire in a single burst.
@export var burst_count: int = 3
# Delay in seconds between each projectile within a burst.
@export var burst_delay: float = 0.1

@onready var fire_rate_timer: Timer = $FireRateTimer

var fire_right: bool = true

func _ready() -> void:
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)

## Signal handler for the fire rate timer's timeout signal.
## This function now initiates the burst sequence.
## The 'async' keyword allows the use of 'await' inside it.
func _on_fire_rate_timer_timeout() -> void:
	# We call another function to handle the burst to keep code clean.
	fire_burst()

## Asynchronously handles the firing of a burst of projectiles.
func fire_burst() -> void:
	# Guard clause: Do not fire if the projectile scene is not set.
	if not projectile_scene:
		printerr("WhipWeapon: Projectile scene is not set.")
		return
	
	# Loop to fire the specified number of projectiles.
	for i in range(burst_count):
		# Flip direction for every shot.
		fire_right = not fire_right
		var direction = Vector2.RIGHT if fire_right else Vector2.LEFT
		var projectile = projectile_scene.instantiate()
		
		# Set the projectile's direction.
		projectile.direction = direction

		# Add the projectile to the main game world.
		# get_tree().current_scene is a robust way to get the root of the running scene.
		get_tree().current_scene.add_child(projectile)
		
		# Set its starting position.
		projectile.global_position = self.global_position

		# --- The Magic Part ---
		# If this is not the last projectile in the burst, wait.
		if i < burst_count - 1:
			# Create a temporary timer and wait for its 'timeout' signal.
			# The function pauses here for burst_delay seconds.
			await get_tree().create_timer(burst_delay).timeout
