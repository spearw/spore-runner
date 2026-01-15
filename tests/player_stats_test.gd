## player_stats_test.gd
## Tests for Player stat calculations and bonuses.
## Focus: Stat multipliers, bonuses, and powers work correctly.
class_name PlayerStatsTest
extends GdUnitTestSuite


# --- Stat Multiplier Behavior ---

func test_stat_multiplier_defaults_to_one() -> void:
	var player = _create_mock_player()

	var multiplier = player.get_stat_multiplier("damage_increase")

	assert_float(multiplier).is_equal(1.0)


func test_bonus_increases_stat_multiplier() -> void:
	var player = _create_mock_player()

	player.add_bonus("damage_increase", 0.25)

	assert_float(player.get_stat_multiplier("damage_increase")).is_equal(1.25)


func test_multiple_bonuses_stack_additively() -> void:
	var player = _create_mock_player()

	player.add_bonus("damage_increase", 0.25)
	player.add_bonus("damage_increase", 0.15)

	# 1.0 + 0.25 + 0.15 = 1.40
	assert_float(player.get_stat_multiplier("damage_increase")).is_equal(1.40)


func test_firerate_bonus_reduces_cooldown() -> void:
	var player = _create_mock_player()

	player.add_bonus("firerate", 0.20)

	# Firerate subtracts from 1.0: max(0.1, 1.0 - 0.20) = 0.80
	assert_float(player.get_stat_multiplier("firerate")).is_equal(0.80)


func test_firerate_cannot_go_below_minimum() -> void:
	var player = _create_mock_player()

	player.add_bonus("firerate", 2.0)  # Huge bonus

	# Should cap at 0.1, not go negative or zero
	assert_float(player.get_stat_multiplier("firerate")).is_equal(0.1)


# --- Timed Bonus Behavior ---

func test_timed_bonus_affects_stat_immediately() -> void:
	var player = _create_mock_player()

	player.apply_timed_bonus("armor", 10.0, 5.0)

	assert_float(player.timed_bonuses.get("armor", 0.0)).is_equal(10.0)


func test_timed_bonuses_stack() -> void:
	var player = _create_mock_player()

	player.apply_timed_bonus("armor", 5.0, 5.0)
	player.apply_timed_bonus("armor", 3.0, 5.0)

	assert_float(player.timed_bonuses.get("armor", 0.0)).is_equal(8.0)


# --- Power System Behavior ---

func test_power_can_be_unlocked() -> void:
	var player = _create_mock_player()

	player.add_power_level("undaunted", 1)

	assert_bool(player.unlocked_powers.has("undaunted")).is_true()
	assert_int(player.unlocked_powers["undaunted"]).is_equal(1)


func test_power_levels_stack() -> void:
	var player = _create_mock_player()

	player.add_power_level("undaunted", 1)
	player.add_power_level("undaunted", 2)

	assert_int(player.unlocked_powers["undaunted"]).is_equal(3)


# --- Helper Functions ---

func _create_mock_player() -> Node:
	var player_script = load("res://actors/player/player.gd")
	var player = CharacterBody2D.new()
	player.set_script(player_script)

	# Create required child nodes
	var artifacts = Node2D.new()
	artifacts.name = "Artifacts"
	player.add_child(artifacts)

	var proximity = Area2D.new()
	proximity.name = "ProximityDetector"
	player.add_child(proximity)

	var targeting = Node.new()
	targeting.name = "TargetingComponent"
	player.add_child(targeting)

	var fire_behavior = Node.new()
	fire_behavior.name = "FireBehaviorComponent"
	player.add_child(fire_behavior)

	var sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	player.add_child(sprite)

	var stats = load("res://actors/player/characters/edgerunner/edgerunner_character.tres")
	if stats:
		player.stats = stats

	return auto_free(player)
