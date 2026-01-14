## collision_utils.gd
## Utility class for setting up collision layers and masks consistently.
## Centralizes the collision layer constants to avoid magic numbers scattered throughout the codebase.
class_name CollisionUtils
extends RefCounted

## Physics Layer Constants (from project.godot)
## These match the layer names defined in Project Settings > Layer Names > 2D Physics.
const LAYER_PLAYER_BODY = 0        # Layer 1: player_body
const LAYER_ENEMY_BODY = 1         # Layer 2: enemy_body
const LAYER_PLAYER_PROJECTILE = 2  # Layer 3: player_projectile
const LAYER_PICKUPS = 3            # Layer 4: pickups
const LAYER_ENEMY_PROJECTILE = 4   # Layer 5: enemy_projectile
const LAYER_PLAYER_AOE = 5         # Layer 6: player_aoe
const LAYER_ENEMY_AOE = 6          # Layer 7: enemy_aoe

## Configures an Area2D as a player projectile (hits enemies).
static func set_player_projectile(area: Area2D) -> void:
	area.collision_layer = 1 << LAYER_PLAYER_PROJECTILE
	area.collision_mask = 1 << LAYER_ENEMY_BODY

## Configures an Area2D as an enemy projectile (hits player).
static func set_enemy_projectile(area: Area2D) -> void:
	area.collision_layer = 1 << LAYER_ENEMY_PROJECTILE
	area.collision_mask = 1 << LAYER_PLAYER_BODY

## Configures an Area2D based on Projectile.Allegiance enum.
static func set_projectile_collision(area: Area2D, allegiance: int) -> void:
	# allegiance: 0 = PLAYER, 1 = ENEMY, 2 = NONE (from Projectile.Allegiance enum)
	match allegiance:
		0: # Projectile.Allegiance.PLAYER
			set_player_projectile(area)
		1: # Projectile.Allegiance.ENEMY
			set_enemy_projectile(area)
		_:
			# NONE or invalid - no collision
			area.collision_layer = 0
			area.collision_mask = 0

## Configures an Area2D as a player AOE (hits enemies).
static func set_player_aoe(area: Area2D) -> void:
	area.collision_layer = 1 << LAYER_PLAYER_AOE
	area.collision_mask = 1 << LAYER_ENEMY_BODY

## Configures an Area2D as an enemy AOE (hits player).
static func set_enemy_aoe(area: Area2D) -> void:
	area.collision_layer = 1 << LAYER_ENEMY_AOE
	area.collision_mask = 1 << LAYER_PLAYER_BODY

## Configures an Area2D to detect pickups (for player pickup radius).
static func set_pickup_detector(area: Area2D) -> void:
	area.collision_layer = 0
	area.collision_mask = 1 << LAYER_PICKUPS

## Disables all collision for an Area2D.
static func disable_collision(area: Area2D) -> void:
	area.collision_layer = 0
	area.collision_mask = 0

## Returns the appropriate target group name for a given allegiance.
## Useful for body.is_in_group() checks.
static func get_target_group(allegiance: int) -> String:
	match allegiance:
		0: # PLAYER allegiance hits enemies
			return "enemies"
		1: # ENEMY allegiance hits player
			return "player"
		_:
			return ""
