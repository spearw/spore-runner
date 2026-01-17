# Weapon Balance Spreadsheet

> **Data Source:** See [weapons.csv](weapons.csv) for raw data with all DPS calculations.

## Factors Considered

| Factor | Description | Impact |
|--------|-------------|--------|
| **Damage** | Base damage per hit | Direct DPS |
| **Fire Rate** | Seconds between attacks | DPS multiplier |
| **Speed** | Projectile velocity (px/s) | Accuracy vs moving targets |
| **Range** | Speed × Lifetime (pixels) | Safety, engagement distance |
| **Homing** | Tracking strength (0-10) | Accuracy, fire-and-forget |
| **Pierce** | Enemies hit per projectile | Multi-target potential |
| **Crit** | Chance % / Bonus damage % | Scaling, burst potential |
| **Armor Pen** | % of armor bypassed | Effectiveness vs tanky enemies |
| **Secondary Effects** | Shockwaves, explosions, ground fire | Total effective damage |
| **Status Effects** | Burning, Poison, etc. | DoT contribution |

---

## DPS Calculation Formula

```
Attacks_Per_Second = 1 / Fire_Rate
Base_DPS = Damage × Attacks_Per_Second
Crit_Multiplier = 1 + (Crit_Rate × Crit_Damage_Bonus)
Crit_DPS = Base_DPS × Crit_Multiplier

Single_Target_DPS = Crit_DPS + Spark_DPS + Secondary_DPS
Multi_Target_DPS = Single_DPS × Effective_Targets

Range = Speed × Lifetime (for projectiles)
```

**Example: Axe**
- Damage: 14, Fire Rate: 1.0s, Crit: 30% chance, +100% bonus
- Base DPS: 14 × 1 = 14.0
- Crit Multiplier: 1 + (0.30 × 1.00) = 1.30
- Crit DPS: 14.0 × 1.30 = **18.2**
- Multi (3 targets): 18.2 × 3 = **54.6**

**Example: Lightning Sword**
- Damage: 10, Fire Rate: 0.8s, Crit: 15% chance, +150% bonus
- Base DPS: 10 × 1.25 = 12.5
- Crit Multiplier: 1 + (0.15 × 1.50) = 1.225
- Crit DPS: 12.5 × 1.225 = **15.3**
- Spark DPS: (6 dmg × 3 bounces) / 0.8s = **22.5**
- Total Single: 15.3 + 22.5 = **37.8**

---

## Melee Weapons

| Weapon | Damage | Fire Rate | Crit % | Crit Mult | Pierce | Armor Pen | Base DPS | Secondary Effect |
|--------|--------|-----------|--------|-----------|--------|-----------|----------|------------------|
| Axe | 14 | 1.0s | 30% | +100% | ∞ | 20% | 18.2 | Large swing arc |
| Spear | 10 | 1.5s | 5% | +50% | ∞ | 20% | 6.8 | Long reach, fast poke |
| Warhammer | 10 | 5.0s | 5% | +150% | ∞ | 60% | 2.2 | **Shockwave**: +10 dmg, ∞ pierce, 100% armor pen, KB 75 |
| Shield | 10 | orbit | 5% | +50% | 5 | 0% | varies | Permanent orbit, knockback 300 |
| Lightning Sword | 10 | 0.8s | 15% | +150% | ∞ | 10% | 15.3 | **SPARK**: +18 chain damage |

**Warhammer Reanalysis** (with shockwave secondary):
- Swing: 10 dmg × 3 targets = 30 damage
- Shockwave: 10 dmg × 5+ targets with **100% armor penetration** = 50+ damage
- Total per attack: ~80 damage → Effective DPS = **16.0** (crowd) / **4.2** (single target)
- The shockwave's 100% armor pen makes it the **best anti-armor weapon**

---

## Ranged Weapons (Single Projectile)

