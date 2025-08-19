## experience_gem.gd
## Represents a collectible experience point gem.
extends Area2D

# The amount of experience this gem provides.
@export var experience_value: int = 25

## Called when the node is ready. Connects signals.
func _ready() -> void:
	# The body_entered signal is emitted when a PhysicsBody2D enters the area.
	self.body_entered.connect(_on_body_entered)

## Handles the collection of the gem.
## @param body: Node2D - The physics body that entered this area.
func _on_body_entered(body: Node2D) -> void:
	# The collision mask should already guarantee this is the player,
	# but a group check is a good safeguard.
	if body.is_in_group("player"):
		# We assume the player has an 'add_experience' method.
		if body.has_method("add_experience"):
			body.add_experience(experience_value)
		
		# The gem has been collected and should be removed.
		queue_free()
