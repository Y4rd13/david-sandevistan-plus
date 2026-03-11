# Lore-Accurate Gameplay Systems — Technical Reference

Four interconnected systems that replace "gamified" timers with physical, unpredictable, and cumulative deterioration inspired by David Martinez's arc in Edgerunners.

## Design Philosophy

In the anime, David's deterioration was:
- **Physical** — stat penalties, not just visual effects
- **Unpredictable** — symptoms struck without warning
- **Cumulative** — each use made the next one worse
- **Gradual** — recovery took time, not a single sleep

These systems implement that philosophy. All are toggleable via cfg flags and configurable through the MartinezPLUS Settings UI.

## System 1: Enhanced Comedown

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

## System 2: Doc Prescription (Graduated Recovery)

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

`SetPsychoData()` expanded from 3 to 5 params:
```redscript
SetPsychoData(psychoLevel, psychoTimer, lastBreathPhase, prescribedDoses, completedDoses)
```

Displays `RX 2/5` next to psycho level when prescription is active.

### Persistence

`prescribedDoses` and `completedDoses` saved/loaded via quest facts (existing pattern).

## System 3: Non-Linear Runtime Drain

Three sub-systems that make sustained Sandevistan use increasingly costly.

### 3a: Accelerating Drain

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

### 3b: Session Fatigue

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

### 3c: Max Runtime Degradation

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

## System 4: Micro-Episodes

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
- DF immunosuppressant is active
- Psycho level is 0

### Implementation

- Timer decrements in `displayTick` phase 3 (every ~1s)
- On fire: `FireMicroEpisode()` → weighted random → apply effect → set cleanup timer
- Brief VFX effects auto-removed after duration via cleanup timers in comedown tick
- Sandy flash auto-stops via separate timer

## Cross-System Interactions

```
             ┌──────────┐
             │ Comedown │◄── suppresses ──┐
             └────┬─────┘                 │
                  │ extends               │
                  ▼                       │
          ┌──────────────┐         ┌──────┴───────┐
          │ Session      │         │ Micro-       │
          │ Fatigue      │         │ Episodes     │
          └──────┬───────┘         └──────────────┘
                 │ more runtime used              ▲
                 ▼                                │
          ┌──────────────┐                        │
          │ Runtime      │    prescription resets ─┘
          │ Degradation  │    timer on level change
          └──────────────┘
                 ▲
                 │ restores
          ┌──────┴───────┐
          │ Doc          │
          │ Prescription │
          └──────────────┘
```

| Interaction | Behavior |
|-------------|----------|
| Comedown suppresses micro-episodes | Body is already in recovery — no stacking |
| Session fatigue extends comedown | More runtime used → longer comedown duration |
| Prescription resets micro-episode timer | Level change = new frequency bracket |
| Last Breath bypasses ALL four systems | Its own decay handles everything |
| DF immunosuppressant suppresses micro-episodes | + counts as partial treatment |
| Sleep resets session fatigue + recovers runtime degradation | Fresh start each day |
| Ripper fully restores runtime degradation | "Good as new" visit |

## Configuration Reference

All parameters with their cfg key names:

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

| File | Changes |
|------|---------|
| `init.lua` | All 4 systems: `End()`, `Start()`, `Running()`, `Rested()`, `VisitedRipper()`, `TimeDilationCalculator()`, `UpdateTremor()`, `displayTick`, new helpers |
| `martinez.lua` | `ComedownEffect` TweakDB record with stat modifiers and VFX |
| `hud.lua` | Passes `prescribedDoses`/`completedDoses` to redscript bridge |
| `DSPHUDSystem.reds` | `SetPsychoData` expanded to 5 params, "RX X/Y" display |
| `MartinezPLUS/init.lua` | ~20 new settings across 3 new subcategories |

## Verification Checklist

1. Toggle each `enable*` flag off → system fully bypassed, no side effects
2. Psycho level 0 → no comedown penalties, no micro-episodes, no prescription
3. Save/load persistence for prescription state (`prescribedDoses`, `completedDoses`, `maxRuntimeDegraded`)
4. Menu/braindance immunity for all effects
5. Last Breath compatibility (all systems properly bypassed)
6. Dark Future compat (immunosuppressant interactions or graceful no-op)
7. Performance: no per-frame table allocations in hot paths
8. CET→redscript: all setters under 6 params (max is `SetContext` at 6)
