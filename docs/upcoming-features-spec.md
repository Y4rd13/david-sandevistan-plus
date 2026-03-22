# Upcoming Features — Technical Spec

All four features have been implemented.

---

## Feature 1: Cyberpsychosis Auto-Attack (Stage 3-5) — IMPLEMENTED

V involuntarily attacks nearby NPCs — loss of motor control. Uses `AIWeapon.Fire()` (same method as Wannabe Edgerunner) to fire V's weapon at a detected NPC. Does not require aiming. If no weapon is drawn, `EquipmentSystem` auto-draws from the weapon wheel slot before firing.

### Trigger Points

Four trigger points, each with stage-scaled chances:

| Trigger | Stage 3 | Stage 4 | Stage 5 | Source |
|---------|---------|---------|---------|--------|
| Manic laugh (micro-episode) | 30% | 50% | 70% | `FireMicroEpisode()` in psychosis.lua |
| Stage change (FrightenNPCs) | 40% | 60% | 80% | `FrightenNPCs()` in psychosis.lua |
| Low runtime (<10%, per second) | 10% | 20% | 35% | `CheckLowRuntimeAutoAttack()` in psychosis.lua |
| Nosebleed (on activation) | 5% | 15% | 25% | `Nosebleed()` in loreEffects.lua |

### Detection Flow
```
1. Guard checks:
   - Stage 3+ required (CyberPsychoWarnings >= 3)
   - Not in menu, braindance, or Last Breath
   - 30s cooldown between attacks (autoAttackCooldown)
   - Random roll against trigger-specific chance

2. Target detection:
   - Game.GetTargetingSystem():GetLookAtObject(V, false, false)
   - Must be NPC (target:IsNPC())
   - Must be within 15m range

3. Attack execution:
   - If weapon in hand (V:GetActiveWeapon()): fire immediately via AIWeapon.Fire() + ono_v_laughs_hard
   - If no weapon: DrawItemRequest → 2s delay (autoAttackFireTime) → AIWeapon.Fire() + ono_v_laughs_hard
   - AIWeapon.Fire(V, weapon, simTime, 1.0, triggerMode) — single shot, instantaneous
   - UpdateAutoAttack() handles the delayed fire after weapon draw

4. Visual feedback:
   - Red outline on target NPC for 2s (OutlineRequestEvent, EOutlineType.RED)
   - PsychoWarningEffect_Medium VFX on V
   - PsychoLaughEffect if not already laughing (fromLaugh parameter)
   - Camera shake spike (tremor 0.008)
   - Stage-aware message from pool

5. Consequences:
   - Target NPC becomes hostile (SetAttitudeTowards AIA_Hostile)
   - Gunshot stimulus broadcast (30m radius — NPCs flee, NCPD reacts)
```

### Weapon Auto-Draw (FrightenNPCs)

During psychosis episodes, `FrightenNPCs()` forces a weapon draw before auto-attack via `DrawItemRequest`:
```lua
local es = V:GetEquipmentSystem()
local drawReq = DrawItemRequest.new()
local espd = EquipmentSystem.GetData(V)
drawReq.itemID = espd:GetItemInEquipSlot(gamedataEquipmentArea.WeaponWheel, 0)
drawReq.owner = V
es:QueueRequest(drawReq)
```

### Combat Buffs (FrightenNPCs + Last Breath)

`PsychosisCombatBuff` is applied during psychosis episodes and Last Breath decay:
- +50% movement speed (MaxSpeed x1.5)
- +100% armor (Armor x2.0)
- x10 health regeneration in combat (HealthInCombatRegenRate x10.0)

### Cycled SFX

`ui_gmpl_perk_edgerunner` (Edgerunner perk sound) fires during psychosis episodes (FrightenNPCs) and at Last Breath decay start.

### Messages Pool (stage-aware)
```
Stage 3:
  "What did I just do..."
  "I didn't mean to... my hand moved on its own"
  "No... that wasn't me"

Stage 4:
  "Can't control it... something's wrong"
  "My hand... it moved on its own"
  "NO... STOP..."

Stage 5:
  "THEY WERE LOOKING AT ME"
  "Had to... had to do it"
  "More... need more"
```

### Implementation

- `TryAutoAttack(chance, fromLaugh)` in psychosis.lua: core auto-attack function
- `CheckLowRuntimeAutoAttack()` in psychosis.lua: per-second check for runtime <10%
- `UpdateAutoAttack()` in psychosis.lua: no-op (AIWeapon.Fire is instantaneous)
- Weapon draw in `FrightenNPCs()` via EquipmentSystem
- Combat buffs in `FrightenNPCs()` and `UpdateLastBreath()` decay transition

---

## Feature 2: Hallucinations (Stage 3-5) — IMPLEMENTED

V sees and hears things that aren't real.

### Tier 1: VFX + Audio Hallucinations (micro-episode system)
- Visual glitch: `PsychoWarningEffect_Light` (0.5-1.5s)
- Medium glitch: `PsychoWarningEffect_Medium` (1.5-3s)
- Nosebleed: `NosebleedEffect` (3s)
- Audio: `quickhack_shortcircuit` on phantom spawn

