// DSPConsumeOverride.reds
// Bypasses the entire vanilla consume pipeline for Immunoblocker items.
// Manually applies the status effect + removes the item, preventing the
// HealthBooster animation from ever triggering. Our CET observer detects
// the applied effect and triggers the custom syringe scene.

// Layer 1: Intercept the item action before the consume state machine runs.
// By not calling wrappedMethod(), the vanilla animation pipeline never starts.
@wrapMethod(ItemActionsHelper)
public final static func ProcessItemAction(gi: GameInstance, executor: wref<GameObject>, itemData: wref<gameItemData>, actionID: TweakDBID, fromInventory: Bool) -> Bool {
    let statusEffectID: TweakDBID;
    let isImmunoblocker: Bool = false;

    if actionID == t"ItemAction.MartinezImmunoblockerUse_Common" {
        statusEffectID = t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Common";
        isImmunoblocker = true;
    } else if actionID == t"ItemAction.MartinezImmunoblockerUse_Uncommon" {
        statusEffectID = t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Uncommon";
        isImmunoblocker = true;
    } else if actionID == t"ItemAction.MartinezImmunoblockerUse_Rare" {
        statusEffectID = t"BaseStatusEffect.MartinezSandevistan_Immunoblocker_Rare";
        isImmunoblocker = true;
    }

    if isImmunoblocker {
        let player: ref<GameObject> = GetPlayer(gi);
        if !IsDefined(player) {
            return false;
        }
        StatusEffectHelper.ApplyStatusEffect(player, statusEffectID);
        GameInstance.GetTransactionSystem(gi).RemoveItem(player, itemData.GetID(), 1);
        return true;
    }

    return wrappedMethod(gi, executor, itemData, actionID, fromInventory);
}

// Layer 2: Safety net — if the consume state machine somehow still runs
// for an Immunoblocker item, suppress the animation feature.
@wrapMethod(ConsumableTransitions)
protected final func ChangeConsumableAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, newState: Bool) -> Void {
    let itemTDBID: TweakDBID = this.GetItemIDFromWrapperPermanentParameter(stateContext, n"consumable").GetTDBID();

    if itemTDBID == t"Items.MartinezImmunoblockerCommon" ||
       itemTDBID == t"Items.MartinezImmunoblockerUncommon" ||
       itemTDBID == t"Items.MartinezImmunoblockerRare" {
        return;
    }

    wrappedMethod(stateContext, scriptInterface, newState);
}
