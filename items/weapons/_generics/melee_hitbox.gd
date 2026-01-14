## melee_hitbox.gd
extends Area2D

var stats: ProjectileStats
var allegiance: Projectile.Allegiance

var pierce_count: int = 0
var hit_targets: Array = [] # Prevent hitting the same enemy twice in one swing


func _ready():
	# Configure collision based on allegiance (using CollisionUtils).
	if allegiance == Projectile.Allegiance.PLAYER:
		self.collision_mask = 1 << CollisionUtils.LAYER_ENEMY_BODY
	else:
		self.collision_mask = 1 << CollisionUtils.LAYER_PLAYER_BODY

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if hit_targets.has(body): return # Already hit this target

	if body.has_method("take_damage"):
		# Roll for crit using DamageUtils.
		var crit_result = DamageUtils.roll_crit(stats.damage, stats.critical_hit_rate, stats.critical_hit_damage)
		var damage = crit_result["damage"]
		var is_crit = crit_result["is_crit"]

		var hit_details = {
			"enemy": body,
			"weapon": get_parent().weapon,
			"damage": damage,
			"position": body.global_position
		}
		Events.emit_signal("enemy_hit", hit_details, is_crit)
		body.take_damage(damage, stats.armor_penetration, is_crit)
		hit_targets.append(body)

		if stats.knockback_force > 0 and body.has_method("apply_knockback"):
			body.apply_knockback(stats.knockback_force, get_parent().global_position)

	if pierce_count != -1:
		pierce_count -= 1
		if pierce_count <= 0:
			$CollisionShape2D.disabled = true
