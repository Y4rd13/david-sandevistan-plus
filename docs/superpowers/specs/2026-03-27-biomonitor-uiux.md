# Biomonitor UI/UX Improvement — Design Spec

**Date:** 2026-03-27
**Status:** Approved
**Scope:** Replace static biomonitor with animated Medtech-style panel, reorganize information hierarchy

---

## Core Principle

**Viktor talks like a doctor (narrative SMS). The biomonitor shows the numbers (clinical data). The HUD shows only what's needed during active gameplay (runtime/dilation).**

---

## 1. Architecture

### Framework
Animated Widgets Framework (4 .reds files) — same framework used by TANSTAAFL mod. Provides:
- `ShowHideCanvas` — size/opacity animations
- `ProgressBar` — loading bar with glitch text
- `AnimatedMonitorController` — sequenced animation (loading → expand → footer → data lines → fade)
- `AnimatedBiomonitorController` — Medtech-themed preset (red, Orbitron Bold)

Files copied to `r6/scripts/AnimatedWidgets/`:
- `AnimatedGlobals.reds` — `inkABorder` + `MonitorListItem` struct
- `AnimatedWidgetsLib.reds` — `ProgressBar` + `ShowHideCanvas`
- `AnimatedMonitor.reds` — base controller
- `AnimatedBiomonitor.reds` — Medtech preset

### Position
- **Location:** Upper-left (same area as TANSTAAFL)
- **Native resolution:** 2560×1440
- **Widget size:** 600×400
- **Margin:** ~100px left, ~200px top
- **Scaling:** `userRes.X / 2560.0 * userScale` with origin compensation (`+ 0.5 * size * (scaleFactor - 1)`)
- **Layer:** `inkHUDLayer` via `GetInkSystem().GetLayer(n"inkHUDLayer").GetVirtualWindow()`

### Color Theme (Medtech Red)
- Text: `HDRColor(1.1761, 0.3809, 0.3476, 1.0)` — warm red
- Header: `HDRColor(1.3698, 0.4437, 0.4049, 1.0)` — brighter red
- Background: `HDRColor(0.2824, 0.1137, 0.1373, 1.0)` at 0.3 opacity — dark maroon
- Border: same as text
- Font: `base\gameplay\gui\fonts\orbitron\orbitron.inkfontfamily`, Bold, size 20
- Logo: `q001_sandra.inkatlas` / `Medtech_Logo` (350×64)

### Animation Sequence (~12s total)
1. **Loading bar** vertical fill (1.5s) — "Loading..." glitch text + percentage counter
2. **Canvas expand** from (0,0) to (550,290) (1.5s)
3. **Footer** scale-in (0.2s)
4. **Data lines** typewriter text + count-up values (0.8s each, 5-7 lines)
5. **Hold** visible (2s)
6. **Fade out** opacity 1→0 (1.5s)
7. **Cleanup** — remove widget children

---

## 2. Biomonitor Content (2 Modes)

### Mode 1 — Immunosuppressant Status

**Triggers:** immunoblocker consumed, keybind manual, tolerance stage change, rebound

```
[Medtech Logo]
Loading... 100%

┌─ IMMUNOSUPPRESSANT STATUS ─┐
│ Substance:     Immunoblocker MILITARY GRADE
│ Tolerance:     MILD (1/3)
│ Efficacy:      80%
│ Neural Strain: 45%
│ Psychosis:     Stage III
│ Treatment:     RX 4/10 — 40%
└─ Client: V — Viktor Vektor Medical ─┘
```

**Data lines (7):**
1. Substance — tier name (Common / Uncommon / Military Grade)
2. Tolerance — stage name + fraction (None/Mild/Moderate/Severe + 0-3/3)
3. Efficacy — percentage (100% / 80% / 50% / 0%)
4. Neural Strain — percentage of threshold (0-150%)
5. Psychosis — stage roman numeral (I-V) or "Clear"
6. Treatment — RX progress fraction + percentage, or "No active protocol"
7. (Footer) Client: V — Viktor Vektor Medical

### Mode 2 — Treatment Protocol Updated

**Triggers:** new prescription at ripperdoc, treatment milestone reached

```
[Medtech Logo]
Loading... 100%

┌─ TREATMENT PROTOCOL UPDATED ─┐
│ Psychosis:     Stage V
│ Prescribed:    10 doses Military Grade
│ Visits:        0/5 completed
│ Tolerance:     NONE (0/3)
│ Milestone:     0% — Not started
└─ Client: V — Viktor Vektor Medical ─┘
```

**Data lines (6):**
1. Psychosis — current stage
2. Prescribed — dose count + tier name
3. Visits — completed/required
4. Tolerance — stage name + fraction
5. Milestone — percentage + label (Not started / Stabilizing / Improving / Complete)
6. (Footer) Client: V — Viktor Vektor Medical

