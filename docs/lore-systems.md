# Lore-Accurate Gameplay Systems — Technical Reference

Six interconnected systems that replace "gamified" timers with physical, unpredictable, and cumulative deterioration inspired by David Martinez's arc in Edgerunners.

### Stage Progression Matrix

![Cyberpsychosis Stage Progression](cyberpsychosis-stages.svg)

## Design Philosophy

In the anime, David's deterioration was:
- **Physical** — stat penalties, not just visual effects
- **Unpredictable** — symptoms struck without warning
- **Cumulative** — each use made the next one worse
- **Gradual** — recovery took time, not a single sleep

These systems implement that philosophy. All are toggleable via cfg flags and configurable through the MartinezPLUS Settings UI.

## System 1: Neural Strain (Episode Trigger)

Replaces the old `PsychoOutburst` countdown timer with an accumulation pool + dice roll system. Episodes are now unpredictable and cumulative — matching David's lore deterioration.

### How It Works

```
NEURAL STRAIN (0 → guaranteed per stage)

Actions add strain:
  Sandy activation    → +5 (+ overuse bonus)
  Sandy active /60s   → +2
  Safety OFF /sec     → +0.15
  Kill during Sandy   → +2 to +8 (faction-based)
  Comedown /5s        → +1

Actions reduce strain:
  Safe area /sec      → -0.05
  Sleep               → -40 (scaled by hours)
  Ripperdoc           → -25
  Immunoblocker /sec  → -0.08/0.18/0.35 per tier (reduces accumulation 80% full, 50% partial)
  DF Immunosup. /sec  → -0.08

When strain >= threshold → dice roll each second:
  chance = (strain - threshold) / 200
  Success → EPISODE (MartinezFury, psycho++) + strain reset to 0
  At guaranteed → forced episode (can't avoid)
```

### Kill Strain (Redscript Hook)

`DSPKillTracker.reds` wraps `ScriptedPuppet.RewardKiller()` via `@wrapMethod` to intercept kills:

| Faction | Strain Cost | Lore |
|---------|-------------|------|
| Civilian / Unaffiliated | 8 | David never wanted to hurt civilians |
| NCPD / NetWatch | 5 | Killing cops accelerates psychosis |
| Arasaka / Militech / KangTao | 3 | Corporate security |
| All gangs | 2 | Normal enemies |

Kill strain routes through `DSPHUDSystem.AddKillStrain(cost)` → CET Lua reads via `GetAndClearKillStrain()` each tick.

### Thresholds Per Stage

| Stage | Threshold | Guaranteed | Experience |
|---|---|---|---|
| 0 | 60 | 100 | Hard to trigger — need heavy overuse |
| 1 | 50 | 90 | Manageable with care |
| 2 | 40 | 80 | Casual overuse is dangerous |
| 3 | 30 | 70 | Almost any aggressive session triggers |
| 4 | 20 | 60 | Constant danger |
| 5 | 10 | 50 | Near-inevitable — Last Breath territory |

### Design Decision: No Auto-Level-Decrease

The old system decreased psycho level when timer was high (safe area recovery). This is removed. Level decreases ONLY via:
- Sleep (prescription system: -1 level per rest)
- Ripperdoc (prescription system: -1 level per visit)

Strain reaching 0 means "safe within current level" but doesn't reduce the level. This cleanly separates: **strain = episode risk within a level**, **psycho level = overall progression**.

### Persistence

`neuralStrain` saved/loaded via quest fact `martinezsandevistan_neuralstrain` (×10+1 encoding for 0.1 resolution). Kill strain is transient (lost on load).

## System 2: Immunoblocker (Consumable Item)

Doc's prescribed medication — *"Nine times your customary dosage."* A consumable item purchasable from ripperdoc TRADE tabs.

### Item Tiers

| Tier | In-Game Name | Duration | Price | Drain Rate | Vendor Availability |
|------|-------------|----------|-------|------------|---------------------|
| Common | Immunoblocker | 180s (3 min) | 3,000€$ | 0.08/s (14.4 total) | Always Present |
| Uncommon | Immunoblocker — High Dosage | 360s (6 min) | 12,000€$ | 0.18/s (64.8 total) | Commonly Present |
| Rare | Military-Grade Immunoblocker | 600s (10 min) | 50,000€$ | 0.35/s (210 total) | Uncommonly Present |

Each tier has a custom inventory icon (separate inkatlas+xbm per tier).

### TweakDB Records (martinez.lua)

