# Weapon Balance Point System

## Core Philosophy

Every weapon gets the same **point budget of 10**. The system is anchored around **Dagger as the perfectly balanced baseline weapon**.

```
Target Budget = 10 points
Dagger (7.2 DPS, 2000 range, no tracking) = 10 points
```

### Why Dagger?
- Single-purpose: pure single-target ranged damage
- Long range (2000px) means safety, but no multi-target
- No homing means skill required
- Represents the "balanced trade-off" archetype

---

## DPS-Based Rating System

Instead of rating raw stats, we rate **outcomes** (DPS) directly, which captures synergies correctly.

### Primary: Single Target DPS Cost

Dagger baseline = 7.2 DPS = 0 cost

| DPS Range | Cost | Notes |
|-----------|------|-------|
| 0-5 | -3 | Very weak |
| 5-10 | 0 | **Baseline** (Dagger) |
| 10-15 | +3 | Good |
| 15-20 | +6 | Strong |
| 20-25 | +9 | Very strong |
| 25-35 | +13 | Overpowered |
| 35+ | +18 | Broken |

### Secondary: Multi-Target Bonus

Multi-target DPS is valuable but secondary to single-target viability.

| Multi/Single Ratio | Cost | Notes |
|-------------------|------|-------|
| 1.0x (same) | 0 | Pure single target |
| 1.5-2x | +1 | Light multi |
| 2-3x | +2 | Good multi |
| 3-5x | +4 | Crowd specialist |
| 5x+ | +6 | AOE monster |

### Range (Safety)

Dagger has 2000px range - very safe. Melee = constant danger.

| Range (px) | Cost | Notes |
|------------|------|-------|
| Melee | -6 | Surrounded constantly |
| 1-300 | -3 | Very risky |
| 300-600 | -1 | Short |
| 600-1000 | +1 | Mid range |
| 1000-1500 | +2 | Safe |
| 1500-2000 | +3 | Very safe |
| 2000+ | +4 | **Dagger baseline** |

### Tracking (Accuracy)

| Homing | Cost | Notes |
|--------|------|-------|
| 0 (aim required) | -2 | **Dagger baseline** |
| 0.5-2 (light) | 0 | Slight assistance |
| 2-5 (medium) | +2 | Reliable |
| 5-10 (strong) | +4 | Auto-target |
| Melee (no tracking needed) | 0 | Hits arc automatically |

### Utility Bonuses

| Effect | Cost | Notes |
|--------|------|-------|
| Armor Pen 20-50% | +1 | Useful vs tanks |
| Armor Pen 50%+ | +2 | Tank killer |
| Burning | +1 | Already in DPS calc |
| Poison | +1 | Already in DPS calc |
| Slow | +3 | Crowd control |
| Knockback 200+ | +1 | Defensive utility |

### Base Value

Every weapon starts with base 8 points. Modifiers adjust from there.

```
Total = 8 + DPS_cost + Multi_cost + Range_cost + Tracking_cost + Utility_cost
Target = 10
```

---

## Complete Weapon Audit (DPS-Based)

Using data from weapons.csv with DPS calculations including SPARK, burning, etc.

### CORE DECK

#### Dagger (BASELINE)
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 7.2 | 0 | Baseline |
| Multi ratio | 1.0x | 0 | Single-target only |
| Range | 2000px | +4 | Very safe |
| Tracking | 0 | -2 | Requires aim |
| Utility | None | 0 | - |
| **TOTAL** | | **10** | **BALANCED** ✓ |

#### Axe
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 18.2 | +6 | Strong |
| Multi ratio | 3.0x (54.6) | +4 | Crowd specialist |
| Range | melee | -6 | High risk |
| Tracking | N/A | 0 | Melee auto-hits |
| Utility | 20% armor pen | 0 | Minor |
| **TOTAL** | | **12** | Slightly over |

**Identity: High-crit melee cleaver**

