## targeting_picker.gd
## A pop-up that lets the player choose a targeting mode for a weapon.
extends PanelContainer

signal targeting_mode_selected(new_mode_enum)

@onready var button_container: VBoxContainer = $VBoxContainer

var weapon_node: Node

## Opens the picker and populates it with choices for a specific weapon.
func open_for_weapon(target_weapon: Node):
	self.weapon_node = target_weapon
	if not is_instance_valid(weapon_node):
		close()
		return
		
	_populate_buttons()
	# We can position it near the mouse or the weapon icon later.
	self.show()

func _populate_buttons():
	for child in button_container.get_children(): child.queue_free()
	
	# Since targeting is a core mechanic, we show all basic modes.
	var all_modes = TargetingComponent.TargetingMode.keys()
	
	for mode_name in all_modes:
		var button = Button.new()
		button.text = mode_name.capitalize()
		# Get the enum value from the name.
		var mode_enum = TargetingComponent.TargetingMode[mode_name]
		button.pressed.connect(_on_mode_button_pressed.bind(mode_enum))
		button_container.add_child(button)

func _on_mode_button_pressed(new_mode_enum: TargetingComponent.TargetingMode):
	var targeting_comp = weapon_node.get_node_or_null("TargetingComponent")
	if targeting_comp:
		targeting_comp.targeting_mode = new_mode_enum
		print("Set %s targeting to %s" % [weapon_node.name, TargetingComponent.TargetingMode.keys()[new_mode_enum]])
	
	close()

func close():
	self.hide()
