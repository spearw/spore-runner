## soul.gd
## A collectible currency pickup.
class_name Soul
extends Area2D

# Make variable later? Large souls are cool.
var soul_value: int = 1

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		# Instead of calling the player, we'll talk to our new GameData singleton.
		GameData.add_souls(soul_value)
		queue_free()
