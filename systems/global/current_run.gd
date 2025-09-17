## current_run.gd
## A Singleton that holds the configuration for the currently active game session.
## This data is NOT saved. It is reset at the start of each run.
extends Node

# The PlayerStats resource for the player in this run.
var selected_character: PlayerStats = null

# The list of resource paths for the packs chosen for this specific run.
var selected_pack_paths: Array[String] = []
