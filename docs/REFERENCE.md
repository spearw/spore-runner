# Fish Food - Game Reference

*Auto-generated from CSV files on 2026-01-15 17:24*

---

## Decks (Upgrade Packs)

Decks determine which upgrades, weapons, and artifacts are available during a run.

| Name | Theme | Unlock Cost | Upgrades | Weapons | Artifacts | Description |
| --- | --- | --- | --- | --- | --- | --- |
| Core | General | 0 | 11 | 0 | 0 | Fundamentals - stat upgrades (damage/speed/crit/etc.) |
| Fire | FIRE | 100 | 19 | 4 | 3 | DoT on hit with ignite chance - Flamethrower/Cinder Volley/Fireball Staff/Molotov |
| Melee | PHYSICAL | 100 | 19 | 4 | 3 | High damage adjacency - Axe/Hammer/Shield/Spear |
| Projectiles | PHYSICAL | 0 | 0 | 0 | 0 | Bullet hell (not implemented yet) |

## Meta Upgrades (Permanent)

Permanent stat upgrades purchased with souls between runs.

| Name | Stat Key | Effect Per Level | Base Cost | Scaling | Max Level | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Swiftness | move_speed | +2% move speed | 100 | 1.5x | 10 | Multiplicative bonus |
| Power | damage_increase | +3% damage | 100 | 1.5x | 10 | Affects all damage |
| Haste | firerate | +2% attack speed | 100 | 1.5x | 10 | Faster weapon cooldowns |
| Precision | critical_hit_rate | +1% crit chance | 150 | 1.6x | 10 | Stacks with weapon crit |
| Brutality | critical_hit_damage | +5% crit damage | 150 | 1.6x | 10 | Multiplies crit multiplier |
| Toughness | armor | +1 armor | 200 | 1.8x | 5 | Flat damage reduction |
| Vitality | max_health | +10 max HP | 100 | 1.4x | 10 | Flat health bonus |
| Fortune | luck | +5% luck | 150 | 1.7x | 10 | Better upgrade rarities |
| Magnetism | pickup_radius | +10% pickup radius | 75 | 1.3x | 10 | Collect items from farther |
| Wisdom | xp_multiplier | +5% XP gained | 100 | 1.5x | 10 | Faster leveling |

## Weapons

| Name | Theme | Effects | Damage | Fire Rate | Notes |
| --- | --- | --- | --- | --- | --- |
| Fireball Staff | FIRE | DOT, HOMING, EXPLOSIVE | 10 | 5.0 | Explodes on death with burning AOE |
| Flamethrower | FIRE | DOT, PIERCE | 1 | rapid | Short range continuous flame |
| Molotov Cocktail | FIRE | DOT, AOE, EXPLOSIVE | 1 | 3.0 | Creates ground fire on impact |
| Cinder Volley | FIRE | DOT, HOMING, BURST | 6 | 5.0 | Multiple homing fire projectiles |
| Poison Cloud | NATURE | DOT, AOE | 0 | 6.0 | Spawns lingering poison cloud |
| Warhammer | PHYSICAL | PIERCE, AOE, KNOCKBACK, ARMOR_PEN | 10 | 5.0 | Melee swing with shockwave |
| Spike Ring | PHYSICAL | BURST | 15 | 4.0 | Fires 8 spikes in a ring |
| Spear | PHYSICAL | PIERCE, KNOCKBACK, ARMOR_PEN | 15 | 1.5 | Melee thrust with infinite pierce |
| Dagger | PHYSICAL | CRIT_BOOST | 10 | 1.5 | High crit chance (15%) |
| Axe | PHYSICAL | PIERCE, KNOCKBACK, CRIT_BOOST | 14 | 1.0 | Melee swing with high crit (30%) |
| Shotgun | PHYSICAL | PIERCE, KNOCKBACK, BURST | 6 | 4.0 | 10 pellets in spread pattern |
| Shield | PHYSICAL | PIERCE, KNOCKBACK | 10 | 10.0 | Orbiting shield bash |
| Meteor | FIRE | AOE, EXPLOSIVE | 50 | 10.0 | Delayed AOE strike with warning |
| Bubble Bullet | ARCANE | SLOW, KNOCKBACK, HOMING | 6 | 2.0 | Slow-moving homing bubbles |
| Chain Lightning | LIGHTNING | CHAIN, KNOCKBACK | 12 | 1.5 | Bounces between up to 3 enemies |

## Artifacts

Passive items that provide stat bonuses or special effects.

| Name | Deck | Type | Effect | Notes |
| --- | --- | --- | --- | --- |
| Tome of Duplication | Core | Stat | +1 projectile to all weapons | Additive bonus before multipliers |
| Swift Bracer | Core | Stat | 20% faster fire rate | Multiplicative (0.8x fire rate timer) |
| Pyrophobia | Fire | Event | Bonus damage to burning enemies | Scales with DoT upgrades |
| Flaming Touch | Fire | Event | Ignited enemies spread fire aura | Creates chain ignition |
| Smoked Fish | Fire | Event | +50% bonus XP from burning kills | Synergizes with fire weapons |
| Goliath | Melee | Scaling | Bonuses based on bonus HP | Gets stronger with max health upgrades |
| Bloodlust | Melee | Event | Cooldown reduction on kills | Luck-scaled proc chance |
| Redirect | Melee | Ability | Allows redirecting projectiles | Active ability for close-range builds |

## Enemies

