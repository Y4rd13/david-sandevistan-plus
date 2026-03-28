# Mod Settings Migration — Design Spec

## Goal

Replace MartinezPLUS (CET nativeSettings mod) with Mod Settings framework (@runtimeProperty in redscript). All 63 settings appear in the in-game Settings panel under "David Sandevistan Plus", organized in 7 categories. MartinezPLUS is deleted entirely.

## Why

- Mod Settings is the community standard (52+ mods use it)
- In-game settings panel vs CET "MODS" tab — better UX
- No manual save/load code — framework handles persistence
- Native dependency system (show/hide settings based on toggles)
- Type-safe redscript properties vs weakly-typed Lua tables
- Eliminates MartinezPLUS as a separate mod to maintain

## Architecture

### Data Flow

```
User changes setting in UI (in-game Settings → Mods → David Sandevistan Plus)
    │
    ▼
Mod Settings framework auto-persists to user.ini
    │
    ▼
DSPSettings.reds properties updated automatically (RegisterListenerToClass)
    │
    ▼
OnModSettingsChange callback sets quest fact: dsp_settings_changed = 1
    │
    ▼
CET displayTick detects quest fact, calls syncSettingsFromRedscript()
    │
    ▼
dsp.cfg table populated from redscript values
    │
    ▼
applyTweakDBFromSettings() updates TweakDB stat modifiers
```

### Key Decisions

1. **Mod Settings is a hard dependency** — no fallback to config.json. If not installed, mod works with hardcoded defaults but has no settings UI.
2. **TweakDB updates stay in CET Lua** — CET already has `TweakDB:SetFlat()` working; no need to duplicate in redscript.
3. **Quest fact bridge for change detection** — redscript sets `dsp_settings_changed = 1` on change, CET polls in displayTick phase 0. Avoids constant polling of 63 fields.
4. **One-time config.json migration** — reads old MartinezPLUS config, writes to user.ini, renames to `.migrated`.
5. **`strainDrainImmunoblocker` array split** — Mod Settings doesn't support arrays. Split into 3 individual Float fields. CET reconstructs the array after sync.

### Files

| Action | File | Purpose |
|--------|------|---------|
| CREATE | `r6/scripts/DavidSandevistanPlus/DSPSettings.reds` | Settings class with 63 @runtimeProperty fields |
| MODIFY | `bin/x64/.../DavidSandevistanPlus/init.lua` | Replace loadConfig → syncSettingsFromRedscript, add TweakDB apply, migration, change detection |
| MODIFY | `bin/x64/.../DavidSandevistanPlus/immunoblocker_logic.lua` | Adapt toleranceDecayHours from cfg (currently hardcoded 24h) |
| DELETE | `bin/x64/.../MartinezPLUS/` | Entire mod folder removed |

---

## Shared Enum

```reds
enum DSPDilationLevel {
    Pct85 = 0,    // world at 15% speed
    Pct90 = 1,    // world at 10% speed
    Pct92_5 = 2,  // world at 7.5% speed
    Pct95 = 3,    // world at 5% speed (default no perk)
    Pct97_5 = 4,  // world at 2.5% speed
    Pct99 = 5,    // world at 1% speed
    Pct99_25 = 6, // world at 0.75% speed
    Pct99_35 = 7, // world at 0.65% speed (default with perk)
    Pct99_5 = 8   // world at 0.5% speed
}
```

CET maps enum int value to float time scale:
```lua
local dilationMap = {
    [0] = 0.15, [1] = 0.10, [2] = 0.075, [3] = 0.05,
    [4] = 0.025, [5] = 0.01, [6] = 0.0075, [7] = 0.0065, [8] = 0.005
}
```

---

## Settings by Category (63 total)

### Category 1: Time Dilation (6 settings)

