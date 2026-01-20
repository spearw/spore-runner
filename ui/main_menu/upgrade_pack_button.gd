## upgrade_pack_button.gd
## A button for selecting an UpgradePack in the pre-run screen.
class_name UpgradePackButton
extends PanelContainer

# Signal to notify the parent when the selection state changes.
# Passes itself as an argument so the parent knows which button was toggled.
signal selection_toggled(button_instance)

@onready var icon_rect: TextureRect = $MarginContainer/VBoxContainer/HeaderRow/IconRect
@onready var name_label: Label = $MarginContainer/VBoxContainer/HeaderRow/NameLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var select_button: Button = $SelectButton
@onready var selection_border: Panel = $SelectionBorder

var pack_data: UpgradePack
var is_unlocked: bool = false
var _is_selected: bool = false

func _ready():
	update_display()
	select_button.pressed.connect(_on_button_pressed)

func set_pack_data(data: UpgradePack, unlocked: bool):
	self.pack_data = data
	self.is_unlocked = unlocked

func update_display():
	if not is_instance_valid(name_label):
		return

	name_label.text = pack_data.pack_name if is_unlocked else "LOCKED"
	description_label.text = pack_data.pack_description if is_unlocked else ""

	if is_unlocked:
		icon_rect.texture = pack_data.pack_icon
		self.modulate = Color.WHITE
		select_button.disabled = false
	else:
		icon_rect.texture = null
		self.modulate = Color.DARK_GRAY
		select_button.disabled = true

	_update_selection_visual()

## Public property to get the selection state.
func is_selected() -> bool:
	return _is_selected

## Public method to set the selection state from the parent.
func set_selected(value: bool):
	_is_selected = value
	_update_selection_visual()

func _update_selection_visual():
	if not is_instance_valid(selection_border):
		return
	selection_border.visible = _is_selected

## Internal signal handler - toggles selection on click.
func _on_button_pressed():
	if is_unlocked:
		_is_selected = not _is_selected
		_update_selection_visual()
		selection_toggled.emit(self)