| Name | Biome | Type | Size | Behavior | HP | Damage | Speed | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Lil Fishy | FRESHWATER | FISH | SMALL | SWARM | 20 | 4 | 110 | Basic chaser enemy |
| Fish | FRESHWATER | FISH | LARGE | SWARM | 150 | 20 | 90 | Horde behavior - seeks allies |
| Pike | FRESHWATER | FISH | LARGE | FAST | 200 | 15 | 130 | Fast aggressive chaser |
| Jelly | SALTWATER | JELLYFISH | TINY | SWARM | 8 | 5 | 120 | Fragile swarm enemy |
| Seahorse | REEF | FISH | SMALL | RANGED | 16 | 5 | 200 | Shoots daggers |
| Noodle Boy | DEEP | JELLYFISH | TINY | SWARM | 4 | 5 | 160 | Horde behavior jellyfish |
| Bonk Boy | REEF | PLANT | MEDIUM | ARMORED/TANK | 80 | 50 | 80 | Sea anemone - has armor and poison cloud |
| Invisi Jelly | DEEP | JELLYFISH | SMALL | EVASIVE | 18 | 10 | 110 | Has armor penetration |
| Comb Jelly | DEEP | JELLYFISH | LARGE | ARMORED/TANK | 200 | 25 | 40 | Heavy armor (10) shoots spike ring |
| Garden Eel | REEF | FISH | SMALL | RANGED/FAST | 10 | 5 | 250 | Very fast skirmisher with bubble shots |
| Golem Boss | DEEP | CRUSTACEAN | BOSS | ARMORED/TANK | 2000 | 25 | 40 | Boss crab - spike ring and meteors |

## Effects

Effects define mechanical behaviors that projectiles can have.

| Effect | ID | Category | Description | Default Values |
| --- | --- | --- | --- | --- |
| DOT | 0 | Damage | Damage over time (burn/poison) | damage_per_tick: 3.0 | tick_rate: 0.5 | duration: 3.0 |
| SLOW | 1 | Damage | Reduces enemy movement speed | slow_percent: 0.3 | duration: 2.0 |
| CHAIN | 2 | Damage | Bounces to nearby enemies | chain_count: 2 | chain_range: 150 | damage_falloff: 0.8 |
| PIERCE | 3 | Damage | Passes through enemies | pierce_count: 1 |
| AOE | 4 | Damage | Area of effect damage | radius: 50 | falloff: true |
| KNOCKBACK | 5 | Damage | Pushes enemies away | force: 200 |
| HOMING | 6 | Projectile | Tracks targets | strength: 5.0 | acquire_range: 200 |
| BURST | 7 | Projectile | Multiple projectiles per shot | count: 3 | spread_angle: 15 |
| EXPLOSIVE | 8 | Projectile | Explodes on impact | explosion_radius: 75 | explosion_damage_mult: 0.5 |
| LIFESTEAL | 9 | Special | Heals user on hit | percent: 0.1 |
| ARMOR_PEN | 10 | Special | Ignores armor | penetration: 0.5 |
| CRIT_BOOST | 11 | Special | Increased crit chance/damage | crit_chance_bonus: 0.1 | crit_damage_bonus: 0.25 |

## Tags Reference

Tags are used for encounter weighting, weapon synergies, and damage bonuses.

### Theme Tags

| Name | ID | Description |
| --- | --- | --- |
| FIRE | 0 | Fire-themed weapons - typically paired with DOT |
| ICE | 1 | Ice-themed weapons - typically paired with SLOW |
| LIGHTNING | 2 | Lightning-themed - typically paired with CHAIN |
| SALT | 3 | Salt/desiccation - bonus vs freshwater enemies |
| NATURE | 4 | Nature/poison - typically paired with DOT |
| ARCANE | 5 | Pure magic damage |
| PHYSICAL | 6 | Non-elemental physical damage |

### Biome Tags

| Name | ID | Description |
| --- | --- | --- |
| FRESHWATER | 0 | Rivers and lakes |
| SALTWATER | 1 | Ocean and sea |
| DEEP | 2 | Deep ocean / abyss |
| CAVE | 3 | Underwater caves |
| REEF | 4 | Coral reefs |
| TROPICAL | 5 | Tropical waters |
| ARCTIC | 6 | Cold waters |

### Type Tags

| Name | ID | Description |
| --- | --- | --- |
| FISH | 0 | Standard fish enemies |
| JELLYFISH | 1 | Jellyfish and cnidarians |
| CRUSTACEAN | 2 | Crabs and lobsters |
| SLUG | 3 | Sea slugs and nudibranchs |
| CEPHALOPOD | 4 | Octopi and squid |
| MAMMAL | 5 | Dolphins and whales |
| PLANT | 6 | Anemones and seaweed |

### Size Tags

| Name | ID | Description |
| --- | --- | --- |
| TINY | 0 | HP x0.4 | DMG x0.4 | SPD x1.3 | Scale 0.6 |
| SMALL | 1 | HP x0.7 | DMG x0.7 | SPD x1.15 | Scale 0.8 |
| MEDIUM | 2 | HP x1.0 | DMG x1.0 | SPD x1.0 | Scale 1.0 |
| LARGE | 3 | HP x1.6 | DMG x1.3 | SPD x0.8 | Scale 1.3 |
| BOSS | 4 | HP x4.0 | DMG x2.0 | SPD x0.6 | Scale 1.8 |

### Behavior Tags

| Name | ID | Description |
| --- | --- | --- |
| SWARM | 0 | Groups together attacks in numbers |
| RANGED | 1 | Attacks from distance |
| ARMORED | 2 | Has damage resistance |
| FAST | 3 | High movement speed |
| TANK | 4 | High health slow movement |
| EVASIVE | 5 | Dodges or phases through attacks |
