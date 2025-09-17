## events.gd
## A global event bus (Singleton) for decoupled communication between game systems.
extends Node

# --- Gameplay Events ---
# Emitted when a treasure chest is collected.
signal boss_reward_requested

# Emitted when enemy hit
# TODO: is this performant?
signal enemy_hit(hit_details: Dictionary)
signal status_applied_to_enemy(enemy_node, status_id)
signal enemy_killed(enemy_node)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Tell GameData to save before the game quits.
		GameData.save_data()
		get_tree().quit() # Manually quit after saving
