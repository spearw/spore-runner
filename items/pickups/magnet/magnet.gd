## magnet.gd
## A pickup that attracts all experience orbs on the screen.
extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	self.modulate = Color.YELLOW
	animated_sprite_2d.play("default")

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		# Announce the event on the global bus.
		Events.emit_signal("magnet_collected", body)
		queue_free()
