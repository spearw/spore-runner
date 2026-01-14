## projectile.gd
## A generic projectile. Its behavior is configured by a ProjectileStats resource.
class_name Projectile
extends Node2D

# --- Allegiance ---
enum Allegiance { PLAYER, ENEMY, NONE }
var allegiance: Allegiance

# --- Public Properties ---
var stats: ProjectileStats
var direction: Vector2 = Vector2.RIGHT
var pierce_count: int = 0
var weapon: Node2D
var user: Node2D
var has_redirected: bool = false

# --- Calculated Values ---
var damage: float = 0.0
var critical_hit_rate: float = 0.0
var critical_hit_damage: float = 0.0
var speed: float = 0.0
var knockback: float = 0.0
var target: Node2D = null
var proximity_detector: Area2D
var status_chance = 0.0

# --- Pooling Support ---
var _is_pooled: bool = false  # Track if this projectile came from pool
var _signals_connected: bool = false  # Track signal state for pooling

# --- Node References ---
@onready var sprite: Sprite2D = $Area2D/Sprite2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var area2d: Area2D = $Area2D

func _ready():
	# For pooled projectiles, initialization happens in activate()
	if _is_pooled:
		return

	_initialize()

## Activate a pooled projectile (called instead of _ready for reused projectiles)
func activate():
	_is_pooled = true
	_initialize()

func _initialize():
	# Guard clause: If stats are missing, this projectile can't function.
	if not stats:
		printerr("Projectile spawned without stats! Deleting.")
		_destroy()
		return
	if not allegiance in Projectile.Allegiance.values():
		printerr("Projectile spawned without a valid allegiance! Deleting.")
		_destroy()
		return

	_calculate_stats()
	pierce_count = stats.pierce + 1 if stats.pierce != -1 else -1

	# Configure visuals from stats.
	sprite.texture = stats.texture
	sprite.scale = stats.scale
	generate_hitbox_from_sprite()

	# Configure physics based on allegiance (using CollisionUtils).
	CollisionUtils.set_projectile_collision(self.area2d, allegiance)

	# This is a normal moving projectile.
	_intialize_as_bullet()
	# Check if it's a retargeting projectile
	if stats.can_retarget:
		# We connect to the global signal that announces any enemy's death.
		Events.enemy_killed.connect(_on_any_enemy_killed)
	# Check if it's a phasing projectile
	if stats.is_phasing:
		_apply_phasing()

func _intialize_as_bullet():
	# Configure lifetime.
	if stats.lifetime > 0:
		lifetime_timer.wait_time = stats.lifetime
		lifetime_timer.one_shot = true
		# Only connect if not already connected (for pooled projectiles)
		if not lifetime_timer.timeout.is_connected(_destroy):
			lifetime_timer.timeout.connect(_destroy)
		lifetime_timer.start()

	# Connect the damage signal (only if not already connected).
	if not _signals_connected:
		self.area2d.body_entered.connect(_on_body_entered)
		_signals_connected = true

## Generates and assigns a collision shape based on the sprite's current texture and scale.
func generate_hitbox_from_sprite():

	# If user is player and the projectile is scaling, apply stat bonuses.
	var size_multiplier = 1
	if stats.is_scaling and user.is_in_group("player"):
		size_multiplier *= user.get_stat("area_size")

	if not sprite.texture:
		printerr("Cannot generate hitbox: sprite has no texture.")
		return

	# Create a new rectangle shape resource.
	var new_shape = RectangleShape2D.new()

	# Set the rectangle's size. Get the texture's size and multiply by the sprite's scale.
	sprite.scale = sprite.scale.abs() * size_multiplier
	new_shape.size = sprite.texture.get_size() * sprite.scale.abs()


	# Assign the newly created and sized shape to our CollisionShape2D node.
	collision_shape.shape = new_shape
	collision_shape.position = sprite.position

func _process(delta: float):
	if stats.homing_strength > 0 and is_instance_valid(target):
		var direction_to_target = (target.global_position - self.global_position).normalized()
		# Rotate the current direction towards the target direction.
		direction = direction.lerp(direction_to_target, stats.homing_strength * delta)
		# Update visual rotation to match the new direction.
		self.rotation = direction.angle()
	global_position += direction * stats.speed * delta

