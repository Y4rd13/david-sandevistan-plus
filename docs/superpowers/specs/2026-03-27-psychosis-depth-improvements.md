# Psychosis Depth Improvements — Design Spec

**Date:** 2026-03-27
**Status:** Approved
**Scope:** 6 gameplay mechanic improvements to deepen the cyberpsychosis experience

---

## Core Design Principle

**Viktor's prescription ALWAYS works if the player follows it.**

All mechanics (tolerance, strain, milestones) feed into a dynamic prescription system. Viktor calculates what V needs based on current state — psycho stage, tolerance level, strain rates, Sandy usage during treatment. The player trusts the doc, follows instructions, gets results. A prescription that doesn't work is a broken mechanic.

---

## 1. Natural Strain Decay (Stages 0-2)

**Purpose:** At low psychosis stages, the body can still recover on its own. Strain decays passively without external help.

**Integration point:** `UpdatePassiveStrain()` in `strain.lua:51-64` — currently only stages 4-5 (positive strain). Extend to stages 0-2 (negative strain = decay).

### Rates
| Stage | Decay rate | Time to clear 30 strain |
|-------|-----------|------------------------|
| 0 | -0.03/sec | ~17 min |
| 1 | -0.02/sec | ~25 min |
| 2 | -0.01/sec | ~50 min |
| 3 | none | needs external help |
| 4 | +0.04/sec | strain increases |
| 5 | +0.08/sec | strain increases |

