## redirect_artifact.gd
## An artifact that grants the user the "Redirect" ability.
class_name RedirectArtifact
extends ArtifactBase

func on_equipped() -> void:
	if is_instance_valid(user) and user.has_method("set_redirect_ability"):
		user.set_redirect_ability(true)

func on_unequipped() -> void:
	if is_instance_valid(user) and user.has_method("set_redirect_ability"):
		user.set_redirect_ability(false)