### Tier 2: Phantom NPCs (implemented)

Phantom NPCs spawn near V via `exEntitySpawner.SpawnRecord()` and despawn after a stage-dependent delay.

#### Trigger
- Stage 3: every 3-5 min, 1 phantom NPC
- Stage 4: every 1-3 min, 1 phantom NPC
- Stage 5: every 30-60s, 1 phantom NPC
- Suppressed by immunoblocker (full/partial effectiveness)
- Suppressed during Last Breath

#### Spawn Flow
```
1. Select random NPC record:
   - Character.otr_service_vendor_ma
   - Character.otr_service_vendor_wa
   - Character.Grilled_Food
   - Character.Chinese_Food_Woman

2. Calculate spawn position:
   - 5-15m from V, in V's forward direction
   - ±1 radian lateral offset for variety

3. Spawn:
   - exEntitySpawner.SpawnRecord(record, worldTransform)
   - Track entityID + despawnTime in self.phantomNPCs table

4. Audio:
   - quickhack_shortcircuit SoundPlayEvent on V

5. Despawn timer:
   - Stage 3: 3-5s
   - Stage 4: 5-8s
   - Stage 5: 2-4s

6. On despawn:
   - exEntitySpawner.Despawn(entity)
   - PsychoWarningEffect_Light VFX on V when ghost vanishes
```

#### Messages on hallucination
```
Stage 3:
  "Did someone just...?"
  "Thought I saw..."
  "Shadows moving... just my eyes"

Stage 4:
  "They're watching me..."
  "Who's there?!"
  "Can't trust what I see anymore"

Stage 5:
  "THEY'RE EVERYWHERE"
  "GET OUT OF MY HEAD"
  "Lucy...? No... not real"
```

#### Implementation
- `UpdateHallucinations(dt)` in psychosis.lua: per-frame timer + spawn/despawn management
- `DespawnAllPhantoms()` in psychosis.lua: cleanup on game load, death, etc.
- `phantomNPCs` table tracks active phantom entities with entityID and despawnTime

---

## Feature 3: Blackout / Wake Up (Overuse Exhaustion) — IMPLEMENTED

V collapses from overuse and wakes up at a safe location hours later.

### Trigger
- `ExhaustionCheck()` fires when `dailyActivations >= 3 * effectiveSafeActivations` and Sandy is active
- **Stage 4-5**: No blackout — psychosis/death path takes over
- Daily cooldown: one blackout per day (`blackoutToday` flag, reset on sleep)

### Stage-Based Chance
| Stage | Blackout Chance |
|-------|----------------|
| 0 | 90% |
| 1 | 70% |
| 2 | 40% |
| 3 | 15% |
| 4-5 | No blackout |

### Distance Check
V must be within 200m of a known safe location (`findNearestBlackoutLocation(vPos, 200)`). If too far, a stun-only fallback triggers without teleport.

### Wakeup Locations
| Location | Type | Strain Drain | Runtime Restore | Health | Treatment Dose | Psycho Recovery | Hours Skipped |
|----------|------|-------------|-----------------|--------|----------------|-----------------|---------------|
| V's apartment | Apartment | -15 | +25% max | 40-60% | 0.5 | Can reduce psycho level (like sleep) | 6-10h |
| Viktor's clinic | Ripper | -25 | +50% max | 60-70% | 1.0 | No | 4-6h |
| Kabuki ripper | Ripper | -25 | +50% max | 60-70% | 1.0 | No | 4-6h |

### Blackout Sequence
```
1. PRE-BLACKOUT (immediate):
   - EndSandevistan() — stop Sandy
   - RemoveAllPsychoVFX() + StopHeartbeat() + RemoveRuntimeStamina()
   - pain SFX (ONO_V_LongPain) + NosebleedEffect + PsychoWarningEffect_Light
   - Set runTime = 0

2. SCREEN BLACK (0.5s delay):
   - Apply BaseStatusEffect.CyberwareInstallationAnimationBlackout
   - Message: "Body gives out... everything goes dark"

3. TELEPORT (1.0s delay):
   - fast_travel_glitch VFX
   - Clear wanted level (PreventionSystem Heat_0)
   - Teleport to nearest safe location within 200m

4. WAKE UP (2.0s after teleport):
   - Location-specific recovery (strain drain, runtime restore, treatment dose)
   - Apartment only: can reduce psycho level (maxPsychoRecoveryPerSleep)
   - Reset dailyActivations + sessionActivations
   - FastForwardPlayerState() — clear temp status effects
   - Advance game time by hoursSkipped
   - Remove blackout effect
   - Post-blackout SFX (ono_v_pain_long) + hacking_glitch_low VFX + NosebleedEffect
   - Set health to location-specific range
   - Location-specific wakeup message
```

