## status_effect_manager.gd
## A generic component that hosts and executes any type of StatusEffect.
class_name StatusEffectManager
extends Node

# Key: status.id, Value: a dictionary containing the effect and its timer
var active_statuses: Dictionary = {}
var host: Node

func _ready():
	host = get_parent()

func _physics_process(delta: float):
	# Loop through all active statuses and call their process function.
	for status_id in active_statuses.keys():
		var status_instance = active_statuses[status_id]["effect"]
		var source = active_statuses[status_id]["source"]
		status_instance.on_process(self, delta, source)

func apply_status(status_resource: StatusEffect, source: Node):
	if not status_resource: return
	
	# Duplicate the resource to create a unique instance for this enemy.
	var status_instance: StatusEffect = status_resource.duplicate(true)

	if active_statuses.has(status_instance.id):
		# Status already exists: refresh its duration.
		active_statuses[status_instance.id]["timer"].start(status_instance.duration)
	else:
		# This is a new status.
		var duration_timer = Timer.new()
		duration_timer.one_shot = true
		duration_timer.wait_time = status_instance.duration
		duration_timer.timeout.connect(func(): _on_status_expired(status_instance.id, source))
		add_child(duration_timer)
		var vfx_instance = _apply_visuals(status_instance)
		
		active_statuses[status_instance.id] = {
			"effect": status_instance,
			"timer": duration_timer,
			"source": source,
			"vfx_instance": vfx_instance
		}
		
		duration_timer.start()
		status_instance.on_apply(self, source)

func _on_status_expired(status_id: String, source):
	if active_statuses.has(status_id):
		var status_instance = active_statuses[status_id]["effect"]
		var timer = active_statuses[status_id]["timer"]
		var vfx_instance = active_statuses[status_id]["vfx_instance"]
		_remove_visuals(	status_instance, vfx_instance)
		
		active_statuses.erase(status_id)
		timer.queue_free()
		
		status_instance.on_expire(self, source)
		
func _apply_visuals(status_instance: StatusEffect):
	var vfx_instance = null
	var host_sprite = host.get_node_or_null("AnimatedSprite2D")

	if status_instance.vfx_sprite_frames:
		# This status has a complex animated effect.
		vfx_instance = preload("res://items/effects/status_vfx/status_vfx.tscn").instantiate()
		vfx_instance.sprite_frames_resource = status_instance.vfx_sprite_frames
		host.add_child(vfx_instance) # Attach the VFX
	elif status_instance.modulate_color != Color.WHITE and host_sprite:
		# Recalcuate modulation based on all active status effects.
		host_sprite.modulate = host_sprite.modulate * status_instance.modulate_color
	return vfx_instance
	
func _remove_visuals(status_instance: StatusEffect, vfx_instance):
		if is_instance_valid(vfx_instance):
			# Remove vfx scene is it exists
			vfx_instance.queue_free()
		else:
			# Unapply any color modulation
			var host_sprite = host.get_node_or_null("AnimatedSprite2D")
			if host_sprite and status_instance.modulate_color != Color.WHITE:
				# Recalcuate modulation based on all active status effects.
				_recalculate_sprite_modulate(host_sprite)
	
func _recalculate_sprite_modulate(host_sprite):
	if not host_sprite: return
	
	var final_color = Color.WHITE
	for status_id in active_statuses:
		var status_effect = active_statuses[status_id]["effect"]
		final_color = final_color * status_effect.modulate_color
	
	host_sprite.modulate = final_color
