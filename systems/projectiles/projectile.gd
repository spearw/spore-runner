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

# --- Node References ---
@onready var sprite: Sprite2D = $Area2D/Sprite2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var area2d: Area2D = $Area2D

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
	
	_calculate_stats()
	pierce_count = stats.pierce + 1 if stats.pierce != -1 else -1

	# Configure visuals from stats.
	sprite.texture = stats.texture
	sprite.scale = stats.scale
	generate_hitbox_from_sprite()
	
	# Configure physics based on allegiance.
	match allegiance:
		Allegiance.PLAYER:
			# I am a player projectile, I should hit enemies.
			self.area2d.collision_layer = 1 << 2 # Set layer to 'player_projectile' (layer 3)
			self.area2d.collision_mask = 1 << 1  # Set mask to scan for 'enemy_body' (layer 2)
		Allegiance.ENEMY:
			# I am an enemy projectile, I should hit the player.
			self.area2d.collision_layer = 1 << 4 # Set layer to 'enemy_projectile' (layer 5)
			self.area2d.collision_mask = 1 << 0  # Set mask to scan for 'player_body' (layer 1)

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
	self.area2d.body_entered.connect(_on_body_entered)

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
	collision_shape.position = sprite.position

func _process(delta: float):
	global_position += direction * stats.speed * delta

func _on_body_entered(body: Node2D):
	
	# Hit Logic
	var can_damage = false
	if allegiance == Allegiance.PLAYER and body.is_in_group("enemies"):
		can_damage = true
	elif allegiance == Allegiance.ENEMY and body.is_in_group("player"):
		can_damage = true

	if can_damage:
		# Apply damage and knockback if the body is a valid target.
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
				# Destroy the projectile.
				queue_free()
				
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
	# Start with the base values from the stats resource.
	damage = stats.damage
	critical_hit_rate = stats.critical_hit_rate
	critical_hit_damage = stats.critical_hit_damage
	speed = stats.speed
	knockback = stats.knockback_force

	# If user is player, apply stat bonuses.
	if user.is_in_group("player"):
		damage *= user.get_stat("damage_increase")
		critical_hit_rate = (critical_hit_rate) * (1 + user.get_stat("critical_hit_rate"))
		critical_hit_damage = (1 + critical_hit_damage) * (1 + user.get_stat("critical_hit_damage"))
		speed *= user.get_stat("projectile_speed")
