## character_button.gd
## A button that displays a single character in the selection screen.
class_name CharacterButton
extends Control

signal character_selected(character_data)

@onready var portrait_rect: TextureRect = $VBoxContainer/TextureRect
@onready var name_label: Label = $VBoxContainer/Label
@onready var select_button: Button = $SelectButton
@onready var panel: Panel = $Panel

var character_data: CharacterData
var is_unlocked: bool = false

## Store data
func set_character(data: CharacterData, unlocked: bool):
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

	name_label.text = character_data.character_name if is_unlocked else "???"
	
	if character_data.character_sprite_frames and character_data.character_sprite_frames.has_animation("default"):
		portrait_rect.texture = character_data.character_sprite_frames.get_frame_texture("default", 0)
	if is_unlocked:
		panel.modulate.a = 0
		portrait_rect.modulate = Color.WHITE
		select_button.disabled = false
	else:
		portrait_rect.modulate = Color.BLACK
		select_button.disabled = true

func _on_select_button_pressed():
	character_selected.emit(character_data)
