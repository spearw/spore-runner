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
		
		active_statuses[status_instance.id] = {
			"effect": status_instance,
			"timer": duration_timer,
			"source": source
		}
		
		duration_timer.start()
		status_instance.on_apply(self, source)

func _on_status_expired(status_id: String, source):
	if active_statuses.has(status_id):
		var status_instance = active_statuses[status_id]["effect"]
		var timer = active_statuses[status_id]["timer"]
		
		active_statuses.erase(status_id)
		timer.queue_free()
		
		status_instance.on_expire(self, source)
