# Mod Settings Migration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace MartinezPLUS (CET nativeSettings) with Mod Settings framework — 63 @runtimeProperty settings in redscript, CET bridge via quest fact, one-time config.json migration.

**Architecture:** DSPSettings.reds declares all settings with @runtimeProperty annotations. On change, redscript sets quest fact `dsp_settings_changed`. CET detects this in displayTick phase 0, reads all values from the redscript class, populates `dsp.cfg`, and applies TweakDB updates. MartinezPLUS is deleted entirely.

**Tech Stack:** Redscript (Mod Settings @runtimeProperty), CET Lua 5.3, TweakDB, Quest Facts bridge

**Spec:** `docs/superpowers/specs/2026-03-28-mod-settings-migration.md`

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| CREATE | `r6/scripts/DavidSandevistanPlus/DSPSettings.reds` | All 63 settings with Mod Settings annotations, lifecycle, quest fact bridge |
| MODIFY | `bin/x64/.../DavidSandevistanPlus/init.lua` | Replace loadConfig with syncSettingsFromRedscript, add applyTweakDBFromSettings, migration, change detection |
| MODIFY | `bin/x64/.../DavidSandevistanPlus/immunoblocker_logic.lua` | Wire toleranceDecayHours from cfg instead of hardcoded 24 |
| MODIFY | `bin/x64/.../DavidSandevistanPlus/strain.lua` | Wire episodeCooldownMultiplier into TriggerStrainEpisode |
| DELETE | `bin/x64/.../MartinezPLUS/init.lua` | Entire mod removed |

---

### Task 1: Create DSPSettings.reds — Enum + Settings Class

**Files:**
- Create: `r6/scripts/DavidSandevistanPlus/DSPSettings.reds`

- [ ] **Step 1: Create DSPSettings.reds with the DSPDilationLevel enum and full settings class**

