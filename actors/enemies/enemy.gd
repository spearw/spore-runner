## enemy.gd
## A generic enemy scene. Its behavior and stats are configured by an EnemyStats resource.
extends CharacterBody2D

signal health_changed(current_health, max_health)

# Import stats
@export var stats: EnemyStats
@export var damage_number_scene: PackedScene
@export var experience_gem_scene: PackedScene
@export var soul_scene: PackedScene

# --- Node References ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var visibility_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var death_timer: Timer = $DeathTimer


# --- Runtime Variables ---
var current_health: int
var player_node: Node2D
var behavior: EnemyBehavior = null
var is_on_screen: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var is_dying: bool = false

# --- Signals ---
signal died(enemy_stats)



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

	# After all equipment is ready, initialize the behavior component.
	if is_instance_valid(behavior) and behavior.has_method("initialize_behavior"):
		behavior.initialize_behavior(self)
		
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
	
	# Detect whether enemy is on screen
	visibility_notifier.screen_entered.connect(_on_screen_entered)
	visibility_notifier.screen_exited.connect(_on_screen_exited)
	
## Tells all equipped weapons to fire once.
func fire_weapons():
	var equipment = get_node_or_null("Equipment")
	if equipment:
		for weapon in equipment.get_children():
			if weapon.has_method("fire"):
				weapon.fire()
	
## Reduces the enemy's health and handles the consequences.
## @param amount: int - The amount of damage to inflict.
## @param armor_pen: float - Armor penetration of incoming hit.
func take_damage(amount: int, armor_pen: float) -> void:
	if is_dying: return
	
	# Armor is reduced by the penetration percentage.
	# Effective Armor = Armor * (1 - Penetration)
	var effective_armor = self.stats.armor * (1.0 - armor_pen)
	var damage_taken = max(0, amount - effective_armor)
	
	# Take damage.
	current_health = max(0, current_health - damage_taken)
	
	# Emit the signal for the health bar.
	health_changed.emit(current_health, stats.max_health)
	
	# Spawn damage number label
	if damage_number_scene:
		var dmg_num_instance = damage_number_scene.instantiate()
		# Add it to the main scene, not the enemy, so it doesn't move with the enemy.
		get_tree().current_scene.add_child(dmg_num_instance)
		dmg_num_instance.start(amount, self.global_position)
	
	if current_health <= 0:
		# When health drops to 0, let death play out.
		is_dying = true
		death_timer.wait_time = 0.3
		death_timer.one_shot = true
		death_timer.timeout.connect(die)
		death_timer.start()
		
## Called by the health_changed signal to update the UI.
func update_health_bar(current: int, max_val: int):
	health_bar.max_value = max_val
	health_bar.value = current
	# Show the bar only when the enemy has taken damage.
	health_bar.visible = current < max_val
	
## Applies a knockback force away from a given point.
## @param force: float - The strength of the knockback.
## @param from_position: Vector2 - The world position the knockback originates from.
func apply_knockback(force: float, from_position: Vector2):
	# Calculate the direction vector away from the damage source.
	var direction = (self.global_position - from_position).normalized()
	# Apply the force to the velocity. This will be handled by move_and_slide.
	knockback_velocity = direction * force

## Handles the enemy's death sequence.
func die(drop_xp=true) -> void:
	died.emit(stats) # Announce death to encounter director.
	# Drop loot
	if stats.special_drop_scene:
		var special_drop = stats.special_drop_scene.instantiate()
		get_tree().current_scene.add_child(special_drop)
		special_drop.global_position = self.global_position
	# Drop XP gems
	if stats.experience_gem_stats and drop_xp:
		# Spawn the generic gem scene.
		var gem_instance = experience_gem_scene.instantiate()
		gem_instance.stats = stats.experience_gem_stats
		get_tree().current_scene.add_child(gem_instance)
		gem_instance.global_position = self.global_position
	# Drop soul
	if randf() < stats.soul_drop_chance:
		if soul_scene:
			var soul_instance = soul_scene.instantiate()
			get_tree().current_scene.add_child(soul_instance)
			soul_instance.global_position = self.global_position
	queue_free()


func _physics_process(delta: float):
	# Knockback decays over time
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.05)
	if is_dying:
		# In in "dying" state, just a ragdoll.
		velocity = knockback_velocity
	else:
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
			# animated_sprite.stop()
			
		if stats.face_movement_direction:
			# Only rotate if we are actually moving.
			if velocity.length() > 0.1:
				# Calculate the angle of the velocity vector and add the offset.
				# We must convert the degrees offset from our data into radians for the code.
				var rotation_offset_radians = deg_to_rad(stats.rotation_offset_degrees)
				animated_sprite.rotation = velocity.angle() + rotation_offset_radians
		else:
			if abs(velocity.x) > 0.1:
				if velocity.x > 0:
					animated_sprite.flip_h = true
				else:
					animated_sprite.flip_h = false

			
		# Check for collision
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if not collision: continue
			
			var collided_object = collision.get_collider()
			
			# Check if the object is the player.
			if is_instance_valid(collided_object) and collided_object.is_in_group("player"):
				# Call the player's damage function, using this enemy's damage stat.
				collided_object.take_damage(stats.damage, stats.armor_pen)
				# The normal enemy dies on contact but does not drop xp.
				die(false)
				return
		velocity += knockback_velocity
	move_and_slide()


## Plays a one-shot animation via the AnimationPlayer.
func play_one_shot_animation(anim_name: String):
	# The AnimationPlayer will take control, play the animation, and then release control.
	animation_player.play(anim_name)

## Called when a one-shot animation is finished.
func _on_animation_finished():
	# Return control to the physics process logic.
	# The next frame, the velocity check will take over again.
	pass
	
func _on_screen_entered():
	is_on_screen = true

func _on_screen_exited():
	is_on_screen = false