Each tier creates:
- **StatusEffect**: `BaseStatusEffect.MartinezSandevistan_ImmunoblockerCommon/Uncommon/Rare` — timed, tagged `Immunoblocker`, no stat packages (detection-only via `StatusEffect_CheckOnly()`)
- **ConsumableItem**: `Items.MartinezImmunoblockerCommon/Uncommon/Rare` — `ItemType.Con_LongLasting`, custom icon via `UIIcon.Immunoblocker_Common/Uncommon/Rare`
- **ObjectActionEffect** + **ItemAction**: bridge records for the consume action
- **VendorItem**: entries on 5 ripperdoc `medicstore_01` vendor `itemStock` arrays (TRADE tab)
- **Price override**: `.buyPrice` set with custom `ConstantStatModifier` (overrides inherited HealthBooster pricing)
- **Stat cleanup**: `.statModifiers`, `.OnEquip` cleared to remove inherited HealthBooster stats; `.statModifierGroups` keeps only `Items.LongLastingConsumableDuration` for tooltip duration

### Vendors

Immunoblockers appear in ripperdoc **TRADE tabs** (not CYBERWARE). Each ripperdoc NPC has two vendor records: `ripperdoc_01` feeds CYBERWARE, `medicstore_01` feeds TRADE.

| Location | Vendor Record |
|----------|---------------|
| Viktor Vektor, Watson | `Vendors.wat_lch_medicstore_01` |
| Cassius Ryder, Kabuki | `Vendors.wat_kab_medicstore_01` |
| Arroyo ripperdoc | `Vendors.std_arr_medicstore_01` |
| Heywood ripperdoc | `Vendors.hey_spr_medicstore_01` |
| Japantown ripperdoc | `Vendors.wbr_jpn_medicstore_01` |

Pacifica excluded — `pac_wwd` has no `medicstore_01` record (no TRADE tab vendor exists in-game).

VendorItem records are created at runtime in `AddImmunoblockersToVendors()` (called from `LoadGamePart1`), not during `onInit`, because CET TweakDB records created during `onInit` are not seen by native `MarketSystem.GetVendorItemsForSale()`.

### Effects While Active

- **Reduces strain accumulation**: 80% when full effectiveness, 50% when partial (not 100% — V still feels it)
- **Drains strain** at tier-specific rates: 0.08/s (Common), 0.18/s (Uncommon), 0.35/s (Rare)
- **Ineffective mode**: 0% accumulation reduction, only 25% of tier drain rate
- **Suppresses micro-episodes** (full/partial only)
- **Counts as prescription dose** (existing behavior)

### Effectiveness by Psycho Level

| Tier | Full | Partial | Ineffective |
|------|------|---------|-------------|
| Common | Lvl 0–1 | Lvl 2 | Lvl 3–5 |
| Uncommon | Lvl 0–2 | Lvl 3 | Lvl 4–5 |
| Rare | Lvl 0–5 | Never | Never |

### DF Immunosuppressant Comparison

| | Immunoblocker | DF Immunosuppressant |
|---|---|---|
| Reduces accumulation | 80% (full) / 50% (partial) | No |
| Drain rate | 0.08–0.35/s (per tier) | -0.08/s |
| Suppresses micro-episodes | Yes (full/partial) | Yes |
| Source | Ripperdoc shop | Dark Future mod |

Both can be active simultaneously without conflict.

### Custom Injection Animation

Immunoblockers use a custom syringe injection scene (`drug_inhale_01`) with timed audio, VFX, and voiceover events. The vanilla HealthBooster animation is suppressed via a redscript `ProcessItemAction` wrapper.

Timeline (~1.9s total):

| Time | Event | Type |
|------|-------|------|
| 0ms | `drug_inhale_01` animation + `lcm_mvs_canvas_fast_light` audio + `inhale_drug_exhale` VFX | Anim/Audio/VFX |
| 10ms | Attach syringe prop → WeaponLeft slot | System |
| 300ms | `cmn_generic_work_inject_drug` — needle enters | Audio |
| 380ms | `ono_v_pain_short` — pain reflex | Voiceover |
| 450ms | `reflex_buster` — vision doubling | VFX |
| 500ms | `skif_buff` — buff flash | VFX |
| 1550ms | `lcm_mvs_canvas_fast_light` — transition audio | Audio |
| 1600ms | `ono_v_laughs_hard` — relief/euphoria | Voiceover |
| 1909ms | `socket OnEnd` — animation complete | System |

![Immunoblocker Injection Timeline](immunoblocker-animation-timeline.svg)

