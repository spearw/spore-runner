## tome_of_duplication.gd
## An artifact that grants extra projectiles to weapons.
class_name TomeOfDuplicationArtifact
extends Node

var projectile_bonus: int = 1

func get_projectile_bonus() -> int:
	return projectile_bonus