```reds
// DSPSettings.reds — Mod Settings integration for David Sandevistan Plus
// All settings declared via @runtimeProperty for the Mod Settings framework.
// CET Lua reads these values via GetScriptableSystemsContainer():Get('DSPSettings').

enum DSPDilationLevel {
    Pct85 = 0,
    Pct90 = 1,
    Pct92_5 = 2,
    Pct95 = 3,
    Pct97_5 = 4,
    Pct99 = 5,
    Pct99_25 = 6,
    Pct99_35 = 7,
    Pct99_5 = 8
}

public class DSPSettings extends ScriptableSystem {

    // ==================== Category 1: Time Dilation ====================

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Time Dilation")
    @runtimeProperty("ModSettings.category.order", "1")
    @runtimeProperty("ModSettings.displayName", "Require EdgeRunner Perk")
    @runtimeProperty("ModSettings.description", "Require the EdgeRunner perk for enhanced time dilation. Without it, V uses the weaker No Perk dilation level.")
    public let requireEdgeRunnerPerk: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Time Dilation")
    @runtimeProperty("ModSettings.category.order", "1")
    @runtimeProperty("ModSettings.displayName", "Time Dilation (No Perk)")
    @runtimeProperty("ModSettings.description", "Base time dilation without EdgeRunner perk. Further modified by psycho stage (stages 3-5 progressively stronger) and session fatigue.")
    @runtimeProperty("ModSettings.displayValues.Pct85", "85% — World at 15% speed")
    @runtimeProperty("ModSettings.displayValues.Pct90", "90% — World at 10% speed")
    @runtimeProperty("ModSettings.displayValues.Pct92_5", "92.5% — World at 7.5% speed")
    @runtimeProperty("ModSettings.displayValues.Pct95", "95% — World at 5% speed")
    @runtimeProperty("ModSettings.displayValues.Pct97_5", "97.5% — World at 2.5% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99", "99% — World at 1% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99_25", "99.25% — World at 0.75% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99_35", "99.35% — World at 0.65% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99_5", "99.5% — World at 0.5% speed")
    public let timeDilationNoPerk: DSPDilationLevel = DSPDilationLevel.Pct95;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Time Dilation")
    @runtimeProperty("ModSettings.category.order", "1")
    @runtimeProperty("ModSettings.displayName", "Time Dilation (With Perk)")
    @runtimeProperty("ModSettings.description", "Base time dilation with EdgeRunner perk. Same stage-based curve and fatigue modifiers apply. 99.35% = David's canonical dilation.")
    @runtimeProperty("ModSettings.displayValues.Pct85", "85% — World at 15% speed")
    @runtimeProperty("ModSettings.displayValues.Pct90", "90% — World at 10% speed")
    @runtimeProperty("ModSettings.displayValues.Pct92_5", "92.5% — World at 7.5% speed")
    @runtimeProperty("ModSettings.displayValues.Pct95", "95% — World at 5% speed")
    @runtimeProperty("ModSettings.displayValues.Pct97_5", "97.5% — World at 2.5% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99", "99% — World at 1% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99_25", "99.25% — World at 0.75% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99_35", "99.35% — World at 0.65% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99_5", "99.5% — World at 0.5% speed")
    public let timeDilationWithPerk: DSPDilationLevel = DSPDilationLevel.Pct99_35;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Time Dilation")
    @runtimeProperty("ModSettings.category.order", "1")
    @runtimeProperty("ModSettings.displayName", "Enable Session Fatigue")
    @runtimeProperty("ModSettings.description", "Each activation beyond the daily safe limit makes time dilation slightly weaker. Simulates neural fatigue from overuse.")
    public let enableSessionFatigue: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Time Dilation")
    @runtimeProperty("ModSettings.category.order", "1")
    @runtimeProperty("ModSettings.displayName", "Fatigue Penalty per Overuse")
    @runtimeProperty("ModSettings.description", "Dilation effectiveness lost per overuse activation. At 0.02, the 5th overuse loses 10% power. Resets on sleep.")
    @runtimeProperty("ModSettings.step", "0.01")
    @runtimeProperty("ModSettings.min", "0.01")
    @runtimeProperty("ModSettings.max", "0.10")
    @runtimeProperty("ModSettings.dependency", "enableSessionFatigue")
    public let sessionFatiguePenalty: Float = 0.02;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Time Dilation")
    @runtimeProperty("ModSettings.category.order", "1")
    @runtimeProperty("ModSettings.displayName", "Max Fatigue Penalty")
    @runtimeProperty("ModSettings.description", "Maximum dilation loss from session fatigue. At 0.10, V never loses more than 10% effectiveness regardless of overuse count.")
    @runtimeProperty("ModSettings.step", "0.01")
    @runtimeProperty("ModSettings.min", "0.05")
    @runtimeProperty("ModSettings.max", "0.30")
    @runtimeProperty("ModSettings.dependency", "enableSessionFatigue")
    public let maxSessionFatiguePenalty: Float = 0.10;

    // ==================== Category 2: Runtime & Drain ====================

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Runtime Tank (seconds)")
    @runtimeProperty("ModSettings.description", "Total runtime reservoir. Drains at 1s/tick normally, 5s/tick Safety OFF. Not real-time — dilation makes each second feel longer.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "600")
    public let sandyDuration: Int32 = 300;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Recharge Duration")
    @runtimeProperty("ModSettings.description", "Base recharge time in real seconds after deactivation.")
    @runtimeProperty("ModSettings.step", "0.5")
    @runtimeProperty("ModSettings.min", "0.5")
    @runtimeProperty("ModSettings.max", "30.0")
    public let rechargeDuration: Float = 2.0;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Cooldown Base")
    @runtimeProperty("ModSettings.description", "Cooldown multiplier after deactivation. Lower = shorter wait before reactivation.")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0.1")
    @runtimeProperty("ModSettings.max", "10.0")
    public let cooldownBase: Float = 0.5;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Activation Cost")
    @runtimeProperty("ModSettings.description", "Stamina cost on activation. 0 = free activation.")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "1.0")
    public let enterCost: Float = 0.0;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Kill Recharge Value")
    @runtimeProperty("ModSettings.description", "Runtime seconds recharged per enemy killed while Sandy is active.")
    @runtimeProperty("ModSettings.step", "0.5")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "50.0")
    public let killRechargeValue: Float = 2.0;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Full Recharge Hours")
    @runtimeProperty("ModSettings.description", "Game-time hours of sleep needed to fully recharge runtime reservoir.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "48")
    public let fullRechargeHours: Int32 = 16;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Max Recharge per Sleep")
    @runtimeProperty("ModSettings.description", "Maximum hours of recharge credited per single sleep session.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "24")
    public let maxRechargePerSleep: Int32 = 10;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Enable Non-Linear Drain")
    @runtimeProperty("ModSettings.description", "Runtime drain accelerates the longer Sandy stays active. First minute is normal, then ramps up exponentially.")
    public let enableNonLinearDrain: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Drain Exponent")
    @runtimeProperty("ModSettings.description", "Acceleration curve exponent. Higher = drain ramps more aggressively. Formula: 1.0 + (overTime ^ exponent).")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "1.0")
    @runtimeProperty("ModSettings.max", "3.0")
    @runtimeProperty("ModSettings.dependency", "enableNonLinearDrain")
    public let drainExponent: Float = 1.5;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Drain Accel Start (sec)")
    @runtimeProperty("ModSettings.description", "Seconds of continuous Sandy use before drain acceleration kicks in. Below this, drain is flat.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "10")
    @runtimeProperty("ModSettings.max", "180")
    @runtimeProperty("ModSettings.dependency", "enableNonLinearDrain")
    public let drainAccelStartSec: Int32 = 60;

    // ==================== Category 3: Combat Stats ====================

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Combat Stats")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.displayName", "Critical Chance")
    @runtimeProperty("ModSettings.description", "Bonus critical hit chance while Sandy is active. Stacks with V's base crit chance.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "100")
    public let critChance: Int32 = 30;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Combat Stats")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.displayName", "Critical Damage")
    @runtimeProperty("ModSettings.description", "Bonus critical hit damage while Sandy is active.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "500")
    public let critDamage: Int32 = 35;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Combat Stats")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.displayName", "Headshot Damage Multiplier")
    @runtimeProperty("ModSettings.description", "Headshot damage multiplier during Sandy. 1.5 = 50% bonus.")
    @runtimeProperty("ModSettings.step", "0.1")
    @runtimeProperty("ModSettings.min", "1.0")
    @runtimeProperty("ModSettings.max", "5.0")
    public let headshotDamageMultiplier: Float = 1.5;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Combat Stats")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.displayName", "Heal on Kill (%)")
    @runtimeProperty("ModSettings.description", "Percentage of V's max health restored per kill during Sandy.")
    @runtimeProperty("ModSettings.step", "0.5")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "50.0")
    public let healOnKill: Float = 3.0;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Combat Stats")
    @runtimeProperty("ModSettings.category.order", "3")
    @runtimeProperty("ModSettings.displayName", "Stamina on Kill")
    @runtimeProperty("ModSettings.description", "Stamina restored per kill during Sandy.")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "100.0")
    public let staminaOnKill: Float = 22.0;

    // ==================== Category 4: Health & Safety ====================

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Health & Safety")
    @runtimeProperty("ModSettings.category.order", "4")
    @runtimeProperty("ModSettings.displayName", "Enable Health Drain")
    @runtimeProperty("ModSettings.description", "Sandy drains V's health over time. Damage scales from minimum (full runtime) to maximum (depleted runtime).")
    public let enableHealthDrain: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Health & Safety")
    @runtimeProperty("ModSettings.category.order", "4")
    @runtimeProperty("ModSettings.displayName", "Min Damage per Tick (%)")
    @runtimeProperty("ModSettings.description", "Health % drained per tick at full runtime (just activated). The floor of the damage curve.")
    @runtimeProperty("ModSettings.step", "0.5")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "10.0")
    @runtimeProperty("ModSettings.dependency", "enableHealthDrain")
    public let damageMin: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Health & Safety")
    @runtimeProperty("ModSettings.category.order", "4")
    @runtimeProperty("ModSettings.displayName", "Max Damage per Tick (%)")
    @runtimeProperty("ModSettings.description", "Health % drained per tick at zero runtime (fully depleted). The ceiling of the damage curve.")
    @runtimeProperty("ModSettings.step", "0.5")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "50.0")
    @runtimeProperty("ModSettings.dependency", "enableHealthDrain")
    public let damageMax: Float = 15.0;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Health & Safety")
    @runtimeProperty("ModSettings.category.order", "4")
    @runtimeProperty("ModSettings.displayName", "Enable Health Brake")
    @runtimeProperty("ModSettings.description", "Auto-stop Sandy when V's health drops below threshold. A safety net against accidental self-destruction.")
    public let enableHealthBrake: Bool = false;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Health & Safety")
    @runtimeProperty("ModSettings.category.order", "4")
    @runtimeProperty("ModSettings.displayName", "Health Brake Threshold (%)")
    @runtimeProperty("ModSettings.description", "Health % where the brake activates and Sandy auto-deactivates.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "15")
    @runtimeProperty("ModSettings.max", "80")
    @runtimeProperty("ModSettings.dependency", "enableHealthBrake")
    public let healthBrakeThreshold: Int32 = 50;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Health & Safety")
    @runtimeProperty("ModSettings.category.order", "4")
    @runtimeProperty("ModSettings.displayName", "Minimum Required Health (%)")
    @runtimeProperty("ModSettings.description", "Absolute minimum health % before Sandy refuses to activate. Independent of health brake.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "5")
    @runtimeProperty("ModSettings.max", "50")
    public let requiredHealthMin: Int32 = 15;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Health & Safety")
    @runtimeProperty("ModSettings.category.order", "4")
    @runtimeProperty("ModSettings.displayName", "Safety OFF Drain Multiplier")
    @runtimeProperty("ModSettings.description", "Runtime drain multiplier when Safety OFF. At 4x, Sandy burns through runtime 4 times faster — raw power at a cost.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "10")
    public let safetyOffDrainMultiplier: Int32 = 4;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Health & Safety")
    @runtimeProperty("ModSettings.category.order", "4")
    @runtimeProperty("ModSettings.displayName", "Safety OFF Time Dilation")
    @runtimeProperty("ModSettings.description", "Time dilation when Safety OFF is engaged. Overrides the normal stage-based curve.")
    @runtimeProperty("ModSettings.displayValues.Pct85", "85% — World at 15% speed")
    @runtimeProperty("ModSettings.displayValues.Pct90", "90% — World at 10% speed")
    @runtimeProperty("ModSettings.displayValues.Pct92_5", "92.5% — World at 7.5% speed")
    @runtimeProperty("ModSettings.displayValues.Pct95", "95% — World at 5% speed")
    @runtimeProperty("ModSettings.displayValues.Pct97_5", "97.5% — World at 2.5% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99", "99% — World at 1% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99_25", "99.25% — World at 0.75% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99_35", "99.35% — World at 0.65% speed")
    @runtimeProperty("ModSettings.displayValues.Pct99_5", "99.5% — World at 0.5% speed")
    public let safetyOffDilation: DSPDilationLevel = DSPDilationLevel.Pct97_5;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Health & Safety")
    @runtimeProperty("ModSettings.category.order", "4")
    @runtimeProperty("ModSettings.displayName", "Enable Safety OFF Kill")
    @runtimeProperty("ModSettings.description", "At psycho stage 5 with Safety OFF, V can die if health drops below threshold. Disable to remove permadeath risk.")
    public let enableSafetyOffKill: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Health & Safety")
    @runtimeProperty("ModSettings.category.order", "4")
    @runtimeProperty("ModSettings.displayName", "Safety OFF Kill Threshold (%)")
    @runtimeProperty("ModSettings.description", "Health % where Safety OFF triggers V's death at psycho stage 5. At 2%, V dies when health is nearly depleted.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "enableSafetyOffKill")
    public let safetyOffKillThreshold: Int32 = 2;

    // ==================== Category 5: Cyberpsychosis ====================

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Enable Cyberpsychosis")
    @runtimeProperty("ModSettings.description", "Master toggle for the entire cyberpsychosis system. Disabling removes all strain, episodes, micro-episodes, treatment, and psycho VFX.")
    public let enableCyberpsychosis: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Safe Activations per Day")
    @runtimeProperty("ModSettings.description", "Activations per day before strain penalties increase. Scales with psycho stage (stage 0 = 3x, stage 4 = 4x). Beyond this, each activation adds bonus strain.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "20")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let dailySafeActivations: Int32 = 3;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Strain per Activation")
    @runtimeProperty("ModSettings.description", "Base neural strain added each Sandy activation. Raw strain (bypasses stage tolerance). Immunoblockers reduce by 80%/50%.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "20")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainPerActivation: Int32 = 5;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Strain per Overuse Bonus")
    @runtimeProperty("ModSettings.description", "Extra strain per activation beyond daily safe limit. Stacks: 3rd overuse adds 3x this on top of base strain.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "20")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainPerOveruseBonus: Int32 = 3;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Strain per Minute Active")
    @runtimeProperty("ModSettings.description", "Strain per minute of active Sandy. Subject to stage multiplier (0-1: 0.5x, 2: 0.75x, 3+: 1.0x).")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "10")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainPerMinuteActive: Int32 = 2;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Strain per Sec Safety OFF")
    @runtimeProperty("ModSettings.description", "Strain per second while Safety OFF active. Raw strain (bypasses stage tolerance). 9 strain per minute.")
    @runtimeProperty("ModSettings.step", "0.01")
    @runtimeProperty("ModSettings.min", "0.01")
    @runtimeProperty("ModSettings.max", "1.0")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainPerSecSafetyOff: Float = 0.15;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Kill Strain: Gang")
    @runtimeProperty("ModSettings.description", "Neural strain per gang member killed during Sandy. Lowest tier.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "20")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainPerKillGang: Int32 = 2;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Kill Strain: Corpo")
    @runtimeProperty("ModSettings.description", "Neural strain per corporate security killed during Sandy.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "20")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainPerKillCorpo: Int32 = 3;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Kill Strain: NCPD")
    @runtimeProperty("ModSettings.description", "Neural strain per NCPD or NetWatch agent killed during Sandy. High-profile targets.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "20")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainPerKillNCPD: Int32 = 5;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Kill Strain: Civilian")
    @runtimeProperty("ModSettings.description", "Neural strain per civilian killed during Sandy. Highest impact — killing innocents accelerates psychosis dramatically.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "20")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainPerKillCivilian: Int32 = 8;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Strain Buildup Speed")
    @runtimeProperty("ModSettings.description", "Global multiplier for ALL strain accumulation. Affects activation, runtime, kill, passive strain (stages 4-5: +0.04/+0.08/s). Immunoblockers reduce independently (80%/50%).")
    @runtimeProperty("ModSettings.step", "0.05")
    @runtimeProperty("ModSettings.min", "0.25")
    @runtimeProperty("ModSettings.max", "3.0")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainBuildupMultiplier: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Strain Recovery Speed")
    @runtimeProperty("ModSettings.description", "Global multiplier for ALL strain recovery. Affects sleep, ripper, immunoblocker, safe area drain, natural decay (stages 0-2: -0.03/-0.02/-0.01/s).")
    @runtimeProperty("ModSettings.step", "0.05")
    @runtimeProperty("ModSettings.min", "0.25")
    @runtimeProperty("ModSettings.max", "3.0")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainRecoveryMultiplier: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Episode Cooldown Multiplier")
    @runtimeProperty("ModSettings.description", "Multiplier for time between psychosis escalations. Base: 48h/36h/24h/12h/6h for stages 1-5. At 2.0x, stage 4->5 needs 24h. Treatment milestones extend further.")
    @runtimeProperty("ModSettings.step", "0.05")
    @runtimeProperty("ModSettings.min", "0.25")
    @runtimeProperty("ModSettings.max", "3.0")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let episodeCooldownMultiplier: Float = 1.0;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Enable Micro-Episodes")
    @runtimeProperty("ModSettings.description", "Random involuntary symptoms (glitches, tremors, nosebleeds, laughs) between major episodes. Frequency scales with psycho stage.")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let enableMicroEpisodes: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Cyberpsychosis")
    @runtimeProperty("ModSettings.category.order", "5")
    @runtimeProperty("ModSettings.displayName", "Micro-Episode Frequency")
    @runtimeProperty("ModSettings.description", "Frequency multiplier. At 0.5, symptoms happen half as often. Base intervals: stage 1 = 5-10min, stage 5 = 5-15sec.")
    @runtimeProperty("ModSettings.step", "0.05")
    @runtimeProperty("ModSettings.min", "0.25")
    @runtimeProperty("ModSettings.max", "3.0")
    @runtimeProperty("ModSettings.dependency", "enableMicroEpisodes")
    public let microEpisodeFrequency: Float = 1.0;

    // ==================== Category 6: Recovery & Treatment ====================

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Enable Prescription System")
    @runtimeProperty("ModSettings.description", "Treatment protocol: recovery requires immunoblocker doses, ripperdoc visits, and rest — prescribed by Viktor. Disabling makes recovery instant.")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let enablePrescription: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Enable Runtime Degradation")
    @runtimeProperty("ModSettings.description", "Each Sandy session permanently reduces max runtime (1% per 60s). Sleep recovers a percentage, ripperdoc can fully restore.")
    public let enableRuntimeDegradation: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Sleep Recovery %")
    @runtimeProperty("ModSettings.description", "Percentage of degraded max runtime recovered per sleep. At 0.75, sleep restores 75% of lost capacity.")
    @runtimeProperty("ModSettings.step", "0.05")
    @runtimeProperty("ModSettings.min", "0.25")
    @runtimeProperty("ModSettings.max", "1.0")
    @runtimeProperty("ModSettings.dependency", "enableRuntimeDegradation")
    public let sleepRecoveryPercent: Float = 0.75;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Ripper Full Restore")
    @runtimeProperty("ModSettings.description", "Ripperdoc visit restores 100% max runtime. If disabled, only sleep recovery works.")
    @runtimeProperty("ModSettings.dependency", "enableRuntimeDegradation")
    public let ripperFullRestore: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Strain Drain: Sleep")
    @runtimeProperty("ModSettings.description", "Base neural strain drained per sleep session. Scaled by hours rested and recovery multiplier.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "5")
    @runtimeProperty("ModSettings.max", "100")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainDrainSleep: Int32 = 40;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Strain Drain: Ripperdoc")
    @runtimeProperty("ModSettings.description", "Neural strain drained per ripperdoc visit. Applied once, scaled by recovery multiplier.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "5")
    @runtimeProperty("ModSettings.max", "100")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainDrainRipper: Int32 = 25;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Strain Drain: Safe Area")
    @runtimeProperty("ModSettings.description", "Strain drained per second in safe areas (apartment, clubs). Slow passive recovery.")
    @runtimeProperty("ModSettings.step", "0.01")
    @runtimeProperty("ModSettings.min", "0.01")
    @runtimeProperty("ModSettings.max", "0.50")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainDrainSafeArea: Float = 0.05;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Strain Drain: Immunoblocker Common")
    @runtimeProperty("ModSettings.description", "Strain drained per second while Common immunoblocker active (3min). Weakest tier.")
    @runtimeProperty("ModSettings.step", "0.01")
    @runtimeProperty("ModSettings.min", "0.01")
    @runtimeProperty("ModSettings.max", "0.50")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainDrainImmunoblockerCommon: Float = 0.08;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Strain Drain: Immunoblocker Uncommon")
    @runtimeProperty("ModSettings.description", "Strain drained per second while Uncommon immunoblocker active (6min). Mid tier.")
    @runtimeProperty("ModSettings.step", "0.01")
    @runtimeProperty("ModSettings.min", "0.01")
    @runtimeProperty("ModSettings.max", "0.50")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainDrainImmunoblockerUncommon: Float = 0.18;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Strain Drain: Immunoblocker Rare")
    @runtimeProperty("ModSettings.description", "Strain drained per second while Military-Grade immunoblocker active (10min). Strongest — prescribed for stages 3+.")
    @runtimeProperty("ModSettings.step", "0.01")
    @runtimeProperty("ModSettings.min", "0.01")
    @runtimeProperty("ModSettings.max", "0.50")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainDrainImmunoblockerRare: Float = 0.35;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Strain Drain: DF Immunosuppressant")
    @runtimeProperty("ModSettings.description", "Strain drained per second while Dark Future Immunosuppressant active. For Dark Future mod compatibility.")
    @runtimeProperty("ModSettings.step", "0.01")
    @runtimeProperty("ModSettings.min", "0.01")
    @runtimeProperty("ModSettings.max", "0.50")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let strainDrainDFImmuno: Float = 0.08;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Recovery & Treatment")
    @runtimeProperty("ModSettings.category.order", "6")
    @runtimeProperty("ModSettings.displayName", "Tolerance Decay Hours")
    @runtimeProperty("ModSettings.description", "Game-time hours before immunoblocker tolerance decays. Tolerance builds per dose (higher = weaker effect). After this period, tolerance slowly decreases.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "6")
    @runtimeProperty("ModSettings.max", "72")
    @runtimeProperty("ModSettings.dependency", "enableCyberpsychosis")
    public let toleranceDecayHours: Int32 = 24;

    // ==================== Category 7: Economy & Interface ====================

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Economy & Interface")
    @runtimeProperty("ModSettings.category.order", "7")
    @runtimeProperty("ModSettings.displayName", "Immunoblocker Price: Common")
    @runtimeProperty("ModSettings.description", "Price in eddies for Common immunoblocker at Viktor's shop. Duration: 3min.")
    @runtimeProperty("ModSettings.step", "500")
    @runtimeProperty("ModSettings.min", "500")
    @runtimeProperty("ModSettings.max", "20000")
    public let immunoblockerPriceCommon: Int32 = 6000;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Economy & Interface")
    @runtimeProperty("ModSettings.category.order", "7")
    @runtimeProperty("ModSettings.displayName", "Immunoblocker Price: Uncommon")
    @runtimeProperty("ModSettings.description", "Price in eddies for Uncommon immunoblocker at Viktor's shop. Duration: 6min.")
    @runtimeProperty("ModSettings.step", "1000")
    @runtimeProperty("ModSettings.min", "1000")
    @runtimeProperty("ModSettings.max", "50000")
    public let immunoblockerPriceUncommon: Int32 = 24000;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Economy & Interface")
    @runtimeProperty("ModSettings.category.order", "7")
    @runtimeProperty("ModSettings.displayName", "Immunoblocker Price: Rare")
    @runtimeProperty("ModSettings.description", "Price in eddies for Military-Grade immunoblocker at Viktor's shop. Duration: 10min.")
    @runtimeProperty("ModSettings.step", "5000")
    @runtimeProperty("ModSettings.min", "5000")
    @runtimeProperty("ModSettings.max", "200000")
    public let immunoblockerPriceRare: Int32 = 100000;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Economy & Interface")
    @runtimeProperty("ModSettings.category.order", "7")
    @runtimeProperty("ModSettings.displayName", "Biomonitor Position X")
    @runtimeProperty("ModSettings.description", "Horizontal position on 3840x2160 canvas. Auto-scales to your resolution.")
    @runtimeProperty("ModSettings.step", "10")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "3000")
    public let biomonitorPosX: Int32 = 80;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Economy & Interface")
    @runtimeProperty("ModSettings.category.order", "7")
    @runtimeProperty("ModSettings.displayName", "Biomonitor Position Y")
    @runtimeProperty("ModSettings.description", "Vertical position on 3840x2160 canvas. Auto-scales to your resolution.")
    @runtimeProperty("ModSettings.step", "10")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "2000")
    public let biomonitorPosY: Int32 = 600;

    // ==================== Lifecycle ====================

    public static func Get(gi: GameInstance) -> ref<DSPSettings> {
        return GameInstance.GetScriptableSystemsContainer(gi).Get(n"DSPSettings") as DSPSettings;
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

- [ ] **Step 2: Verify redscript compiles**

Copy to game directory and check for compile errors on game launch:
```bash
cp r6/scripts/DavidSandevistanPlus/DSPSettings.reds "/mnt/g/SteamLibrary/steamapps/common/Cyberpunk 2077/r6/scripts/DavidSandevistanPlus/DSPSettings.reds"
```

Expected: No redscript compile errors in `r6/cache/redscript.log`. Settings appear in Settings → Mods → "David Sandevistan Plus" with 7 categories.

- [ ] **Step 3: Commit**

```bash
git add r6/scripts/DavidSandevistanPlus/DSPSettings.reds
git commit -m "feat: add DSPSettings.reds — 63 Mod Settings properties in 7 categories"
```

---

### Task 2: Add syncSettingsFromRedscript + applyTweakDBFromSettings to init.lua

**Files:**
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua:114-126` (replace loadConfig)
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua:1647-1651` (replace LoadGamePart1 call)
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua:1406-1419` (add change detection to displayTick phase 0)

