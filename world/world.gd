## world.gd
## Manages the main game state and scene-level logic.
extends Node2D

# We need a reference to the player to connect to its signals.
@onready var player: CharacterBody2D = $Player

## Called once when the node enters the scene tree.
func _ready() -> void:
	# Check if the player instance is valid before connecting.
	if is_instance_valid(player):
		# Connect to the player's 'died' signal.
		player.died.connect(_on_player_died)

## Signal handler for when the player's 'died' signal is emitted.
func _on_player_died() -> void:
	print("GAME OVER")
	# get_tree().paused stops all process functions, effectively pausing the game.
	get_tree().paused = true
	# In the future, we would show a Game Over screen here.
