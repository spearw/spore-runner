## An artifact that modifies the player's speed.
class_name RunningShoesArtifact
extends Node

# The percentage increase in speed (1.10 = +10%).
@export var speed_multiplier: float = 1.10

## Applies this artifact's modification to a base speed value.
## @param base_speed: float - The incoming speed value.
## @return: float - The modified speed value.
func modify_speed(base_speed: float) -> float:
	return base_speed * speed_multiplier
