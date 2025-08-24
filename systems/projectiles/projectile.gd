## projectile.gd
## A generic projectile. Its behavior is configured by a ProjectileStats resource.
class_name Projectile
extends Area2D

# --- Allegiance ---
# This determines who the projectile belongs to and who it should hit.
enum Allegiance { PLAYER, ENEMY, NONE }
var allegiance: Allegiance

# --- Public Properties ---
var stats: ProjectileStats
var direction: Vector2 = Vector2.RIGHT

# --- Node References ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready():
	# This function is called AFTER the spawner has set properties.
	# Guard clause: If stats are missing, this projectile can't function.
	if not stats:
		printerr("Projectile spawned without stats! Deleting.")
		queue_free()
		return
	if not allegiance in Projectile.Allegiance.values():
		printerr("Projectile spawned without a valid allegiance! Deleting.")
		queue_free()
		return

	# Configure visuals from stats.
	sprite.texture = stats.texture
	sprite.scale = stats.scale
	generate_hitbox_from_sprite()
	
	# Configure physics based on allegiance.
	match allegiance:
		Allegiance.PLAYER:
			# I am a player projectile, I should hit enemies.
			self.collision_layer = 1 << 2 # Set layer to 'player_projectile' (layer 3)
			self.collision_mask = 1 << 1  # Set mask to scan for 'enemy_body' (layer 2)
		Allegiance.ENEMY:
			# I am an enemy projectile, I should hit the player.
			self.collision_layer = 1 << 4 # Set layer to 'enemy_projectile' (layer 5)
			self.collision_mask = 1 << 0  # Set mask to scan for 'player_body' (layer 1)
	
	if stats.is_aoe:
		# This is an explosion, run the AoE logic.
		_execute_aoe()
	else:
		# This is a normal moving projectile.
		_intialize_as_bullet()
	
func _intialize_as_bullet():
	# Configure lifetime.
	if stats.lifetime > 0:
		lifetime_timer.wait_time = stats.lifetime
		lifetime_timer.one_shot = true
		lifetime_timer.timeout.connect(queue_free) # Delete self when timer ends
		lifetime_timer.start()

	# Connect the damage signal.
	self.body_entered.connect(_on_body_entered)
	
func _execute_aoe():
	
	await get_tree().process_frame # Wait for physics server
	
	var bodies = get_overlapping_bodies()

	# Play the visual effect
	sprite.texture = stats.aoe_effect_sprite
	sprite.scale = stats.aoe_effect_scale
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, stats.aoe_effect_duration)
	
	await tween.finished
	queue_free()
	
	
## Generates and assigns a collision shape based on the sprite's current texture and scale.
func generate_hitbox_from_sprite():
	# Wait for one frame to ensure the sprite's texture has been fully loaded and sized.
	await get_tree().process_frame
	
	if not sprite.texture:
		printerr("Cannot generate hitbox: sprite has no texture.")
		return

	# Create a new rectangle shape resource.
	var new_shape = RectangleShape2D.new()
	
	# Set the rectangle's size. Get the texture's size and multiply by the sprite's scale.
	new_shape.size = sprite.texture.get_size() * sprite.scale.abs()
	
	# Assign the newly created and sized shape to our CollisionShape2D node.
	collision_shape.shape = new_shape

func _process(delta: float):
	global_position += direction * stats.speed * delta

func _on_body_entered(body: Node2D):
	# The physics layers have already guaranteed we hit a valid target.
	if body.has_method("take_damage"):
		body.take_damage(stats.damage)
	
	queue_free()
