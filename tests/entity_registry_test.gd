## entity_registry_test.gd
## Tests for the EntityRegistry singleton.
## Focus: Enemy registration and candidate retrieval work correctly.
class_name EntityRegistryTest
extends GdUnitTestSuite

var _initial_enemies: Array[Node]
var _initial_alive: Array[Node]


func before_test() -> void:
	# Store and clear for isolated testing
	_initial_enemies = EntityRegistry._enemies.duplicate()
	_initial_alive = EntityRegistry._alive_enemies.duplicate()
	EntityRegistry._enemies.clear()
	EntityRegistry._alive_enemies.clear()


func after_test() -> void:
	# Restore original state
	EntityRegistry._enemies = _initial_enemies
	EntityRegistry._alive_enemies = _initial_alive


# --- Registration Behavior ---

func test_registered_enemy_appears_in_candidates() -> void:
	var mock_enemy = _create_mock_enemy()

	EntityRegistry.register_enemy(mock_enemy)

	var candidates = EntityRegistry.get_enemy_candidates()
	assert_bool(candidates.has(mock_enemy)).is_true()


func test_dying_enemy_excluded_from_candidates() -> void:
	var alive_enemy = _create_mock_enemy()
	var dying_enemy = _create_mock_enemy()

	EntityRegistry.register_enemy(alive_enemy)
	EntityRegistry.register_enemy(dying_enemy)
	EntityRegistry.mark_enemy_dying(dying_enemy)

	var candidates = EntityRegistry.get_enemy_candidates()
	assert_bool(candidates.has(alive_enemy)).is_true()
	assert_bool(candidates.has(dying_enemy)).is_false()


func test_alive_count_reflects_registered_enemies() -> void:
	var enemy1 = _create_mock_enemy()
	var enemy2 = _create_mock_enemy()

	EntityRegistry.register_enemy(enemy1)
	EntityRegistry.register_enemy(enemy2)

	assert_int(EntityRegistry.get_alive_enemy_count()).is_equal(2)


# --- Performance (These Matter for Gameplay) ---

func test_handles_200_enemies() -> void:
	for i in 200:
		var enemy = _create_mock_enemy()
		EntityRegistry.register_enemy(enemy)

	assert_int(EntityRegistry.get_enemy_candidates().size()).is_equal(200)


func test_candidate_lookup_under_1ms() -> void:
	for i in 100:
		EntityRegistry.register_enemy(_create_mock_enemy())

	var start_time = Time.get_ticks_usec()
	for i in 1000:
		var _candidates = EntityRegistry.get_enemy_candidates()
	var elapsed = Time.get_ticks_usec() - start_time

	# 1000 lookups should complete in under 1ms (1000 usec)
	assert_int(elapsed).is_less(1000)


# --- Helper Functions ---

func _create_mock_enemy() -> Node2D:
	var enemy = auto_free(Node2D.new())
	enemy.add_to_group("enemy")
	return enemy
