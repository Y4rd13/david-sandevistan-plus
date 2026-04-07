// DSPPlayerEvents — migrated from CET ObserveAfter to @wrapMethod
// Signals CET via quest facts for: player attach/detach, immunoblocker apply/remove

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
    let effectID: TweakDBID = evt.staticData.GetID();
    let tier: Int32 = 0;
    if effectID == t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Common" {
        tier = 1;
    } else if effectID == t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Uncommon" {
        tier = 2;
    } else if effectID == t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Rare" {
        tier = 3;
    }
    if tier > 0 {
        GameInstance.GetQuestsSystem(this.GetGame()).SetFactStr("dsp_immuno_applied", tier);
    }
    return result;
}

@wrapMethod(PlayerPuppet)
protected cb func OnStatusEffectRemoved(evt: ref<RemoveStatusEffect>) -> Bool {
    let result: Bool = wrappedMethod(evt);
    let effectID: TweakDBID = evt.staticData.GetID();
    let tier: Int32 = 0;
    if effectID == t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Common" {
        tier = 1;
    } else if effectID == t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Uncommon" {
        tier = 2;
    } else if effectID == t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Rare" {
        tier = 3;
    }
    if tier > 0 {
        GameInstance.GetQuestsSystem(this.GetGame()).SetFactStr("dsp_immuno_removed", tier);
    }
    return result;
}
