## mender_ai.gd -- the Cleaner Wrasse's brain. Personal space first (flee inside FLEE_RADIUS),
## tending otherwise (TendBehavior parks it beside a patient); the mend aura ticks through either
## state. It mends everything nearby EXCEPT its own kind, and never itself -- so focus fire and
## direct damage stay the clean answers, and two wrasses cannot knot into an unkillable pair.
## Recipients flash the regenerator's green (one visual language for healing), and every heal
## routes through enemy.heal(), where Festering Wounds gets its say.
class_name MenderAI
extends AIController

const FLEE_RADIUS := 250.0
const MEND_RADIUS := 180.0
const MEND_PER_SEC := 6.0
const MEND_INTERVAL := 0.5

var _mend_clock := 0.0

## The aura ring: a quiet green circle so the mend zone is READABLE. Pull a target out of the
## circle and it stops being healed -- the circle is the counterplay's UI.
class MendRing extends Node2D:
	func _draw() -> void:
		draw_arc(Vector2.ZERO, MenderAI.MEND_RADIUS, 0.0, TAU, 48, Color(0.45, 1.0, 0.55, 0.28), 2.0)

func _ready():
	super._ready()
	var ring := MendRing.new()
	ring.z_index = -1
	host.add_child(ring)

func _physics_process(delta):
	var player = host.player_node if "player_node" in host else null
	if is_instance_valid(player) and host.global_position.distance_squared_to(
			player.global_position) < FLEE_RADIUS * FLEE_RADIUS:
		set_state(states["fleebehavior"], {"target": player})
	else:
		set_state(states["tendbehavior"])
	_tick_mend(delta)
	super._physics_process(delta)

func _tick_mend(delta: float) -> void:
	if not is_instance_valid(host) or host.is_dying:
		return
	_mend_clock += delta
	if _mend_clock < MEND_INTERVAL:
		return
	_mend_clock -= MEND_INTERVAL
	var amount := int(round(MEND_PER_SEC * MEND_INTERVAL))
	var my_name: String = host.stats.display_name
	for ally in EntityRegistry.get_enemies():
		if not is_instance_valid(ally) or ally == host or ally.is_dying:
			continue
		if ally.stats.display_name == my_name:
			continue
		if ally.current_health >= ally.stats.max_health:
			continue
		if host.global_position.distance_squared_to(ally.global_position) > MEND_RADIUS * MEND_RADIUS:
			continue
		ally.heal(amount)
		if ally.has_method("flash_heal"):
			ally.flash_heal()