- [ ] **Step 1: Replace loadConfig with syncSettingsFromRedscript and applyTweakDBFromSettings**

Replace lines 114-126 (`local configFile` through end of `loadConfig`) with:

```lua
local dilationMap = {
	[0] = 0.15, [1] = 0.10, [2] = 0.075, [3] = 0.05,
	[4] = 0.025, [5] = 0.01, [6] = 0.0075, [7] = 0.0065, [8] = 0.005
}

local function syncSettingsFromRedscript(cfg)
	local ok, settings = pcall(function()
		return Game.GetScriptableSystemsContainer():Get(CName.new('DSPSettings'))
	end)
	if not ok or not settings then return false end

	-- Enums → float time scale
	cfg.timeDilationNoPerk = dilationMap[settings.timeDilationNoPerk] or 0.05
	cfg.timeDilationWithPerk = dilationMap[settings.timeDilationWithPerk] or 0.0065
	cfg.safetyOffTimeDilation = dilationMap[settings.safetyOffDilation] or 0.025

	-- Booleans
	cfg.enableCyberpsychosis = settings.enableCyberpsychosis
	cfg.requireEdgeRunnerPerk = settings.requireEdgeRunnerPerk
	cfg.enableHealthDrain = settings.enableHealthDrain
	cfg.enableHealthBrake = settings.enableHealthBrake
	cfg.enableSafetyOffKill = settings.enableSafetyOffKill
	cfg.enableNonLinearDrain = settings.enableNonLinearDrain
	cfg.enableSessionFatigue = settings.enableSessionFatigue
	cfg.enableRuntimeDegradation = settings.enableRuntimeDegradation
	cfg.enablePrescription = settings.enablePrescription
	cfg.enableMicroEpisodes = settings.enableMicroEpisodes
	cfg.ripperFullRestore = settings.ripperFullRestore

	-- Integers
	cfg.sandyDuration = settings.sandyDuration
	cfg.fullRechargeHours = settings.fullRechargeHours
	cfg.maxRechargePerSleep = settings.maxRechargePerSleep
	cfg.dailySafeActivations = settings.dailySafeActivations
	cfg.strainPerActivation = settings.strainPerActivation
	cfg.strainPerOveruseBonus = settings.strainPerOveruseBonus
	cfg.strainPerMinuteActive = settings.strainPerMinuteActive
	cfg.strainPerKillGang = settings.strainPerKillGang
	cfg.strainPerKillCorpo = settings.strainPerKillCorpo
	cfg.strainPerKillNCPD = settings.strainPerKillNCPD
	cfg.strainPerKillCivilian = settings.strainPerKillCivilian
	cfg.strainDrainSleep = settings.strainDrainSleep
	cfg.strainDrainRipper = settings.strainDrainRipper
	cfg.immunoblockerPriceCommon = settings.immunoblockerPriceCommon
	cfg.immunoblockerPriceUncommon = settings.immunoblockerPriceUncommon
	cfg.immunoblockerPriceRare = settings.immunoblockerPriceRare
	cfg.critChance = settings.critChance
	cfg.critDamage = settings.critDamage
	cfg.drainAccelStartSec = settings.drainAccelStartSec
	cfg.safetyOffDrainMultiplier = settings.safetyOffDrainMultiplier
	cfg.safetyOffKillThreshold = settings.safetyOffKillThreshold
	cfg.requiredHealthMin = settings.requiredHealthMin
	cfg.biomonitorPosX = settings.biomonitorPosX
	cfg.biomonitorPosY = settings.biomonitorPosY
	cfg.toleranceDecayHours = settings.toleranceDecayHours

	-- Renamed field: redscript healthBrakeThreshold → internal healthBrakeDefault
	cfg.healthBrakeDefault = settings.healthBrakeThreshold

	-- Floats
	cfg.damageMin = settings.damageMin
	cfg.damageMax = settings.damageMax
	cfg.rechargeDuration = settings.rechargeDuration
	cfg.cooldownBase = settings.cooldownBase
	cfg.enterCost = settings.enterCost
	cfg.killRechargeValue = settings.killRechargeValue
	cfg.headshotDamageMultiplier = settings.headshotDamageMultiplier
	cfg.healOnKill = settings.healOnKill
	cfg.staminaOnKill = settings.staminaOnKill
	cfg.strainPerSecSafetyOff = settings.strainPerSecSafetyOff
	cfg.strainDrainSafeArea = settings.strainDrainSafeArea
	cfg.strainDrainDFImmuno = settings.strainDrainDFImmuno
	cfg.strainBuildupMultiplier = settings.strainBuildupMultiplier
	cfg.strainRecoveryMultiplier = settings.strainRecoveryMultiplier
	cfg.episodeCooldownMultiplier = settings.episodeCooldownMultiplier
	cfg.microEpisodeFrequency = settings.microEpisodeFrequency
	cfg.sessionFatiguePenalty = settings.sessionFatiguePenalty
	cfg.maxSessionFatiguePenalty = settings.maxSessionFatiguePenalty
	cfg.sleepRecoveryPercent = settings.sleepRecoveryPercent
	cfg.drainExponent = settings.drainExponent

	-- Reconstruct immunoblocker drain array from split fields
	cfg.strainDrainImmunoblocker = {
		settings.strainDrainImmunoblockerCommon,
		settings.strainDrainImmunoblockerUncommon,
		settings.strainDrainImmunoblockerRare
	}

	print('[DSP] Settings synced from Mod Settings')
	return true
end

local function applyTweakDBFromSettings(cfg)
	local base = 'Items.MartinezSandevistanPlusPlus'
	pcall(function()
		TweakDB:SetFlat(base .. '_Stat_Modifier_04.value', 0.15)
		TweakDB:SetFlat(base .. '_Stat_Modifier_03.value', cfg.sandyDuration * 1.0)
		TweakDB:SetFlat(base .. '_Stat_Modifier_05.value', cfg.rechargeDuration * 1.0)
		TweakDB:SetFlat(base .. '_Stat_Modifier_06.value', cfg.cooldownBase * 1.0)
		TweakDB:SetFlat(base .. '_Stat_Modifier_07.value', cfg.killRechargeValue * 1.0)
		TweakDB:SetFlat(base .. '_Stat_Modifier_08.value', cfg.enterCost * 1.0)
		TweakDB:SetFlat(base .. '_Equip3_SM1.value', cfg.critChance * 1.0)
		TweakDB:SetFlat(base .. '_Equip3_SM2.value', cfg.critDamage * 1.0)
		TweakDB:SetFlat(base .. '_Equip3_SM3.value', cfg.headshotDamageMultiplier * 1.0)
		TweakDB:SetFlat(base .. '_Equip4_SPU1.statPoolValue', cfg.healOnKill * 1.0)
		TweakDB:SetFlat(base .. '_Equip4_SPU2.statPoolValue', cfg.staminaOnKill * 1.0)
		local dilationPct = math.floor((1 - cfg.timeDilationNoPerk) * 1000 + 0.5) / 10
		TweakDB:SetFlat(base .. '_Equip1_Various_UI.floatValues',
			{dilationPct, cfg.critChance * 1.0, cfg.critDamage * 1.0, cfg.headshotDamageMultiplier * 1.0,
			 cfg.healOnKill * 1.0, cfg.staminaOnKill * 1.0, cfg.sandyDuration * 1.0})
		for _, suffix in ipairs({'_Stat_Modifier_04', '_Stat_Modifier_03', '_Stat_Modifier_05',
			'_Stat_Modifier_06', '_Stat_Modifier_07', '_Stat_Modifier_08',
			'_Equip3_SM1', '_Equip3_SM2', '_Equip3_SM3',
			'_Equip4_SPU1', '_Equip4_SPU2', '_Equip1_Various_UI'}) do
			TweakDB:Update(base .. suffix)
		end
	end)
	print('[DSP] TweakDB updated from settings')
end
```

