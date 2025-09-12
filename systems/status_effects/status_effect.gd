## status_effect.gd
## A Resource that defines the properties of a status effect like Burning or Poisoned.
class_name StatusEffect
extends Resource

# Properties
@export var id: String
@export var duration: float = 5.0
@export var icon: Texture2D
@export var modulate_color: Color = Color.WHITE # Simple color modulation
@export var vfx_sprite_frames: SpriteFrames # Optional visual for status

## Called once when the status is first applied to a target.
func on_apply(manager: StatusEffectManager, source):
	pass

## Called every physics frame while the status is active.
func on_process(manager: StatusEffectManager, delta: float, source):
	pass

## Called once when the status effect expires or is removed.
func on_expire(manager: StatusEffectManager, source):
	pass
