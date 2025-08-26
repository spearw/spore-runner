## events.gd
## A global event bus (Singleton) for decoupled communication between game systems.
extends Node

# --- Gameplay Events ---
# Emitted when a treasure chest is collected.
signal boss_reward_requested
