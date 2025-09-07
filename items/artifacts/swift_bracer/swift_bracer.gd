## swift_bracer.gd
## An artifact that increases global weapon fire rate.
class_name SwiftBracerArtifact
extends Node

# 20% faster fire rate
var firerate_modifier: float = 0.8 

func get_firerate_modifier() -> float:
	return firerate_modifier
