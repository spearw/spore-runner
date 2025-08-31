## upgrade_pack_button.gd
## A button for selecting an UpgradePack in the pre-run screen.
class_name UpgradePackButton
extends PanelContainer

# Signal to notify the parent when the selection state changes.
# Passes itself as an argument so the parent knows which button was toggled.
signal selection_toggled(button_instance)

@onready var icon_rect: TextureRect = $VBoxContainer/IconRect
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var select_button: CheckButton = $SelectButton

var pack_data: UpgradePack
var is_unlocked: bool = false

func _ready():
	update_display()
	select_button.toggled.connect(_on_selection_toggled)

func set_pack_data(data: UpgradePack, unlocked: bool):
	self.pack_data = data
	self.is_unlocked = unlocked

func update_display():
	name_label.text = pack_data.pack_name if is_unlocked else "LOCKED"
	
	if is_unlocked:
		icon_rect.texture = pack_data.pack_icon
		self.modulate = Color.WHITE
		select_button.disabled = false
	else:
		icon_rect.texture = null
		self.modulate = Color.DARK_GRAY
		select_button.disabled = true

## Public property to get the selection state.
func is_selected() -> bool:
	return select_button.button_pressed

## Public method to set the selection state from the parent.
func set_selected(value: bool):
	select_button.button_pressed = value

## Internal signal handler.
func _on_selection_toggled(is_pressed: bool):
	# Announce the change to the parent panel.
	selection_toggled.emit(self)
