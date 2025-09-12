## flamethrower_weapon.gd
## A specialized weapon that adds unique transformation logic for the Flamethrower.
class_name FlamethrowerWeapon
extends Weapon

# --- Transformation Flags ---
var has_flaming_tongues: bool = false
var has_ring_of_fire: bool = false

# --- Reference for the Ring of Fire effect ---
var ring_of_fire_instance: Node = null

# The fire() method is called by the timer.
func fire(multiplier: int = 1):
	# If the "Ring of Fire" transformation is active, it completely takes over.
	# The normal firing mechanism is disabled.
	if has_ring_of_fire:
		# The aura is persistent, so the timer firing doesn't need to do anything.
		return

	# If we have "Flaming Tongues", we override the pattern for this shot.
	if has_flaming_tongues:
		fire_behavior_component.override_pattern_for_next_shot(FireBehaviorComponent.FirePattern.MIRRORED_FORWARD)

	# Call the original fire logic from the FireBehaviorComponent.
	fire_behavior_component.fire()

## This function is called by the UpgradeManager.
func apply_transformation(id: String):
	if id == "flaming_tongues":
		has_flaming_tongues = true
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

	# We'll need a new scene for the aura effect.
	var ring_scene = load("res://items/weapons/flamethrower/ring_of_fire_effect.tscn")
	ring_of_fire_instance = ring_scene.instantiate()
	
	# Pass necessary stats to the aura.
	ring_of_fire_instance.stats = self.projectile_stats
	ring_of_fire_instance.allegiance = stats_component.get_projectile_allegiance()
	ring_of_fire_instance.user = user
	
	# Attach the aura to the player.
	user.add_child(ring_of_fire_instance)
