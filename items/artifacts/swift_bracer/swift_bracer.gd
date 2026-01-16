## swift_bracer.gd
## An artifact that increases global weapon fire rate.
class_name SwiftBracerArtifact
extends ArtifactBase

# 20% faster fire rate (0.8 = 20% faster because fire rate timer is multiplied)
var firerate_modifier: float = 0.8

func get_firerate_modifier() -> float:
	return firerate_modifier
