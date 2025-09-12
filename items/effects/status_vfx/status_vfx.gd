## status_vfx.gd
## A simple container for a looping visual effect.
extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# This will be set by the StatusEffectManager.
var sprite_frames_resource: SpriteFrames

func _ready():
	if sprite_frames_resource:
		animated_sprite.sprite_frames = sprite_frames_resource
		animated_sprite.play("active")