#### Spear
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 6.8 | 0 | Baseline |
| Multi ratio | 3.0x (20.5) | +4 | Good pierce |
| Range | melee | -6 | High risk |
| Tracking | N/A | 0 | Melee auto-hits |
| Utility | 20% armor pen | 0 | Minor |
| **TOTAL** | | **6** | Under budget |

**Identity: Fast poke, long reach melee**

#### Warhammer
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 4.2 | -3 | Very weak direct |
| Multi ratio | 3.8x (16.0) | +4 | Shockwave AOE |
| Range | melee | -6 | High risk |
| Tracking | N/A | 0 | Melee auto-hits |
| Utility | 60% armor pen, knockback | +3 | Tank killer |
| **TOTAL** | | **6** | Under budget |

**Identity: Slow tank-killer with shockwave**

#### Shield
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | varies | 0 | Orbit depends on density |
| Multi ratio | N/A | +2 | Constant hits |
| Range | orbit | -3 | Must be near enemies |
| Tracking | Auto | 0 | Orbits automatically |
| Utility | Knockback 300 | +1 | Defensive |
| **TOTAL** | | **8** | Slightly under |

**Identity: Defensive orbit, knockback utility**

#### Shotgun
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 15.4 | +3 | Good (10 pellets) |
| Multi ratio | 2.0x (30.8) | +2 | Spread hits multiple |
| Range | 400px | -1 | Short |
| Tracking | 0 | -2 | Requires aim |
| Utility | None | 0 | - |
| **TOTAL** | | **10** | **BALANCED** ✓ |

**Identity: Close-range burst damage**

#### Spike Ring
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 30.8 | +13 | Very strong |
| Multi ratio | 1.0x | 0 | 8 directions, no overlap |
| Range | 1000px | +2 | Safe |
| Tracking | 0 | -2 | Fixed directions |
| Utility | None | 0 | - |
| **TOTAL** | | **21** | **WAY OVER** |

**Identity: 360° coverage**

---

### LIGHTNING DECK

#### Lightning Sword
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 37.8 | +18 | BROKEN (includes SPARK) |
| Multi ratio | 1.6x (60.0) | +1 | SPARK chains |
| Range | melee | -6 | High risk |
| Tracking | N/A | 0 | Melee auto-hits |
| Utility | 10% armor pen | 0 | Minor |
| **TOTAL** | | **21** | **WAY OVER** |

**Identity: Fast melee with chain lightning**

#### Spark Dagger
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 32.3 | +13 | Very strong (SPARK+crit) |
| Multi ratio | 1.4x (45.0) | +1 | SPARK chains |
| Range | 600px | -1 | Short |
| Tracking | 0 | -2 | Requires aim |
| Utility | Crit boost | 0 | Already in DPS |
| **TOTAL** | | **19** | **OVER** |

**Identity: Crit-focused ranged with SPARK**

#### Chain Lightning
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 20.5 | +9 | Strong (SPARK) |
| Multi ratio | 1.7x (35.0) | +1 | Chains to nearby |
| Range | 600px | -1 | Short |
| Tracking | 5 | +4 | Strong homing |
| Utility | None | 0 | - |
| **TOTAL** | | **21** | **WAY OVER** |

**Identity: Homing chain attacks**

#### Tesla Coil
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 10.7 | +3 | Good |
| Multi ratio | 1.9x (20.0) | +1 | SPARK chains |
| Range | 1000px | +2 | Safe |
| Tracking | 3 | +2 | Medium tracking |
| Utility | None | 0 | - |
| **TOTAL** | | **16** | **OVER** |

**Identity: Slow but long-range SPARK**

#### Storm Staff
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 13.4 | +3 | Good |
| Multi ratio | 1.9x (25.0) | +1 | AOE + SPARK |
| Range | 875px | +1 | Mid-safe |
| Tracking | 2 | +2 | Light tracking |
| Utility | AOE 40px | +1 | Small AOE |
| **TOTAL** | | **16** | **OVER** |

