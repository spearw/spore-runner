## axe_hitbox.gd
extends Area2D

var stats: ProjectileStats
var allegiance: Projectile.Allegiance
var final_damage: float

var pierce_count: int = 0
var hit_targets: Array = [] # Prevent hitting the same enemy twice in one swing

func _ready():
	# We'll use Area2D layers/masks for collision
	if allegiance == Projectile.Allegiance.PLAYER:
		self.collision_mask = 1 << 1 # Scan for enemy_body
	else:
		self.collision_mask = 1 << 0 # Scan for player_body
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if hit_targets.has(body): return # Already hit this target

	if body.has_method("take_damage"):
		body.take_damage(stats.damage)
		hit_targets.append(body)
		if stats.knockback_force > 0 and body.has_method("apply_knockback"):
			body.apply_knockback(stats.knockback_force, get_parent().global_position) # Knockback from player
			
	if pierce_count != -1:
		pierce_count -= 1
		if pierce_count <= 0:
			$CollisionShape2D.disabled = true