### Rules
- Does NOT apply during active Sandy (strain doesn't decay while using chrome)
- Immunoblocker active: decay rate ×2
- Respects `cfg.strainRecoveryMultiplier` (existing global multiplier)
- Stacks with existing safe area / ripper / immunoblocker drain (additive)
- Floor at 0 (strain never goes negative)

---

## 2. Sandy Penalty During Active Treatment

**Purpose:** Using Sandy while on Viktor's treatment protocol works against the medication. It doesn't block Sandy (David doesn't stop), but it extends the treatment.

**Integration point:** `StartSandevistan` in `init.lua:715-730`, where `AddStrain()` is called on activation.

### Mechanics
- If `treatmentActive == true` when Sandy activates:
  - Strain per activation: ×1.5 (50% more than normal)
  - Track `sandyUsesDuringTreatment` counter
  - Every 3 Sandy uses during treatment: `prescribedDoses += 1` (prescription gets longer)
- First Sandy use during treatment: Viktor warning SMS (once per treatment):
  - *"V, my readings just spiked. You're using the Sandy while on treatment? That's working against everything we're doing here. Keep it up and I'll need to adjust your prescription."*
- After 3 uses: prescription recalculated, Viktor SMS:
  - *"You're still running the Sandy. I've adjusted your prescription — you'll need [X] more doses now. Your call, kid."*

### Rules
- Does NOT block Sandy activation
- Does NOT cancel treatment
- Prescription adjusts dynamically — always completable
- `sandyUsesDuringTreatment` resets when treatment completes
- SMS warnings are per-treatment (not per-session)

---

## 3. Medication Tolerance (Dark Future-inspired)

**Purpose:** Repeated immunoblocker use builds tolerance, reducing effectiveness. Viktor compensates in prescriptions.

**Integration points:**
- `GetImmunoblockerEffectiveness()` in `immunoblocker_logic.lua:26-35`
- `CheckTreatmentDose()` in `psychosis.lua:549-575`
- `GetPrescription()` in `psychosis.lua:537-541`

### Two-Layer System

**Continuous value:** `toleranceAmount` (Float, 0.0+)
- Buildup per dose (probability-based, not guaranteed):

| Tier | Chance | Amount |
|------|--------|--------|
| Common | 70% | +1.0 |
| Uncommon | 50% | +1.0 |
| Rare | 30% | +0.5 |

**Discrete stages:** `toleranceStage` (0-3)
- Thresholds: 4.0 → 8.0 → 12.0
- On threshold cross: stage +1, amount resets to 0

### Effect on Effectiveness

| Tolerance | Effect | Rare behaves as |
|-----------|--------|----------------|
| 0 | no penalty | Rare (full at all stages) |
| 1 | -1 tier | Uncommon |
| 2 | -2 tiers | Common |
| 3 | -3 tiers | Ineffective |

### Decay
- Natural: if no immunoblocker used for 24h game-time, `toleranceAmount -= 1.0/day`
- If amount drops below current stage threshold: stage decreases
- Full natural recovery (stage 3 → 0): ~12 game-days without consumption
- Ripperdoc visit: `toleranceAmount -= 4.0` (one full threshold per visit)

### Prescription Compensation (Viktor Principle)
- `GetPrescription()` multiplies doses by tolerance factor:
  - Tolerance 0: ×1.0
  - Tolerance 1: ×1.3
  - Tolerance 2: ×1.6
  - Tolerance 3: ×2.0

### Persistence
- `toleranceAmount` and `toleranceStage` saved via quest facts
- Restored on game load

---

## 4. Micro-Episode Chaining

**Purpose:** Micro-episodes can cascade, creating moments where V feels like they're losing control. A glitch triggers a nosebleed, which triggers a laugh.

**Integration point:** `FireMicroEpisode()` in `psychosis.lua:620-684`

### Chain Definitions
```
visual_glitch → 25% → tremor_burst → 15% → nosebleed
tremor_burst  → 20% → nosebleed   → 10% → manic_laugh
sandy_flash   → 30% → visual_glitch
medium_glitch → 20% → manic_laugh
```

### Rules
- Max 3 episodes per chain
- Delay between links: 1.5-3s (organic feel)
- Each link adds +0.001 tremor intensity (cumulative)
- Chain chance scales with stage:
  - Stage 1-2: base chance
  - Stage 3: ×1.5
  - Stage 4: ×2.0
  - Stage 5: ×2.5
- Immunoblocker full: chains blocked (only first episode fires)
- Immunoblocker partial: chain chance ×0.5

### State Variables
- `microEpisodeChainCount` (0-3): position in current chain
- `microEpisodeChainTimer`: countdown to next link
- `pendingChainType`: which episode fires next
- Reset when chain ends or 5s pass without chain trigger

### Post-Chain Cooldown
- After chain of 3: next micro-episode interval ×2 (breathing room)

### Practical Result
- Stage 1-2: ~1 in 4-5 micro-episodes chains (rare)
- Stage 3: ~1 in 3 generates a 2-chain
- Stage 4-5: frequent chains, sometimes 3-deep, feels like losing control

---

## 5. Phantom Visual Escalation

**Purpose:** Phantoms escalate from peripheral shadows to in-your-face terror. They should NEVER become predictable or comfortable.

**Integration point:** `applyPhantomBehavior()` in `psychosis.lua:792-922`, spawn logic at `psychosis.lua:1189-1235`

### Core Principle: Phantoms Are Shock, Not Decoration
- Disappear BEFORE the player can fully process them
- Never predictable timing or position
- Proximity despawn: approaching a phantom makes it vanish (you can't confirm it was real)

### Stage 3 — Peripheral Shadows
- Distance: 15-25m, always outside direct FOV
- Behavior: 100% `frozen` (just staring)
- Duration: 4-6s (brief, "did I see something?")
- VFX: subtle `quickhack_shortcircuit`
- Records: civilians only
- Proximity despawn: <2m → instant glitch despawn

### Stage 4 — Hostile Presences
- Distance: 8-15m, can appear in FOV
- Behavior: 40% `approach`, 40% `attack`, 20% `frozen`
- Duration: 8-14s
- VFX: `quickhack_cyberpsychosis_mech` + visual glitch
- Records: mix civilians + gang members
- 30% chance of phantom voice (hallucination message as subtitle, no audio)
- Proximity despawn: <2m → instant glitch despawn (except attack behavior)

### Stage 5 — Total Terror
- Distance: 3-8m, directly in FOV
- Behavior: 60% `attack`, 20% `approach`, 10% `frozen`, 10% `lover_stare`
- Duration: 10-20s
- VFX: full blackwall + intense glitch
- Records: aggressive gang + lovers (×2 weight if romance active)
- 30% chance of group spawn (2 phantoms together)
- Phantom flicker: 1-2 times during lifespan, disappear and reappear 0.3s later (reality glitch)

### Lover Phantom (All Stages)
- Stares at V
- If V approaches <3m → instant despawn with glitch (more sensitive than regular phantoms)
- Max duration: 4-6s (never long enough to "study")
- Effect: flash of recognition followed by emptiness

### Reactive Despawn Rules
- Frozen/approach phantoms: despawn if V gets within 2m
- Attack phantoms: do NOT despawn on proximity (they're threats)
- Lover phantoms: despawn at 3m (David recoils psychologically)
- Check every 0.5s in `UpdateHallucinations`

### Intensity Amplifiers
- Sandy used in last 30s: next phantom spawn delay ×0.5
- Kill during Sandy: 40% chance of immediate phantom spawn
- Night + outdoors: phantoms last 30% less (more fleeting, more shadowy)
- Strain >75% of threshold: group spawn chance +20%

### Anti-Habituation
- No repeat of same record 2 times in a row
- Interval jitter: ×0.5 to ×2.0 of base interval (never predictable)
- 20% chance of "false alarm": spawn sound/glitch plays but NO NPC appears (V thought they saw something)

---

## 6. Treatment Intermediate Milestones

**Purpose:** The player sees gradual improvement during treatment, not a binary switch at the end. Following Viktor's protocol gives progressive relief.

**Integration point:** `CheckTreatmentDose()` and `CheckTreatmentComplete()` in `psychosis.lua:549-605`

### Progress Calculation
```
progress = (completedDoses / prescribedDoses + completedVisits / prescribedVisits) / 2
```
50% weight doses, 50% weight visits.

### Milestones

**Milestone 1 — progress ≥ 0.33:**
- Passive strain rate: -30%
- Micro-episode interval: ×1.3 (slower)
- Viktor SMS: *"Good, V. Your readings are stabilizing. Keep taking the meds. Don't skip doses."*

**Milestone 2 — progress ≥ 0.66:**
- Passive strain rate: -60%
- Micro-episode interval: ×1.6
- Phantom spawn interval: ×1.5 (fewer hallucinations)
- Viktor SMS: *"Real improvement here, kid. Neural pathways are re-routing. Almost there."*

**Milestone 3 — progress ≥ 1.0 (treatment complete):**
- Stage -1 (existing behavior)
- Strain reset to 0
- Treatment state reset
- Viktor completion SMS (existing)

### Interactions
- Sandy penalty adds doses → progress measured against adjusted `prescribedDoses`
- Tolerance adds doses → same, measured against adjusted total
- Strain decay natural (stages 0-2) stacks with milestone strain reduction
- Milestone benefits persist across save/load (quest fact stores reached milestone)

### Milestone Benefits Are Cumulative
- At milestone 2: player has BOTH milestone 1 + milestone 2 benefits
- On treatment completion: all milestone modifiers removed (replaced by stage reduction)

---

## Implementation Order

Ordered by dependency and complexity (simplest/independent first):

| # | Mechanic | Dependencies | Effort |
|---|----------|-------------|--------|
| 1 | Natural Strain Decay | None | Very low |
| 2 | Sandy Penalty During Treatment | None | Low |
| 3 | Micro-Episode Chaining | None | Low-Medium |
| 4 | Phantom Visual Escalation | None | Medium |
| 5 | Medication Tolerance | Needs before #6 | Medium |
| 6 | Treatment Milestones | Needs #5 (tolerance affects prescription) | Medium |

Each mechanic is implemented → tested in-game → committed before starting the next.

---

## Files Modified

| File | Mechanics |
|------|-----------|
| `strain.lua` | #1 (decay), #2 (sandy penalty strain multiplier) |
| `init.lua` | #2 (sandy activation hook), #5 (tolerance state vars), #6 (milestone state) |
| `psychosis.lua` | #3 (chaining), #4 (phantoms), #5 (tolerance in prescription), #6 (milestones in treatment) |
| `immunoblocker_logic.lua` | #5 (tolerance buildup on consumption, effectiveness reduction) |
| `sms.lua` | #2, #5, #6 (Viktor dynamic SMS) |
