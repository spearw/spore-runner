## hud.gd
## Manages the Heads-Up Display, like the XP bar and level text.
extends CanvasLayer

@onready var xp_bar: TextureProgressBar = $TextureProgressBar
@onready var level_label: Label = $Label

func _ready():
	# Wait a frame to ensure the player exists, then connect.
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.experience_changed.connect(_on_player_experience_changed)
		player.leveled_up.connect(_on_player_leveled_up)
		# Initialize with player's starting values.
		_on_player_experience_changed(player.current_experience, player.experience_to_next_level)
		_on_player_leveled_up(player.level)

func _on_player_experience_changed(current_xp: int, required_xp: int):
	xp_bar.max_value = required_xp
	xp_bar.value = current_xp

func _on_player_leveled_up(new_level: int):
	level_label.text = "LVL %s" % new_level
