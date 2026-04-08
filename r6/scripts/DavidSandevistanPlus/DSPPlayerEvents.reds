// DSPPlayerEvents — migrated from CET ObserveAfter to @wrapMethod
// Signals CET via quest facts for: player attach/detach, immunoblocker apply/remove

public static func DSPGetImmunoTier(effectID: TweakDBID) -> Int32 {
    if effectID == t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Common" { return 1; }
    if effectID == t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Uncommon" { return 2; }
    if effectID == t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Rare" { return 3; }
    return 0;
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    let result: Bool = wrappedMethod();
    if !this.IsReplacer() {
        GameInstance.GetQuestsSystem(this.GetGame()).SetFactStr("dsp_player_attached", 1);
    }
    return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
    GameInstance.GetQuestsSystem(this.GetGame()).SetFactStr("dsp_player_detached", 1);
    return wrappedMethod();
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let result: Bool = wrappedMethod(evt);
    let tier: Int32 = DSPGetImmunoTier(evt.staticData.GetID());
    if tier > 0 {
        GameInstance.GetQuestsSystem(this.GetGame()).SetFactStr("dsp_immuno_applied", tier);
    }
    return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let result: Bool = wrappedMethod(evt);
    let tier: Int32 = DSPGetImmunoTier(evt.staticData.GetID());
    if tier > 0 {
        GameInstance.GetQuestsSystem(this.GetGame()).SetFactStr("dsp_immuno_removed", tier);
    }
    return result;
}
