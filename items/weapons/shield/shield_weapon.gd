## shield_weapon.gd
## A unique weapon that spawns and maintains a defensive shield for its user.
class_name ShieldWeapon
extends TransformableWeapon

@export var shield_offset_distance: float = 40.0

var user: Node2D;
var shield_instance: Node2D

func _ready():
	super._ready()
	# Init shield immediately
	fire()

func fire(multiplier: int = 1):
	user = stats_component.user
	if not is_instance_valid(user): return

	# --- Core Logic: Prevent Stacking ---
	# Check if the user already has a shield equipped.
	var new_spawn = false
	if not shield_instance:
		Logs.add_message(["Spawning a new shield."])
		new_spawn = true
		# If no shield exists, spawn one.
		shield_instance = custom_projectile_scene.instantiate()

	# Update shield stats, for new or existing shield
	shield_instance.stats = self.projectile_stats.duplicate()
	# Calculate final damage/knockback based on upgrades
	var user_damage_mult = user.get_stat("damage_increase")
	if has_transformation("bash"):
		shield_instance.stats.knockback_force = projectile_stats.knockback_force * 3.0
	else:
		shield_instance.stats.damage = 0
	if has_transformation("tower"):
		shield_instance.can_block_projectiles = true
		shield_instance.stats.pierce = shield_instance.stats.pierce * 2

	if new_spawn:
		# Parent the shield to the user.
		user.add_child(shield_instance)
		shield_instance.name = "ShieldEffect"

## The shield's orientation should match the player's aim.
## We do this every frame.
func _physics_process(_delta):
	if not is_instance_valid(user): return

	# Find the active shield.
	if is_instance_valid(shield_instance):
		# Rotate shield to angle of target
		var target_direction = targeting_component.get_fire_direction(self.global_position, Vector2.RIGHT, Projectile.Allegiance.PLAYER)
		shield_instance.rotation = target_direction.angle()
		shield_instance.position = target_direction * shield_offset_distance

func _on_transformation_acquired(id: String):
	# Shield needs to be recreated when transformations are applied
	if id == "bash" or id == "tower":
		if is_instance_valid(shield_instance):
			shield_instance.queue_free()
			shield_instance = null
		fire()
		var timer = get_node_or_null("FireRateTimer")
		if is_instance_valid(timer):
			timer.start()