---

## 3. Trigger Map

| Event | Biomonitor Mode | Viktor SMS |
|-------|----------------|------------|
| Immunoblocker consumed | Mode 1 (status) | — |
| Tolerance stage advances | Mode 1 (status) | Narrative warning ("your body's building resistance...") |
| New prescription (ripper visit) | Mode 2 (protocol) | Narrative ("I'm uploading the protocol to your biomonitor...") |
| Treatment milestone (33%/66%) | Mode 2 (protocol) | Narrative ("Your readings are stabilizing...") |
| Rebound (immunoblocker expires) | Mode 1 (status) | David voice line ("Doc warned me about this...") |
| Keybind manual | Mode 1 (status) | — |
| Treatment complete | Mode 2 (protocol) | Narrative ("Treatment complete. Neural readings are clean.") |

### Trigger Behavior
- **Hybrid auto+manual:** Auto-triggers on events, manual via keybind
- **Duration:** ~12s total (animation + hold + fade), auto-dismiss
- **No stacking:** New trigger replaces existing biomonitor (remove previous, start new)
- **Blocked during:** menu, braindance, Last Breath, loading

---

## 4. Information Hierarchy Changes

### Moved TO biomonitor (removed from elsewhere)
| Info | Was | Now |
|------|-----|-----|
| RX progress (4/10) | HUD permanent text | Biomonitor only |
| Prescription numbers (doses, tier) | Viktor SMS text | Biomonitor mode 2 |
| Tolerance stage | Invisible to player | Biomonitor mode 1 |
| Efficacy percentage | Invisible to player | Biomonitor mode 1 |

### Stays in BOTH (HUD + biomonitor)
| Info | Why both |
|------|----------|
| Neural Strain % | Player needs real-time during gameplay (HUD) + clinical view (biomonitor) |
| Psycho Stage | Same reason — context-dependent |

### Stays as Viktor SMS only (narrative)
| Info | Why SMS |
|------|---------|
| Prescription narrative | "This is the same protocol I had for Maine" — emotional context |
| Milestone narrative | "Your readings are stabilizing" — doctor feedback |
| Tolerance warning narrative | "Your body's building resistance" — doctor concern |
| Vendor tips | "There's a vet in Rancho Coronado..." — location guidance |
| Stage change alerts | "Come see me" — urgency |

### Viktor SMS change
Prescription SMS no longer contains numbers. Example:

**Before:** "Stage V. 10 doses Military Grade and 5 visits. This is the protocol I had for Maine."

**After:** "Stage V. I'm uploading the protocol to your biomonitor. This is the same one I had for Maine. He didn't finish it. You will."

Numbers appear in biomonitor mode 2 (triggered simultaneously).

---

## 5. Implementation Approach

### DSPHUDSystem changes
- Remove current static biomonitor (`TriggerBiomonitor`, `DismissBiomonitor`, `RemoveBiomonitor`)
- Add `DSPBiomonitorController extends AnimatedBiomonitorController` — custom subclass
- Add `ShowBiomonitorStatus(tier, toleranceStage, efficacyPct, strain, psychoStage, rxProgress, rxTotal)` — mode 1
- Add `ShowBiomonitorProtocol(psychoStage, doses, tierName, visitsCompleted, visitsRequired, toleranceStage, milestonePct)` — mode 2
- Both methods: create canvas on fullscreen slot, attach controller, populate items, start animation
- Named widget `n"DSPBiomonitor"` — removed before creating new (no stacking)
- Callback chain: animation ends → `OnAnimSequenceEnded` → remove widget

### CET bridge
- `ShowImmunoblockerStatus` → calls `ShowBiomonitorStatus` with all data
- New `ShowTreatmentProtocol` → calls `ShowBiomonitorProtocol` when prescription/milestone fires
- Keybind `ShowBiomonitor` → calls `ShowBiomonitorStatus` with current data
- Remove RX from `SetPsychoData` HUD setter (or keep but don't display)

### Files modified

| File | Changes |
|------|---------|
| `r6/scripts/AnimatedWidgets/*.reds` (4 files) | Copy framework to project |
| `r6/scripts/DavidSandevistanPlus/DSPHUDSystem.reds` | Replace static biomonitor with animated controller, 2 modes |
| `immunoblocker_logic.lua` | ShowImmunoblockerStatus passes full data for mode 1 |
| `psychosis.lua` | Prescription + milestone triggers mode 2, narrative-only Viktor SMS |
| `init.lua` | Keybind updated, ripper visit triggers mode 2 |

### Requires game restart
Yes — new .reds files (AnimatedWidgets framework) + DSPHUDSystem changes both require redscript recompilation on game launch.