**Identity: AOE lightning with tracking**

---

### FIRE DECK

#### Flamethrower
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 17.6 | +6 | Strong |
| Multi ratio | 2.8x (50.0) | +4 | 8 proj × pierce |
| Range | 400px | -1 | Short |
| Tracking | 0 | -2 | Requires aim |
| Utility | 50% armor pen, burn | +2 | Good utility |
| **TOTAL** | | **17** | **OVER** |

**Identity: Close-range crowd burner**

#### Cinder Volley
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 9.8 | 0 | Baseline |
| Multi ratio | 2.0x (20.0) | +2 | Multiple homing |
| Range | 3200px | +4 | Very safe |
| Tracking | 10 | +4 | Strong homing |
| Utility | Burning | +1 | DoT |
| **TOTAL** | | **19** | **OVER** |

**Identity: Long-range homing fire**

#### Molotov
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 19.0 | +6 | Strong (ground fire) |
| Multi ratio | 3.2x (60.0) | +4 | Overlapping pools |
| Range | 250px | -3 | Very short |
| Tracking | 0 | -2 | Requires aim |
| Utility | Burning, zone control | +2 | Good utility |
| **TOTAL** | | **15** | **OVER** |

**Identity: Area denial, crowd damage**

#### Fireball Staff
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 9.1 | 0 | Baseline |
| Multi ratio | 3.3x (30.0) | +4 | Explosion pierce |
| Range | 500px | -1 | Short |
| Tracking | 2 | +2 | Light tracking |
| Utility | 50% armor pen, burn | +2 | Good |
| **TOTAL** | | **15** | **OVER** |

**Identity: Explosive AOE with armor pen**

#### Meteor
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 21.4 | +9 | Very strong |
| Multi ratio | 2.3x (50.0) | +2 | AOE |
| Range | AOE (instant) | 0 | Random target |
| Tracking | N/A | 0 | Auto-targets |
| Utility | Burning | +1 | DoT |
| **TOTAL** | | **20** | **WAY OVER** |

**Identity: Big slow AOE nuke**

---

### POISON DECK

#### Poison Cloud
| Factor | Value | Cost | Notes |
|--------|-------|------|-------|
| Base | - | 8 | Starting value |
| Single DPS | 11.0 | +3 | Good |
| Multi ratio | 3.6x (40.0) | +4 | Large AOE persist |
| Range | instant/AOE | 0 | Spawns on enemies |
| Tracking | N/A | 0 | Auto-targets |
| Utility | Poison, zone | +2 | Good |
| **TOTAL** | | **17** | **OVER** |

**Identity: Large persistent poison zones**

---

## Summary Table

| Weapon | Deck | Points | vs Target (10) | Status |
|--------|------|--------|----------------|--------|
| Dagger | Core | **10** | 0 | ✓ BALANCED |
| Shotgun | Core | **10** | 0 | ✓ BALANCED |
| Shield | Core | 8 | -2 | Slightly under |
| Spear | Core | 6 | -4 | UNDER |
| Warhammer | Core | 6 | -4 | UNDER |
| Axe | Core | 12 | +2 | Slightly over |
| Spike Ring | Core | **21** | +11 | WAY OVER |
| Lightning Sword | Lightning | **21** | +11 | WAY OVER |
| Chain Lightning | Lightning | **21** | +11 | WAY OVER |
| Spark Dagger | Lightning | **19** | +9 | OVER |
| Tesla Coil | Lightning | 16 | +6 | OVER |
| Storm Staff | Lightning | 16 | +6 | OVER |
| Flamethrower | Fire | 17 | +7 | OVER |
| Molotov | Fire | 15 | +5 | OVER |
| Fireball Staff | Fire | 15 | +5 | OVER |
| Cinder Volley | Fire | **19** | +9 | OVER |
| Meteor | Fire | **20** | +10 | WAY OVER |
| Poison Cloud | Poison | 17 | +7 | OVER |

