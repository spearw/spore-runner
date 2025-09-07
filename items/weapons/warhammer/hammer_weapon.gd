## hammer_weapon.gd
## A specialized weapon that adds unique transformation logic for the Hammer.
class_name HammerWeapon
extends Weapon

# --- Transformation Flags ---
var has_smash = false	#Adds substantial knockback to sledgehammer
var has_shockwave = false 	#Creates cone-shaped AOE behind hit enemy

@export var shockwave_effect_scene: PackedScene
@export var shockwave_stats: ProjectileStats

func _ready():
	super._ready()
	# Connect to the enemy_hit signal.
	Events.enemy_hit.connect(_on_enemy_hit)
	
# This function replaces the fire() method from weapon.gd.
func fire(damage_multiplier=1):
	var user = stats_component.user
	if not is_instance_valid(user): return
	
	# --- Attack Priority ---
	
	if has_shockwave:
		# Add a projectile for shockwave
		super.fire()
	# Smash/Normal attacks
	else:
		super.fire()
		
## This is the on-hit trigger for shockwave effect.
func _on_enemy_hit(hit_details: Dictionary):
	# First, check if we have the upgrade and if the hit was from this weapon.
	if not has_shockwave or hit_details["weapon"] != self:
		return

	# Spawn the shockwave effect.
	var enemy_hit = hit_details["enemy"]
	var user = stats_component.user
	
	var shockwave = shockwave_effect_scene.instantiate()
	
	shockwave.stats = shockwave_stats
	shockwave.allegiance = Projectile.Allegiance.PLAYER
	if user.has_method("get_stat"):
		shockwave.stats.damage = shockwave_stats.base_damage * user.get_stat("damage_increase")
		shockwave.stats.critical_hit_rate = shockwave_stats.critical_hit_rate * (1 + user.get_stat("critical_hit_rate"))
		shockwave.stats.critical_hit_damage = shockwave_stats.critical_hit_damage * (1 + user.get_stat("critical_hit_damage"))
	else:
		shockwave.stats.damage = shockwave_stats.base_damage
		
	# Add to the world
	get_tree().current_scene.add_child(shockwave)
	shockwave.global_position = enemy_hit.global_position
	
	# Aim it away from the player
	var direction_away = (enemy_hit.global_position - user.global_position).normalized()
	shockwave.rotation = direction_away.angle()

func apply_transformation(id: String):
	if id == "smash":
		# Increase base knockback
		projectile_stats.knockback_force = projectile_stats.knockback_force * 2
		projectile_stats.armor_penetration = 0.75
		has_smash = true
		print("Hammer has gained Smash!")
	if id == "shockwave":
		has_shockwave = true
		print("Hammer has gained Shockwave!")
