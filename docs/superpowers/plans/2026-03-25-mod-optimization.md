# DSP Mod Optimization Implementation Plan — COMPLETED 2026-03-26

> **Status:** All tasks completed via incremental approach (13 commits). First batch attempt failed; incremental redo succeeded with zero regressions. Additional improvements made: immunoblocker persistence, Viktor alert scaling, treatment dose fallback detection.

**Goal:** Fix 2 bugs, eliminate redundant Game.GetPlayer() calls, remove dead code, and add cleanup handlers across the mod.

**Architecture:** All changes are in CET Lua files. Applied incrementally (one change at a time with in-game verification) instead of the original 5-commit batch plan.

**Tech Stack:** CET Lua 5.3, Cyberpunk 2077 RED4 API

---

## File Map

| File | Changes |
|------|---------|
| `init.lua` | Bug fix (E-2), player cache, sps cache, HUD dedup, dead code removal, onShutdown, global leaks |
| `psychosis.lua` | Bug fix (E-5), combatNPCs cleanup, phantomNPCs table reuse |
| `strain.lua` | Hoist threshold/guaranteed/immunoReduction tables to module level |
| `immunoblocker_logic.lua` | Polling interval 0.25s→1s, remove no-op |

---

### Task 1: Fix real bugs (E-2, E-5, E-4)

**Files:**
- Modify: `init.lua:1990-1999` (SaveTreatmentState/LoadTreatmentState)
- Modify: `init.lua:547` (RestedRuntime global leak)
- Modify: `init.lua:1731` (PlayerLevel global leak)
- Modify: `psychosis.lua:147` (health pcall)

- [ ] **Step 1: Fix E-2 — LoadTreatmentState writes to `qs` instead of `dsp`**

At `init.lua:1995-1999`, `LoadTreatmentState` sets `self.treatmentActive` and `self.completedVisits` where `self` is `qs`. But treatment logic reads from `dsp`. Fix by having LoadTreatmentState write to `dsp` directly:

```lua
-- init.lua:1990
,SaveTreatmentState = (function(self)
    self:SetFactValue(self.TreatmentActiveFactName, dsp.treatmentActive and 2 or 1)
    self:SetFactValue(self.CompletedVisitsFactName, (dsp.completedVisits or 0) + 1)
 end)
,LoadTreatmentState = (function(self)
    local active = self:GetFactValue(self.TreatmentActiveFactName)
    dsp.treatmentActive = (active == 2)
    local visits = self:GetFactValue(self.CompletedVisitsFactName) - 1
    dsp.completedVisits = (visits >= 0) and visits or 0
 end)
```

- [ ] **Step 2: Fix E-5 — pcall returns boolean, not health**

At `psychosis.lua:147`, change:
```lua
-- FROM:
local health = pcall(function() return Game.GetPlayer():GetHealth() end) or 100
-- TO:
local ok, health = pcall(function() return Game.GetPlayer():GetHealth() end)
if not ok then health = 100 end
```

- [ ] **Step 3: Fix E-4 — global variable leaks**

At `init.lua:547`, add `local`:
```lua
local RestedRuntime = self.MaxRuntime * (RestedHours/self.FullRechargeHours)
```

At `init.lua:1731`, add `local`:
```lua
local PlayerLevel = SS:GetStatValue(VEntity, "Level")
```

