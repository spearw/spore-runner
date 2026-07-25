## mender_verify.gd -- headless proof of the Cleaner Wrasse (the mender elite) in the booted world:
##   1. Wiring: the world's director carries reef_menders at 6:30, and the book inherits it.
##   2. The aura mends a wounded neighbor at ~6 HP/s, through heal() (the festering choke point).
##   3. It never mends itself, never mends its own kind, never reaches beyond the ring.
##   4. It tends when the player is far and flees, away from the player, when crowded.
## Run: Godot --headless --path . res://mender_verify.tscn
extends Node

var is_probe := false
var _booted := false
var _boot_frames := 0

const WRASSE := "res://actors/enemies/normal_enemy_types/cleaner_wrasse/cleaner_wrasse.tres"
const FISH := "res://actors/enemies/normal_enemy_types/fish/fish.tres"

func _ready() -> void:
	if is_probe:
		process_mode = Node.PROCESS_MODE_ALWAYS
		return
	CurrentRun.reset_run_state()
	CurrentRun.selected_character = load("res://actors/player/characters/test_character/test_character.tres")
	CurrentRun.selected_biome = load("res://systems/spawner/biomes/reef_biome.tres")
	CurrentRun.selected_pack_paths = []
	var probe = load("res://mender_verify.gd").new()
	probe.is_probe = true
	get_tree().root.add_child.call_deferred(probe)
	get_tree().change_scene_to_file.call_deferred("res://world/world.tscn")

func _process(_dt: float) -> void:
	if not is_probe:
		return
	get_tree().paused = false
	if _booted:
		return
	_boot_frames += 1
	if _boot_frames > 1500:
		print("MENDER ERROR: world never became ready")
		get_tree().quit()
		return
	var player = get_tree().get_first_node_in_group("player")
	var scene := get_tree().current_scene
	if not is_instance_valid(player) or scene == null:
		return
	var director = scene.find_child("EncounterDirector", true, false)
	if director == null or not is_instance_valid(director.player_node):
		return
	_booted = true
	_run(director, player)

func _run(director, player) -> void:
	director.spawn_pulse_timer.stop()

	# --- 1. Wiring: the set is in the world and the book inherits it ---
	var set_ok := false
	for encounter_set in director.encounter_sets:
		for stats in encounter_set.enemies:
			if stats.display_name == "Cleaner Wrasse" and encounter_set.time_start == 390:
				set_ok = true
	var book: BestiaryList = load("res://systems/global/lists/master_bestiary_list.tres")
	var book_ok := false
	for entry in book.swarm_entries():
		if entry["stats"].display_name == "Cleaner Wrasse" and entry["from_time"] == 390:
			book_ok = true
	print("MENDER wiring: set=%s book=%s" % [str(set_ok), str(book_ok)])

	# --- 2 + 3. The aura: a wounded neighbor mends; self, kin and the far do not ---
	# Patients are PINNED (physics off) so the geometry holds still; the wrasse keeps its brain.
	var far: Vector2 = player.global_position + Vector2.RIGHT * 600.0
	var wrasse = director.spawn_enemy(load(WRASSE), far)
	var patient = director.spawn_enemy(load(FISH), far + Vector2.RIGHT * 100.0)
	var kin = director.spawn_enemy(load(WRASSE), far + Vector2.DOWN * 100.0)
	var beyond = director.spawn_enemy(load(FISH), far + Vector2.DOWN * 400.0)
	await get_tree().physics_frame
	for pinned in [patient, kin, beyond]:
		pinned.set_physics_process(false)
		var pinned_ai = pinned.get_node_or_null("AI")
		if pinned_ai:
			pinned_ai.set_physics_process(false)
	patient.current_health = int(patient.stats.max_health * 0.4)
	kin.current_health = int(kin.stats.max_health * 0.4)
	beyond.current_health = int(beyond.stats.max_health * 0.4)
	wrasse.current_health = int(wrasse.stats.max_health * 0.4)
	var p0: int = patient.current_health
	var k0: int = kin.current_health
	var b0: int = beyond.current_health
	var w0: int = wrasse.current_health
	for i in range(100):  # ~1.67s at 60fps -> three 0.5s aura ticks of 3 HP
		await get_tree().physics_frame
	var healed: int = patient.current_health - p0
	var aura_ok: bool = healed >= 6
	var self_ok: bool = wrasse.current_health == w0
	var kin_ok: bool = kin.current_health == k0
	var range_ok: bool = beyond.current_health == b0
	print("MENDER aura: patient+%d ok=%s self=%s kin=%s range=%s" % [
		healed, str(aura_ok), str(self_ok), str(kin_ok), str(range_ok)])

	# --- 4. Tend far from the player; flee, away, when crowded ---
	var tend_ok: bool = is_instance_valid(wrasse.ai.current_state) \
		and wrasse.ai.current_state.name == "TendBehavior"
	var runner = director.spawn_enemy(load(WRASSE), player.global_position + Vector2.RIGHT * 150.0)
	await get_tree().physics_frame
	for i in range(20):
		await get_tree().physics_frame
	var away: Vector2 = runner.global_position - player.global_position
	var flee_ok: bool = is_instance_valid(runner.ai.current_state) \
		and runner.ai.current_state.name == "FleeBehavior" \
		and runner.velocity.dot(away) > 0.0
	print("MENDER states: tend=%s flee=%s" % [str(tend_ok), str(flee_ok)])

	var pass_all: bool = set_ok and book_ok and aura_ok and self_ok and kin_ok \
		and range_ok and tend_ok and flee_ok
	print("MENDER RESULT=%s" % ("PASS" if pass_all else "FAIL"))
	get_tree().quit()
