## projectile.gd
## Manages the behavior of a single projectile.
## Relies on collision masks to ensure it only interacts with player.
extends Area2D

@export var speed: float = 200.0
@export var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

func _process(delta: float) -> void:
	global_position += direction * speed * delta

## Signal handler for when a physics body enters this projectile's area.
## @param body: Node2D - The body that entered the area.
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	queue_free()