| Field | Type | Range / Step | Default | Dependency | Tooltip |
|-------|------|-------------|---------|------------|---------|
| `requireEdgeRunnerPerk` | Bool | — | true | — | Require the EdgeRunner perk for enhanced time dilation. Without it, V uses the weaker 'No Perk' dilation level. |
| `timeDilationNoPerk` | DSPDilationLevel | enum | Pct95 | — | Base time dilation without EdgeRunner perk. Further modified by: psycho stage (stages 3-5 make dilation progressively stronger through a hardcoded curve), and reduced by session fatigue if enabled. |
| `timeDilationWithPerk` | DSPDilationLevel | enum | Pct99_35 | — | Base time dilation with EdgeRunner perk. Same stage-based curve and fatigue modifiers apply. 99.35% = David's canonical dilation in the anime. |
| `enableSessionFatigue` | Bool | — | true | — | Each activation beyond the daily safe limit makes time dilation slightly weaker for the rest of the day. Simulates neural fatigue from overuse. |
| `sessionFatiguePenalty` | Float | 0.01–0.10 / 0.01 | 0.02 | enableSessionFatigue | Dilation effectiveness lost per overuse activation. At 0.02, the 5th overuse activation loses 10% dilation power. Fatigue resets on sleep. |
| `maxSessionFatiguePenalty` | Float | 0.05–0.30 / 0.01 | 0.10 | enableSessionFatigue | Maximum dilation loss from session fatigue. At 0.10, V never loses more than 10% effectiveness regardless of overuse count. |

**Enum displayValues for dilation fields:**
- Pct85 → "85% — World at 15% speed"
- Pct90 → "90% — World at 10% speed"
- Pct92_5 → "92.5% — World at 7.5% speed"
- Pct95 → "95% — World at 5% speed"
- Pct97_5 → "97.5% — World at 2.5% speed"
- Pct99 → "99% — World at 1% speed"
- Pct99_25 → "99.25% — World at 0.75% speed"
- Pct99_35 → "99.35% — World at 0.65% speed"
- Pct99_5 → "99.5% — World at 0.5% speed"

### Category 2: Runtime & Drain (10 settings)

| Field | Type | Range / Step | Default | Dependency | Tooltip |
|-------|------|-------------|---------|------------|---------|
| `sandyDuration` | Int32 | 1–600 / 1 | 300 | — | Total runtime reservoir in seconds. Drains at 1s/tick normally, 5s/tick with Safety OFF. Not real-time — dilation makes each second feel much longer. [TweakDB] |
| `rechargeDuration` | Float | 0.5–30.0 / 0.5 | 2.0 | — | Base recharge time in real seconds after deactivation. [TweakDB] |
| `cooldownBase` | Float | 0.1–10.0 / 0.1 | 0.5 | — | Cooldown multiplier after deactivation. Lower = shorter wait before reactivation. [TweakDB] |
| `enterCost` | Float | 0.0–1.0 / 0.1 | 0.0 | — | Stamina cost on activation. 0 = free activation. [TweakDB] |
| `killRechargeValue` | Float | 0.0–50.0 / 0.5 | 2.0 | — | Runtime seconds recharged per enemy killed while Sandy is active. [TweakDB] |
| `fullRechargeHours` | Int32 | 1–48 / 1 | 16 | — | Game-time hours of sleep needed to fully recharge runtime reservoir. |
| `maxRechargePerSleep` | Int32 | 1–24 / 1 | 10 | — | Maximum hours of recharge credited per single sleep session. Sleeping 12h with this set to 10 only credits 10h. |
| `enableNonLinearDrain` | Bool | — | true | — | Runtime drain accelerates the longer Sandy stays active. First minute is normal, then ramps up exponentially. |
| `drainExponent` | Float | 1.0–3.0 / 0.1 | 1.5 | enableNonLinearDrain | Acceleration curve exponent. Higher = drain ramps up more aggressively after the start threshold. Formula: 1.0 + (overTime ^ exponent). |
| `drainAccelStartSec` | Int32 | 10–180 / 1 | 60 | enableNonLinearDrain | Seconds of continuous Sandy use before drain acceleration kicks in. Below this, drain is flat. |

### Category 3: Combat Stats (5 settings)

| Field | Type | Range / Step | Default | Dependency | Tooltip |
|-------|------|-------------|---------|------------|---------|
| `critChance` | Int32 | 0–100 / 1 | 30 | — | Bonus critical hit chance while Sandy is active. Stacks with V's base crit chance. [TweakDB] |
| `critDamage` | Int32 | 0–500 / 1 | 35 | — | Bonus critical hit damage while Sandy is active. [TweakDB] |
| `headshotDamageMultiplier` | Float | 1.0–5.0 / 0.1 | 1.5 | — | Headshot damage multiplier during Sandy. 1.5 = 50% bonus. [TweakDB] |
| `healOnKill` | Float | 0.0–50.0 / 0.5 | 3.0 | — | Percentage of V's max health restored per kill during Sandy. [TweakDB] |
| `staminaOnKill` | Float | 0.0–100.0 / 1.0 | 22.0 | — | Stamina restored per kill during Sandy. [TweakDB] |