func _on_body_entered(body: Node2D):
	# Hit Logic - check if this body is a valid target for our allegiance.
	var target_group = CollisionUtils.get_target_group(allegiance)
	if not body.is_in_group(target_group):
		return

	# Valid target found - apply damage and knockback.
	if body.has_method("take_damage"):
		_deal_damage(body)
	if stats.status_to_apply and body.has_node("StatusEffectManager"):
		_apply_status(body)
	if stats.knockback_force > 0 and body.has_method("apply_knockback"):
		body.apply_knockback(stats.knockback_force, self.global_position)

	# Decrement pierce_count
	if pierce_count != -1: # Do nothing if pierce is infinite
		pierce_count -= 1
		if pierce_count <= 0:
			_destroy()

func _deal_damage(body: Node2D):
	var is_crit = false
	if randf() < critical_hit_rate:
		damage = damage * critical_hit_damage
		is_crit = true
	body.take_damage(damage, stats.armor_penetration, is_crit, self)

func _apply_status(body: Node2D):
	var status_manager = body.get_node("StatusEffectManager")
	status_manager.apply_status(stats.status_to_apply, user)

## Calculates all final stats by querying the weapon's user.
func _calculate_stats():
	# Use DamageUtils to centralize stat scaling logic.
	var scaled = DamageUtils.scale_all_projectile_stats(stats, user)
	damage = scaled["damage"]
	critical_hit_rate = scaled["crit_rate"]
	critical_hit_damage = scaled["crit_damage"]
	speed = scaled["speed"]
	status_chance = scaled["status_chance"]
	knockback = stats.knockback_force


func _apply_phasing():
	# Start with the main hitbox disabled.
	CollisionUtils.disable_collision(area2d)

	# Create and configure a small proximity detector.
	proximity_detector = Area2D.new()
	var proximity_shape = CircleShape2D.new()
	proximity_shape.radius = 30 # Small radius
	var proximity_collider = CollisionShape2D.new()
	proximity_collider.shape = proximity_shape
	proximity_detector.add_child(proximity_collider)

	# The detector only needs to look for potential targets.
	proximity_detector.collision_mask = 1 << CollisionUtils.LAYER_ENEMY_BODY if allegiance == Allegiance.PLAYER else 1 << CollisionUtils.LAYER_PLAYER_BODY

	proximity_detector.body_entered.connect(_on_proximity_detected)
	add_child(proximity_detector)

func _on_proximity_detected(body: Node2D):
	# When any enemy enters our proximity, check if it's the specific target.
	if body == self.target:
		# Re-enable our main hitbox and destroy the detector.
		print("Seeker missile arming!")
		CollisionUtils.set_projectile_collision(area2d, allegiance)
		proximity_detector.queue_free()

func _destroy():
	# Disconnect from global signals to prevent memory leaks
	if stats and stats.can_retarget and Events.enemy_killed.is_connected(_on_any_enemy_killed):
		Events.enemy_killed.disconnect(_on_any_enemy_killed)

	# Stop the lifetime timer
	if lifetime_timer:
		lifetime_timer.stop()

	# Clean up phasing proximity detector if it exists
	if is_instance_valid(proximity_detector):
		proximity_detector.queue_free()
		proximity_detector = null

	# Only pool simple projectiles (no phasing, no retargeting - they have extra state)
	if _is_pooled and stats and not stats.can_retarget and not stats.is_phasing:
		# Reset state for reuse
		target = null
		has_redirected = false
		ProjectilePool.return_projectile(self)
	else:
		queue_free()

## Called by the global "enemy_killed" signal.
func _on_any_enemy_killed():
	# This function runs when ANY enemy on the screen dies.

	# First, check if our own target is the one that just died or is now invalid.
	if target.is_dying:
		# Find a new target.
		var target_group
		if allegiance == Allegiance.PLAYER:
			target_group = "enemies"
		else:
			target_group = "player"
		var candidates = TargetingUtils.get_candidates(target_group)
		var new_target = TargetingUtils.find_nearest(self.global_position, candidates)
		if is_instance_valid(new_target):
			print("Living Flame is re-targeting!")
			self.target = new_target
