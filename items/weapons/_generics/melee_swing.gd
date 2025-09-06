## melee_swing.gd
## The controller for the melee swing effect. Plays the animation.
extends Projectile

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox

func _ready():
	# Pass configuration data down to the hitbox.
	hitbox.stats = self.stats
	hitbox.allegiance = self.allegiance
	# Configure self from stats
	hitbox.pierce_count = stats.pierce + 1 if stats.pierce != -1 else -1

	# Configure and start the self-destruct timer.
	lifetime_timer.wait_time = stats.lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(queue_free)
	lifetime_timer.start()
	
	await get_tree().process_frame
	
	# Play the animation.
	animation_player.play("swing")
