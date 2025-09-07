## explosion.gd
## Deals one-time area damage to enemies within its shape, configured by ProjectileStats.
class_name Explosion
extends Area2D

# --- Configured by ProjectileStats ---
var stats: ProjectileStats
var allegiance: Projectile.Allegiance # Still set by the spawner weapon

@onready var sprite: Sprite2D = $Sprite2D # Assuming you have a Sprite2D child
@onready var collision_shape: CollisionShape2D = $CollisionShape2D # Assuming you have one

func _ready():
	if not stats:
		printerr("Explosion spawned without ProjectileStats resource! Deleting self.")
		queue_free()
		return
	
	# Configure visuals from stats (if applicable)
	if sprite and stats.texture:
		sprite.texture = stats.texture
		sprite.scale = stats.scale
		# Optionally, adjust collision shape size to match sprite dynamically
		# var new_shape = RectangleShape2D.new()
		# new_shape.size = sprite.texture.get_size() * sprite.scale.abs()
		# collision_shape.shape = new_shape
	elif collision_shape and collision_shape.shape == null:
		# Fallback: if no sprite/texture, ensure there's at least a default collision shape.
		# Or, we can ensure the default shape is already defined in the scene.
		pass # For now, assume a CircleShape2D is set in editor.

	# Give the physics engine a frame to register the area's position and shape.
	await get_tree().process_frame
	
	# --- NEW: Configure Physics based on allegiance ---
	if not allegiance in Projectile.Allegiance.values():
		printerr("Explosion spawned without a valid allegiance! Deleting.")
		queue_free()
		return
		
	match allegiance:
		Projectile.Allegiance.PLAYER:
			# I am a player explosion, I should hit enemies.
			self.collision_layer = 1 << 2 # (Player Projectile Layer)
			self.collision_mask = 1 << 1  # (Enemy Body Layer)
		Projectile.Allegiance.ENEMY:
			# I am an enemy explosion, I should hit the player.
			self.collision_layer = 1 << 4 # (Enemy Projectile Layer)
			self.collision_mask = 1 << 0  # (Player Body Layer)

	# Get all overlapping bodies.
	var bodies = get_overlapping_bodies()
	for body in bodies:
		# The collision mask filters for us, but a group check is safer.
		var target_group = "enemies" if allegiance == Projectile.Allegiance.PLAYER else "player"
		if body.is_in_group(target_group) and body.has_method("take_damage"):
			body.take_damage(stats.damage, stats.armor_penetration) # Use damage from stats
			
	# Quick scale animation for visual feedback.
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.4).from(Vector2(1, 1))
	await tween.finished
	queue_free()
