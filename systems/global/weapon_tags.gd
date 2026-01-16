## weapon_tags.gd
## Enum definitions for the weapon tag system.
## Themes define what a weapon IS (damage type, synergies).
## Effects define what a weapon DOES (mechanical behaviors).
class_name WeaponTags
extends RefCounted

## DamageType tags - the weapon's elemental/thematic identity.
## Affects: damage type bonuses, artifact synergies, visuals.
enum DamageType {
	FIRE,       # Fire-themed, typically paired with DOT
	ICE,        # Ice-themed, typically paired with SLOW
	LIGHTNING,  # Lightning-themed, typically paired with CHAIN
	SALT,       # Salt/desiccation, bonus vs freshwater enemies
	NATURE,     # Nature/poison, typically paired with DOT
	ARCANE,     # Pure magic damage
	PHYSICAL,   # Non-elemental physical damage
}

## Effect tags - the weapon's mechanical behaviors.
## Affects: how projectiles interact with enemies.
enum Effect {
	# Damage patterns
	DOT,        # Damage over time (burn, poison, bleed)
	SLOW,       # Reduces enemy movement speed
	CHAIN,      # Bounces to nearby enemies
	PIERCE,     # Passes through enemies
	AOE,        # Area of effect damage
	KNOCKBACK,  # Pushes enemies away

	# Projectile behaviors
	HOMING,     # Tracks targets
	BURST,      # Multiple projectiles per shot
	EXPLOSIVE,  # Explodes on impact

	# Special effects
	LIFESTEAL,  # Heals user on hit
	ARMOR_PEN,  # Ignores armor
	CRIT_BOOST, # Increased crit chance/damage
	SPARK,      # Spawns spark projectiles on hit (lightning weapons)
}
