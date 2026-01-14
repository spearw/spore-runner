## damage_utils.gd
## Utility class for damage calculations. Centralizes armor and damage logic.
class_name DamageUtils
extends RefCounted

## Calculates damage after applying armor reduction.
## Formula: effective_armor = armor * (1 - armor_pen), damage_taken = max(0, damage - effective_armor)
## @param damage: The raw damage amount before armor.
## @param armor: The target's armor value.
## @param armor_pen: Armor penetration as a float (0.0 to 1.0). 1.0 = full bypass.
## @returns: The final damage after armor reduction.
static func apply_armor(damage: float, armor: float, armor_pen: float = 0.0) -> int:
	var effective_armor = armor * (1.0 - clampf(armor_pen, 0.0, 1.0))
	return max(0, int(damage - effective_armor))

## Rolls for a critical hit and returns the final damage.
## @param base_damage: The damage before crit calculation.
## @param crit_rate: Chance to crit (0.0 to 1.0).
## @param crit_multiplier: Damage multiplier on crit (e.g., 1.5 = 150% damage).
## @returns: Dictionary with "damage" (int) and "is_crit" (bool).
static func roll_crit(base_damage: float, crit_rate: float, crit_multiplier: float) -> Dictionary:
	var is_crit = randf() < crit_rate
	var final_damage = base_damage
	if is_crit:
		final_damage = base_damage * crit_multiplier
	return {
		"damage": int(final_damage),
		"is_crit": is_crit
	}

## Combines crit roll and armor application in one call.
## @param base_damage: Raw damage before any modifiers.
## @param crit_rate: Critical hit chance.
## @param crit_multiplier: Critical hit damage multiplier.
## @param armor: Target's armor value.
## @param armor_pen: Armor penetration percentage.
## @returns: Dictionary with "damage" (int) and "is_crit" (bool).
static func calculate_final_damage(
	base_damage: float,
	crit_rate: float,
	crit_multiplier: float,
	armor: float,
	armor_pen: float = 0.0
) -> Dictionary:
	var crit_result = roll_crit(base_damage, crit_rate, crit_multiplier)
	var final_damage = apply_armor(crit_result["damage"], armor, armor_pen)
	return {
		"damage": final_damage,
		"is_crit": crit_result["is_crit"]
	}
