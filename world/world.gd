## world.gd
## Manages the main game state and scene-level logic.
extends Node2D

# The time in seconds the player must survive to win.
@export var survival_goal_seconds: float = 120.0 

var game_time: float = 0.0
var is_game_over: bool = false

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

## Called once when the node enters the scene tree.
func _ready() -> void:
	# Check if the player instance is valid before connecting.
	if is_instance_valid(player):
		# Connect to the player's 'died' signal.
		player.died.connect(_on_player_died)

func _physics_process(delta: float):
	# Don't advance the timer if the game has ended.
	if is_game_over:
		return
		
	game_time += delta
	
	# Update the HUD with the new time.
	hud.update_time(game_time)
	
	# Check for the win condition.
	if game_time >= survival_goal_seconds:
		win_game()
		
func _on_player_died():
	if is_game_over: return # Prevent this from running twice
	
	is_game_over = true
	print("GAME OVER - YOU LOSE")
	
	# We can create a simple game over screen later.
	# For now, we'll just pause the tree.
	get_tree().paused = true

func win_game():
	if is_game_over: return # Prevent this from running twice
	
	is_game_over = true
	print("VICTORY - YOU SURVIVED!")
	
	# Stop enemies from spawning.
	var spawner = get_node_or_null("EnemySpawner")
	if spawner:
		spawner.set_physics_process(false)
		
	# You could also kill all remaining enemies for a satisfying screen clear.
	# for enemy in get_tree().get_nodes_in_group("enemies"):
	# 	enemy.queue_free()
		
	# We can create a victory screen later.
	# For now, just pause the tree.
	get_tree().paused = true
