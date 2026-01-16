## surge_protector_artifact.gd
## An artifact that fires sparks when the player is hit.
## With spark upgrades, this can become very powerful!
class_name SurgeProtectorArtifact
extends ArtifactBase

const SPARK_SCENE = preload("res://items/weapons/spark/spark_projectile.tscn")
const BASE_SPARK_COUNT: int = 5

func on_equipped() -> void:
	if not Events.player_was_hit.is_connected(_on_player_was_hit):
		Events.player_was_hit.connect(_on_player_was_hit)

func on_unequipped() -> void:
	if Events.player_was_hit.is_connected(_on_player_was_hit):
		Events.player_was_hit.disconnect(_on_player_was_hit)

## Called when the player is hit by anything (before armor calculation).
func _on_player_was_hit(_source_node: Node) -> void:
	if not is_instance_valid(user):
		return

	# Get spark stats from registry defaults
	var spark_data = WeaponTagRegistry.get_effect_data(WeaponTags.Effect.SPARK, {})
	var spark_damage = spark_data.get("spark_damage", 6)
	var spark_bounces = spark_data.get("spark_bounces", 3)
	var spark_range = spark_data.get("spark_range", 200.0)
	var spark_speed = spark_data.get("spark_speed", 600.0)
	var spark_lifetime = spark_data.get("spark_lifetime", 0.5)

	# Apply player bonuses
	var total_sparks = BASE_SPARK_COUNT
	if user.has_method("get_stat"):
		total_sparks += int(user.get_stat("spark_count_bonus")) if user.get_stat("spark_count_bonus") else 0
		var damage_mult = user.get_stat("spark_damage_bonus") if user.get_stat("spark_damage_bonus") else 1.0
		spark_damage = int(spark_damage * damage_mult)
		spark_bounces += int(user.get_stat("spark_bounce_bonus")) if user.get_stat("spark_bounce_bonus") else 0

	# Find enemies to target
	var candidates = TargetingUtils.get_candidates("enemies")

	# Sort by distance
	if not candidates.is_empty():
		var user_pos = user.global_position
		candidates.sort_custom(func(a, b):
			return user_pos.distance_squared_to(a.global_position) < user_pos.distance_squared_to(b.global_position)
		)

	# Spawn sparks in all directions
	for i in range(total_sparks):
		var target = candidates[i % candidates.size()] if not candidates.is_empty() else null
		_spawn_spark(target, spark_damage, spark_bounces, spark_range, spark_speed, spark_lifetime)

func _spawn_spark(target: Node2D, damage: int, bounces: int, range_val: float, speed: float, lifetime: float):
	var spark = SPARK_SCENE.instantiate()

	spark.allegiance = SparkProjectile.Allegiance.PLAYER
	spark.user = user
	spark.weapon = null
	spark.target = target
	spark.base_damage = damage
	spark.bounce_count = bounces
	spark.bounces_remaining = bounces
	spark.bounce_range = range_val
	spark.speed = speed
	spark.lifetime = lifetime

	spark.global_position = user.global_position

	# Aim at target if we have one, otherwise spread in a circle
	if is_instance_valid(target):
		spark.direction = (target.global_position - user.global_position).normalized()
	else:
		var random_angle = randf() * TAU
		spark.direction = Vector2.from_angle(random_angle)
	spark.rotation = spark.direction.angle()

	user.get_tree().current_scene.add_child(spark)
