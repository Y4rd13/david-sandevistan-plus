// DSPViktorPhone.reds — Viktor Vektor phone contact via PhoneExtension framework

import PhoneExtension.DataStructures.*
import PhoneExtension.Classes.*
import PhoneExtension.System.*

public class DSPViktorContact extends PhoneEventsListener {

    private let m_messages: array<ref<DSPViktorMessage>>;
    private let m_messengerController: wref<MessengerDialogViewController>;
    private let m_hasUnread: Bool;

    public func GetContactHash() -> Int32 = 77701

    public func GetContactData(isText: Bool) -> ref<ContactData> {
        let contactData: ref<ContactData>;
        contactData = new ContactData();
        contactData.hash = this.GetContactHash();
        contactData.localizedName = s"Viktor Vektor";
        contactData.contactId = s"ViktorVektor_DSP";
        contactData.id = s"VIKDSP";
        contactData.avatarID = t"PhoneAvatars.Avatar_Victor_vector";
        contactData.questRelated = false;
        contactData.isCallable = false;
        if isText {
            contactData.type = MessengerContactType.SingleThread;
            if ArraySize(this.m_messages) > 0 {
                contactData.lastMesssagePreview = this.m_messages[ArraySize(this.m_messages) - 1].text;
            } else {
                contactData.lastMesssagePreview = s"";
            };
            contactData.messagesCount = ArraySize(this.m_messages);
            contactData.hasMessages = ArraySize(this.m_messages) > 0;
            contactData.playerIsLastSender = false;
            if this.m_hasUnread {
                contactData.unreadMessegeCount = 1;
                ArrayInsert(contactData.unreadMessages, 0, 1);
            };
        } else {
            contactData.type = MessengerContactType.Contact;
        };
        return contactData;
    }

    public func ShowDialog(messengerController: wref<MessengerDialogViewController>) -> Bool {
        this.m_messengerController = messengerController;
        this.m_hasUnread = false;
        if ArraySize(this.m_messages) == 0 {
            return false;
        };
        let i: Int32 = 0;
        while i < ArraySize(this.m_messages) {
            let playSound: Bool = i == ArraySize(this.m_messages) - 1;
            this.m_messengerController.PushMessageCustom(this.m_messages[i].text, MessageViewType.Received, s"Viktor", playSound);
            i += 1;
        };
        this.m_messengerController.m_scrollController.SetScrollPosition(1.00);
        return true;
    }

    public func ActivateReply(messageID: Int32) -> Void {
    }

    public func AddMessage(text: String) -> Void {
        let msg: ref<DSPViktorMessage> = new DSPViktorMessage();
        msg.text = text;
        ArrayPush(this.m_messages, msg);
        this.m_hasUnread = true;
        while ArraySize(this.m_messages) > 20 {
            ArrayErase(this.m_messages, 0);
        };
    }
}

public class DSPViktorMessage {
    public let text: String;
}

// ---------------------------------------------------------------
// Registration — same pattern as VehicleInsurancePhone example
// ---------------------------------------------------------------
@addField(NewHudPhoneGameController)
private let m_dspViktorContact: ref<DSPViktorContact>;

@wrapMethod(NewHudPhoneGameController)
protected cb func OnInitialize() -> Bool {
    let ret: Bool = wrappedMethod();
    let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
    if !IsDefined(this.m_dspViktorContact) {
        this.m_dspViktorContact = new DSPViktorContact();
    };
    syst.Register(this.m_dspViktorContact);
    // Wire to bridge for CET access
    let gi: GameInstance = this.GetPlayerControlledObject().GetGame();
    let bridge: ref<ScriptableSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"DSPViktorBridge");
    if IsDefined(bridge) {
        (bridge as DSPViktorBridge).SetContact(this.m_dspViktorContact);
    };
    return ret;
}

@wrapMethod(NewHudPhoneGameController)
protected cb func OnUninitialize() -> Bool {
    let ret: Bool = wrappedMethod();
    let syst = PhoneExtensionSystem.GetInstance(this.GetPlayerControlledObject());
    syst.Unregister(this.m_dspViktorContact);
    return ret;
}