| Weapon | Damage | Fire Rate | Speed | Range* | Homing | Pierce | Base DPS | Notes |
|--------|--------|-----------|-------|--------|--------|--------|----------|-------|
| Dagger | 10 | 1.5s | 400 | 2000 | 0 | 0 | 7.2 | Fast, accurate, single target |
| Bubble Bullet | 6 | 2.0s | 175 | 612 | 0.5 | 0 | 3.0 | NPC weapon (intentionally weak) |
| Spark Dagger | 6 | 0.8s | 600 | 600 | 0 | 1 | 9.8 | Pierce 1, **SPARK** + **CRIT_BOOST** (+15% crit, +50% crit dmg) |

*Range = Speed × Lifetime (pixels)

---

## Ranged Weapons (Multi-Projectile)

| Weapon | Damage | Fire Rate | Speed | Range | Homing | Proj | Pierce | Realistic DPS | Notes |
|--------|--------|-----------|-------|-------|--------|------|--------|---------------|-------|
| Shotgun | 6 | 4.0s | 400 | 400 | 0 | 10 | 1 | ~15-20 | Short range spread, 2 hits/pellet |
| Spike Ring | 15 | 4.0s | 250 | 1000 | 0 | 8 | 0 | ~25 | Radiates outward from player |
| Cinder Volley | 6 | 5.0s | 800 | 3200 | **10** | 3 | 0 | ~10 | Strong homing + Burning DoT |

---

## Fire Weapons (DoT Focus)

**Burning Status:** 2 damage/tick × 1 tick/sec × 5 sec = **10 total DoT per application**

| Weapon | Direct DMG | Fire Rate | Speed | Range | Homing | Pierce | Direct DPS | Secondary Effect |
|--------|------------|-----------|-------|-------|--------|--------|------------|------------------|
| Flamethrower | 1 | 5.0s | 500 | 400 | 0 | 2 | 4.8 | 8 proj, 50% armor pen, **Burning** |
| Cinder Volley | 6 | 5.0s | 800 | 3200 | **10** | 0 | 3.8 | 3 proj, strong tracking, **Burning** |
| Molotov | 1 | 3.0s | 250 | 250 | 0 | 0 | 0.3 | **Ground fire**: 1 dmg/0.3s for 5s + Burning |
| Fireball Staff | 10 | 5.0s | 200 | 500 | 2 | 0 | 2.1 | **Explosion**: 25 dmg, ∞ pierce, 50% armor pen, KB 300 |
| Meteor | 50 | 10.0s | aoe | aoe | 0 | AOE | 15.0 | 3 proj, AOE explosion + **Burning** |

**Effective DPS with Secondary Effects:**

| Weapon | Direct | Ground/Explosion | Burn (per target) | Total DPS (1 target) | Total DPS (5 targets) |
|--------|--------|------------------|-------------------|----------------------|-----------------------|
| Flamethrower | 4.8 | - | 16.0 | 20.8 | ~50+ |
| Cinder Volley | 3.8 | - | 6.0 | 9.8 | ~20 |
| Molotov | 0.3 | 16.7 | 2.0 | **19.0** | **60+** (overlapping fire) |
| Fireball Staff | 2.1 | 5.0 | 2.0 | **9.1** | **30+** (explosion AOE) |
| Meteor | 15.0 | AOE | 6.0 | ~21 | ~50+ |

**Molotov Ground Fire Analysis:**
- Creates fire pool: 1 damage every 0.3s = 3.3 DPS per enemy standing in it
- Duration 5s × 3.3 DPS = 16.7 damage per pool
- Fire rate 3s means pools overlap → massive crowd damage potential

---

## Lightning Weapons (SPARK Focus)

**SPARK Effect (Default):**
- 1 spark × 6 damage × 3 bounces = **18 bonus damage per hit** (spread across enemies)
- Upgrades add spark_count_bonus, spark_damage_bonus, spark_bounce_bonus

