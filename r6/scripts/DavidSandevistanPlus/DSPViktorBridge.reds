// DSPViktorBridge.reds — Minimal ScriptableSystem bridge for CET → PhoneExtension
// Separated from DSPHUDSystem to avoid cross-module import conflicts
// CET calls: Game.GetScriptableSystemsContainer():Get("DSPViktorBridge"):NotifyViktor(text)

import PhoneExtension.Classes.*
import PhoneExtension.System.*

public class DSPViktorBridge extends ScriptableSystem {

    private let m_contact: wref<DSPViktorContact>;

    public func SetContact(contact: ref<DSPViktorContact>) -> Void {
        this.m_contact = contact;
    }

    // Single entry point from CET: adds to history + pushes SMS notification
    public func NotifyViktor(text: String) -> Void {
        // 1. Add to persistent message history
        if IsDefined(this.m_contact) {
            this.m_contact.AddMessage(text);
        };
        // 2. Push SMS notification via PhoneExtension
        let player: ref<GameObject> = GetPlayer(this.GetGameInstance());
        if IsDefined(player) {
            let syst: ref<PhoneExtensionSystem> = PhoneExtensionSystem.GetInstance(player);
            if IsDefined(syst) {
                syst.NotifyNewMessageCustom(77701, s"Viktor Vektor", text);
            };
        };
    }
}
