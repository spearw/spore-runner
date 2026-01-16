## weapon_tag_registry.gd
## Central registry for weapon effect defaults.
## Weapons specify which effects they have; this provides default values.
## Weapons can override specific values via effect_overrides dictionary.
class_name WeaponTagRegistry
extends RefCounted

## Default data for each effect tag.
## Weapons inherit these values unless they specify overrides.
const EFFECT_DEFAULTS = {
	# Damage patterns
	WeaponTags.Effect.DOT: {
		"damage_per_tick": 3.0,
		"tick_rate": 0.5,
		"duration": 3.0,
	},
	WeaponTags.Effect.SLOW: {
		"slow_percent": 0.3,  # 30% slow
		"duration": 2.0,
	},
	WeaponTags.Effect.CHAIN: {
		"chain_count": 2,
		"chain_range": 150.0,
		"damage_falloff": 0.8,  # 80% damage per bounce
	},
	WeaponTags.Effect.PIERCE: {
		"pierce_count": 1,  # -1 for infinite
	},
	WeaponTags.Effect.AOE: {
		"radius": 50.0,
		"falloff": true,  # Damage decreases with distance
	},
	WeaponTags.Effect.KNOCKBACK: {
		"force": 200.0,
	},

	# Projectile behaviors
	WeaponTags.Effect.HOMING: {
		"strength": 5.0,
		"acquire_range": 200.0,
	},
	WeaponTags.Effect.BURST: {
		"count": 3,
		"spread_angle": 15.0,  # Degrees between projectiles
	},
	WeaponTags.Effect.EXPLOSIVE: {
		"explosion_radius": 75.0,
		"explosion_damage_mult": 0.5,  # 50% of base damage
	},

	# Special effects
	WeaponTags.Effect.LIFESTEAL: {
		"percent": 0.1,  # 10% of damage healed
	},
	WeaponTags.Effect.ARMOR_PEN: {
		"penetration": 0.5,  # 50% armor bypass
	},
	WeaponTags.Effect.CRIT_BOOST: {
		"crit_chance_bonus": 0.1,
		"crit_damage_bonus": 0.25,
	},
	WeaponTags.Effect.SPARK: {
		"spark_count": 1,        # Sparks per hit
		"spark_damage": 6,       # Flat damage per spark
		"spark_bounces": 3,      # How many times each spark bounces
		"spark_range": 200.0,    # Range to find bounce targets
		"spark_speed": 600.0,    # Spark movement speed
		"spark_lifetime": 0.5,   # Short lifespan for limited range
	},
}

## Gets the merged effect data for a weapon/projectile.
## Combines defaults with any overrides specified on the weapon.
## @param effect: The effect tag to get data for.
## @param overrides: Dictionary of override values from the weapon.
## @returns: Dictionary with all effect parameters.
static func get_effect_data(effect: WeaponTags.Effect, overrides: Dictionary = {}) -> Dictionary:
	var base = EFFECT_DEFAULTS.get(effect, {}).duplicate()
	base.merge(overrides, true)  # Overrides take precedence
	return base

## Checks if an effect tag has valid defaults defined.
static func has_effect(effect: WeaponTags.Effect) -> bool:
	return effect in EFFECT_DEFAULTS

## Returns all required keys for an effect (useful for validation).
static func get_required_keys(effect: WeaponTags.Effect) -> Array:
	if effect in EFFECT_DEFAULTS:
		return EFFECT_DEFAULTS[effect].keys()
	return []
