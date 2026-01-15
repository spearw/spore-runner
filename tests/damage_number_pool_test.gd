## damage_number_pool_test.gd
## Tests for the DamageNumberPool singleton.
## Focus: Pool provides valid, reusable damage numbers with correct display.
class_name DamageNumberPoolTest
extends GdUnitTestSuite


func before_test() -> void:
	# Clear pool before each test for isolation
	DamageNumberPool._pool.clear()


# --- Core Pool Behavior ---

func test_get_damage_number_returns_valid_label() -> void:
	var damage_num = DamageNumberPool.get_damage_number()

	assert_object(damage_num).is_not_null()
	assert_bool(damage_num is Label).is_true()

	damage_num.queue_free()


func test_pool_reuses_returned_instances() -> void:
	var original = DamageNumberPool.get_damage_number()
	DamageNumberPool.return_damage_number(original)

	var reused = DamageNumberPool.get_damage_number()

	assert_object(reused).is_same(original)

	reused.queue_free()


func test_returned_numbers_are_hidden() -> void:
	var damage_num = DamageNumberPool.get_damage_number()
	damage_num.visible = true

	DamageNumberPool.return_damage_number(damage_num)

	assert_bool(damage_num.visible).is_false()


func test_returned_numbers_reset_alpha() -> void:
	var damage_num = DamageNumberPool.get_damage_number()
	damage_num.modulate.a = 0.0

	DamageNumberPool.return_damage_number(damage_num)

	assert_float(damage_num.modulate.a).is_equal(1.0)


# --- Damage Number Display ---

func test_start_displays_damage_amount() -> void:
	var damage_num = DamageNumberPool.get_damage_number()
	add_child(damage_num)

	damage_num.start(50, Vector2(100, 100), false)

	assert_str(damage_num.text).is_equal("50")

	damage_num.queue_free()


func test_crit_damage_shows_exclamation() -> void:
	var damage_num = DamageNumberPool.get_damage_number()
	add_child(damage_num)

	damage_num.start(100, Vector2.ZERO, true)

	assert_str(damage_num.text).is_equal("100!")

	damage_num.queue_free()
