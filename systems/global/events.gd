## events.gd
## A global event bus (Singleton) for decoupled communication between game systems.
extends Node

# --- Gameplay Events ---
# Emitted when a treasure chest is collected.
signal boss_reward_requested

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Tell GameData to save before the game quits.
		GameData.save_data()
		get_tree().quit() # Manually quit after saving
