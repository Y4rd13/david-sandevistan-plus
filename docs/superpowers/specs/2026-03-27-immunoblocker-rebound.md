# Immunoblocker Observer Fix + Rebound Effect — Design Spec

**Date:** 2026-03-27
**Status:** Approved
**Scope:** Fix observer bug + implement slingshot/rebound effect when immunoblocker expires

**Lore reference:** Doc warns David in Edgerunners S01E08: *"These immuno-blockers are military-issued. Nine times your customary dosage. They should keep you on the right side of crazy. But they only delay the effects, not erase 'em. By the time you hit the last vial... whatever's still left of you, they will slingshot the other way and fly straight over the edge."*

---

## Part 1: Observer Fix

### Problem

The immunoblocker observer registers in `immunoblocker_logic.attach()` (mod load time), but `TweakDBID` is not available yet. Registration fails silently (pcall). The observer is never re-attempted.

The fallback (`RealTimeImmunoblockerTick`) uses `GetImmunoblockerTier()` which returns the ACTIVE effect tier, not the consumed tier. When Rare is active and player consumes Common, fallback detects tier 3 instead of tier 1 — bypassing the `minTier` validation in `CheckTreatmentDose`.

### Fix

1. **Move observer registration to `onInit`** in `init.lua` (where `TweakDBID` is available)
2. The observer in `immunoblocker_logic.lua` stays as-is (it works when `TweakDBID` exists — e.g. hot reload)
3. `RealTimeImmunoblockerTick` fallback: **remove treatment dose and tolerance tracking**. Keep only animation trigger and qty sync. The observer is the sole source for "which tier was consumed".

### Integration point
- `init.lua:2484+` — `onInit` handler, after other observers

---

## Part 2: Rebound/Slingshot Effect

### Trigger

When an immunoblocker status effect **expires naturally** (duration ends). NOT when:
- Replaced by another immunoblocker (refresh)
- Removed manually
- During Last Breath
- In menu/braindance

### Detection

New observer on `OnStatusEffectRemoved` — checks if the removed effect is one of the 3 immunoblocker effects, maps to tier.

To distinguish natural expiration from replacement: track `self.immunoblockerRefreshed` flag. Set it to `true` in the `OnStatusEffectApplied` observer when a new immunoblocker is consumed. The `OnStatusEffectRemoved` observer checks this flag — if true, the old effect was replaced (no rebound). If false, it expired naturally.

### Rebound Effects by Tier

| Tier | Base Strain | VFX | Duration |
|---|---|---|---|
| Common (1) | +5 raw | tremor_burst (1s) | instant |
| Uncommon (2) | +15 raw | NosebleedEffect (3s) | instant |
| Rare (3) | +30 raw | PsychoWarningEffect_Medium + tremor (3s) | instant |

### Tolerance Amplification

Strain spike multiplied by tolerance factor:
- Tolerance 0: ×1.0
- Tolerance 1: ×1.3
- Tolerance 2: ×1.6
- Tolerance 3: ×2.0

Example: Rare + tolerance stage 2 = +30 × 1.6 = **+48 raw strain** instant.

### David's Voice Lines (3 variants per tier, random)

**Common:**
- *"Meds wearing off..."*
- *"Could use another dose..."*
- *"Starting to feel it again..."*

**Uncommon:**
- *"Crash is hitting... need another dose"*
- *"Body's fighting back... the meds aren't enough"*
- *"Withdrawal kicking in..."*

**Rare:**
- *"Doc warned me about this... the slingshot"*
- *"Nine times the dose... and the crash is nine times worse"*
- *"The edge... I can feel it pulling"*

### Rules
- Strain is **raw** (bypasses stage multiplier — physical crash, not tolerance-based)
- 10s cooldown post-rebound (prevents cascading if multiple effects expire)
- No rebound during Last Breath
- No rebound in menu/braindance
- No rebound if `immunoblockerRefreshed` flag is true (effect was replaced, not expired)
- Messages shown via `SendWarning` with voice line key (for future Audioware integration)

### State Variables
- `immunoblockerRefreshed = false` — set true on apply, checked on remove
- `lastReboundTime = 0` — 10s cooldown tracking

---

## Files Modified

| File | Changes |
|---|---|
| `init.lua` | Observer registration in onInit, state vars |
| `immunoblocker_logic.lua` | Remove treatment/tolerance from fallback, rebound function, OnStatusEffectRemoved observer |

---

## Implementation Order

1. Fix observer (move to onInit) + remove fallback treatment/tolerance tracking
2. Add rebound effect (OnStatusEffectRemoved observer + rebound function)
3. Test: consume immunoblocker, wait for expiration, verify rebound fires
