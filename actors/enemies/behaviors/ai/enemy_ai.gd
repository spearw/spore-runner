## enemy_ai.gd
## A generic AI brain that manages and executes behavior states.
class_name AIController
extends Node

@onready var anim_controller: AnimationController
var states: Dictionary = {}
var current_state: EnemyBehavior = null
var default_state_node: EnemyBehavior = null
var host: Node

var proximity_detector: Area2D
var proximity_radius: float = 100.0

var _requested_state_node: EnemyBehavior = null
var _requested_context: Dictionary = {}

func _ready():
	host = get_parent()
	var library = get_node("BehaviorLibrary")
	for child in library.get_children():
		if child is EnemyBehavior:
			var state_name = child.name.to_lower()
			states[state_name] = child
			child.enabled = false
	# Configure the host's proximity detector.
	self.proximity_detector = host.proximity_detector
	var proximity_shape = proximity_detector.get_node("CollisionShape2D")
	proximity_shape.shape.radius = self.proximity_radius
	self.proximity_detector.collision_mask = 1 << 1 # enemy_body
	
	anim_controller = host.get_node("AnimationController")
	anim_controller.animation_lock_released.connect(_on_animation_lock_released)

	

# This is called by the host Enemy from its _ready() function.
func initialize_ai(default_state_name: String):
	var key = default_state_name.to_lower()
	if states.has(key):
		self.default_state_node = states[key]
		set_state(self.default_state_node)
	else:
		printerr("AI Brain could not find default state named: ", key)
		# Fallback to the first available state if the name is wrong.
		if not states.is_empty():
			self.default_state_node = states.values()[0]
			set_state(self.default_state_node)

# Update context and set request for new state.
func set_state(new_state_node: EnemyBehavior, context: Dictionary = {}):
	if new_state_node != current_state:
		self._requested_state_node = new_state_node
		self._requested_context = context

func _on_animation_lock_released():
	# The animator says we're free. Check if there's a pending state change.
	_process_state_change(true)

func _physics_process(delta):
	# If the animator is busy, the AI brain does nothing.
	if anim_controller and anim_controller.is_locked:
		return

	# We're not locked, so first, process any pending state change.
	_process_state_change()

	# Then, execute the current behavior.
	if is_instance_valid(current_state):
		current_state.process_behavior(delta, host)
		
## The actual state transition logic.
func _process_state_change(is_finished=false):
	if not is_instance_valid(_requested_state_node):
		return # No request pending.

	# Skip exiting if we've already played it.
	if not is_finished:
		# Deactivate the old state and play its exit animation.
		if is_instance_valid(current_state):
			current_state.enabled = false
			if current_state.has_method("on_exit"):
				current_state.on_exit() # This might trigger an exit animation and re-lock.
				if anim_controller.is_locked:
					return # Wait for the exit animation to finish.
	
	# Execute the change.
	current_state = _requested_state_node
	_requested_state_node = null # Clear the request
	
	current_state.enabled = true
	if current_state.has_method("on_enter"):
		current_state.on_enter(host, _requested_context)

## Find nearby allies
func get_nearby_allies() -> Array[Node2D]:
	var nearby_bodies = proximity_detector.get_overlapping_bodies()
	var my_name = host.stats.display_name
	return nearby_bodies.filter(func(body): return body != host and body.stats.display_name == my_name)
