## conductive_artifact.gd
## An artifact that makes ALL weapons spawn sparks on hit.
## Transforms any build into a lightning hybrid!
class_name ConductiveArtifact
extends ArtifactBase

func on_equipped() -> void:
	if is_instance_valid(user):
		user.add_bonus("has_conductive", 1.0, false)

func on_unequipped() -> void:
	if is_instance_valid(user):
		user.add_bonus("has_conductive", -1.0, false)
