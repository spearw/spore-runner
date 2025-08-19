## projectile.gd
## Manages the behavior of a single projectile.
## Relies on collision masks to ensure it only interacts with enemies.
extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

## The _ready() function is no longer needed to connect the signal
## if we connect it via the editor, which is good practice. Let's do that.
# func _ready() -> void:
#     self.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	global_position += direction * speed * delta

## Signal handler for when a physics body enters this projectile's area.
## @param body: Node2D - The body that entered the area.
## We know this can only be an enemy due to our collision mask settings.
func _on_body_entered(body: Node2D) -> void:
	# No need to check the layer here, but we should still check
	# for the method to be safe.
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	queue_free()