**Target Budget: 10 points**

---

## Rebalancing Recommendations

### Preserve Identity Principle

Each weapon has a **core identity** we must keep:
- **Axe**: High-crit melee cleaver
- **Lightning Sword**: Fast melee with SPARK chains
- **Chain Lightning**: Homing chain attacks
- **Warhammer**: Slow tank-killer with shockwave
- **Molotov**: Area denial crowd damage
- etc.

When nerfing, reduce **non-identity stats** first.

---

### CORE DECK ADJUSTMENTS

#### Spear (6 → 10): BUFF
**Identity: Fast poke with long reach**

| Change | Effect | Points |
|--------|--------|--------|
| Damage 10 → 14 | +3 DPS → 9.5 DPS | +3 |
| Add 5% armor pen → 25% | Tank utility | +1 |

*Becomes a faster Axe alternative with less crit, more consistent.*

#### Warhammer (6 → 10): BUFF
**Identity: Slow tank-killer with shockwave**

| Change | Effect | Points |
|--------|--------|--------|
| Shockwave dmg 10 → 20 | More AOE damage | +2 |
| Armor pen 60% → 80% | True tank killer | +2 |

*Doubles down on the "slow but devastating" identity.*

#### Spike Ring (21 → 10): MAJOR NERF
**Identity: 360° coverage**

| Change | Effect | Points |
|--------|--------|--------|
| Damage 15 → 8 | 30.8 → ~16.5 DPS | -7 |
| Fire rate 4s → 5s | Slower shots | -3 |
| Add pierce 1 | Can hit 2 enemies per spike | +1 |

*Less raw DPS, more utility through pierce. Still great for surrounded situations.*

---

### LIGHTNING DECK ADJUSTMENTS

#### Lightning Sword (21 → 10): MAJOR NERF
**Identity: Fast melee with SPARK chains**

| Change | Effect | Points |
|--------|--------|--------|
| Fire rate 0.8s → 1.2s | 37.8 → ~25 DPS | -6 |
| SPARK bounces 3 → 2 | Less chain damage | -3 |
| Keep crit 15%/+150% | Identity preserved | 0 |
| Add 15% armor pen | Utility compensation | +1 |

*Still fast for melee, still has SPARK, but not 37 DPS anymore.*

#### Spark Dagger (19 → 10): NERF
**Identity: Crit-focused ranged with SPARK**

| Change | Effect | Points |
|--------|--------|--------|
| Crit damage +200% → +150% | Less crit spike | -3 |
| Fire rate 0.8s → 1.0s | Slower attacks | -3 |
| Range 600 → 800 | Safer positioning | +1 |
| SPARK bounces 3 → 2 | Less chain | -2 |

*Keeps crit identity but requires better aim, rewards positioning.*

#### Chain Lightning (21 → 10): MAJOR NERF
**Identity: Homing chain attacks**

| Change | Effect | Points |
|--------|--------|--------|
| Damage 12 → 8 | Lower base | -3 |
| Homing 5 → 3 | Still reliable | -2 |
| SPARK bounces 3 → 2 | Less chain | -2 |
| Fire rate 1.5s → 2.0s | Slower | -2 |
| Range 600 → 900 | More safety | +1 |

*Still the "set it and forget it" option but at lower throughput.*

#### Tesla Coil (16 → 10): NERF
**Identity: Slow long-range SPARK**

| Change | Effect | Points |
|--------|--------|--------|
| Fire rate 2.5s → 3.5s | Much slower | -3 |
| SPARK bounces 3 → 2 | Less chain | -2 |
| Damage 8 → 10 | Slightly better base | +1 |

*Becomes the "sniper" of lightning - slow, long range, reliable.*

#### Storm Staff (16 → 10): NERF
**Identity: AOE lightning with tracking**