- [ ] **Step 2: Update LoadGamePart1 to use syncSettingsFromRedscript instead of loadConfig**

Replace line 1649 (`loadConfig(self.cfg)`) with:

```lua
		syncSettingsFromRedscript(self.cfg)
```

- [ ] **Step 3: Add defaults for new settings to dsp.cfg table**

Add after line 177 (`strainRecoveryMultiplier = 1.0,`):

```lua
		episodeCooldownMultiplier = 1.0, -- global multiplier for episode cooldown hours
		toleranceDecayHours = 24,        -- game-time hours before tolerance starts to decay
```

- [ ] **Step 4: Add change detection to displayTick phase 0**

After the `self.VIsInControl = self.sps:InControl()` line (line 1409), add:

```lua
				-- Detect Mod Settings changes via quest fact bridge
				pcall(function()
					local changed = Game.GetQuestSystem():GetFactValue(CName.new('dsp_settings_changed'))
					if changed and changed > 0 then
						syncSettingsFromRedscript(self.cfg)
						applyTweakDBFromSettings(self.cfg)
						self:UpdateImmunoblockerPrices()
						self.FullRechargeHours = self.cfg.fullRechargeHours
						self.MaxRechargePerSleep = self.cfg.maxRechargePerSleep
						Game.GetQuestSystem():SetFactValue(CName.new('dsp_settings_changed'), 0)
						print('[DSP] Settings reloaded from Mod Settings')
					end
				end)
```

