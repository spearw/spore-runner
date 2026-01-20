## character_button.gd
## A button that displays a single character in the selection screen.
class_name CharacterButton
extends PanelContainer

signal character_selected(character_data)

@onready var portrait_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var name_label: Label = $MarginContainer/VBoxContainer/Label
@onready var select_button: Button = $SelectButton
@onready var selection_border: Panel = $SelectionBorder

var character_data: PlayerStats
var is_unlocked: bool = false
var _is_selected: bool = false

## Store data
func set_character(data: PlayerStats, unlocked: bool):
	self.character_data = data
	self.is_unlocked = unlocked

func _ready():
	# Update display
	update_display()
	select_button.pressed.connect(_on_select_button_pressed)

## Update display
func update_display():
	# This check is a good safeguard.
	if not is_instance_valid(name_label) or not character_data:
		return

	name_label.text = character_data.display_name if is_unlocked else "???"

	if character_data.sprite_frames and character_data.sprite_frames.has_animation("default"):
		portrait_rect.texture = character_data.sprite_frames.get_frame_texture("default", 0)
	if is_unlocked:
		portrait_rect.modulate = Color.WHITE
		select_button.disabled = false
	else:
		portrait_rect.modulate = Color.BLACK
		select_button.disabled = true

	_update_selection_visual()

func set_selected(value: bool):
	_is_selected = value
	_update_selection_visual()

func is_selected() -> bool:
	return _is_selected

func _update_selection_visual():
	if not is_instance_valid(selection_border):
		return
	selection_border.visible = _is_selected

func _on_select_button_pressed():
	character_selected.emit(character_data)