### Category 4: Health & Safety (10 settings)

| Field | Type | Range / Step | Default | Dependency | Tooltip |
|-------|------|-------------|---------|------------|---------|
| `enableHealthDrain` | Bool | — | true | — | Sandy drains V's health over time. Damage scales from minimum (at full runtime) to maximum (at depleted runtime). |
| `damageMin` | Float | 0.0–10.0 / 0.5 | 1.0 | enableHealthDrain | Health % drained per tick at full runtime (just activated). The floor of the damage curve. |
| `damageMax` | Float | 0.0–50.0 / 0.5 | 15.0 | enableHealthDrain | Health % drained per tick at zero runtime (fully depleted). The ceiling of the damage curve. |
| `enableHealthBrake` | Bool | — | false | — | Auto-stop Sandy when V's health drops below threshold. A safety net against accidental self-destruction. |
| `healthBrakeThreshold` | Int32 | 15–80 / 1 | 50 | enableHealthBrake | Health % where the brake activates and Sandy auto-deactivates. |
| `requiredHealthMin` | Int32 | 5–50 / 1 | 15 | — | Absolute minimum health % before Sandy refuses to activate. Independent of health brake. |
| `safetyOffDrainMultiplier` | Int32 | 1–10 / 1 | 4 | — | Runtime drain multiplier when Safety OFF. At 4x, Sandy burns through runtime 4 times faster — raw power at a cost. |
| `safetyOffDilation` | DSPDilationLevel | enum | Pct97_5 | — | Time dilation level when Safety OFF is engaged. Overrides the normal stage-based curve. |
| `enableSafetyOffKill` | Bool | — | true | — | At psycho stage 5 with Safety OFF, V can die if health drops below threshold. Disable to remove permadeath risk from Safety OFF. |
| `safetyOffKillThreshold` | Int32 | 1–10 / 1 | 2 | enableSafetyOffKill | Health % where Safety OFF triggers V's death at psycho stage 5. At 2%, V dies when health is nearly depleted. |

### Category 5: Cyberpsychosis (15 settings)

