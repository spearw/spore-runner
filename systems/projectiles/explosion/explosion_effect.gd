## explosion_effect.gd
## A specialized projectile that creates an instant Area of Effect.
extends Projectile

func _ready():
	if not stats: queue_free(); return
	sprite.texture = stats.texture
	sprite.scale = stats.scale
	generate_hitbox_from_sprite()
	_configure_collision_mask()
	_calculate_stats()

	_execute_aoe()

## Execute AoE
func _execute_aoe():
	
	var explosion_data: ExplosionStats = stats as ExplosionStats
	if not explosion_data:
		printerr("ExplosionEffect requires an ExplosionStats resource!")
		queue_free()
		return
	
	# Wait one process_frame for hitbox to be registered.
	await get_tree().process_frame
	# Wait one physics_frame for overlapping bodies list to be populated.
	await get_tree().physics_frame
	
	var bodies = area2d.get_overlapping_bodies()
	for body in bodies:
		var target_group = "enemies" if allegiance == Allegiance.PLAYER else "player"
		if body.is_in_group(target_group) and body.has_method("take_damage"):
			_deal_damage(body)
		if stats.status_to_apply and body.has_node("StatusEffectManager"):
			if randf() < stats.status_chance:
				_apply_status(body)
		if stats.knockback_force > 0 and body.has_method("apply_knockback"):
			body.apply_knockback(stats.knockback_force, self.global_position)
			
	
	# Play visual effect.
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4) # Simple fade out
	await tween.finished
	queue_free()

## Collision setup.
func _configure_collision_mask():
	if allegiance == Allegiance.PLAYER:
		area2d.collision_mask = 1 << 1 # enemy_body
	else:
		area2d.collision_mask = 1 << 0 # player_body