| Weapon | Direct DMG | Fire Rate | Speed | Range | Homing | Effects | Direct DPS | Notes |
|--------|------------|-----------|-------|-------|--------|---------|------------|-------|
| Chain Lightning | 12 | 1.5s | 400 | 600 | **5.0** | HOMING, SPARK | 8.5 | Strong tracking, crit 5%/+150% |
| Tesla Coil | 8 | 2.5s | 500 | 1000 | 3.0 | SPARK | 3.5 | Medium tracking |
| Storm Staff | 20 | 3.0s | 350 | 875 | 2.0 | AOE(40), HOMING, SPARK | 7.4 | AOE + tracking, crit 8%/+175% |
| Spark Dagger | 6 | 0.8s | 600 | 600 | 0 | CRIT_BOOST, SPARK | 9.8 | No tracking, high crit 15%/+200% |
| Lightning Sword | 10 | 0.8s | melee | melee | 0 | SPARK | 15.3 | Melee range, crit 15%/+150% |

**Total DPS with SPARK Effect:**

| Weapon | Direct DPS | Spark Bonus* | Total DPS (single) | Total DPS (3+ enemies) |
|--------|------------|--------------|--------------------|-----------------------|
| Chain Lightning | 8.5 | +12.0 | **20.5** | ~35 (sparks chain) |
| Tesla Coil | 3.5 | +7.2 | **10.7** | ~20 |
| Storm Staff | 7.4 | +6.0 | **13.4** | ~25 (AOE + sparks) |
| Spark Dagger | 9.8 | +22.5 | **32.3** | ~45 |
| Lightning Sword | 15.3 | +22.5 | **37.8** | ~60 (melee cleave + sparks) |

*Spark DPS = (spark_damage × bounces) / fire_rate = (6 × 3) / fire_rate

**Tracking/Accuracy Tier:**
- **Excellent** (5+ homing): Chain Lightning - almost never misses
- **Good** (2-3 homing): Tesla Coil, Storm Staff - reliable tracking
- **None** (0 homing): Spark Dagger, Lightning Sword - requires aim/positioning

---

## Poison Weapons

**Poison Status:** 1 damage/tick × 1 tick/sec × 10 sec = **10 total DoT** (same total as Burning, but slower)

| Weapon | Direct DMG | Fire Rate | Speed | Range | Ground Effect | Total DPS |
|--------|------------|-----------|-------|-------|---------------|-----------|
| Poison Cloud | 0 | 6.0s | instant | AOE | 3 dmg/0.3s × 12s + Poison | **~25-40** |

**Poison Cloud Analysis:**
- Projectile does 0 damage, instantly creates ground cloud at target location
- Ground cloud: 3 damage every 0.3s = **10 DPS** per enemy standing in it
- Cloud duration: 12s, fire rate: 6s → 2 clouds active at once (overlap)
- Enemies in cloud also get Poison status (+1 DPS for 10s)
- Total: 10 direct + 1 poison = **11 DPS per enemy in cloud**
- Excellent zone control, punishes stationary/slow enemies

## DPS Tier Summary (Multi-Target/Crowd)

| Tier | Effective | Weapons | Why |
|------|-----------|---------|-----|
| S | Excellent | Lightning Sword, Molotov, Axe, Meteor | High cleave + secondaries |
| A | Very Good | Flamethrower, Spike Ring, Warhammer, Fireball Staff | AOE/pierce + secondaries |
| B | Good | Chain Lightning, Storm Staff, Shotgun, Poison Cloud | Multi-hit or tracking |
| C | Fair | Spear, Tesla Coil, Spark Dagger, Cinder Volley | Limited AOE |
| D | Single-Target | Dagger | No multi-target capability |

---

## Accuracy/Tracking Tier

| Tier | Homing | Weapons | Playstyle |
|------|--------|---------|-----------|
| Auto-aim | 5+ | Chain Lightning, Cinder Volley | Fire and forget |
| Tracking | 2-3 | Tesla Coil, Storm Staff, Fireball Staff | Reliable hits |
| None | 0 | Dagger, Spark Dagger, Shotgun, Spike Ring | Requires positioning |
| Melee | N/A | Axe, Spear, Warhammer, Shield, Lightning Sword | Close range |