| Change | Effect | Points |
|--------|--------|--------|
| Fire rate 3.0s → 4.0s | Slower | -3 |
| AOE 40 → 30 | Smaller explosion | -1 |
| Damage 20 → 22 | Compensation | +1 |

*Slower but punchier AOE bursts.*

---

### FIRE DECK ADJUSTMENTS

#### Flamethrower (17 → 10): NERF
**Identity: Close-range crowd burner**

| Change | Effect | Points |
|--------|--------|--------|
| Proj count 8 → 6 | Fewer flames | -3 |
| Pierce 2 → 1 | Less penetration | -2 |
| Fire rate 5s → 4s | Faster burst | +2 |

*Faster bursts but narrower cone, rewards positioning.*

#### Cinder Volley (19 → 10): MAJOR NERF
**Identity: Long-range homing fire**

| Change | Effect | Points |
|--------|--------|--------|
| Homing 10 → 5 | Still good tracking | -2 |
| Proj count 3 → 2 | Fewer projectiles | -2 |
| Fire rate 5s → 6s | Slower | -1 |
| Range 3200 → 2400 | Still safe | -1 |
| Damage 6 → 8 | Compensation | +1 |

*Reliable homing but not overwhelming volume.*

#### Molotov (15 → 10): NERF
**Identity: Area denial, crowd damage**

| Change | Effect | Points |
|--------|--------|--------|
| Fire rate 3s → 4s | Fewer overlapping pools | -3 |
| Ground persist 5s → 4s | Shorter duration | -2 |

*Still creates fire zones but less overlap abuse.*

#### Fireball Staff (15 → 10): NERF
**Identity: Explosive AOE with armor pen**

| Change | Effect | Points |
|--------|--------|--------|
| Fire rate 5s → 6s | Slower | -2 |
| Explosion damage 25 → 20 | Less burst | -2 |
| Add slight homing 3 | Compensation | +1 |

*Slower explosions but more reliable targeting.*

#### Meteor (20 → 10): MAJOR NERF
**Identity: Big slow AOE nuke**

| Change | Effect | Points |
|--------|--------|--------|
| Damage 50 → 35 | Less per meteor | -4 |
| Proj count 3 → 2 | Fewer meteors | -2 |
| Fire rate 10s → 12s | Even slower | -2 |
| Burning duration +1s | Compensation | +1 |

*Truly slow but satisfying nukes. Quality over quantity.*

---

### POISON DECK ADJUSTMENTS

#### Poison Cloud (17 → 10): NERF
**Identity: Large persistent poison zones**

| Change | Effect | Points |
|--------|--------|--------|
| Tick rate 0.3s → 0.4s | Slower damage ticks | -3 |
| Duration 12s → 10s | Shorter persistence | -2 |
| AOE size +20% | Larger coverage | +1 |

*Bigger zones but lower damage density.*

---

## Implementation Priority

**Phase 1 - Critical Nerfs** (breaks game balance):
1. Lightning Sword (-11 points)
2. Chain Lightning (-11 points)
3. Spike Ring (-11 points)
4. Meteor (-10 points)

**Phase 2 - Moderate Nerfs** (over budget):
5. Spark Dagger (-9 points)
6. Cinder Volley (-9 points)
7. Tesla Coil (-6 points)
8. Storm Staff (-6 points)
9. Flamethrower (-7 points)
10. Poison Cloud (-7 points)

**Phase 3 - Minor Adjustments**:
11. Molotov (-5 points)
12. Fireball Staff (-5 points)
13. Axe (-2 points)

**Phase 4 - Buffs**:
14. Spear (+4 points)
15. Warhammer (+4 points)
16. Shield (+2 points)

---

## Post-Balance Target State

| Weapon | Current | Target | Change |
|--------|---------|--------|--------|
| All weapons | varies | 10 | Normalized |

After rebalancing:
- **All weapons viable** at baseline
- **Upgrades matter more** since base isn't carrying
- **Build diversity** since no weapon is clearly best
- **Identity preserved** - each weapon feels different
