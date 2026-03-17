// DSPKillTracker.reds — Kill tracking for Neural Strain system
// Wraps ScriptedPuppet.RewardKiller() to detect kills and route faction
// categories through DSPHUDSystem. CET Lua applies configurable costs.

@wrapMethod(ScriptedPuppet)
protected func RewardKiller(killer: wref<GameObject>, killType: gameKillType, isAnyDamageNonlethal: Bool) -> Void {
    wrappedMethod(killer, killType, isAnyDamageNonlethal);

    // Only track actual kills by the player (not defeats/knockouts)
    if Equals(killType, gameKillType.Defeat) {
        return;
    }

    let player: ref<PlayerPuppet> = killer as PlayerPuppet;
    if !IsDefined(player) {
        return;
    }

    // Only track human NPCs
    let npcRecord: ref<Character_Record> = this.GetRecord();
    if !IsDefined(npcRecord) {
        return;
    }

    // Determine faction category: 0=gang, 1=corpo, 2=ncpd, 3=civilian
    let factionId: Int32 = 1; // default: corpo
    let affiliation: wref<Affiliation_Record> = npcRecord.Affiliation();
    if IsDefined(affiliation) {
        let affiliationType: TweakDBID = affiliation.GetID();

        // Civilian kills (highest strain — David never wanted to hurt civilians)
        if affiliationType == t"Factions.Civilian" || affiliationType == t"Factions.Unaffiliated" {
            factionId = 3;
        // NCPD / NetWatch kills
        } else if affiliationType == t"Factions.NCPD" || affiliationType == t"Factions.NetWatch" {
            factionId = 2;
        // Corporate security
        } else if affiliationType == t"Factions.Arasaka" || affiliationType == t"Factions.Militech" || affiliationType == t"Factions.KangTao" {
            factionId = 1;
        // Gang members (lowest strain — normal enemies)
        } else if affiliationType == t"Factions.Maelstrom" || affiliationType == t"Factions.TygerClaws" || affiliationType == t"Factions.Valentinos" || affiliationType == t"Factions.SixthStreet" || affiliationType == t"Factions.VoodooBoys" || affiliationType == t"Factions.Animals" || affiliationType == t"Factions.Scavengers" || affiliationType == t"Factions.Wraiths" || affiliationType == t"Factions.Aldecaldos" || affiliationType == t"Factions.BarghestArmy" {
            factionId = 0;
        }
    }

    // Route through DSPHUDSystem singleton
    let gi: GameInstance = player.GetGame();
    let dspHUD: ref<DSPHUDSystem> = DSPHUDSystem.GetInstance(gi);
    if IsDefined(dspHUD) {
        dspHUD.AddKillByFaction(factionId);
    }
}