---

## Range Tier

| Tier | Range (px) | Weapons | Notes |
|------|------------|---------|-------|
| Long | 1000+ | Cinder Volley (3200), Dagger (2000), Spike Ring (1000), Tesla Coil (1000) | Safe distance |
| Medium | 500-1000 | Chain Lightning (600), Storm Staff (875), Spark Dagger (600), Fireball Staff (500) | Mid-range |
| Short | <500 | Flamethrower (400), Shotgun (400), Molotov (250) | Close range risk |
| Melee | Touch | Axe, Spear, Warhammer, Shield, Lightning Sword | Highest risk |

---

## Balancing Methodology Recommendations

### 1. Target DPS Bands by Weapon Type

Establish baseline DPS targets that account for weapon utility:

| Category | Target Base DPS | Reasoning |
|----------|-----------------|-----------|
| Melee (high risk) | 12-18 | Compensates for close-range danger |
| Ranged (no utility) | 8-12 | Pure damage dealers |
| Ranged (utility) | 5-8 | Homing, crowd control add value |
| DoT-focused | 3-5 direct | Total ~12-18 with status damage |
| AOE-focused | 8-12 total | Divided by average targets hit |

### 2. The "Role" Framework

Every weapon should excel in ONE area:

| Role | Primary Stat | Secondary Benefit | Example |
|------|--------------|-------------------|---------|
| **Assassin** | High single-target DPS | Crit scaling | Cinder Volley, Dagger |
| **Clearer** | Multi-target damage | Wide coverage | Spike Ring, Flamethrower |
| **Debuffer** | Status application | Consistent uptime | Poison Cloud, Molotov |
| **Utility** | Unique mechanic | Situational power | Shield (orbits), Bubble (homing) |
| **Synergy** | Enables other weapons | Tag interactions | Lightning weapons (SPARK chains) |

### 3. Balance Levers

1. **Fire Rate** - Most impactful, easy to tune
2. **Projectile Count** - For multi-shot weapons
3. **Base Damage** - Direct but affects scaling
4. **Pierce/Targets** - Changes single vs multi role
5. **Crit Values** - Careful: multiplicative scaling can explode

Total upgraded weapon should be ~3-5x starting power by endgame.

### 5. Rarity Budget System

Assign "power points" to each stat, ensure rarities are balanced:

| Stat | Points per Unit |
|------|-----------------|
| +1 Damage | 1 point |
| +1 Projectile | 3 points |
| +0.1s Fire Rate | 2 points |
| +1 Pierce | 2 points |
| +5% Crit Chance | 1 point |
| +25% Crit Damage | 1 point |

**Target by rarity:**
- Common: 2-3 points
- Rare: 4-5 points
- Epic: 6-8 points
- Legendary: 10-12 points
- Mythic: 15+ points (or unique effect)

### 6. Practical Testing Checklist

- [ ] Do all weapons feel different to play? (identity check)
- [ ] Are "bad" upgrades still situationally useful? (no trap options)
- [ ] Does every deck have 2-3 viable starting weapons? (deck parity)


## Future: Automated Balance Testing

**Monte Carlo Simulation** could automate balance validation:

1. **Wave Simulation** - Spawn varied enemy compositions, simulate combat
2. **Key Metrics** - Time to clear, survival rate, damage dealt
3. **Compare Weapons** - Identify outliers automatically

Raw DPS formulas are already captured here. The valuable next step is simulating **waves with movement and aiming** - this captures:
- Homing value (auto-aim vs manual)
- Range safety (melee takes more damage)
- Crowd effectiveness (actual enemy density)

**Implementation approach:**
- Python simulation extracting combat math
- No rendering needed - just the numbers
- Run 1000+ iterations per weapon, aggregate results

**Example output:**
```
Weapon               Clear%     Avg Time   Survival%
--------------------------------------------------
Lightning Sword      98.2%       12.3s      45.2%
Dagger               78.5%       22.1s      88.7%
```

This would validate our point system empirically rather than relying solely on theory.
