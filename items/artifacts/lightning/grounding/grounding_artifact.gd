## grounding_artifact.gd
## An artifact that allows chain lightning to bounce through the player.
## When chains pass through the player, they deal +50% damage to the next enemy.
## Pattern: Boss(100%) -> Player -> Boss(150%) -> Player -> Boss(225%)
class_name GroundingArtifact
extends ArtifactBase

func on_equipped() -> void:
	if is_instance_valid(user) and user.has_method("set_grounding_ability"):
		user.set_grounding_ability(true)

func on_unequipped() -> void:
	if is_instance_valid(user) and user.has_method("set_grounding_ability"):
		user.set_grounding_ability(false)
