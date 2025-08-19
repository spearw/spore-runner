## EnemySpawner.gd
## Manages the spawning of enemy entities into the game world.
## It spawns enemies in a circular radius around the player's current position.
extends Node

# The enemy scene to be instantiated. This is set from the editor.
@export var enemy_scene: PackedScene

# The radius in pixels from the player at which enemies will spawn.
@export var spawn_radius: float = 450.0

# A reference to the player node.
var player_node: Node2D

# A reference to the Timer child node for easy access.
@onready var timer: Timer = $Timer

## Called once when the node enters the scene tree.
func _ready() -> void:
	# Validate that an enemy scene has been assigned in the editor.
	if not enemy_scene:
		printerr("EnemySpawner: enemy_scene is not set. Spawning is disabled.")
		# Disable the spawner process if the scene is not set.
		set_process(false)
		return

	# Acquire the player reference via its group.
	player_node = get_tree().get_first_node_in_group("player")

## Spawns a single enemy instance at a random location around the player.
func spawn_enemy() -> void:
	# Guard clause: Do not attempt to spawn if the player node is not valid.
	if not is_instance_valid(player_node):
		return

	# Instantiate the provided enemy scene.
	var enemy_instance = enemy_scene.instantiate()

	# Determine a random spawn position.
	var random_angle = randf_range(0, TAU) # TAU is 2 * PI
	var spawn_offset = Vector2.RIGHT.rotated(random_angle) * spawn_radius
	var spawn_position = player_node.global_position + spawn_offset

	# Set the enemy's global position.
	enemy_instance.global_position = spawn_position

	# Add the new enemy to the main scene tree.
	# get_parent() refers to the 'World' node.
	get_parent().add_child(enemy_instance)
