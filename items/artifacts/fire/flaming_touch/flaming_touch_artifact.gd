## flaming_touch_artifact.gd
## Ignited enemies gain a fiery aura that spreads Burning to other enemies.
class_name FlamingTouchArtifact
extends ArtifactBase

# --- Configuration ---
# The data for the aura this artifact creates.
@export var aura_stats: PersistentEffectStats
# The scene for the generic aura effect.
const AURA_SCENE = preload("res://items/effects/persistent_damage_effect.tscn")

func on_equipped() -> void:
	Events.status_applied_to_enemy.connect(_on_status_applied_to_enemy)

func on_unequipped() -> void:
	if Events.status_applied_to_enemy.is_connected(_on_status_applied_to_enemy):
		Events.status_applied_to_enemy.disconnect(_on_status_applied_to_enemy)

func _on_status_applied_to_enemy(enemy_node: Node, status_id: String):
	if status_id != "ignited":
		return
		
	if is_instance_valid(enemy_node):
		print("Flaming Touch triggered on ", enemy_node.name)
		
		# Create an instance of the generic persistent effect.
		var aura_instance = AURA_SCENE.instantiate()
		
		# Configure it with our specific data.
		aura_instance.stats = self.aura_stats
		aura_instance.user = self.user
		aura_instance.allegiance = Projectile.Allegiance.PLAYER
		
		# Parent the aura to the ignited enemy.
		enemy_node.add_child(aura_instance)
