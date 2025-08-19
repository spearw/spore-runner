## Enemy.gd
## Manages enemy behavior, including movement and dealing damage on contact.
## Uses physics body collision detection instead of a separate Area2D.
extends CharacterBody2D

@export var speed: float = 120.0
@export var damage: int = 10
@export var experience_gem_scene: PackedScene

var player_node: Node2D

func _ready() -> void:
	player_node = get_tree().get_first_node_in_group("player")
	
func take_damage(amount: int) -> void:
	# If an experience gem scene is assigned, instance and place it.
	if experience_gem_scene:
		var gem_instance = experience_gem_scene.instantiate()
		# Add the gem to the main scene tree.
		get_tree().current_scene.add_child(gem_instance)
		# Position the gem where the enemy died.
		gem_instance.global_position = self.global_position
	# Destroy enemy.
	queue_free()

func _physics_process(delta: float) -> void:
	# Movement logic.
	if player_node:
		var direction: Vector2 = (player_node.global_position - self.global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	# After moving, check for collisions.
	# get_slide_collision_count() returns the number of collisions this frame.
	for i in range(get_slide_collision_count()):
		# get_slide_collision(i) returns a KinematicCollision2D object.
		var collision = get_slide_collision(i)
		
		# get_collider() returns the node we collided with.
		var collided_object = collision.get_collider()
		
		# Check if the object is valid and is in the "player" group.
		if is_instance_valid(collided_object) and collided_object.is_in_group("player"):
			# Call the player's damage function.
			collided_object.take_damage(damage)
			
			# Destroy self after dealing damage.
			queue_free()
			
			# Important: Break the loop as this enemy is now queued for deletion
			# and should not process further collisions.
			break