| Field | Type | Range / Step | Default | Dependency | Tooltip |
|-------|------|-------------|---------|------------|---------|
| `enableCyberpsychosis` | Bool | — | true | — | Master toggle for the entire cyberpsychosis system. Disabling removes all strain, episodes, micro-episodes, treatment, and psycho VFX. |
| `dailySafeActivations` | Int32 | 1–20 / 1 | 3 | enableCyberpsychosis | Activations per day before strain penalties increase. Scales with psycho stage: stage 0 gets 3x this value, stage 4 gets 4x. Beyond this limit, each activation adds bonus strain and session fatigue. |
| `strainPerActivation` | Int32 | 1–20 / 1 | 5 | enableCyberpsychosis | Base neural strain added each time Sandy activates. Applied as raw strain (bypasses stage tolerance). Immunoblockers reduce this by 80%/50%. |
| `strainPerOveruseBonus` | Int32 | 1–20 / 1 | 3 | enableCyberpsychosis | Extra strain per activation beyond the daily safe limit. Stacks: 3rd overuse adds 3x this value on top of base strain. |
| `strainPerMinuteActive` | Int32 | 1–10 / 1 | 2 | enableCyberpsychosis | Strain accumulated per minute of active Sandy use. Subject to stage multiplier (stages 0-1: 0.5x, stage 2: 0.75x, stages 3+: 1.0x). |
| `strainPerSecSafetyOff` | Float | 0.01–1.0 / 0.01 | 0.15 | enableCyberpsychosis | Strain per second while Safety OFF is active. Applied as raw strain (bypasses stage tolerance). Adds up fast — 9 strain per minute. |
| `strainPerKillGang` | Int32 | 0–20 / 1 | 2 | enableCyberpsychosis | Neural strain per gang member killed during Sandy. Lowest tier — routine targets. |
| `strainPerKillCorpo` | Int32 | 0–20 / 1 | 3 | enableCyberpsychosis | Neural strain per corporate security killed during Sandy. |
| `strainPerKillNCPD` | Int32 | 0–20 / 1 | 5 | enableCyberpsychosis | Neural strain per NCPD or NetWatch agent killed during Sandy. High-profile targets weigh on V's psyche. |
| `strainPerKillCivilian` | Int32 | 0–20 / 1 | 8 | enableCyberpsychosis | Neural strain per civilian killed during Sandy. Highest impact — killing innocents accelerates psychosis dramatically. |
| `strainBuildupMultiplier` | Float | 0.25–3.0 / 0.05 | 1.0 | enableCyberpsychosis | Global multiplier for ALL neural strain accumulation. Affects activation strain, runtime strain, kill strain, and passive strain at stages 4-5 (+0.04/+0.08 per sec). Does NOT affect raw strain sources (Safety OFF, kills). Immunoblockers reduce strain independently (80% full / 50% partial). |
| `strainRecoveryMultiplier` | Float | 0.25–3.0 / 0.05 | 1.0 | enableCyberpsychosis | Global multiplier for ALL strain recovery. Affects sleep drain, ripperdoc drain, immunoblocker drain, safe area drain, and natural decay at stages 0-2 (-0.03/-0.02/-0.01 per sec). Higher = faster recovery. |
| `episodeCooldownMultiplier` | Float | 0.25–3.0 / 0.05 | 1.0 | enableCyberpsychosis | Multiplier for minimum game-time between psychosis stage escalations. Base cooldowns: 48h/36h/24h/12h/6h for stages 1-5. At 2.0x, stage 4 to 5 requires 24h instead of 12h. Treatment milestones further extend cooldowns dynamically. |
| `enableMicroEpisodes` | Bool | — | true | enableCyberpsychosis | Random involuntary symptoms (visual glitches, tremors, nosebleeds, manic laughs) between major episodes. Frequency scales with psycho stage. |
| `microEpisodeFrequency` | Float | 0.25–3.0 / 0.05 | 1.0 | enableMicroEpisodes | Multiplier for micro-episode frequency. At 0.5, symptoms happen half as often. Base intervals: stage 1 = 5-10min, stage 5 = 5-15sec. |

### Category 6: Recovery & Treatment (12 settings)

