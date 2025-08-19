## Manages the behavior of a single spike projectile.
extends Area2D

var speed: float = 300.0
var damage: int = 15
var direction: Vector2 = Vector2.UP

func _ready():
	self.body_entered.connect(_on_body_entered)

func _process(delta: float):
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
