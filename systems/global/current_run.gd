## current_run.gd
## A Singleton that holds the configuration for the currently active game session.
## This data is NOT saved. It is reset at the start of each run.
extends Node

# The CharacterData resource for the player in this run.
var selected_character: CharacterData = null
