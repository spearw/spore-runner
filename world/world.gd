## world.gd
## Manages the main game state and scene-level logic.
extends Node2D

# The time in seconds the player must survive to win.
@export var survival_goal_seconds: float = 300.0 
var game_time: float = 0.0
var is_game_over: bool = false

# Player references
@export var player_scene: PackedScene
@onready var player: CharacterBody2D = null

# Game references.
@onready var upgrade_manager: Node = $UpgradeManager
@onready var spawner: Node = $EncounterDirector
@onready var level_up_ui: CanvasLayer = $LevelUpUI

# Hud
@onready var hud: CanvasLayer = $HUD

## Called once when the node enters the scene tree.
func _ready() -> void:
	# Check if a character was selected for the current run.
	if CurrentRun.selected_character:
		# Instance our generic player scene.
		player = player_scene.instantiate()
		# Add player to scene tree
		add_child(player)
		# Init spawner.
		spawner.player_node = player
		# Init level up logic.
		level_up_ui.player_node = player
		level_up_ui.player_node.leveled_up.connect(level_up_ui.on_player_leveled_up)
		# Init stats.
		player.initialize_character(CurrentRun.selected_character, upgrade_manager)
		
		player.died.connect(_on_player_died)
	else:
		# Failsafe in case we somehow get here without selecting a character.
		printerr("World: No character selected in CurrentRun! Returning to main menu.")
		get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")
		return

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
	spawner.set_physics_process(false)
		
	# You could also kill all remaining enemies for a satisfying screen clear.
	# for enemy in get_tree().get_nodes_in_group("enemies"):
	# 	enemy.queue_free()
		
	# We can create a victory screen later.
	# For now, just pause the tree.
	#get_tree().paused = true
	
