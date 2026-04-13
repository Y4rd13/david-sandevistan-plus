# Martinez Rush — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an Edgerunner-perk-inspired **Rush** mechanic: a kill-triggered, chance-based burst of combat power during Sandy active, with chance scaling by cyberpsychosis stage and cost paid via runtime drain instead of strain — preserving the existing stage progression balance.

**Concept:** Inspired by the vanilla Edgerunner perk's Fury state, but (1) triggered by cyberpsychosis stage, not cyberware overflow; (2) uses runtime drain as cost, not health; (3) distinct from the existing `MartinezFury` / `PsychosisCombatBuff` (which fires during psycho episodes — forced, 15s, Sandy off). Martinez Rush is voluntary-adjacent (kill-procced), 12s, Sandy stays active.

**Architecture:** Self-contained addition to existing systems. New status effect in `martinez.lua`, new trigger function in `init.lua`, hook into the existing kill-strain flow at `init.lua:1608` (where `GetAndClearKillStrain` is polled from the redscript DSPHUDSystem). Uses the existing `martinez_fx_*` custom effect infrastructure for VFX. No redscript changes required.

**Tech Stack:** CET Lua 5.3, Cyberpunk 2077 TweakDB stat modifiers, existing `martinez.lua` TweakDB factory, existing `entEffects` custom effect loader.

**Lore rationale:** Cyberpunk Edgerunners shows Maine and David having "rage bursts" during psychosis (Ep 7-10). Cyberpsychosis canon grants "enhanced physical abilities" in short outbursts. The chance-by-stage curve mirrors the anime — stage 0-1 rare bursts, stage 5 near-guaranteed. Companion to the existing `PsychosisCombatBuff` which fires during actual episodes.

---

## Resource Verification Status

### ✅ Stats CONFIRMED (redmodding wiki + existing mod usage)

| Stat | Used for | Modifier type | Direction |
|------|----------|---------------|-----------|
| `BaseStats.MaxSpeed` | Movement | Multiplier | Higher = faster |
| `BaseStats.CritChance` | Crit | Additive | Higher = more |
| `BaseStats.CritDamage` | Crit | Additive | Higher = more |
| `BaseStats.Armor` | Armor | Multiplier | Higher = more |
| `BaseStats.HealthInCombatRegenRate` | Regen | Multiplier | Higher = faster |
| `BaseStats.CycleTime` | Ranged fire rate | Multiplier | **Lower = faster** (inverted) |
| `BaseStats.AttackSpeed` | Melee attack rate | Multiplier | Higher = faster (assumed, verify) |
| `BaseStats.ReloadTime` | Reload | Multiplier | **Lower = faster** (inverted) |

**Verification source:** `wiki.redmodding.org/cyberpunk-2077-modding/.../cheat-sheet-base-stats` + existing mod usage in `martinez.lua:881,1004,1097,1110`.

### ✅ Custom VFX system CONFIRMED

The mod has `entEffects:CreateCustomEffect(owner, customName, effectPath)` at `martinez.lua:1321-1325`, which loads any `.effect` file from the game archives at runtime under a custom name. Already working with 5 blackwall-themed effects.

**Reusable options for Rush** (already loaded in mod, no new file needed):
- `martinez_fx_onscreen_frame` — red vertical distortion at screen edges (used for `SafetiesOffStatusEffect_VFX2` + `CyberpsychoStatusEffect_FX3`). **Good candidate**: red, intense, combat-themed, NOT the laugh.
- `martinez_fx_onscreen_sick_start` — blackwall squares at startup (too psycho)
- `martinez_fx_onscreen_sick_pulse` — soft analog pulse (comedown use)

**Recommended**: Use `martinez_fx_onscreen_frame` directly for Rush. It's already loaded, red/intense themed, and distinct from `perk_edgerunner_player` (the Fury laugh). Shared with SafetyOFF is fine — `StatusEffect_CheckAndApply` is idempotent.

### ⚠️ SFX candidates (verify in-game during implementation)

**Do not reuse:**
- `ui_gmpl_perk_edgerunner` (Fury laugh)
- `q004_sc_04a_heartbeat` (health/psycho warning)
- `quickhack_cyberpsychosis_mech` (Sandy shutdown)

