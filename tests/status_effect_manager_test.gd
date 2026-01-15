## status_effect_manager_test.gd
## Tests for the StatusEffectManager system.
## Focus: Observable behavior only (status tracking, visual effects).
class_name StatusEffectManagerTest
extends GdUnitTestSuite

var manager: StatusEffectManager
var mock_host: Node2D


func before_test() -> void:
	# Create a mock host with AnimatedSprite2D for visual tests
	mock_host = auto_free(Node2D.new())
	var sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	mock_host.add_child(sprite)

	# Create manager as child of host
	manager = auto_free(StatusEffectManager.new())
	mock_host.add_child(manager)
	manager._ready()


func after_test() -> void:
	manager = null
	mock_host = null


# --- Status Application Behavior ---

func test_apply_status_tracks_active_status() -> void:
	var effect = _create_test_effect("test_burn")

	manager.apply_status(effect, null)

	assert_bool(manager.active_statuses.has("test_burn")).is_true()


func test_apply_same_status_refreshes_duration() -> void:
	var effect = _create_test_effect("test_poison", 5.0)

	manager.apply_status(effect, null)
	var first_timer = manager.active_statuses["test_poison"]["timer"]

	# Wait a bit then reapply
	await get_tree().create_timer(0.1).timeout
	manager.apply_status(effect, null)

	# Timer should be refreshed to full duration
	assert_float(first_timer.time_left).is_greater(4.8)


func test_apply_null_status_is_safe() -> void:
	manager.apply_status(null, null)

	assert_int(manager.active_statuses.size()).is_equal(0)


# --- Visual Effects Behavior ---

func test_status_tints_sprite_with_modulate_color() -> void:
	var effect = _create_test_effect("red_effect")
	effect.modulate_color = Color.RED

	manager.apply_status(effect, null)

	var sprite = mock_host.get_node("AnimatedSprite2D")
	assert_object(sprite.modulate).is_equal(Color.RED)


func test_multiple_status_colors_combine() -> void:
	var red_effect = _create_test_effect("red")
	red_effect.modulate_color = Color(1.0, 0.5, 0.5)

	var blue_effect = _create_test_effect("blue")
	blue_effect.modulate_color = Color(0.5, 0.5, 1.0)

	manager.apply_status(red_effect, null)
	manager.apply_status(blue_effect, null)

	# Colors multiply: (1*0.5, 0.5*0.5, 0.5*1) = (0.5, 0.25, 0.5)
	var sprite = mock_host.get_node("AnimatedSprite2D")
	assert_float(sprite.modulate.r).is_equal_approx(0.5, 0.01)
	assert_float(sprite.modulate.g).is_equal_approx(0.25, 0.01)
	assert_float(sprite.modulate.b).is_equal_approx(0.5, 0.01)


# --- Helper Functions ---

func _create_test_effect(id: String, duration: float = 5.0) -> StatusEffect:
	var effect = StatusEffect.new()
	effect.id = id
	effect.duration = duration
	effect.needs_processing = false
	return effect