| Field | Type | Range / Step | Default | Dependency | Tooltip |
|-------|------|-------------|---------|------------|---------|
| `enablePrescription` | Bool | — | true | enableCyberpsychosis | Treatment protocol: recovery requires immunoblocker doses, ripperdoc visits, and rest — prescribed by Viktor per stage. Disabling makes recovery instant on sleep/ripper visit. |
| `enableRuntimeDegradation` | Bool | — | true | — | Each Sandy session permanently reduces max runtime (1% per 60s active). Sleep recovers a percentage, ripperdoc can fully restore. Simulates hardware wear. |
| `sleepRecoveryPercent` | Float | 0.25–1.0 / 0.05 | 0.75 | enableRuntimeDegradation | Percentage of degraded max runtime recovered per sleep. At 0.75, sleep restores 75% of lost capacity. Full restore requires ripperdoc. |
| `ripperFullRestore` | Bool | — | true | enableRuntimeDegradation | Ripperdoc visit restores 100% max runtime, removing all degradation. If disabled, only sleep recovery works. |
| `strainDrainSleep` | Int32 | 5–100 / 1 | 40 | enableCyberpsychosis | Base neural strain drained per sleep session. Scaled by hours rested and recovery multiplier. |
| `strainDrainRipper` | Int32 | 5–100 / 1 | 25 | enableCyberpsychosis | Neural strain drained per ripperdoc visit. Applied once per visit, scaled by recovery multiplier. |
| `strainDrainSafeArea` | Float | 0.01–0.50 / 0.01 | 0.05 | enableCyberpsychosis | Strain drained per second while in safe areas (V's apartment, clubs). Slow passive recovery when not in danger. |
| `strainDrainImmunoblockerCommon` | Float | 0.01–0.50 / 0.01 | 0.08 | enableCyberpsychosis | Strain drained per second while Common immunoblocker is active (3min duration). Weakest tier. |
| `strainDrainImmunoblockerUncommon` | Float | 0.01–0.50 / 0.01 | 0.18 | enableCyberpsychosis | Strain drained per second while Uncommon immunoblocker is active (6min duration). Mid tier. |
| `strainDrainImmunoblockerRare` | Float | 0.01–0.50 / 0.01 | 0.35 | enableCyberpsychosis | Strain drained per second while Military-Grade immunoblocker is active (10min duration). Strongest tier — prescribed for stages 3+. |
| `strainDrainDFImmuno` | Float | 0.01–0.50 / 0.01 | 0.08 | enableCyberpsychosis | Strain drained per second while Dark Future's Immunosuppressant is active. For compatibility with Dark Future mod. |
| `toleranceDecayHours` | Int32 | 6–72 / 1 | 24 | enableCyberpsychosis | Game-time hours before immunoblocker tolerance starts to decay. Tolerance builds with each dose (higher tolerance = weaker effectiveness). After this period without doses, tolerance slowly decreases. |

### Category 7: Economy & Interface (5 settings)

| Field | Type | Range / Step | Default | Dependency | Tooltip |
|-------|------|-------------|---------|------------|---------|
| `immunoblockerPriceCommon` | Int32 | 500–20000 / 500 | 6000 | — | Price in eddies for Common immunoblocker at Viktor's shop. Duration: 3min. |
| `immunoblockerPriceUncommon` | Int32 | 1000–50000 / 1000 | 24000 | — | Price in eddies for Uncommon immunoblocker at Viktor's shop. Duration: 6min. |
| `immunoblockerPriceRare` | Int32 | 5000–200000 / 5000 | 100000 | — | Price in eddies for Military-Grade immunoblocker at Viktor's shop. Duration: 10min. |
| `biomonitorPosX` | Int32 | 0–3000 / 10 | 80 | — | Biomonitor horizontal position on 3840x2160 reference canvas. Auto-scales to your resolution. |
| `biomonitorPosY` | Int32 | 0–2000 / 10 | 600 | — | Biomonitor vertical position on 3840x2160 reference canvas. Auto-scales to your resolution. |

---

## Changes vs Current MartinezPLUS

| Change | Detail |
|--------|--------|
| **Removed** | `maxPsychoRecoveryPerSleep`, `ripperRecoveryLevels` (dead code from old recovery system), `tickLength` (internal engine constant) |
| **Renamed** | `healthBrakeDefault` → `healthBrakeThreshold` |
| **New** | `episodeCooldownMultiplier`, `toleranceDecayHours` |
| **Exposed** (previously hidden in config.json) | `strainPerActivation`, `strainPerOveruseBonus`, `strainPerMinuteActive`, `strainPerSecSafetyOff`, `safetyOffDrainMultiplier`, `safetyOffDilation`, `enableSafetyOffKill`, `safetyOffKillThreshold` |
| **Split** | `strainDrainImmunoblocker` array → 3 individual Float fields |
| **Type changed** | `timeDilationNoPerk`/`WithPerk` float→enum, `safetyOffTimeDilation`→`safetyOffDilation` enum |

---

## Migration: config.json → user.ini

### Strategy: One-time automatic migration from CET on first init.

1. CET checks if `config.json` exists alongside init.lua
2. Reads and parses the JSON
3. Maps keys to new names/types (see mapping table below)
4. Reads existing user.ini, checks if `[DSPSettings]` section exists
5. If section does NOT exist: writes migrated values to user.ini
6. Renames `config.json` → `config.json.migrated`
7. Shows notification: "Settings migrated to Mod Settings (in-game Settings → Mods)"

### Key Mapping

| config.json key | user.ini field | Transform |
|----------------|----------------|-----------|
| `timeDilationNoPerk` | `timeDilationNoPerk` | float → enum index (fuzzy-match to nearest value) |
| `timeDilationWithPerk` | `timeDilationWithPerk` | float → enum index |
| `safetyOffTimeDilation` | `safetyOffDilation` | int 975 → enum Pct97_5 (convert: match (1000-val)/1000 to dilation map) |
| `healthBrakeDefault` | `healthBrakeThreshold` | rename only |
| `strainDrainImmunoblocker` | 3 fields | array[1]→Common, [2]→Uncommon, [3]→Rare |
| All others | same name | direct value copy |

### Keys NOT migrated (removed):
- `maxPsychoRecoveryPerSleep` — ignored
- `ripperRecoveryLevels` — ignored
- `tickLength` — ignored

### Edge case: user.ini already has [DSPSettings]
Do NOT overwrite. The user already configured via Mod Settings. Only migrate if the section does not exist.

---

## DSPSettings.reds — Lifecycle

```reds
public class DSPSettings extends ScriptableSystem {

    // ... 63 @runtimeProperty fields (see categories above) ...

    public static func Get(gi: GameInstance) -> ref<DSPSettings> {
        return GameInstance.GetScriptableSystemsContainer(gi)
            .Get(n"DSPSettings") as DSPSettings;
    }

    @if(ModuleExists("ModSettingsModule"))
    private func OnAttach() -> Void {
        ModSettings.RegisterListenerToClass(this);
        ModSettings.RegisterListenerToModifications(this);
    }

    @if(ModuleExists("ModSettingsModule"))
    private func OnDetach() -> Void {
        ModSettings.UnregisterListenerToClass(this);
        ModSettings.UnregisterListenerToModifications(this);
    }

    @if(ModuleExists("ModSettingsModule"))
    private cb func OnModSettingsChange() -> Void {
        SetFactValue(GetGameInstance(), n"dsp_settings_changed", 1);
    }

    @if(!ModuleExists("ModSettingsModule"))
    private func OnAttach() -> Void {}

    @if(!ModuleExists("ModSettingsModule"))
    private func OnDetach() -> Void {}
}
```

---

## CET Bridge (init.lua)

### syncSettingsFromRedscript()

Replaces `loadConfig()`. Called on init and when quest fact `dsp_settings_changed` is detected.

```lua
local dilationMap = {
    [0] = 0.15, [1] = 0.10, [2] = 0.075, [3] = 0.05,
    [4] = 0.025, [5] = 0.01, [6] = 0.0075, [7] = 0.0065, [8] = 0.005
}

local function syncSettingsFromRedscript()
    local ok, settings = pcall(function()
        return Game.GetScriptableSystemsContainer():Get(CName.new('DSPSettings'))
    end)
    if not ok or not settings then return false end

    -- Enums → float time scale
    dsp.cfg.timeDilationNoPerk = dilationMap[settings.timeDilationNoPerk] or 0.05
    dsp.cfg.timeDilationWithPerk = dilationMap[settings.timeDilationWithPerk] or 0.0065
    dsp.cfg.safetyOffTimeDilation = dilationMap[settings.safetyOffDilation] or 0.025

    -- Booleans and numbers: direct copy
    dsp.cfg.enableCyberpsychosis = settings.enableCyberpsychosis
    dsp.cfg.requireEdgeRunnerPerk = settings.requireEdgeRunnerPerk
    -- ... all 50+ remaining fields ...

    -- Reconstruct array from split fields
    dsp.cfg.strainDrainImmunoblocker = {
        settings.strainDrainImmunoblockerCommon,
        settings.strainDrainImmunoblockerUncommon,
        settings.strainDrainImmunoblockerRare
    }

    -- Renamed field
    -- healthBrakeThreshold in redscript → healthBrakeDefault in dsp.cfg (internal name preserved)
    dsp.cfg.healthBrakeDefault = settings.healthBrakeThreshold

    return true
end
```

### applyTweakDBFromSettings()

Moved from MartinezPLUS. Reads from `dsp.cfg` and applies to TweakDB:

```lua
local function applyTweakDBFromSettings()
    local base = 'Items.MartinezSandevistanPlusPlus'
    TweakDB:SetFlat(base .. '_Stat_Modifier_03.value', dsp.cfg.sandyDuration + 0.0)
    TweakDB:SetFlat(base .. '_Stat_Modifier_05.value', dsp.cfg.rechargeDuration)
    TweakDB:SetFlat(base .. '_Stat_Modifier_06.value', dsp.cfg.cooldownBase)
    TweakDB:SetFlat(base .. '_Stat_Modifier_07.value', dsp.cfg.killRechargeValue)
    TweakDB:SetFlat(base .. '_Stat_Modifier_08.value', dsp.cfg.enterCost)
    TweakDB:SetFlat(base .. '_Equip3_SM1.value', dsp.cfg.critChance + 0.0)
    TweakDB:SetFlat(base .. '_Equip3_SM2.value', dsp.cfg.critDamage + 0.0)
    TweakDB:SetFlat(base .. '_Equip3_SM3.value', dsp.cfg.headshotDamageMultiplier)
    TweakDB:SetFlat(base .. '_Equip4_SPU1.statPoolValue', dsp.cfg.healOnKill)
    TweakDB:SetFlat(base .. '_Equip4_SPU2.statPoolValue', dsp.cfg.staminaOnKill)
    -- Update all modified flats
    for _, suffix in ipairs({'_Stat_Modifier_03', '_Stat_Modifier_05', '_Stat_Modifier_06',
        '_Stat_Modifier_07', '_Stat_Modifier_08', '_Equip3_SM1', '_Equip3_SM2', '_Equip3_SM3',
        '_Equip4_SPU1', '_Equip4_SPU2'}) do
        TweakDB:Update(base .. suffix)
    end
end
```

### Change detection in displayTick

```lua
-- displayTick phase 0 (runs every ~1s)
local changed = Game.GetQuestSystem():GetFactValue(CName.new('dsp_settings_changed'))
if changed and changed > 0 then
    syncSettingsFromRedscript()
    applyTweakDBFromSettings()
    Game.GetQuestSystem():SetFactValue(CName.new('dsp_settings_changed'), 0)
end
```

### Init flow

```lua
registerForEvent("onInit", function()
    -- Try Mod Settings first
    local ok = syncSettingsFromRedscript()
    if not ok then
        print('[DSP] WARNING: Mod Settings not detected. Using defaults.')
        -- dsp.cfg retains hardcoded defaults — mod works without settings UI
    end

    -- Migrate old config.json if present
    migrateConfigJson()

    -- Apply TweakDB
    applyTweakDBFromSettings()
end)
```

---

## What Gets Deleted

### MartinezPLUS mod (entire folder)
- `bin/x64/.../MartinezPLUS/init.lua` — 500+ lines of nativeSettings UI code
- `bin/x64/.../MartinezPLUS/json.lua` — JSON encoder/decoder (only used by MartinezPLUS)
- Any other files in the MartinezPLUS folder

### Dependencies no longer required by DSP
- `nativeSettings` CET mod — no longer needed (other mods may still use it)
- `nativeSettings_side_menu_add_on` — no longer needed

### From init.lua
- `loadConfig()` function
- `configFile` path variable
- Any references to MartinezPLUS or nativeSettings

---

## Hardcoded Values — Tooltip Documentation

All hardcoded values that affect configurable settings are documented in tooltips. Users see the full mechanical context without needing to read code. Key examples:

- **strainBuildupMultiplier tooltip** explains: stage multipliers (0.5x/0.5x/0.75x/1.0x/1.0x/1.0x), passive strain rates (+0.04/+0.08 per sec at stages 4-5), immunoblocker reduction (80%/50%)
- **dailySafeActivations tooltip** explains: psycho-scaled multiplier (stage 0 = 3x base, stage 4 = 4x)
- **episodeCooldownMultiplier tooltip** explains: base cooldown hours per stage (48/36/24/12/6), dynamic treatment milestone extension
- **microEpisodeFrequency tooltip** explains: base intervals per stage (5-10min at stage 1, 5-15sec at stage 5)
- **timeDilation tooltips** explain: stage-based curve, fatigue modifier, Safety OFF override

---

## Verification Checklist

1. Settings appear in-game under Settings → Mods → "David Sandevistan Plus"
2. 7 categories visible with correct grouping
3. Dependencies work (disable enableCyberpsychosis → Cyberpsychosis + Recovery settings hidden)
4. Enum dropdowns show localized labels ("99.35% — World at 0.65% speed")
5. Changing a setting persists to user.ini
6. Changing a setting triggers quest fact → CET syncs → dsp.cfg updated
7. TweakDB values update when combat stats change
8. config.json migration works: old values appear in Mod Settings, file renamed to .migrated
9. MartinezPLUS folder deleted, no orphan references
10. Mod works with defaults if Mod Settings not installed (no crash)
11. No nativeSettings dependency remains
