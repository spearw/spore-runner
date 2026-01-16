## slow_status_effect.gd
## A status effect that reduces the target's movement speed.
class_name SlowStatusEffect
extends StatusEffect

# --- Properties ---
@export_range(0.0, 1.0) var slow_percent: float = 0.3  # 30% slow by default

# --- Overridden Functions ---
## Called once when the slow is first applied.
func on_apply(manager: StatusEffectManager, source):
	var host = manager.get_parent()
	if host.has_method("apply_speed_modifier"):
		host.apply_speed_modifier(id, 1.0 - slow_percent)

## Called once when the slow expires.
func on_expire(manager: StatusEffectManager, source):
	var host = manager.get_parent()
	if host.has_method("remove_speed_modifier"):
		host.remove_speed_modifier(id)
