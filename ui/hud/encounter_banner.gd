## encounter_banner.gd
## A banner that displays the current encounter config at the start of a run.
## Animates in, shows for a duration, then animates out.
extends Control

@export var display_duration: float = 3.0
@export var fade_duration: float = 0.5

@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var description_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel

func _ready():
	# Start hidden
	modulate.a = 0.0

	# Show the banner if we have a config
	if CurrentRun.selected_encounter_config:
		show_config(CurrentRun.selected_encounter_config)

func show_config(config: EncounterConfig):
	if not config:
		return

	title_label.text = config.display_name
	description_label.text = config.description

	# Animate in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_SINE)

	# Wait for display duration
	tween.tween_interval(display_duration)

	# Animate out
	tween.tween_property(self, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_SINE)

	# Hide when done
	tween.tween_callback(hide)