**Candidates** (known Cyberpunk 2077 event names, likely exist — test order):
1. **`ui_jingle_buff_start`** — buff stinger (primary choice)
2. **`ui_perk_upgrade_power`** — perk unlock sound
3. **`ui_music_stinger_combat_start`** — combat start stinger
4. **`quickhack_shortcircuit`** — already confirmed working (electrical zap) — fallback

**Strategy:** Try #1 first via `Game.GetAudioSystem():Play(CName.new("..."))`. If no sound plays in CET console test, fall back to #2, #3, #4 in order. The fallback `quickhack_shortcircuit` is already confirmed working, so worst-case Rush has a viable activation SFX.

---

## Balance Analysis (critical — validated before implementation)

### Current strain sources (defaults, raw=true applied for kills/runtime)

- Activation: +5 × stageMult (0.5/0.5/0.75/1.0/1.0/1.0)
- Overuse bonus: +3 per extra × stageMult
- Runtime active: +2/min × stageMult
- Safety OFF: +0.10/sec raw
- Kills: gang=+2, corpo=+3, ncpd=+5, civilian=+8 raw (bypass stageMult, NOT strainBuildupMult)

### Current thresholds (stage advancement requires crossing threshold + dice roll + cooldown expiry)

| Stage | Threshold | Guaranteed | Prior cooldown |
|-------|-----------|------------|----------------|
| 0→1 | 85 | (ceiling 150) | — |
| 1→2 | 85 | (ceiling 150) | 48h game-time |
| 2→3 | 70 | 120 | 36h |
| 3→4 | 55 | 100 | 24h |
| 4→5 | 40 | 80 | 12h |

### Impact of Martinez Rush on strain (with proposed design: 0 strain cost)

**Rush adds ZERO strain directly.** Cost is paid via runtime drain multiplier during the 12s Rush window (×1.5 drain rate), which is a separate resource (Sandy tank). Indirect strain still comes from natural kill strain and extended combat — but that's the same rate as without Rush.

**Scenario:** Stage 2, 20-kill encounter (15 gang + 5 corpo), Sandy active 2 min, 7% Rush chance per kill

**Without Rush:**
- Activation: +5 × 0.75 = +3.75
- Runtime 2min: +4 × 0.75 = +3
- Kill strain: 15×2 + 5×3 = +45 raw
- **Total: ~52 strain**

**With Rush (0 strain cost, runtime drain ×1.5):**
- Expected procs: 20 × 0.07 = 1.4
- Strain added by Rush directly: **+0**
- Indirect cost: 1.4 procs × 12s × 1.5 = 25s extra runtime drain (~8% of 300s tank)
- **Total: ~52 strain, Sandy tank shortened by 8%**

**Stage 5 scenario (20 kills, 25% chance):**
- Expected procs: 5
- Strain added: +0
- Runtime cost: 5 × 12s × 1.5 = 90s extra drain (30% of tank → Sandy ends 30% sooner)
- **Total: ~58 strain (from natural kill strain), Sandy significantly shorter**

**Conclusion:** Stage progression is unaffected. Players at high psychosis stages get more Rushes but burn their Sandy faster, which naturally limits combat duration and indirect strain.

---

## Implementation Tasks

### Task 1: Create MartinezRush status effect in martinez.lua

**Files:**
- Modify: `bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/martinez.lua`

**Location:** After existing `PsychosisCombatBuff` definition (~line 1096-1107), before `RuntimeExhaustion` (~line 1109).

- [ ] **Step 1.1: Add TweakDBID constants**

Add near other status effect TweakDBIDs (~line 118-150 area, alongside `PsychosisCombatBuff` entries):

```lua
martinez.MartinezRush                = 'BaseStatusEffect.MartinezSandevistan_MartinezRush'
martinez.MartinezRush_LP             = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_LP'
martinez.MartinezRush_SMG            = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_SMG'
martinez.MartinezRush_SM1            = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_SM1'  -- CycleTime
martinez.MartinezRush_SM2            = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_SM2'  -- AttackSpeed
martinez.MartinezRush_SM3            = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_SM3'  -- ReloadTime
martinez.MartinezRush_SM4            = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_SM4'  -- MaxSpeed
martinez.MartinezRush_SM5            = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_SM5'  -- CritChance
martinez.MartinezRush_SM6            = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_SM6'  -- CritDamage
martinez.MartinezRush_SM7            = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_SM7'  -- Armor
martinez.MartinezRush_SM8            = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_SM8'  -- HealthInCombatRegenRate
martinez.MartinezRush_MD             = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_MD'  -- MaxDuration
martinez.MartinezRush_FX1            = 'BaseStatusEffect.MartinezSandevistan_MartinezRush_FX1'
```