### Implementation
- `ExhaustionCheck()` in loreEffects.lua: trigger logic with stage chance + distance check
- `UpdateBlackout(dt)` in loreEffects.lua: 3-phase state machine (darken → teleport → wakeup)
- `blackoutLocations` table: coordinates, recovery values, messages per location
- `blackoutChance` table: stage-based probability
- `blackoutToday` flag: daily cooldown, reset on sleep
- `blackoutState` table: tracks phase, elapsed time, location, hoursSkipped

---

## Pre-Psychosis VFX Sequence

The VFX sequence during stage changes is split across two functions to avoid overlap:

1. **BleedingEffect** (pre-psychosis): `johnny_sickness_blackout` VFX + pain SFX (short at low stages, long at high stages)
2. **FrightenNPCs** (during episode): `ono_v_fear_panic_scream` + MartinezFury + combat buffs + weapon draw + cycled SFX + auto-attack

The digital distortion cascade (`johnny_sickness_blackout`) fires BEFORE the episode. The panic scream and MartinezFury fire DURING the episode. No temporal overlap between the two.

## Strain Multiplier Separation

`AddStrain(amount, raw)` separates tolerance-based strain from psychological/physical strain:

- **Tolerance-based** (`raw = false`): Sandy activation (+5), overuse bonus (+3 per excess), active time (+2/min). Scaled by stage multiplier: Stage 0-1 x0.5, Stage 2 x0.75, Stage 3-5 x1.0.
- **Psychological/physical** (`raw = true`): Kills (+2 to +8), low runtime (+0.5/s), zero runtime (+1.0/s), Safety OFF (+0.15/s). Bypasses stage multiplier entirely.

The separation means: at stage 0, casual Sandy use is half as dangerous (body is fresh), but killing civilians still hits at full force. By stage 3+, the body no longer resists — all strain hits equally hard.

## Stage 6 Additions

Last Breath (Stage VI) includes all combat effects from psychosis episodes, plus exclusive Blackwall civilian corruption:

| Effect | Context |
|--------|---------|
| PsychosisCombatBuff | Applied at decay start (+50% speed, +100% armor, x10 health regen) |
| Cycled SFX | `ui_gmpl_perk_edgerunner` fires at decay start |
| Blackwall civilian corruption | 30% at Chorus 1, 40% at Chorus 2, 60% at Final Chorus |
| Ticking Time Bomb | Song-synced AoE stun (Chorus drops) |
| Blackwall Kill | Song-synced AoE kill (Chorus drops) |

---

## Feature 4: Activity Tracking + Sleep Multiplier — IMPLEMENTED

Human connections reduce Neural Strain and improve sleep recovery. David stayed human through Lucy and his crew.

### Tracked Activities

Six activities tracked per day, each firing once (boolean flag per activity):

| Activity | Strain Drain | Runtime Restore | Detection Method |
|----------|-------------|-----------------|------------------|
| Lover (romantic partner) | -5 | +10% max | Redscript LocKey match + romance quest fact validation |
| Sleep with Lover | -8 | +15% max | Redscript LocKey match (LocKey#46047) |
| Shower | -5 | +5% max | Redscript LocKey match (LocKey#46419) + CET status effect fallback |
| Social (dance, drink, rollercoaster) | -3 | -- | Redscript LocKey match (5 LocKeys) |
| Pet (Nibbles, cats, iguana) | -2 | -- | Redscript LocKey match (5 LocKeys) + CET status effect fallback |
| Apartment amenity | -2 | -- | 30s in safe area (not club, Sandy inactive) |

### Sleep Multiplier

```
sleepMultiplier = 1.0 + (activityCount * 0.25)   -- range: 1.0 to 2.5
sleepStrainDrain = strainDrainSleep * (RestedHours / 8) * strainRecoveryMultiplier * sleepMultiplier
```

### Detection Architecture

**Phase 2 (primary):** `DSPActivityTracker.reds` wraps `dialogWidgetGameController`:
1. `DialogHubLogicController.SetupTitle()` → captures hub title LocKey via `DSPHubTitleUpdatedEvent`
2. `OnDSPLastAttemptedChoice()` → calls `DSPActivityChecker.Check(locKey, gi)`
3. Activity type (Int32: 1=shower, 2=pet, 3=apartment, 4=social, 5=lover, 6=sleepWithLover) → `dsp_activity_detected` quest fact
4. CET Lua polls quest fact each display tick via `CheckActivityQuestFact()`

**Phase 1 (fallback):** CET `OnStatusEffectApplied` observer matches status effect names (`Shower`, `Refreshed`, `PetInteraction`, `Nibbles`).

**Apartment detection:** `safeAreaTime` accumulator in display tick — 30 continuous seconds in safe area (not club, Sandy not active) triggers apartment activity.

### Implementation

- `DSPActivityTracker.reds`: dialog LocKey interception + `DSPActivityChecker` with activity-specific matchers
- `RegisterActivity(name)` in init.lua: immediate strain drain + runtime restore + message
- `ResetActivities()` in init.lua: called from `Rested()` — resets all flags + count
- `GetSleepMultiplier()` in init.lua: `1.0 + (activityCount * 0.25)`
- `CheckActivityQuestFact()` in init.lua: polls `dsp_activity_detected` quest fact each tick
