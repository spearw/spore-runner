## tend_behavior.gd
## The Cleaner Wrasse's working state: drift to the nearest patient (any enemy that is not our
## own kind) and hold station beside it. This behavior only solves POSITION -- the mending itself
## is MenderAI's aura tick, which runs in every state.
class_name TendBehavior
extends MovementBehavior

## Close enough to park: inside this range the wrasse holds still and lets the aura work.
const HOLD_DISTANCE := 110.0

func process_behavior(_delta: float, host: CharacterBody2D):
	var patient = _find_patient(host)
	if not is_instance_valid(patient):
		host.velocity = Vector2.ZERO
		return
	var to_patient: Vector2 = patient.global_position - host.global_position
	if to_patient.length() <= HOLD_DISTANCE:
		host.velocity = Vector2.ZERO
		return
	host.velocity = to_patient.normalized() * host.get_effective_move_speed()

## Nearest non-wrasse enemy. Nearest (not most-wounded) keeps the movement calm -- the aura heals
## everyone in the ring anyway, and a healer that teleports its attention reads as jittery.
func _find_patient(host: Node) -> Node:
	var my_name: String = host.stats.display_name
	var best: Node = null
	var best_dist := INF
	for enemy in EntityRegistry.get_enemies():
		if not is_instance_valid(enemy) or enemy == host:
			continue
		if enemy.is_dying or enemy.stats.display_name == my_name:
			continue
		var d: float = host.global_position.distance_squared_to(enemy.global_position)
		if d < best_dist:
			best_dist = d
			best = enemy
	return best
