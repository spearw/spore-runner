## Gems
extends Area2D

@export var stats: ExperienceGemStats
@onready var sprite: Sprite2D = $Sprite2D

var is_homing: bool = false
var target_player: Node2D = null
var homing_speed: float = 250.0

func _ready():
	if not stats:
		printerr("Gem spawned without stats! Deleting.")
		queue_free()
		return
	
	sprite.texture = stats.texture
	sprite.scale = stats.scale
	
	# Connect to signals for direct and magnetic pickup.
	self.body_entered.connect(_on_body_entered) # For direct player collision.
	self.area_entered.connect(_on_area_entered) # For magnetic radius detection.

	# Give the physics engine one frame to settle.
	# This ensures get_overlapping_areas() is reliable.
	await get_tree().process_frame
	
	# Check if gem spawned inside a pickup area.
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("player_pickup_area"):
			# Get the player (the area's parent) and start homing.
			start_homing(area.get_parent())
			# Only need to find one, so the gem can stop checking.
			break

func _process(delta: float):
	if is_homing and is_instance_valid(target_player):
		global_position = global_position.move_toward(target_player.global_position, homing_speed * delta)

## Signal handler for when the player's pickup radius enters gem's area.
func _on_area_entered(area: Area2D):
	if area.is_in_group("player_pickup_area"):
		start_homing(area.get_parent())

## Signal handler for when the player's body directly touches gem.
func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if body.has_method("add_experience"):
			body.add_experience(stats.experience_value)
		queue_free()

func start_homing(player_node: Node2D):
	if not is_homing:
		is_homing = true
		target_player = player_node
