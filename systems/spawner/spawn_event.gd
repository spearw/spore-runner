## spawn_event.gd
## A Resource that defines a single event in the enemy spawn timeline.
class_name SpawnEvent
extends Resource

# The time in seconds into the run when this event becomes active.
@export var time_start: int = 0
# The time in seconds into the run when this event becomes inactive. -1 runs indefinitely.
@export var time_end: int = -1
# The type of enemy to spawn for this event.
@export var enemy_stats: EnemyStats
# The number of enemies to spawn at once in a single group.
@export var quantity: int = 1
# The time in seconds between each spawn group for this event.
@export var interval: float = 2.0
# If true, this event only happens once as a "burst" and does not repeat.
@export var is_burst: bool = false