## System 3: Enhanced Comedown

Deactivating the Sandy triggers real stat penalties instead of the previous brief `MinorBleeding` effect.

### TweakDB Record

`BaseStatusEffect.MartinezSandevistan_Comedown` — defined in `martinez.lua`:

| Component | Record | Value |
|-----------|--------|-------|
| **Status Effect** | Infinite duration, controlled by Lua timer | VFX: `burnout_glitch` + `hacking_glitch_low` |
| **Stat: MaxSpeed** | ConstantStatModifier | ×0.6 (40% slower) |
| **Stat: StaminaRegenRate** | ConstantStatModifier | ×0.3 (70% less regen) |
| **Stat: Armor** | ConstantStatModifier | ×0.5 (50% less armor) |

### Duration Formula

```
runtimeUsed = sandyStartRuntime - currentRuntime
scale = min(runtimeUsed / comedownScalingThreshold, 1.0)
duration = comedownBaseDuration + (comedownMaxDuration - comedownBaseDuration) * scale

if psychoLevel >= 3:
    duration *= comedownPsychoMultiplier
```

| Defaults | Value |
|----------|-------|
| `comedownBaseDuration` | 5.0s |
| `comedownMaxDuration` | 20.0s |
| `comedownScalingThreshold` | 60s |
| `comedownPsychoMultiplier` | 1.5 |

**Examples:**
- 10s Sandy use → ~7.5s comedown
- 60s Sandy use → 20s comedown
- 60s Sandy use at psycho 3 → 30s comedown

### Behavior

- Sandy blocked during comedown (`comedownBlockSandy = true`)
- Camera tremor at psycho 3+ (`comedownTremorAtPsycho = true`, intensity 0.003)
- Comedown removed on death/Last Breath
- Cleanup in `RemoveAllPsychoVFX()` and `RemoveDeadV()`

## System 4: Doc Prescription (Graduated Recovery)

Recovery is a process, not an instant cure. Each psycho level requires a specific number of treatment "doses" to clear.

### Prescription Table

| Psycho Level | Required Doses | Min Ripper Visits | Sleep Can Cure? |
|---|---|---|---|
| 0 | 0 | 0 | — |
| 1 | 1 | 0 | Yes (1 sleep) |
| 2 | 2 | 0 | Yes (2 sleeps) |
| 3 | 3 | 1 | No — needs 1 visit + 2 sleeps |
| 4 | 5 | 2 | No — needs 2 visits + 3 sleeps |
| 5 | 7 | 3 | No — can't go below 4 without ripper |

### Recovery Mechanics

**Sleep (`Rested()`):**
- Max -1 psycho level per sleep (configurable via `maxPsychoRecoveryPerSleep`)
- Counts as 1 treatment dose toward prescription
- Level 5 can only drop to 4 via sleep — ripper required to go lower
- Clears comedown state, resets `sessionActivations`
- Recovers 75% of degraded max runtime (`sleepRecoveryPercent`)

**Ripperdoc (`VisitedRipper()`):**
- Issues prescription on first visit (sets `prescribedDoses`)
- Each visit = 1 treatment dose + -1 psycho level
- Grants 50% max runtime recharge
- Fully restores degraded max runtime (`ripperFullRestore`)

**Dark Future Immunosuppressant:**
- 60s of active immunosuppressant = 0.5 treatment dose

### HUD Display

`SetPsychoData()` now takes 4 params (timer removed — replaced by Neural Strain bar):
```redscript
SetPsychoData(psychoLevel, lastBreathPhase, prescribedDoses, completedDoses)
```

New `SetStrainData()` for Neural Strain bar:
```redscript
SetStrainData(neuralStrain, strainThreshold, strainGuaranteed, immunoblockerActive)
```

Displays `RX 2/5` next to psycho level when prescription is active.
Strain bar shows `STRAIN 45/60` with blue→yellow→red color coding.

### Persistence

`prescribedDoses` and `completedDoses` saved/loaded via quest facts (existing pattern).

## System 5: Non-Linear Runtime Drain

Three sub-systems that make sustained Sandevistan use increasingly costly.

### 5a: Accelerating Drain

Replaces flat `runTime -= dt` with an accelerating curve:

```lua
drainRate = 1.0
if enableNonLinearDrain and not lastBreath then
    activeSeconds = sandyStartRuntime - runTime
    if activeSeconds > drainAccelStartSec then
        overTime = (activeSeconds - drainAccelStartSec) / 60
        drainRate = 1.0 + overTime ^ drainExponent
    end
end
runTime -= dt * drainRate
```

