## enemy.gd
## A generic enemy scene. Its behavior and stats are configured by an EnemyStats resource.
extends CharacterBody2D

signal health_changed(current_health, max_health)

# Import stats
@export var stats: EnemyStats
@export var damage_number_scene: PackedScene
@export var experience_gem_scene: PackedScene

# --- Node References ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_bar: TextureProgressBar = $TextureProgressBar

# --- Runtime Variables ---
var current_health: int
var player_node: Node2D

func _ready() -> void:
	player_node = get_tree().get_first_node_in_group("player")
	
	# Delete if not properly init
	if not stats:
		printerr("Enemy spawned without EnemyStats resource! Deleting self.")
		queue_free()
		return
		
	# Apply stats from the resource.
	current_health = stats.max_health
	sprite.texture = stats.texture
	sprite.scale = stats.scale
	sprite.modulate = stats.modulate
	collision_shape.scale = stats.scale
	
	health_changed.connect(update_health_bar)
	update_health_bar(current_health, stats.max_health)
	health_bar.visible = false
	
## Reduces the enemy's health and handles the consequences.
## @param amount: int - The amount of damage to inflict.
func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	
	# Emit the signal for the health bar.
	health_changed.emit(current_health, stats.max_health)
	
	# Spawn damage number label
	if damage_number_scene:
		var dmg_num_instance = damage_number_scene.instantiate()
		# Add it to the main scene, not the enemy, so it doesn't move with the enemy.
		get_tree().current_scene.add_child(dmg_num_instance)
		dmg_num_instance.start(amount, self.global_position)
	
	if current_health <= 0:
		die()
		
## Called by the health_changed signal to update the UI.
func update_health_bar(current: int, max_val: int):
	health_bar.max_value = max_val
	health_bar.value = current
	# Show the bar only when the enemy has taken damage.
	health_bar.visible = current < max_val

## Handles the enemy's death sequence.
func die() -> void:
	# Drop experience
	if stats.experience_gem_stats:
		# Spawn the generic gem scene.
		var gem_instance = experience_gem_scene.instantiate()
		gem_instance.stats = stats.experience_gem_stats
		get_tree().current_scene.add_child(gem_instance)
		gem_instance.global_position = self.global_position
	queue_free()

func _physics_process(delta: float):
	if player_node:
		var direction: Vector2 = (player_node.global_position - self.global_position).normalized()
		# Use stats.speed instead of a local variable.
		velocity = direction * stats.speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	# After moving, check for collisions.
	# get_slide_collision_count() returns the number of collisions this frame.
	for i in range(get_slide_collision_count()):
		# get_slide_collision(i) returns a KinematicCollision2D object.
		var collision = get_slide_collision(i)
		# get_collider() returns the node collided with.
		var collided_object = collision.get_collider()
		
		# Check if the object is valid and is in the "player" group.
		if is_instance_valid(collided_object) and collided_object.is_in_group("player"):
			# Call the player's damage function.
			collided_object.take_damage(stats.damage)
			
			# Destroy self after dealing damage.
			queue_free()
			break
