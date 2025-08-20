## damage_number.gd
## A label that displays a number, animates, and then deletes itself.
extends Label

## Public function to initialize the damage number.
## @param damage_amount: int - The number to display.
## @param start_position: Vector2 - The world position to spawn at.
func start(damage_amount: int, start_position: Vector2):
	self.text = str(damage_amount)
	self.global_position = start_position
	
	# Add a little random horizontal offset to make numbers overlap less.
	self.global_position.x += randf_range(-8.0, 8.0)
	
	# Create a Tween to handle the animation.
	var tween = create_tween()
	
	# Animate the position property. Move up by 20 pixels over 0.6 seconds.
	tween.tween_property(self, "global_position", global_position + Vector2(0, -20), 0.6)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
	# Animate the modulate property's alpha channel to fade out at the same time.
	# 'modulate:a' is the shorthand for the alpha component of the modulate color.
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		
	# After the tween finishes, the node should be removed from the scene.
	await tween.finished
	queue_free()