- [ ] **Step 4: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/psychosis.lua
git commit -m "fix: treatment save/load bug, health pcall, global leaks"
```

---

### Task 2: Cache Game.GetPlayer() per frame (P-1, P-2, P-3)

**Files:**
- Modify: `init.lua` (onUpdate, StatusEffect helpers, sps methods)

- [ ] **Step 1: Add cached player field and refresh in onUpdate**

At the top of the `registerForEvent('onUpdate', ...)` callback (around line 2596), add player cache refresh:

```lua
registerForEvent('onUpdate', function(dt)
    -- Cache player reference once per frame
    local ok, player = pcall(function() return Game.GetPlayer() end)
    dsp.cachedPlayer = (ok and player and IsDefined(player)) and player or nil
    -- ... rest of onUpdate
```

- [ ] **Step 2: Update StatusEffect helpers to use cached player**

At `init.lua:1059-1086`, change `StatusEffect_CheckOnly`, `StatusEffect_CheckAndApply`, `StatusEffect_CheckAndRemove` to use `self.cachedPlayer` instead of calling `Game.GetPlayer()`:

```lua
,StatusEffect_CheckOnly = (function(self, effect, target)
    local V = target or self.cachedPlayer
    if not V or not IsDefined(V) then return false end
    -- ... rest unchanged
```

Same pattern for CheckAndApply and CheckAndRemove.

- [ ] **Step 3: Update sps methods to accept optional player param**

For the most-called sps methods (`getHealth`, `getAdrenaline`, `damage`, `SandevistanCharge`, `EndSandevistan`), add optional `player` parameter that falls back to `Game.GetPlayer()`:

```lua
,getHealth = (function(self, noBuffer, player)
    local V = player or Game.GetPlayer()
    if not IsDefined(V) then return 100 end
    -- ... rest unchanged
```

Then in `Running()` (line ~1140), cache once and pass:
```lua
local V = self.cachedPlayer
if not V then return end
-- ... later:
local VsHealthNow = self.sps:getHealth(true, V)
```

- [ ] **Step 4: Update loreEffects UpdateTremor and UpdateFOVPulse**

At `loreEffects.lua:47` and `loreEffects.lua:64`, use `self.cachedPlayer` instead of `Game.GetPlayer()`:

```lua
local V = self.cachedPlayer
if not V or not IsDefined(V) then return end
```

- [ ] **Step 5: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/loreEffects.lua
git commit -m "perf: cache Game.GetPlayer() per frame, pass to hot-path functions"
```

---

### Task 3: Hoist tables to module level (P-6), fix polling interval (P-7), cache equipment (R-7)

**Files:**
- Modify: `strain.lua:10,17,40,63` (hoist tables)
- Modify: `immunoblocker_logic.lua:112` (polling interval)
- Modify: `init.lua:387-405` (equipment cache)

- [ ] **Step 1: Hoist strain tables to module level**

In `strain.lua`, move the table literals OUTSIDE the functions to module-local scope (created once at require time):

```lua
-- At top of strain.attach(), before any function definitions:
local strainThresholds = { [0]=100, [1]=85, [2]=70, [3]=55, [4]=40, [5]=30 }
local strainGuaranteed = { [2]=120, [3]=100, [4]=80, [5]=70 }
local immunoReduction = { full = 0.8, partial = 0.5 }

-- Then in GetStrainThreshold:
dsp.GetStrainThreshold = (function(self)
    return strainThresholds[self.CyberPsychoWarnings] or 100
 end)

-- In GetStrainGuaranteed:
dsp.GetStrainGuaranteed = (function(self)
    return strainGuaranteed[self.CyberPsychoWarnings]
 end)

-- In AddStrain and UpdatePassiveStrain, reference the module-level immunoReduction
```

- [ ] **Step 2: Increase immunoblocker polling interval**

At `immunoblocker_logic.lua:112`, change `0.25` to `1.0`:
```lua
if now - immunoRealTimeClock < 1.0 then return end
```

- [ ] **Step 3: Cache IsWearingSandevistan result**

At `init.lua`, add a cached field and invalidate on game load:

```lua
-- In IsWearingSandevistan (line 399):
,IsWearingSandevistan = (function(self)
    if self.cachedIsWearing ~= nil then return self.cachedIsWearing end
    local result = self:GetSandevistanIndex()
    self.cachedIsWearing = (result ~= false and result ~= nil)
    return self.cachedIsWearing
 end)
```

Invalidate in `LoadGamePart1` and on cyberware change:
```lua
self.cachedIsWearing = nil
```

- [ ] **Step 4: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/strain.lua bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/immunoblocker_logic.lua bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua
git commit -m "perf: hoist tables to module level, cache equipment, reduce polling"
```

---

### Task 4: Remove dead code, fix redundant branches (R-1 through R-6, P-5)

**Files:**
- Modify: `init.lua` (multiple locations)
- Modify: `immunoblocker_logic.lua:127-128`

- [ ] **Step 1: Remove CheckImmunoblockerConsumed no-op call**

At `init.lua:1426`, remove the call:
```lua
-- DELETE: self:CheckImmunoblockerConsumed()
```

At `immunoblocker_logic.lua:127-128`, remove the no-op definition:
```lua
-- DELETE: dsp.CheckImmunoblockerConsumed = (function(self) end)
```

- [ ] **Step 2: Fix TimeDilationEffects redundant branch**

At `init.lua:1015-1024`, the `elseif not self:IsWearingSandevistan()` and `else` both call `TimeDilationEffects_AllOff()`. Simplify:

```lua
-- FROM:
elseif not self:IsWearingSandevistan() then
    self:TimeDilationEffects_AllOff()
else
    self:TimeDilationEffects_AllOff()
end
-- TO:
else
    self:TimeDilationEffects_AllOff()
end
```

- [ ] **Step 3: Remove bbs no-ops**

At `init.lua`, find `bbs.Init` and `bbs.StartSandevistan` definitions and remove the empty function bodies. Also remove their call sites if they exist.

- [ ] **Step 4: Remove duplicate field declarations**

At `init.lua`, if `prescribedDoses` and `completedDoses` are declared twice in the `dsp` table, remove the duplicate.

- [ ] **Step 5: Deduplicate HUD update during Sandy**

At `init.lua:1159-1161` (runningHudTick 0.2s path), this overlaps with displayTick Phase 0 which also calls UpdateUIText. The runningHudTick path is the important one during Sandy (faster). The displayTick UpdateUIText at Phase 0 should skip when Sandy is running:

```lua
-- In displayTick Phase 0 (around line 1305):
if self.displayTick2 == 0 then
    -- ... menu/braindance checks ...
    if not self.isRunning then  -- Sandy has its own HUD tick at 0.2s
        self:UpdateUIText()
    end
```

- [ ] **Step 6: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/immunoblocker_logic.lua
git commit -m "refactor: remove dead code, fix redundant branches, deduplicate HUD updates"
```

---

### Task 5: Add onShutdown handler, fix stale refs, fix phantomNPCs GC (C-1, M-1, M-3)

**Files:**
- Modify: `init.lua` (add onShutdown, combatNPCs cleanup)
- Modify: `psychosis.lua` (phantomNPCs table reuse)

- [ ] **Step 1: Add onShutdown handler**

At end of `init.lua` (before the last `end` or after last `registerInput`), add:

```lua
registerForEvent('onShutdown', function()
    -- Stop audio
    pcall(function() dsp:StopHeartbeat() end)
    pcall(function() Game.GetAudioSystem():Stop(CName.new("ui_gmpl_perk_edgerunner")) end)
    pcall(function() dsp.hud:StopSong() end)
    pcall(function() dsp.hud:StopVoiceLine() end)
    -- Clean time dilation
    pcall(function()
        local ts = Game.GetTimeSystem()
        ts:UnsetTimeDilation("sandevistan")
        ts:SetIgnoreTimeDilationOnLocalPlayerZero(false)
    end)
    -- Despawn phantoms
    pcall(function() dsp:DespawnAllPhantoms() end)
    print('[DSP] onShutdown: cleanup complete')
end)
```

- [ ] **Step 2: Add combatNPCs periodic cleanup**

In displayTick Phase 2 or 3 (called 1/sec), add a periodic cleanup of stale combatNPCs references. Every ~30s, iterate and remove entries where `IsDefined()` returns false:

```lua
-- In displayTick, add accumulator:
self.combatNPCCleanupAccum = (self.combatNPCCleanupAccum or 0) + 1
if self.combatNPCCleanupAccum >= 30 then
    self.combatNPCCleanupAccum = 0
    local cleaned = 0
    for eid, _ in pairs(self.combatNPCs) do
        local ok, ent = pcall(function() return Game.FindEntityByID(EntEntityID.new({hash = tonumber(eid)})) end)
        if not ok or not ent or not IsDefined(ent) then
            self.combatNPCs[eid] = nil
            cleaned = cleaned + 1
        end
    end
    if cleaned > 0 then print('[DSP] Cleaned '..cleaned..' stale combatNPC refs') end
end
```

- [ ] **Step 3: Fix phantomNPCs table reuse**

In `psychosis.lua` UpdateHallucinations, instead of creating `local newList = {}` every frame, filter in-place or reuse:

```lua
-- Replace the newList pattern with in-place removal (iterate backwards):
local i = #self.phantomNPCs
while i >= 1 do
    local phantom = self.phantomNPCs[i]
    -- ... process phantom (behavior, glitch, despawn checks) ...
    if now >= phantom.despawnTime then
        -- despawn logic
        table.remove(self.phantomNPCs, i)
    end
    i = i - 1
end
```

- [ ] **Step 4: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/psychosis.lua
git commit -m "fix: add onShutdown cleanup, periodic stale ref cleanup, reduce GC pressure"
```

---

### Task 6: Copy to game and verify

- [ ] **Step 1: Sync all modified files to game directory**

```bash
for f in init.lua strain.lua psychosis.lua loreEffects.lua immunoblocker_logic.lua; do
    cp "bin/x64/.../DavidSandevistanPlus/$f" "/mnt/g/SteamLibrary/.../DavidSandevistanPlus/$f"
done
```

- [ ] **Step 2: Start game, load save, verify no errors in CET log**

Check `scripting.log` for `[DSP]` entries — should see all modules attached without errors.

- [ ] **Step 3: Test critical paths**

1. Activate Sandy → verify HUD updates, tremor works
2. Visit ripper with psycho level > 0 → verify treatment protocol, SMS
3. Save/load → verify treatmentActive and completedVisits persist correctly (E-2 fix)
4. Let Sandy drain health → verify health brake works
5. Exit game → check log for `[DSP] onShutdown: cleanup complete`
