## hud.gd
## Manages the Heads-Up Display, like the XP bar and level text.
extends CanvasLayer

@onready var xp_bar: TextureProgressBar = $ExperienceBar
@onready var level_label: Label = $LevelLabel
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var damage_flash: ColorRect = $DamageFlash
@onready var time_label: Label = $GameTimer

var tween

func _ready():
	# Wait a frame to ensure the player exists, then connect.
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Connect listeners
		player.experience_changed.connect(_on_player_experience_changed)
		player.leveled_up.connect(_on_player_leveled_up)
		player.health_changed.connect(_on_player_health_changed)
		player.took_damage.connect(_on_player_took_damage)
		
		# Initialize with player's starting values.
		_on_player_experience_changed(player.current_experience, player.experience_to_next_level)
		_on_player_leveled_up(player.level)
		# Initialize the health bar
		_on_player_health_changed(player.current_health, player.max_health)

func _on_player_experience_changed(current_xp: int, required_xp: int):
	xp_bar.max_value = required_xp
	xp_bar.value = current_xp

func _on_player_leveled_up(new_level: int):
	level_label.text = "LVL %s" % new_level
	
## Called by the player's 'health_changed' signal.
func _on_player_health_changed(current_health: int, max_health: int):
	health_bar.max_value = max_health
	health_bar.value = current_health
	
## Handle screen flash when player takes damage
func _on_player_took_damage():
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()

	# Only animate modulate.a (color.a should stay at 1.0 in the scene)
	damage_flash.modulate.a = 0.4

	# Create the tween to animate it to zero.
	tween.tween_property(damage_flash, "modulate:a", 0.0, 0.3)\
		.set_trans(Tween.TRANS_SINE)
		
## Formats seconds into a MM:SS string and updates the label.
func update_time(seconds: float):
	# floori ensures we only get whole seconds.
	var total_seconds = floori(seconds)
	var minutes = total_seconds / 60
	var remaining_seconds = total_seconds % 60
	# The "%02d" format specifier ensures there's a leading zero for single-digit numbers.
	time_label.text = "%02d:%02d" % [minutes, remaining_seconds]
