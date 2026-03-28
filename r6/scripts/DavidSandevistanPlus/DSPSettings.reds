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
