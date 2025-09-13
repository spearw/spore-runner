## flamethrower_weapon.gd
## A specialized weapon that adds unique transformation logic for the Flamethrower.
class_name FlamethrowerWeapon
extends Weapon

# --- Transformation Flags ---
var has_flaming_tongues: bool = false
var has_ring_of_fire: bool = false
@export var ring_of_fire_stats: PersistentEffectStats

# --- Reference for the Ring of Fire effect ---
var ring_of_fire_instance: Node = null

# The fire() method is called by the timer.
func fire(multiplier: int = 1):
	# If the "Ring of Fire" transformation is active, it completely takes over.
	# The normal firing mechanism is disabled.
	if has_ring_of_fire:
		# The aura is persistent, so the timer firing doesn't need to do anything.
		return
	
	super.fire()

## This function is called by the UpgradeManager.
func apply_transformation(id: String):
	super.apply_transformation(id)
	if id == "flaming_tongues":
		has_flaming_tongues = true
		fire_behavior_component.fire_pattern = FireBehaviorComponent.FirePattern.MIRRORED_FORWARD
		print("Flamethrower gained Flaming Tongues!")
		
	if id == "ring_of_fire":
		has_ring_of_fire = true
		print("Flamethrower gained Ring of Fire!")
		# When we get this upgrade, immediately create the ring.
		_create_ring_of_fire()

## Logic to create and manage the persistent Ring of Fire aura.
func _create_ring_of_fire():
	var user = stats_component.user
	if not is_instance_valid(user): return
	
	# If a ring already exists, don't create another one.
	if is_instance_valid(ring_of_fire_instance): return

	# Load aura scene
	var ring_scene = load("res://items/effects/persistent_damage_effect.tscn")
	ring_of_fire_instance = ring_scene.instantiate()
	
	# Pass necessary stats to the aura.
	ring_of_fire_instance.stats = self.ring_of_fire_stats
	ring_of_fire_instance.allegiance = stats_component.get_projectile_allegiance()
	ring_of_fire_instance.user = user
	
	# Attach the aura to the player.
	user.add_child(ring_of_fire_instance)
