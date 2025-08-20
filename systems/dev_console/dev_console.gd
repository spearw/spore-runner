## dev_console.gd
## A node that provides developer/debug functionality.
## This should be removed or disabled in a release build.
extends Node

# Amount of experience to grant with the dev key.
@export var xp_grant_amount: int = 100

# A cached reference to the player node.
var player: Node = null

## Called when the node enters the scene tree.
func _ready() -> void:
	# Wait until the first frame is processed to ensure the player exists.
	await get_tree().process_frame
	
	# Find the player node once and store the reference.
	player = get_tree().get_first_node_in_group("player")

## Called every frame. Used here to check for unhandled input events.
## The '_unhandled_input' function is a special Godot function that receives
## input events that have not been consumed by the UI or other nodes.
## This is the ideal place for global, non-player-specific key presses.
func _unhandled_input(event: InputEvent) -> void:
	# Guard clause: Do nothing if the player reference is not valid.
	if not is_instance_valid(player):
		return

	# Check if the "dev_add_xp" action was just pressed.
	if event.is_action_pressed("dev_add_xp"):
		print("DEV: Granting %s XP." % xp_grant_amount)
		player.add_experience(xp_grant_amount)
		# Mark the event as handled so other nodes don't process it.
		get_viewport().set_input_as_handled()

	# Check if the "dev_force_levelup" action was just pressed.
	if event.is_action_pressed("dev_force_levelup"):
		print("DEV: Forcing level up.")
		# We can cheat by giving the player exactly enough XP to level up.
		var xp_needed = player.experience_to_next_level - player.current_experience
		player.add_experience(xp_needed)
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("dev_kill_all"):
		print("DEV: Killing all enemies.")
		# Get an array of all nodes currently in the "enemies" group.
		var all_enemies = get_tree().get_nodes_in_group("enemies")
		
		# Loop through the array and call the die() method on each one.
		for enemy in all_enemies:
			# Check if the enemy is valid and has the die method before calling.
			if is_instance_valid(enemy) and enemy.has_method("die"):
				enemy.die()
				
		get_viewport().set_input_as_handled()