- [ ] **Step 1.2: Create the status effect factory block**

Insert after PsychosisCombatBuff block (~line 1107), before RuntimeExhaustion (~line 1109):

```lua
-- MartinezRush: kill-triggered combat burst during Sandy
-- +33% fire rate, +30% melee speed, +54% reload, +20% movement, +15 crit chance, +25 crit dmg, +40% armor, 5x regen
-- Duration: 12s (base) — extended to 15s if Safety OFF (handled in init.lua)
-- Distinct from PsychosisCombatBuff which fires during psycho episodes (forced, Sandy off)
self:CreateConstantStatModifier(self.MartinezRush_SM1, { 'Multiplier', 'BaseStats.CycleTime', 0.75 })  -- -25% cycle = +33% fire rate
self:CreateConstantStatModifier(self.MartinezRush_SM2, { 'Multiplier', 'BaseStats.AttackSpeed', 1.30 })  -- +30% melee
self:CreateConstantStatModifier(self.MartinezRush_SM3, { 'Multiplier', 'BaseStats.ReloadTime', 0.65 })  -- -35% reload time
self:CreateConstantStatModifier(self.MartinezRush_SM4, { 'Multiplier', 'BaseStats.MaxSpeed', 1.20 })
self:CreateConstantStatModifier(self.MartinezRush_SM5, { 'Additive', 'BaseStats.CritChance', 15.0 })
self:CreateConstantStatModifier(self.MartinezRush_SM6, { 'Additive', 'BaseStats.CritDamage', 25.0 })
self:CreateConstantStatModifier(self.MartinezRush_SM7, { 'Multiplier', 'BaseStats.Armor', 1.40 })
self:CreateConstantStatModifier(self.MartinezRush_SM8, { 'Multiplier', 'BaseStats.HealthInCombatRegenRate', 5.0 })
self:CreateConstantStatModifier(self.MartinezRush_MD,  { 'Additive', 'BaseStats.MaxDuration', 12.0 })

local MartinezRushStats = {
    self.MartinezRush_SM1, self.MartinezRush_SM2, self.MartinezRush_SM3, self.MartinezRush_SM4,
    self.MartinezRush_SM5, self.MartinezRush_SM6, self.MartinezRush_SM7, self.MartinezRush_SM8
}
self:CreateLogicPackage(self.MartinezRush_LP, { '', {}, {}, {}, '', false, {}, MartinezRushStats })
self:CreateStatModifierGroup(self.MartinezRush_SMG, { false, false, {}, false, MartinezRushStats, -1, nil })
self:CloneRecord(self.MartinezRush_FX1, VFX_SuperHacked)
TweakDB:SetFlat(self.MartinezRush_FX1 .. '.name', self.martinez_fx_onscreen_frame)  -- red frame edges

self:CreateStatusEffect(self.MartinezRush, {
     '' , {} , {} , '' , {} , self.MartinezRush_SMG , false
    ,{ self.MartinezRush_MD } , 'InstantDuration' , false , {} , nil , 0
    ,{ self.MartinezRush_LP } , nil , false , false , nil , false , false , false
    ,{ self.MartinezRush_FX1 } , {} , {}
    ,'Buff' , 'ChromeRush' , 'UIIcon.MartinezRush' , { self.MartinezRush_SMG } , {}
})
```

> **Note:** The `CreateStatusEffect` signature above follows the same pattern as `PsychosisCombatBuff` at martinez.lua:1102-1106. Verify the exact arg count by comparing against existing status effects in the same file. The "Buff" flavor and duration handling match.

- [ ] **Step 1.3: Test the status effect applies cleanly in CET console**

After copying to game directory and restarting game, in CET console:
```lua
dsp:StatusEffect_CheckAndApply(dsp.martinez.MartinezRush)
```
Verify no errors, VFX applies, and `mcp__cet-bridge__get_active_effects` shows the effect. Wait 12s, verify it expires.

---

### Task 2: Implement TryProcMartinezRush trigger logic in init.lua

**Files:**
- Modify: `bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua`

- [ ] **Step 2.1: Add module-level state + chance table**

Near the top of `registerForEvent('onInit', ...)` or alongside other `dsp.*` field definitions (~line 340 area after `dsp.tremor = ...`):