| Active Time | Drain Rate | Effective Drain |
|---|---|---|
| 0–60s | 1.0× | Normal |
| 90s | 1.2× | Slight acceleration |
| 120s | 2.0× | Double drain |
| 180s | 3.8× | Nearly 4× drain |
| 240s | 6.2× | Brutally expensive |

### 5b: Session Fatigue

Each Sandy activation past the safe daily limit reduces dilation effectiveness:

```lua
excessUses = max(0, sessionActivations - effectiveSafeActivations)
penalty = min(excessUses * sessionFatiguePenalty, maxSessionFatiguePenalty)
timeScale += penalty  -- higher timeScale = less dilation
```

| Excess Uses | Penalty | Effective Dilation (from 90% base) |
|---|---|---|
| 0 | 0% | 90.0% |
| 3 | -6% | 84.0% |
| 5 | -10% (cap) | 80.0% |

Resets on sleep.

### 5c: Max Runtime Degradation

Each Sandy session permanently reduces max runtime:

```
degradation = (runtimeUsed / 60) * 0.01 * MaxRuntime
maxRuntimeDegraded += degradation  (capped at 0.5 * MaxRuntime)
effectiveMaxRuntime = MaxRuntime - maxRuntimeDegraded
```

| Recovery | Amount |
|----------|--------|
| Sleep | 75% of degraded amount restored |
| Ripperdoc | 100% restored (full max runtime) |

Helper: `GetEffectiveMaxRuntime()` used in `Rested()` and runtime calculations.

## System 6: Micro-Episodes

Random involuntary symptoms that fire between major psycho episodes.

### Episode Pool

| Type | Min Level | Weight | Duration | Effect |
|------|-----------|--------|----------|--------|
| Visual glitch | 1 | 10 | 0.5–1.5s | `PsychoWarningEffect_Light` |
| Tremor burst | 2 | 7 | 1–3s | Camera shake intensity spike |
| Nosebleed | 2 | 5 | 3s | `NosebleedEffect` |
| Manic laugh | 3 | 4 | 3s | `PsychoLaughEffect` |
| Sandy flash | 3 | 3 | 1–2s | Involuntary Sandy activation, auto-stops |
| Medium glitch | 4 | 2 | 1.5–3s | `PsychoWarningEffect_Medium` |

Selection: weighted random from eligible pool (level gated), no consecutive repeats.

### Frequency by Level

| Level | Interval Range | Experience |
|---|---|---|
| 1 | 300–600s (5–10 min) | Rare — easy to dismiss |
| 2 | 120–300s (2–5 min) | Noticeable — something's wrong |
| 3 | 30–120s (0.5–2 min) | Constant — can't ignore |
| 4 | 15–60s | Relentless — barely functional |
| 5 | 5–15s | Continuous — stacks with existing behavior |

Actual interval = random within range × `1 / microEpisodeFrequency`.

### Guards

