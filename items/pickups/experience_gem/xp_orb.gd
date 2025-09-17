## xp_orb.gd
extends Area2D

@export var stats: ExperienceOrbStats
# Determines effect of arc as moving towards player.
@export var orbit_strength: float = 700.0
@export var orbit_decay: float = 0.99
var orbit_speed: float

# TODO: Put rng in global files
var rng = RandomNumberGenerator.new()

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_homing: bool = false
var target_player: Node2D = null
var homing_speed: float = 200.0

func _ready():
	rng.randomize()
	if not stats:
		printerr("Gem spawned without stats! Deleting.")
		queue_free()
		return

	
	# Connect to signals for direct and magnetic pickup.
	self.body_entered.connect(_on_body_entered) # For direct player collision.
	self.area_entered.connect(_on_area_entered) # For magnetic radius detection.
	Events.magnet_collected.connect(_on_magnet_collected) # For magnet pickup.

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
			
	self.modulate = stats.color
	animated_sprite_2d.play("default")
	animated_sprite_2d.scale = stats.scale

func _process(delta: float):
	if is_homing and is_instance_valid(target_player):
		if not orbit_speed:
			# Apply 10% variation.
			orbit_speed = orbit_strength * rng.randf_range(.9, 1.1)
		# Calculate the direction vector towards the player.
		var direction_to_player = (target_player.global_position - global_position).normalized()
		# Get a perpendicular vector for the "orbit" motion.
		var orbit_vector = direction_to_player.orthogonal()
		# Combine the homing and orbiting vectors to get the final velocity.
		var velocity = (direction_to_player * homing_speed) + (orbit_vector * orbit_strength)
		# Move the gem.
		global_position += velocity * delta
		# Increase homing speed and decrease orbit strength over time.
		homing_speed *= 1.02
		orbit_strength *= orbit_decay

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
		
## Called by the global event when ANY magnet is picked up.
func _on_magnet_collected(player_node: Node2D):
	# If this orb isn't already homing, start homing towards the player
	# that collected the magnet.
	start_homing(player_node)