```lua
,lastRushProcTime = 0        -- os.clock() of last Martinez Rush proc (45s cooldown)
,rushActive = false          -- true during the 12s Rush window
,rushEndTime = nil           -- os.clock() when current Rush ends
,rushSafetyOffExtension = false  -- true if current Rush was activated with Safety OFF
```

- [ ] **Step 2.2: Define the trigger function**

Add a new function on `dsp` near the kill strain handling or alongside `TryAutoInject` (~line 404 area of immunoblocker_logic.lua, or in init.lua onInit):

```lua
-- Martinez Rush: Edgerunner-inspired kill-triggered combat burst
-- Chance scales with cyberpsychosis stage. Cost: runtime drain ×1.5 during window + post-Rush crash.
-- Does NOT add strain directly (preserves stage progression balance).
local rushChanceByStage = { [0]=0.02, [1]=0.04, [2]=0.07, [3]=0.12, [4]=0.18, [5]=0.25 }

dsp.TryProcMartinezRush = (function(self)
    -- Gates
    if not self.isRunning then return false end              -- only during Sandy
    if self.lastBreath then return false end                 -- blocked during Last Breath
    if self.rushActive then return false end                 -- already active, no stacking
    if self.CachedInMenu or self.CachedBrainDance then return false end
    if not self.VIsInControl then return false end

    -- Cooldown (45s real-time between procs)
    local now = os.clock()
    if now - (self.lastRushProcTime or 0) < 45 then return false end

    -- Chance roll
    local chance = rushChanceByStage[self.CyberPsychoWarnings] or 0.02
    if math.random() > chance then return false end

    -- PROC
    self.lastRushProcTime = now
    self.rushActive = true
    self.rushSafetyOffExtension = not self.SafetyOn  -- +25% duration if Safety OFF
    local duration = self.rushSafetyOffExtension and 15 or 12
    self.rushEndTime = now + duration

    -- Apply status effect
    self:StatusEffect_CheckAndApply(self.martinez.MartinezRush)

    -- SFX — try candidates in order, fall back to confirmed-working
    local sfxCandidates = {
        "ui_jingle_buff_start",
        "ui_perk_upgrade_power",
        "quickhack_shortcircuit"  -- confirmed working fallback
    }
    pcall(function()
        Game.GetAudioSystem():Play(CName.new(sfxCandidates[1]))
    end)

    -- HUD notification
    if self.bbs then
        local msgs = {
            "In the zone...",
            "Everything's clicking...",
            "Got this.",
            "Time to move.",
        }
        self.bbs:SendMessage(msgs[math.random(#msgs)], 2.5)
    end

    dlog('[DSP] Martinez Rush proc! stage=' .. tostring(self.CyberPsychoWarnings) ..
         ' duration=' .. tostring(duration) .. ' safetyOff=' .. tostring(self.rushSafetyOffExtension))
    return true
 end)
```

- [ ] **Step 2.3: Add Rush window tick (onUpdate handler)**

In `registerForEvent('onUpdate', function(dt) ... end)` near other time-based checks (~line 3075 area where biomonitor auto-close lives):

```lua
-- Martinez Rush: end window tick
if dsp.rushActive and dsp.rushEndTime and os.clock() >= dsp.rushEndTime then
    dsp.rushActive = false
    dsp.rushEndTime = nil
    dsp.rushSafetyOffExtension = false
    -- Rush status effect expires naturally via MaxDuration (12s or 15s)
    -- Post-Rush crash: apply short ComedownEffect-lite (3s stamina drain)
    pcall(function()
        dsp:StatusEffect_CheckAndApply(dsp.martinez.StaminaDrain)
    end)
    dsp.rushCrashEndTime = os.clock() + 3.0
    dlog('[DSP] Martinez Rush ended, crash applied')
end

-- Post-Rush crash tick
if dsp.rushCrashEndTime and os.clock() >= dsp.rushCrashEndTime then
    dsp.rushCrashEndTime = nil
    pcall(function()
        dsp:StatusEffect_CheckAndRemove(dsp.martinez.StaminaDrain)
    end)
end
```

- [ ] **Step 2.4: Hook TryProcMartinezRush into kill strain processing**

Find the existing kill strain poll at `init.lua:1608` (where `self:AddStrain(killStrain, true)` is called after polling `GetAndClearKillStrain` from the redscript DSPHUDSystem). Immediately after that line, add:

```lua
-- Try to proc Martinez Rush on each kill (one attempt per poll, not per kill)
self:TryProcMartinezRush()
```

> **Note:** The poll happens every frame via onUpdate, so TryProcMartinezRush will be called every frame that has a kill registered. The cooldown check inside the function prevents chain procs. If you want per-kill rolls (not per-poll), move the call into DSPKillTracker.reds via a new quest fact bridge — but per-poll is simpler and functionally equivalent for the ~100ms polling rate.

- [ ] **Step 2.5: Implement runtime drain ×1.5 during Rush window**

Find the runtime drain calculation in `init.lua` (search for `drainAccelStartSec` or `drainRate`, near line 1388-1400). Add a Rush drain multiplier:

```lua
-- Martinez Rush: ×1.5 drain during window
if self.rushActive then
    drainRate = drainRate * 1.5
end
```

Place this after the existing drain acceleration formula but before the final drain is applied.

---

### Task 3: Deploy + In-game verification

- [ ] **Step 3.1: Copy modified files to game directory**

```bash
cp "bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/martinez.lua" \
   "/mnt/g/SteamLibrary/steamapps/common/Cyberpunk 2077/bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/martinez.lua"

cp "bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua" \
   "/mnt/g/SteamLibrary/steamapps/common/Cyberpunk 2077/bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua"
```

- [ ] **Step 3.2: Full game restart (required — TweakDB records must rebuild)**

- [ ] **Step 3.3: Verify status effect applies manually via CET console**

```lua
dsp:StatusEffect_CheckAndApply(dsp.martinez.MartinezRush)
```
Expected: VFX (red frame edges) appears, 12s countdown, stats buff active (test by checking weapon fire rate/reload speed in-game during the window).

- [ ] **Step 3.4: Verify chance table by forcing stage + observing procs**

```lua
-- Set stage to 5 (25% chance)
dsp.CyberPsychoWarnings = 5
-- Activate Sandy, kill 10 enemies
-- Expected: 2-3 Rush procs with cooldown between
```
Repeat for stage 0 (should be rare) and stage 2 (~7% = ~1-2 per 20 kills).

- [ ] **Step 3.5: Verify SFX candidates — test each in console**

```lua
Game.GetAudioSystem():Play(CName.new("ui_jingle_buff_start"))
-- If no sound, try:
Game.GetAudioSystem():Play(CName.new("ui_perk_upgrade_power"))
-- If no sound, fall back to:
Game.GetAudioSystem():Play(CName.new("quickhack_shortcircuit"))
```
Update the `sfxCandidates[1]` in `TryProcMartinezRush` with the first one that actually plays.

- [ ] **Step 3.6: Verify runtime drain ×1.5 during Rush**

- Activate Sandy at full tank
- Proc Rush manually via CET console
- Observe runtime drain rate during 12s window — should be visibly ~50% faster
- After window, drain returns to normal

- [ ] **Step 3.7: Verify post-Rush StaminaDrain applies for 3s**

Check after Rush ends that V has reduced stamina regen briefly.

- [ ] **Step 3.8: Verify no interaction bugs**

- Rush + Safety OFF → 15s duration
- Rush + PsychosisCombatBuff (during episode) → both active, check stat stack
- Rush during Last Breath → blocked (gate check)
- Rush in menus/BrainDance → blocked
- Two Rush procs within 45s → second one blocked (cooldown)

---

### Task 4: Optional — Mod Settings exposure

**Files:**
- Modify: `r6/scripts/DavidSandevistanPlus/DSPSettings.reds`
- Modify: `bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua` (syncSettingsFromRedscript)

- [ ] **Step 4.1: Add new Mod Settings fields**

Add under the "Combat Stats" category in `DSPSettings.reds`:

```swift
@runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
@runtimeProperty("ModSettings.category", "Combat Stats")
@runtimeProperty("ModSettings.category.order", "3")
@runtimeProperty("ModSettings.displayName", "Enable Martinez Rush")
@runtimeProperty("ModSettings.description", "Kill-triggered combat burst during Sandy. Chance scales with cyberpsychosis stage (2% at stage 0 → 25% at stage 5). Grants +33% fire rate, +30% melee speed, +54% reload, +20% movement, +15 crit, +25 crit dmg, +40% armor, 5x regen for 12s. Cost: runtime drain ×1.5 during window.")
public let enableMartinezRush: Bool = true;

@runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
@runtimeProperty("ModSettings.category", "Combat Stats")
@runtimeProperty("ModSettings.category.order", "3")
@runtimeProperty("ModSettings.displayName", "Rush Chance Multiplier")
@runtimeProperty("ModSettings.description", "Global multiplier for Rush proc chance per stage. 1.0 = default, 0.5 = half as frequent, 2.0 = double.")
@runtimeProperty("ModSettings.step", "0.1")
@runtimeProperty("ModSettings.min", "0.25")
@runtimeProperty("ModSettings.max", "3.0")
@runtimeProperty("ModSettings.dependency", "enableMartinezRush")
public let rushChanceMultiplier: Float = 1.0;

@runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
@runtimeProperty("ModSettings.category", "Combat Stats")
@runtimeProperty("ModSettings.category.order", "3")
@runtimeProperty("ModSettings.displayName", "Rush Duration (sec)")
@runtimeProperty("ModSettings.description", "Duration of Martinez Rush in seconds (Safety OFF extends by 25%).")
@runtimeProperty("ModSettings.step", "1")
@runtimeProperty("ModSettings.min", "6")
@runtimeProperty("ModSettings.max", "30")
@runtimeProperty("ModSettings.dependency", "enableMartinezRush")
public let rushDuration: Int32 = 12;
```

- [ ] **Step 4.2: Wire to CET cfg**

In `init.lua:syncSettingsFromRedscript`, add:

```lua
cfg.enableMartinezRush = settings.enableMartinezRush
cfg.rushChanceMultiplier = settings.rushChanceMultiplier
cfg.rushDuration = settings.rushDuration
```

Add defaults in the `local cfg = { ... }` block (~line 234):

```lua
enableMartinezRush = true,
rushChanceMultiplier = 1.0,
rushDuration = 12,
```

- [ ] **Step 4.3: Apply settings in TryProcMartinezRush**

Update the gate + duration calc:
```lua
if not self.cfg.enableMartinezRush then return false end
...
local mult = self.cfg.rushChanceMultiplier or 1.0
local chance = (rushChanceByStage[self.CyberPsychoWarnings] or 0.02) * mult
...
local baseDuration = self.cfg.rushDuration or 12
local duration = self.rushSafetyOffExtension and math.floor(baseDuration * 1.25) or baseDuration
```

> **Note:** The `MartinezRush_MD` TweakDB MaxDuration is set at init time and can't be dynamically adjusted per-proc. For user-configurable duration, either (a) update the TweakDB flat on settings change, or (b) use a Lua-side timer to remove the effect early if the user configured it shorter. Option (a) is cleaner.

---

## Rollback Plan

If implementation causes issues:
1. Revert `martinez.lua` and `init.lua` changes (single commit, clean rollback)
2. No save file corruption risk — status effects are runtime-only, no persistence
3. TweakDB records persist in memory until game restart, but don't cause side effects if unused
4. No archive/mod file dependencies added

---

## Success Criteria

- [ ] Rush procs on kills during Sandy with visible VFX + SFX cue
- [ ] Chance scales with cyberpsychosis stage (verified at stages 0, 2, 5)
- [ ] All 8 stat buffs are visibly active (fire rate, reload, melee, speed, crit, armor, regen)
- [ ] Duration is 12s normal / 15s if Safety OFF
- [ ] 45s cooldown prevents chain procs
- [ ] Runtime drain is visibly ~50% faster during Rush window
- [ ] Post-Rush stamina drain applies for 3s
- [ ] Rush is blocked in menus, BrainDance, Last Breath
- [ ] No strain added directly (verified by monitoring `dsp.neuralStrain` before/after Rush)
- [ ] No crash or error in CET console log
- [ ] Stacks cleanly with PsychosisCombatBuff during episodes

---

## References

- Vanilla Edgerunner perk: [Cyberpunk Wiki](https://cyberpunk.fandom.com/wiki/Edgerunner_(perk))
- Anime lore (David combat progression): Ep 7-10 of Cyberpunk: Edgerunners
- BaseStats cheat sheet: [redmodding wiki](https://wiki.redmodding.org/cyberpunk-2077-modding/for-mod-creators-theory/references-lists-and-overviews/cheat-sheet-tweak-ids/cheat-sheet-base-stats)
- Existing pattern: `PsychosisCombatBuff` at `martinez.lua:1096-1106`
- Kill strain flow: `init.lua:1608` + `DSPKillTracker.reds`
