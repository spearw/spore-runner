## entity_registry.gd
## A singleton that maintains cached lists of entities for efficient querying.
## Updates via signals instead of tree queries every frame.
class_name EntityRegistry
extends Node

# --- Cached Entity Lists ---
var _enemies: Array[Node] = []
var _players: Array[Node] = []

# --- Quick Access ---
var player: Node = null  # Single player reference for common case

func _ready() -> void:
	# Connect to enemy lifecycle signals
	Events.enemy_killed.connect(_on_enemy_killed)

	# We'll need to populate initial lists after scene is ready
	call_deferred("_initialize_lists")

func _initialize_lists() -> void:
	# One-time population at game start
	_enemies.assign(get_tree().get_nodes_in_group("enemies"))
	var players = get_tree().get_nodes_in_group("player")
	_players.assign(players)
	if players.size() > 0:
		player = players[0]

## Called when a new enemy spawns. Should be called by the spawner.
func register_enemy(enemy: Node) -> void:
	if enemy not in _enemies:
		_enemies.append(enemy)

## Called when an enemy dies (connected to Events.enemy_killed).
func _on_enemy_killed(enemy_node: Node) -> void:
	_enemies.erase(enemy_node)

## Called when player spawns.
func register_player(player_node: Node) -> void:
	if player_node not in _players:
		_players.append(player_node)
	player = player_node

## Get all enemies (returns cached array - do not modify!)
func get_enemies() -> Array[Node]:
	return _enemies

## Get all players (returns cached array - do not modify!)
func get_players() -> Array[Node]:
	return _players

## Get filtered candidates for targeting (filters out dying entities)
func get_enemy_candidates() -> Array:
	return _enemies.filter(func(e): return is_instance_valid(e) and not e.is_dying)

## Get player candidates
func get_player_candidates() -> Array:
	return _players.filter(func(p): return is_instance_valid(p) and not p.is_dying)

## Get candidates by group name (for compatibility with existing code)
func get_candidates(target_group: String) -> Array:
	match target_group:
		"enemies":
			return get_enemy_candidates()
		"player":
			return get_player_candidates()
		_:
			# Fallback to tree query for unknown groups
			return get_tree().get_nodes_in_group(target_group).filter(
				func(e): return e is CharacterBody2D and not e.get("is_dying")
			)

## Get enemy count (useful for performance checks)
func get_enemy_count() -> int:
	return _enemies.size()
