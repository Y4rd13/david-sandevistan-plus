// DSPKillTracker.reds — Kill tracking for Neural Strain system
// Wraps ScriptedPuppet.RewardKiller() to detect kills and route strain
// costs through DSPHUDSystem (avoids creating a second ScriptableSystem).

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

    // Get affiliation for faction-based cost
    let cost: Int32 = 3; // default (gang/corpo)
    let affiliation: wref<Affiliation_Record> = npcRecord.Affiliation();
    if IsDefined(affiliation) {
        let affiliationType: TweakDBID = affiliation.GetID();

        // Civilian kills: highest cost (David never wanted to hurt civilians)
        if affiliationType == t"Factions.Civilian" || affiliationType == t"Factions.Unaffiliated" {
            cost = 8;
        // NCPD kills: high cost (killing cops accelerates psychosis)
        } else if affiliationType == t"Factions.NCPD" || affiliationType == t"Factions.NetWatch" {
            cost = 5;
        // Corporate security
        } else if affiliationType == t"Factions.Arasaka" || affiliationType == t"Factions.Militech" || affiliationType == t"Factions.KangTao" {
            cost = 3;
        // Gang members: lowest cost (normal enemies)
        } else if affiliationType == t"Factions.Maelstrom" || affiliationType == t"Factions.TygerClaws" || affiliationType == t"Factions.Valentinos" || affiliationType == t"Factions.SixthStreet" || affiliationType == t"Factions.VoodooBoys" || affiliationType == t"Factions.Animals" || affiliationType == t"Factions.Scavengers" || affiliationType == t"Factions.Wraiths" || affiliationType == t"Factions.Aldecaldos" || affiliationType == t"Factions.BarghestArmy" {
            cost = 2;
        }
    }

    // Route through DSPHUDSystem singleton
    let gi: GameInstance = player.GetGame();
    let dspHUD: ref<DSPHUDSystem> = DSPHUDSystem.GetInstance(gi);
    if IsDefined(dspHUD) {
        dspHUD.AddKillStrain(cost);
    }
}
