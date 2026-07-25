## festering_verify.gd -- headless proof of Festering Wounds (Venom artifact) in the booted world:
##   1. Without the artifact, heals land whole.
##   2. With it, each poison stack eats 20% of a heal; five stacks eat all of it.
##   3. Plain regeneration still works with the artifact held (no stacks = no suppression),
##      and a max-stacked regenerator cannot heal at all.
##   4. The wrasse's mending is suppressed through the same choke point, live: a poisoned patient
##      stays down while an unpoisoned one in the same ring mends.
##   5. The card sits in the Venom deck at EPIC, and its tooltip defines Poison.
## Run: Godot --headless --path . res://festering_verify.tscn
extends Node

var is_probe := false
var _booted := false
var _boot_frames := 0

const WRASSE := "res://actors/enemies/normal_enemy_types/cleaner_wrasse/cleaner_wrasse.tres"
const FISH := "res://actors/enemies/normal_enemy_types/fish/fish.tres"
const SEA_STAR := "res://actors/enemies/normal_enemy_types/sea_star/sea_star.tres"
const POISON := "res://systems/status_effects/poison/poison_status_effect.tres"
const Glossary := preload("res://systems/global/glossary.gd")

func _ready() -> void:
	if is_probe:
		process_mode = Node.PROCESS_MODE_ALWAYS
		return
	CurrentRun.reset_run_state()
	CurrentRun.selected_character = load("res://actors/player/characters/test_character/test_character.tres")
	CurrentRun.selected_biome = load("res://systems/spawner/biomes/reef_biome.tres")
	CurrentRun.selected_pack_paths = []
	var probe = load("res://festering_verify.gd").new()
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
		print("FESTER ERROR: world never became ready")
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
	var far: Vector2 = player.global_position + Vector2.RIGHT * 600.0

	# --- 1. Baseline: no artifact, the heal lands whole ---
	var fish = director.spawn_enemy(load(FISH), far)
	await get_tree().physics_frame
	fish.set_physics_process(false)
	var fish_ai = fish.get_node_or_null("AI")
	if fish_ai:
		fish_ai.set_physics_process(false)
	fish.current_health = 10
	fish.heal(10)
	var base_ok: bool = fish.current_health == 20

	# --- 2. Stacks scale the suppression: 2 stacks eat 40%, 5 eat everything ---
	var artifact = load("res://items/artifacts/venom/festering_wounds/festering_wounds.tscn").instantiate()
	player.artifacts_node.add_child(artifact)
	var stat_ok: bool = absf(player.get_stat("fester_per_stack") - 0.2) < 0.001
	var poison: StatusEffect = load(POISON)
	var manager = fish.get_node("StatusEffectManager")
	manager.apply_status(poison, player)
	manager.apply_status(poison, player)
	fish.current_health = 10
	fish.heal(10)
	var two_ok: bool = fish.current_health == 16
	for i in range(3):
		manager.apply_status(poison, player)
	fish.current_health = 10
	fish.heal(10)
	var five_ok: bool = fish.current_health == 10
	print("FESTER stacks: base=%s stat=%s two=%s five=%s" % [
		str(base_ok), str(stat_ok), str(two_ok), str(five_ok)])

	# --- 3. Regeneration: clean star still heals; a max-stacked star cannot ---
	var star = director.spawn_enemy(load(SEA_STAR), far + Vector2.DOWN * 150.0)
	await get_tree().physics_frame
	star.current_health = int(star.stats.max_health * 0.5)
	var s0: int = star.current_health
	for i in range(75):  # ~1.25s of regen with the artifact held but no stacks
		await get_tree().physics_frame
	var clean_regen_ok: bool = star.current_health > s0
	var star_manager = star.get_node("StatusEffectManager")
	for i in range(5):
		star_manager.apply_status(poison, player)
	star.current_health = int(star.stats.max_health * 0.5)
	star.heal(10)
	var walled_star_ok: bool = star.current_health == int(star.stats.max_health * 0.5)
	print("FESTER regen: clean_heals=%s stacked_cannot=%s" % [
		str(clean_regen_ok), str(walled_star_ok)])

	# --- 4. The mend, live: the poisoned patient stays down, the clean one mends ---
	var deep: Vector2 = player.global_position + Vector2.RIGHT * 750.0
	var wrasse = director.spawn_enemy(load(WRASSE), deep)
	var sick = director.spawn_enemy(load(FISH), deep + Vector2.RIGHT * 90.0)
	var clean = director.spawn_enemy(load(FISH), deep + Vector2.DOWN * 90.0)
	await get_tree().physics_frame
	for pinned in [sick, clean]:
		pinned.set_physics_process(false)
		var pinned_ai = pinned.get_node_or_null("AI")
		if pinned_ai:
			pinned_ai.set_physics_process(false)
	var sick_manager = sick.get_node("StatusEffectManager")
	for i in range(5):
		sick_manager.apply_status(poison, player)
	sick.current_health = int(sick.stats.max_health * 0.4)
	clean.current_health = int(clean.stats.max_health * 0.4)
	var sick0: int = sick.current_health
	var clean0: int = clean.current_health
	for i in range(100):  # ~1.67s: three aura ticks
		await get_tree().physics_frame
	var mend_suppressed_ok: bool = sick.current_health <= sick0
	var mend_clean_ok: bool = clean.current_health - clean0 >= 6
	print("FESTER mend: sick %d->%d suppressed=%s clean +%d ok=%s" % [
		sick0, sick.current_health, str(mend_suppressed_ok),
		clean.current_health - clean0, str(mend_clean_ok)])

	# --- 5. The card in the deck ---
	var deck: Deck = load("res://systems/upgrades/packs/toxin_pack.tres")
	var card: Upgrade = null
	for upgrade in deck.upgrades:
		if upgrade != null and upgrade.id == "festering_wounds_unlock":
			card = upgrade
	var deck_ok: bool = card != null and card.rarity == Upgrade.Rarity.EPIC \
		and card.type == Upgrade.UpgradeType.UNLOCK_ARTIFACT
	var tooltip_ok: bool = card != null and Glossary.tooltip_for(card.description).contains("Poison:")
	print("FESTER card: in_deck=%s tooltip=%s" % [str(deck_ok), str(tooltip_ok)])

	var pass_all: bool = base_ok and stat_ok and two_ok and five_ok and clean_regen_ok \
		and walled_star_ok and mend_suppressed_ok and mend_clean_ok and deck_ok and tooltip_ok
	print("FESTER RESULT=%s" % ("PASS" if pass_all else "FAIL"))
	get_tree().quit()
