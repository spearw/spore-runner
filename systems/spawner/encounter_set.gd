## encounter_set.gd
## A Resource that defines a thematic pool of enemies for a specific time window.
class_name EncounterSet
extends Resource

@export var time_start: int = 0  # Time in seconds this set becomes available.
@export var time_end: int = -1   # Time in seconds this set is no longer available (-1 for indefinite).

# The list of enemy types that can spawn during this encounter.
@export var enemies: Array[EnemyStats]