- [ ] **Step 5: Add applyTweakDBFromSettings call to LoadGamePart1**

After line 1650 (`self:UpdateImmunoblockerPrices()`), add:

```lua
		applyTweakDBFromSettings(self.cfg)
```

- [ ] **Step 6: Verify in-game**

1. Launch game, load save
2. Check CET console for `[DSP] Settings synced from Mod Settings`
3. Check CET console for `[DSP] TweakDB updated from settings`
4. Change a setting in Settings → Mods → David Sandevistan Plus
5. Wait ~1s, verify `[DSP] Settings reloaded from Mod Settings` appears in console
6. Verify changed value takes effect in gameplay

- [ ] **Step 7: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua
git commit -m "feat: replace loadConfig with Mod Settings bridge (syncSettingsFromRedscript)"
```

---

### Task 3: Wire new settings — episodeCooldownMultiplier + toleranceDecayHours

**Files:**
- Modify: `bin/x64/.../DavidSandevistanPlus/strain.lua:176`
- Modify: `bin/x64/.../DavidSandevistanPlus/immunoblocker_logic.lua:61`

- [ ] **Step 1: Wire episodeCooldownMultiplier into TriggerStrainEpisode**

In `strain.lua`, replace line 176:

```lua
			self.episodeCooldownUntil = now + (cooldownH * 3600)
