## shield_weapon.gd
## A unique weapon that spawns and maintains a defensive shield for its user.
class_name ShieldWeapon
extends Weapon

@export var shield_offset_distance: float = 40.0 

# --- Transformation Flags ---
var has_bash: bool = false
var has_tower: bool = false
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
	if self.has_bash:
		shield_instance.stats.knockback_force = projectile_stats.knockback_force * 3.0
	else:
		shield_instance.stats.damage = 0
	if self.has_tower:
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
		# Update its rotation to match the user's last move direction.
		# shield_instance.rotation = user.last_move_direction.angle()
		# shield_instance.position = user.last_move_direction * shield_offset_distance

func apply_transformation(id: String):
	super.apply_transformation(id)
	var has_changed = false
	if id == "bash":
		has_bash = true
		has_changed = true
		Logs.add_message(["Shield gained Bash!"])
	if id == "tower":
		has_tower = true
		has_changed = true
		Logs.add_message(["Shield gained Tower!"])
	if has_changed:
		# Delete shield and apply new
		shield_instance.queue_free()
		fire()
		var timer = get_node_or_null("FireRateTimer")
		if is_instance_valid(timer):
			timer.start()
