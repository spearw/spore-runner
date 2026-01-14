## entity_registry.gd
## A singleton that maintains cached lists of entities for efficient querying.
## Updates via signals instead of tree queries every frame.
## Note: No class_name needed - accessed as autoload "EntityRegistry"
extends Node

# --- Cached Entity Lists ---
var _enemies: Array[Node] = []
var _alive_enemies: Array[Node] = []  # Pre-filtered list of non-dying enemies
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
	_alive_enemies.assign(_enemies.filter(func(e): return is_instance_valid(e) and not e.is_dying))
	var players = get_tree().get_nodes_in_group("player")
	_players.assign(players)
	if players.size() > 0:
		player = players[0]

## Called when a new enemy spawns. Should be called by the spawner.
func register_enemy(enemy: Node) -> void:
	if enemy not in _enemies:
		_enemies.append(enemy)
		_alive_enemies.append(enemy)

## Called when an enemy starts dying (remove from alive list immediately).
## Call this when enemy.is_dying is set to true.
func mark_enemy_dying(enemy_node: Node) -> void:
	_alive_enemies.erase(enemy_node)

## Called when an enemy dies (connected to Events.enemy_killed).
func _on_enemy_killed(enemy_node: Node) -> void:
	_enemies.erase(enemy_node)
	_alive_enemies.erase(enemy_node)  # Redundant if mark_enemy_dying was called, but safe

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

## Get filtered candidates for targeting (returns pre-filtered alive list)
func get_enemy_candidates() -> Array[Node]:
	return _alive_enemies

## Get player candidates
func get_player_candidates() -> Array:
	return _players.filter(func(p): return is_instance_valid(p) and not p.get("is_dying"))

## Get candidates by group name (for compatibility with existing code)
func get_candidates(target_group: String) -> Array:
	match target_group:
		"enemies":
			return _alive_enemies
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

## Get alive enemy count
func get_alive_enemy_count() -> int:
	return _alive_enemies.size()
