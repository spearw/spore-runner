## warning_indicator.gd
## Fades in and then out to signal an impending strike.
extends Sprite2D

func _ready():
	# Start fully transparent
	modulate.a = 0
	var tween = create_tween()
	# Chain two animations: fade in, then fade out.
	# Fade in to 75% opacity over 0.2 seconds.
	tween.tween_property(self, "modulate:a", 0.75, 0.2)
	# Then, fade out to 0% opacity over the next 0.8 seconds.
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	# After the tween is finished, remove the node.
	await tween.finished
	queue_free()