Micro-episodes are suppressed when:
- V is in menu or braindance
- Comedown is active (body already in recovery)
- Last Breath is active (its own systems handle everything)
- Immunoblocker is active (Doc's medication)
- DF immunosuppressant is active
- Psycho level is 0

### Implementation

- Timer decrements in `displayTick` phase 3 (every ~1s)
- On fire: `FireMicroEpisode()` → weighted random → apply effect → set cleanup timer
- Brief VFX effects auto-removed after duration via cleanup timers in comedown tick
- Sandy flash auto-stops via separate timer

## Cross-System Interactions

```
          ┌───────────────┐
          │ Neural Strain │◄── accumulates from ──┐
          └───────┬───────┘                       │
                  │ episode triggers               │
                  ▼                                │
          ┌──────────────┐                  ┌─────┴──────┐
          │ Psycho Level │                  │ Comedown   │
          │ (1→5)        │                  │ (+1/5s)    │
          └──────┬───────┘                  └────────────┘
                 │ increases                      ▲
                 ▼                                │
          ┌──────────────┐                  ┌─────┴──────┐
          │ Micro-       │                  │ Sandy Use  │
          │ Episodes     │                  │ + Kills    │
          └──────────────┘                  └────────────┘
                 ▲ suppresses                     ▲ blocks
                 │                                │
          ┌──────┴───────┐                  ┌─────┴──────┐
          │ Immunoblocker│─── drains ──────►│ Strain     │
          │ + DF Immuno  │                  │ Pool       │
          └──────────────┘                  └────────────┘
                                                  ▲
                                                  │ drains
          ┌──────────────┐                  ┌─────┴──────┐
          │ Doc          │─── drains ──────►│ Sleep /    │
          │ Prescription │                  │ Ripper     │
          └──────────────┘                  └────────────┘
```

| Interaction | Behavior |
|-------------|----------|
| Neural Strain triggers episodes | Dice roll above threshold → MartinezFury + psycho level++ |
| Kills add strain (faction-based) | Redscript hook → DSPHUDSystem bridge → CET Lua |
| Comedown adds strain | +1 every 5s — recovery still stresses the system |
| Immunoblocker blocks + drains strain | -0.1/s drain, blocks ALL accumulation, suppresses micro-episodes |
| DF Immunosuppressant drains strain | -0.08/s drain (weaker, doesn't block accumulation) |
| Comedown suppresses micro-episodes | Body is already in recovery — no stacking |
| Session fatigue extends comedown | More runtime used → longer comedown duration |
| Prescription resets micro-episode timer | Level change = new frequency bracket |
| Last Breath bypasses ALL six systems | Its own decay handles everything, sets strain=0 |
| Sleep resets session fatigue + recovers runtime degradation + drains strain | Fresh start each day |
| Ripper fully restores runtime degradation + drains strain | "Good as new" visit |

## Configuration Reference

All parameters with their cfg key names:

### Neural Strain
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `strainPerActivation` | int | 5 | Base strain per Sandy activation |
| `strainPerOveruseBonus` | int | 3 | Extra strain per activation beyond safe limit |
| `strainPerMinuteActive` | int | 2 | Strain per minute of Sandy use |
| `strainPerSecSafetyOff` | float | 0.15 | Strain per second with Safety OFF |
| `strainPerKillBase` | int | 3 | Base kill strain (overridden by faction cost) |
| `strainPerComedown5s` | int | 1 | Strain every 5s during comedown |
| `strainDrainSafeArea` | float | 0.05 | Drain per second in safe areas |
| `strainDrainSleep` | int | 40 | Drain on sleep (scaled by hours/8) |
| `strainDrainRipper` | int | 25 | Drain per ripperdoc visit |
| `strainDrainImmunoblocker` | float | 0.1 | Drain per second with Immunoblocker |
| `strainDrainDFImmuno` | float | 0.08 | Drain per second with DF Immunosuppressant |
| `strainBuildupMultiplier` | float | 1.0 | Global multiplier for all strain accumulation |
| `strainRecoveryMultiplier` | float | 1.0 | Global multiplier for all strain drain |

### Comedown
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `enableComedown` | bool | true | Master toggle |
| `comedownBaseDuration` | float | 5.0 | Minimum duration (seconds) |
| `comedownMaxDuration` | float | 20.0 | Maximum duration (seconds) |
| `comedownScalingThreshold` | float | 60 | Runtime threshold for max duration |
| `comedownBlockSandy` | bool | true | Block Sandy during comedown |
| `comedownPsychoMultiplier` | float | 1.5 | Duration multiplier at psycho 3+ |
| `comedownTremorAtPsycho` | bool | true | Camera shake during comedown at psycho 3+ |

### Prescription
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `enablePrescription` | bool | true | Master toggle |
| `maxPsychoRecoveryPerSleep` | int | 1 | Max levels recovered per sleep |
| `ripperRecoveryLevels` | int | 1 | Levels recovered per ripper visit |

### Non-Linear Drain
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `enableNonLinearDrain` | bool | true | Master toggle for accelerating drain |
| `drainExponent` | float | 1.5 | Acceleration curve exponent |
| `drainAccelStartSec` | float | 60 | Seconds before acceleration starts |
| `enableSessionFatigue` | bool | true | Toggle session fatigue |
| `sessionFatiguePenalty` | float | 0.02 | Dilation loss per excess use |
| `maxSessionFatiguePenalty` | float | 0.10 | Maximum fatigue cap |
| `enableRuntimeDegradation` | bool | true | Toggle runtime degradation |
| `sleepRecoveryPercent` | float | 0.75 | % of degraded runtime recovered by sleep |
| `ripperFullRestore` | bool | true | Ripper fully restores max runtime |

### Micro-Episodes
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `enableMicroEpisodes` | bool | true | Master toggle |
| `microEpisodeFrequency` | float | 1.0 | Frequency multiplier |

## Implementation Files

| File | Purpose |
|------|---------|
| `init.lua` | Core game loop, all system orchestration: `Running()`, `Start()`, `End()`, `Rested()`, `VisitedRipper()`, `TimeDilationCalculator()`, `displayTick` phases, VFX progression (stages 0-5), config defaults |
| `martinez.lua` | TweakDB factory: all status effects (Fury, Comedown, VFX warnings Light/Medium/Heavy, Sluggish, Immunoblocker 3 tiers), Sandevistan item, vendor records |
| `loreEffects.lua` | Sensory effects: `UpdateTremor()` (stages 1-5), `UpdateFOVPulse()`, `UpdateTerminalClarity()`, `Heartbeat()` (stage 2+), `Nosebleed()`, `ExhaustionCheck()`, `RandomNosebleed()` (stage 2+), `GetEffectiveMaxRuntime()` |
| `strain.lua` | Neural Strain accumulation/drain: `AddStrain()` (with buildup multiplier), `DrainStrain()`, `GetStrainThreshold()`, `GetStrainGuaranteed()`, dice roll logic |
| `psychosis.lua` | Cyberpsychosis episode handling: `FireMicroEpisode()`, `PsychoOutburst()`, `FrightenNPCs()`, psycho level transitions |
| `death.lua` | Death and Last Breath: `KillV()`, `KillV_Execute()`, `UpdateLastBreath()`, song-synced timeline, combat effects (Ticking Time Bomb, Blackwall Kill) |
| `immunoblocker.lua` | Immunoblocker TweakDB records: consumable items (3 tiers), vendor integration, custom icons |
| `immunoblocker_logic.lua` | Immunoblocker runtime logic: `IsImmunoblockerActive()`, `GetImmunoblockerEffectiveness()`, strain blocking/draining |
| `gameListeners.lua` | CET event listeners: `onInit`, `onUpdate`, `onDraw`, game state observers (sleep, ripperdoc, scene changes) |
| `entEffects.lua` | Entity effects: combat VFX (Ticking Time Bomb AoE, Blackwall Kill AoE) |
| `ncpd.lua` | NCPD bounty system interaction |
| `hud.lua` | CET→redscript bridge: 4 setters + `RefreshHUD()` |
| `gui.lua` | CET ImGui debug window |
| `DSPHUDSystem.reds` | Redscript HUD: fullscreen ink canvas, runtime/psycho/strain bars, widget tree |
| `DSPKillTracker.reds` | Redscript kill hook: `@wrapMethod(ScriptedPuppet) RewardKiller()` → faction-based strain costs |
| `MartinezPLUS/init.lua` | Native Settings UI: 50 settings across 14 subcategories, config persistence |

## Verification Checklist

1. Toggle each `enable*` flag off → system fully bypassed, no side effects
2. Psycho level 0 → no comedown penalties, no micro-episodes, no prescription
3. Save/load persistence for prescription state (`prescribedDoses`, `completedDoses`, `maxRuntimeDegraded`, `neuralStrain`)
4. Menu/braindance immunity for all effects
5. Last Breath compatibility (all systems properly bypassed, strain=0)
6. Dark Future compat (immunosuppressant strain drain or graceful no-op)
7. Performance: no per-frame table allocations in hot paths
8. CET→redscript: all setters under 6 params (max is `SetContext` at 6)
9. Neural Strain accumulates from Sandy use, Safety OFF, kills, comedown
10. Neural Strain drains in safe areas, with Immunoblocker, with DF Immunosuppressant
11. Dice roll triggers episodes unpredictably above threshold
12. Guaranteed episode at max strain (can't game the system indefinitely)
13. Kill tracking works with faction-based costs (redscript hook)
14. Immunoblocker purchasable at ripperdocs, blocks strain + counts as dose
15. HUD strain bar visible, color-coded, hidden when strain=0
16. Immunoblocker suppresses micro-episodes
17. WannabeEdgerunner co-existence (multiple @wrapMethod on RewardKiller chains correctly)
18. PsychoWarningEffect_Heavy (3-layer VFX) applied at stage 4
19. PsychoSluggishEffect (85% MaxSpeed) applied at stage 4+
20. Tremor starts at stage 1 (0.001 intensity), progressive through stage 5 (0.008)
21. Heartbeat starts at stage 2+ (not 3+)
22. RandomNosebleed fires independently at stage 2+, suppressed by Immunoblocker
23. strainBuildupMultiplier scales all strain accumulation in AddStrain()
24. strainRecoveryMultiplier scales all strain drain (sleep, ripper, immunoblocker, safe area, DF immuno)
