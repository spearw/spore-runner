## redirect_artifact.gd
## An artifact that grants the user the "Redirect" ability.
class_name RedirectArtifact
extends Node

# This script is primarily a marker. We need to tell the user they have this power.
var user: Node = null

func _ready():
	# When this artifact is equipped, tell the user to activate their redirect flag.
	if is_instance_valid(user) and user.has_method("set_redirect_ability"):
		user.set_redirect_ability(true)

## When the artifact is removed (which we don't handle yet, but is good practice),
## it should disable the ability.
func _tree_exiting():
	if is_instance_valid(user) and user.has_method("set_redirect_ability"):
		user.set_redirect_ability(false)
