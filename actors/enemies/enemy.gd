## enemy.gd
## A generic enemy scene. Its behavior and stats are configured by an EnemyStats resource.
extends CharacterBody2D

signal health_changed(current_health, max_health)

# Import stats
@export var stats: EnemyStats
@export var damage_number_scene: PackedScene
@export var experience_gem_scene: PackedScene

# --- Node References ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_bar: TextureProgressBar = $TextureProgressBar

# --- Runtime Variables ---
var current_health: int
var player_node: Node2D
var behavior: EnemyBehavior = null

func _ready() -> void:
	player_node = get_tree().get_first_node_in_group("player")
	
	# Delete if not properly init
	if not stats:
		printerr("Enemy spawned without EnemyStats resource! Deleting self.")
		queue_free()
		return
		
	if stats.behavior_scene:
		self.behavior = stats.behavior_scene.instantiate()
		add_child(self.behavior)
	
	# Equip weapon
	if stats.weapon_scenes:
		var equipment_node = get_node("Equipment")
		for weapon_scene in stats.weapon_scenes:
			var new_weapon = weapon_scene.instantiate()
			# The weapon needs to know who its user is.
			var stats_comp = new_weapon.get_node("WeaponStatsComponent")
			if stats_comp:
				stats_comp.user = self
			
			equipment_node.add_child(new_weapon)

		
	# Apply stats from the resource.
	current_health = stats.max_health
	# Apply the animation library to the sprite node.
	animated_sprite.sprite_frames = stats.sprite_frames
	# Apply the scale to the enemy's root node so all children scale together.
	self.scale = stats.scale
	collision_shape.scale = stats.scale
	animated_sprite.play("move")
	
	health_changed.connect(update_health_bar)
	update_health_bar(current_health, stats.max_health)
	health_bar.visible = false
	
## Tells all equipped weapons to fire once.
func fire_weapons():
	var equipment = get_node_or_null("Equipment")
	if equipment:
		for weapon in equipment.get_children():
			if weapon.has_method("fire"):
				weapon.fire()
	
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
	if is_instance_valid(behavior):
		behavior.process_behavior(delta, self)
		
	# Only change animation if we are not in the middle of a special animation (like "fire").
	if animation_player.is_playing():
		return # Let the AnimationPlayer finish its job.
		
	if velocity.length() > 0.1:
		animated_sprite.play("move")
	else:
		# Play idle animation, if one exists
		animated_sprite.play("idle")
		animated_sprite.stop()
		animated_sprite.frame = 0

		
	# Check for collision
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if not collision: continue
		
		var collided_object = collision.get_collider()
		
		# Check if the object is the player.
		if is_instance_valid(collided_object) and collided_object.is_in_group("player"):
			# Call the player's damage function, using this enemy's damage stat.
			collided_object.take_damage(stats.damage)
			# The normal enemy is deleted on contact.
			# This prevents dealing damage every single frame and dropping xp.
			queue_free()
			return


## Plays a one-shot animation via the AnimationPlayer.
func play_one_shot_animation(anim_name: String):
	# The AnimationPlayer will take control, play the animation, and then release control.
	animation_player.play(anim_name)

## Called when a one-shot animation is finished.
func _on_animation_finished():
	# Return control to the physics process logic.
	# The next frame, the velocity check will take over again.
	pass
