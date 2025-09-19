## animation_controller.gd
## Manages animation playback by directly controlling the AnimatedSprite2D.
class_name AnimationController
extends Node

@onready var animated_sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")

# Bool to prevent one shot animations from being interrupted
var is_locked: bool = false
# Signal to send to AIController
signal animation_lock_released

var current_looping_animation: String = ""
var desired_loop_animation: String = ""

func _ready():
	animated_sprite.animation_finished.connect(_on_sprite_animation_finished)

func play_loop(anim_name: String):
	if current_looping_animation == anim_name and not is_locked: return

	self.desired_loop_animation = anim_name
	
	var transition_name = "start_" + anim_name
	
	if animated_sprite.sprite_frames.has_animation(transition_name):
		is_locked = true # Lock the state machine
		animated_sprite.play(transition_name)
		current_looping_animation = ""
	else:
		# If no transition, there's no lock.
		is_locked = false
		animated_sprite.play(anim_name)
		current_looping_animation = anim_name

## This is for playing an exit animation.
func play_exit_and_loop(exit_anim: String, next_loop: String):
	if animated_sprite.sprite_frames.has_animation(exit_anim):
		is_locked = true # Lock the state machine
		self.desired_loop_animation = next_loop
		animated_sprite.play(exit_anim)
		current_looping_animation = ""
	else:
		# If no exit animation, just go straight to the next loop.
		play_loop(next_loop)
		
func play_once(anim_name: String): # For attacks like "fire"
	# Default back to idle after shot.
	self.desired_loop_animation = "idle"
	# Attacks can interrupt loops but shouldn't lock the AI state for long.
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)
		current_looping_animation = ""

func _on_sprite_animation_finished():
	# A one-shot animation is done.
	is_locked = false # Release the lock
	animation_lock_released.emit() # Announce that we're ready for a new state
	
	# Transition to the desired loop.
	if desired_loop_animation != "" and animated_sprite.sprite_frames.has_animation(desired_loop_animation):
		animated_sprite.play(desired_loop_animation)
		current_looping_animation = desired_loop_animation
		
## Checks if animation exists.
func has_animation(anim_name: String) -> bool:
	return animated_sprite.sprite_frames.has_animation(anim_name)
