## festering_wounds_artifact.gd -- Venom deck: each poison stack festers the wound, suppressing
## 20% of every heal the enemy receives; at five stacks wounds cannot close at all. By design this
## flips the regenerator counter the way Lethal Dose does (artifacts may turn a counter on its
## head -- user call, Jul 2026), and it answers the Cleaner Wrasse's mending through the same
## enemy.heal() choke point. The artifact just announces itself via the stat; the enemy-side
## filter does the arithmetic.
extends ArtifactBase

func get_fester_per_stack_bonus() -> float:
	return 0.2
