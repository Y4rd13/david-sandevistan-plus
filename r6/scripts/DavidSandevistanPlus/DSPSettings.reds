// DSPSettings.reds — Mod Settings integration for David Sandevistan Plus
// All settings declared via @runtimeProperty for the Mod Settings framework.
// CET Lua reads these values via GetScriptableSystemsContainer():Get('DSPSettings').

public class DSPSettings extends ScriptableSystem {

    // ==================== Category 1: Time Dilation ====================

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Time Dilation")
    @runtimeProperty("ModSettings.category.order", "1")
    @runtimeProperty("ModSettings.displayName", "Require EdgeRunner Perk")
    @runtimeProperty("ModSettings.description", "Require the EdgeRunner perk for full Sandy potential. Without it, runtime is capped at 33% of max and time dilation is weaker. The stage-based dilation curve (stages 0-5) applies regardless.")
    public let requireEdgeRunnerPerk: Bool = true;

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Time Dilation")
    @runtimeProperty("ModSettings.category.order", "1")
    @runtimeProperty("ModSettings.displayName", "Enable Session Fatigue")
    @runtimeProperty("ModSettings.description", "Each activation beyond the daily safe limit reduces time dilation by 2% (capped at 10% total). Resets on sleep. The penalty adds directly to the time scale — at max penalty, 99.35% dilation becomes ~89.35%.")
    public let enableSessionFatigue: Bool = true;

    // ==================== Category 2: Runtime & Drain ====================

    @runtimeProperty("ModSettings.mod", "David Sandevistan Plus")
    @runtimeProperty("ModSettings.category", "Runtime & Drain")
    @runtimeProperty("ModSettings.category.order", "2")
    @runtimeProperty("ModSettings.displayName", "Runtime Tank (seconds)")
    @runtimeProperty("ModSettings.description", "Total runtime reservoir in seconds. Without EdgeRunner perk, only 33% is accessible (e.g. 100s of 300s). Drains at 1s/tick normally, multiplied by Safety OFF drain multiplier. Not real-time — dilation makes each second feel longer.")
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
    @runtimeProperty("ModSettings.displayName", "Drain Accel Start (sec)")
    @runtimeProperty("ModSettings.description", "Seconds of continuous Sandy use before drain acceleration kicks in. Below this, drain is 1x. Above it, drain ramps up exponentially (exponent 1.5). Shorter = more pressure to act fast.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "10")
    @runtimeProperty("ModSettings.max", "180")
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
    @runtimeProperty("ModSettings.displayName", "Enable Debug Logs")
    @runtimeProperty("ModSettings.description", "Print detailed debug messages to the CET console. Useful for troubleshooting. Disable for a clean console.")
    public let enableDebugLogs: Bool = false;

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
