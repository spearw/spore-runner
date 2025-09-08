## heart_pickup.gd
extends Area2D

var heal_amount: int = 25
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	self.modulate = Color.HOT_PINK
	animated_sprite_2d.play("default")

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and body.has_method("heal"):
		body.heal(heal_amount)
		queue_free()