```

with:

```lua
			local mult = self.cfg.episodeCooldownMultiplier or 1.0
			self.episodeCooldownUntil = now + (cooldownH * mult * 3600)
```

- [ ] **Step 2: Wire toleranceDecayHours into UpdateToleranceDecay**

In `immunoblocker_logic.lua`, replace line 61:

```lua
	if hoursSinceUse < 24 then return end
```

with:

```lua
	if hoursSinceUse < (self.cfg.toleranceDecayHours or 24) then return end
```

- [ ] **Step 3: Verify in-game**

1. Set `episodeCooldownMultiplier` to 2.0 in Mod Settings
2. Trigger a psychosis episode — cooldown should be 2x normal
3. Set `toleranceDecayHours` to 6 in Mod Settings
4. Use immunoblocker, wait 6h game-time — tolerance should start decaying

- [ ] **Step 4: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/strain.lua
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/immunoblocker_logic.lua
git commit -m "feat: wire episodeCooldownMultiplier and toleranceDecayHours from Mod Settings"
```

---

### Task 4: One-time config.json migration

**Files:**
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua` (add migrateConfigJson function, call in LoadGamePart1)

- [ ] **Step 1: Add migrateConfigJson function after applyTweakDBFromSettings**

```lua
local function migrateConfigJson()
	local file = io.open("config.json", "r")
	if not file then return end
	local ok, loaded = pcall(json.decode, file:read("*a"))
	file:close()
	if not ok or type(loaded) ~= "table" then return end

	-- Check if user.ini already has [DSPSettings] section — don't overwrite
	local userIniPath = "../../../red4ext/plugins/mod_settings/user.ini"
	local iniFile = io.open(userIniPath, "r")
	local iniContent = ""
	if iniFile then
		iniContent = iniFile:read("*a") or ""
		iniFile:close()
	end
	if iniContent:find("%[DSPSettings%]") then
		-- Already migrated or user configured manually — just archive old config
		os.rename("config.json", "config.json.migrated")
		print('[DSP] config.json archived (user.ini already has DSPSettings)')
		return
	end

	-- Build INI section from old config
	local lines = { "\n[DSPSettings]" }

	-- Dilation enum mapping: float → enum name
	local dilationToEnum = {
		[0.15] = "Pct85", [0.10] = "Pct90", [0.075] = "Pct92_5", [0.05] = "Pct95",
		[0.025] = "Pct97_5", [0.01] = "Pct99", [0.0075] = "Pct99_25",
		[0.0065] = "Pct99_35", [0.005] = "Pct99_5"
	}
	local function findClosestEnum(val)
		local best, bestDiff = "Pct95", 999
		for fv, name in pairs(dilationToEnum) do
			local diff = math.abs(fv - val)
			if diff < bestDiff then best, bestDiff = name, diff end
		end
		return best
	end

	-- safetyOffTimeDilation: int 975 → enum
	local function safetyOffToEnum(val)
		local scale = (1000 - val) / 1000
		return findClosestEnum(scale)
	end

	-- Keys to skip (removed settings)
	local skip = { maxPsychoRecoveryPerSleep=true, ripperRecoveryLevels=true, tickLength=true }

	for key, val in pairs(loaded) do
		if not skip[key] then
			if key == "timeDilationNoPerk" then
				lines[#lines+1] = "timeDilationNoPerk = " .. findClosestEnum(tonumber(val) or 0.05)
			elseif key == "timeDilationWithPerk" then
				lines[#lines+1] = "timeDilationWithPerk = " .. findClosestEnum(tonumber(val) or 0.0065)
			elseif key == "safetyOffTimeDilation" then
				lines[#lines+1] = "safetyOffDilation = " .. safetyOffToEnum(tonumber(val) or 975)
			elseif key == "healthBrakeDefault" then
				lines[#lines+1] = "healthBrakeThreshold = " .. tostring(val)
			elseif key == "strainDrainImmunoblocker" and type(val) == "table" then
				lines[#lines+1] = "strainDrainImmunoblockerCommon = " .. tostring(val[1] or 0.08)
				lines[#lines+1] = "strainDrainImmunoblockerUncommon = " .. tostring(val[2] or 0.18)
				lines[#lines+1] = "strainDrainImmunoblockerRare = " .. tostring(val[3] or 0.35)
			elseif type(val) == "boolean" then
				lines[#lines+1] = key .. " = " .. tostring(val)
			elseif type(val) == "number" then
				lines[#lines+1] = key .. " = " .. tostring(val)
			end
		end
	end

	-- Append to user.ini
	local outFile = io.open(userIniPath, "a")
	if outFile then
		outFile:write(table.concat(lines, "\n") .. "\n")
		outFile:close()
		print('[DSP] Config migrated to user.ini (' .. (#lines - 1) .. ' settings)')
	end

	-- Archive old config
	os.rename("config.json", "config.json.migrated")
	print('[DSP] config.json renamed to config.json.migrated')
end
```

- [ ] **Step 2: Call migrateConfigJson in LoadGamePart1**

After the `syncSettingsFromRedscript(self.cfg)` call in LoadGamePart1, add:

```lua
		migrateConfigJson()
```

- [ ] **Step 3: Verify migration**

1. Place a `config.json` with custom values alongside init.lua
2. Launch game, load save
3. Verify `[DSP] Config migrated to user.ini` in CET console
4. Verify `config.json` renamed to `config.json.migrated`
5. Check `user.ini` has `[DSPSettings]` section with migrated values
6. Open Settings → Mods — values should reflect migrated config

- [ ] **Step 4: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua
git commit -m "feat: add one-time config.json → user.ini migration for Mod Settings"
```

---

### Task 5: Delete MartinezPLUS and clean up references

**Files:**
- Delete: `bin/x64/.../MartinezPLUS/init.lua`
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua` (remove dead config keys from defaults)

- [ ] **Step 1: Delete MartinezPLUS folder from repo**

```bash
git rm -r bin/x64/plugins/cyber_engine_tweaks/mods/MartinezPLUS/
```

- [ ] **Step 2: Remove dead config keys from dsp.cfg defaults**

In `init.lua`, remove these lines from the cfg table (lines ~195-197):

```lua
		maxPsychoRecoveryPerSleep = 1,   -- max levels recovered per sleep
		ripperRecoveryLevels = 1,        -- levels per ripperdoc visit
```

And remove:

```lua
		tickLength = 1.25,               -- main game loop tick interval in seconds
```

Replace the `tickLength` usage at line 1655:

```lua
		self.TickLength = self.cfg.tickLength
```

with:

```lua
		self.TickLength = 1.25
```

- [ ] **Step 3: Verify no remaining references to MartinezPLUS or nativeSettings**

Search the codebase for orphan references:
```bash
grep -r "MartinezPLUS\|nativeSettings\|loadConfig\|configFile\|config\.json" bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/
```

Expected: No results (migration function references `config.json` intentionally).

- [ ] **Step 4: Verify in-game**

1. Launch game — no errors about missing MartinezPLUS
2. CET MODS tab — MartinezPLUS no longer appears
3. Settings → Mods → David Sandevistan Plus — all settings work
4. Gameplay unaffected

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor: delete MartinezPLUS, remove dead config keys (tickLength, maxPsychoRecoveryPerSleep, ripperRecoveryLevels)"
```

---

## Self-Review Checklist

### Spec Coverage

| Spec Requirement | Task |
|---|---|
| DSPSettings.reds with 63 @runtimeProperty fields | Task 1 |
| DSPDilationLevel enum with displayValues | Task 1 |
| syncSettingsFromRedscript replacing loadConfig | Task 2 |
| applyTweakDBFromSettings with tooltip floatValues | Task 2 |
| Quest fact bridge change detection | Task 2 (step 4) |
| episodeCooldownMultiplier wired | Task 3 |
| toleranceDecayHours wired | Task 3 |
| config.json → user.ini migration | Task 4 |
| MartinezPLUS deletion | Task 5 |
| Dead config keys removed | Task 5 |
| 7 categories with category.order | Task 1 |
| Dependencies (enableCyberpsychosis → sub-settings) | Task 1 |
| Mod works with defaults if Mod Settings not installed | Task 2 (pcall fallback) |

### Placeholder Scan
- No TBDs, TODOs, or "implement later" references
- All code blocks contain complete, copy-pasteable code
- All field names are consistent across tasks (e.g., `healthBrakeThreshold` in reds → `healthBrakeDefault` in Lua)

### Type Consistency
- `settings.timeDilationNoPerk` → int (enum ordinal) → mapped via dilationMap → float in cfg ✓
- `settings.safetyOffDilation` → int → mapped via dilationMap → stored as `cfg.safetyOffTimeDilation` (float) ✓
- `settings.healthBrakeThreshold` → Int32 → stored as `cfg.healthBrakeDefault` (int) ✓
- All `strainDrainImmunoblocker*` → Float → reconstructed as Lua array ✓
