## transformable_weapon.gd
## Base class for weapons with transformation upgrades.
## Provides a dictionary-based system for tracking transformations and helper methods.
class_name TransformableWeapon
extends Weapon

## Dictionary tracking all acquired transformations by ID.
var acquired_transformations: Dictionary = {}

## Called by the upgrade system to apply a transformation.
## Subclasses should override _on_transformation_acquired() instead of this.
func apply_transformation(id: String):
	super.apply_transformation(id)
	acquired_transformations[id] = true
	_log_transformation(id)
	_on_transformation_acquired(id)

## Override this in subclasses to handle specific transformation logic.
func _on_transformation_acquired(id: String):
	pass

## Check if a specific transformation has been acquired.
func has_transformation(id: String) -> bool:
	return acquired_transformations.has(id)

## Override this to customize the log message format.
func _log_transformation(id: String):
	var weapon_name = name if name else "Weapon"
	var formatted_id = id.capitalize().replace("_", " ")
	Logs.add_message([weapon_name, "gained", formatted_id + "!"])
