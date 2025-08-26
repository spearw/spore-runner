## treasure_chest.gd
## A special pickup that grants a multi-upgrade reward when collected.
extends Area2D

func _ready():
	# We only care about direct body collision for this one.
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		# Emit the signal on the global event bus.
		Events.emit_signal("boss_reward_requested")
		
		queue_free()
