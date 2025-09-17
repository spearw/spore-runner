## enemy_ai.gd
## A generic AI brain that manages and executes behavior states.
class_name AIController
extends Node

var states: Dictionary = {}
var current_state: EnemyBehavior = null
var default_state_node: EnemyBehavior = null
var host: Node

func _ready():
	host = get_parent()
	var library = get_node("BehaviorLibrary")
	for child in library.get_children():
		if child is EnemyBehavior:
			var state_name = child.name.to_lower()
			states[state_name] = child
			child.enabled = false

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

# This brain's only job is to run its current state. More complex brains
# will override this to add decision-making logic.
func _physics_process(delta):
	if is_instance_valid(current_state):
		current_state.process_behavior(delta, host)

func set_state(new_state_node: EnemyBehavior, context: Dictionary = {}):
	if is_instance_valid(current_state):
		current_state.enabled = false
		if current_state.has_method("on_exit"): current_state.on_exit()
			
	current_state = new_state_node
	current_state.enabled = true
	if current_state.has_method("on_enter"): current_state.on_enter(context)

func set_state_by_name(new_state_name: String, context: Dictionary = {}):
	var key = new_state_name.to_lower()
	if states.has(key):
		set_state(states[key], context)
	else:
		printerr("AI Brain could not find state named: ", key)

func restore_default_state():
	if default_state_node:
		set_state(default_state_node)
