## burning_status_effect.gd
## A specialized status effect that deals damage over time and can ignite.
class_name BurningStatusEffect

# --- Properties ---
@export var damage_per_tick: float = 2.0
@export var time_between_ticks: float = 1.0
@export_range(0.0, 1.0) var ignite_chance: float = 0.0
@export var ignited_status_effect: StatusEffect

# --- Runtime variables used by the manager ---
var tick_timer: float = 0.0

# --- Overridden Functions ---
## Called once when Burning is first applied.
func on_apply(manager: StatusEffectManager, source):
	# Apply the first tick of damage immediately.
	_do_damage_tick(manager, source)
	# Reset the tick timer.
	tick_timer = time_between_ticks

## Called every frame.
func on_process(manager: StatusEffectManager, delta: float, source):
	tick_timer -= delta
	if tick_timer <= 0:
		_do_damage_tick(manager, source)
		# Reset the timer for the next tick.
		tick_timer += time_between_ticks

## Helper function to apply damage and check for ignite.
func _do_damage_tick(manager: StatusEffectManager, source):
	var host = manager.get_parent()
	if host.has_method("take_damage"):
		var damage_multiplier = 1.0
		if is_instance_valid(source):
			damage_multiplier = source.get_stat("dot_damage_bonus") # Example stat
		
		host.take_damage(damage_per_tick * damage_multiplier, null, false)
		
		# Handle Ignite chance.
		var ignite_chance_mult = 1.0
		if is_instance_valid(source):
			ignite_chance_mult = source.get_stat("ignite_chance_bonus")

		if ignite_chance > 0 and randf() < (ignite_chance * ignite_chance_mult):
			if ignited_status_effect:
				manager.apply_status(ignited_status_effect, source)
