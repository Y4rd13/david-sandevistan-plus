// DSPActivityTracker.reds — Detect human interactions for sleep multiplier
// Wraps dialogWidgetGameController to intercept dialog choices and match LocKeys.
// Reports detected activities via quest facts (read by CET Lua).

// Activity LocKey checker (like Wannabe Edgerunner's EdgerunnerInteractionChecker)
public class DSPActivityChecker {

    // Shower
    public static func IsShower(locKey: String) -> Bool {
        return Equals(locKey, "LocKey#46419");
    }

    // Pet interaction (Nibbles, cats, iguana)
    public static func IsPet(locKey: String) -> Bool {
        return Equals(locKey, "LocKey#39016")    // Iguana
            || Equals(locKey, "LocKey#32348")    // Cat
            || Equals(locKey, "LocKey#32183")    // Nibbles
            || Equals(locKey, "LocKey#32185")    // Nibbles alt
            || Equals(locKey, "LocKey#80033");   // Cat near Pacifica
    }

    // Apartment amenities
    public static func IsApartment(locKey: String) -> Bool {
        return Equals(locKey, "LocKey#47352")    // Tea Set
            || Equals(locKey, "LocKey#2061")     // Coffee Machine
            || Equals(locKey, "LocKey#46089")    // Record player
            || Equals(locKey, "LocKey#80877")    // Pool table
            || Equals(locKey, "LocKey#45726")    // Incense
            || Equals(locKey, "LocKey#39629");   // Guitar
    }

    // Social interactions
    public static func IsSocial(locKey: String) -> Bool {
        return Equals(locKey, "LocKey#46442")    // Rollercoaster
            || Equals(locKey, "LocKey#93677")    // Growl FM Dance Party
            || Equals(locKey, "LocKey#49986")    // Dance interaction
            || Equals(locKey, "LocKey#42930")    // Bar sitting
            || Equals(locKey, "LocKey#6820");    // Drinking with partner
    }

    // Lover interactions (requires romance quest fact check)
    public static func IsLover(locKey: String, gi: GameInstance) -> Bool {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(gi);
        // Judy
        if (Equals(locKey, "LocKey#34479") || Equals(locKey, "Judy")) && qs.GetFactStr("sq030_judy_lover") == 1 {
            return true;
        }
        // River
        if (Equals(locKey, "LocKey#34418") || Equals(locKey, "River")) && qs.GetFactStr("sq029_river_lover") == 1 {
            return true;
        }
        // Kerry
        if (Equals(locKey, "LocKey#34536") || Equals(locKey, "Kerry")) && qs.GetFactStr("sq028_kerry_lover") == 1 {
            return true;
        }
        // Panam
        if (Equals(locKey, "LocKey#34412") || Equals(locKey, "Panam")) && qs.GetFactStr("sq027_panam_lover") == 1 {
            return true;
        }
        return false;
    }

    // Main check: returns activity type as Int32 (0=unknown, 1=shower, 2=pet, 3=apartment, 4=social, 5=lover)
    public static func Check(locKey: String, gi: GameInstance) -> Int32 {
        if DSPActivityChecker.IsShower(locKey) { return 1; }
        if DSPActivityChecker.IsPet(locKey) { return 2; }
        if DSPActivityChecker.IsApartment(locKey) { return 3; }
        if DSPActivityChecker.IsSocial(locKey) { return 4; }
        if DSPActivityChecker.IsLover(locKey, gi) { return 5; }
        return 0;
    }
}

// Dialog hub title tracker (captures the LocKey of the selected dialog option)
@addField(dialogWidgetGameController)
private let m_dspLastSelectedHub: String = "";

@addField(dialogWidgetGameController)
private let m_dspLastChoiceBB: wref<IBlackboard>;

@addField(dialogWidgetGameController)
private let m_dspLastChoiceCallbackId: ref<CallbackHandle>;

@wrapMethod(dialogWidgetGameController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();
    this.m_dspLastChoiceBB = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIInteractions);
    this.m_dspLastChoiceCallbackId = this.m_dspLastChoiceBB.RegisterListenerVariant(
        GetAllBlackboardDefs().UIInteractions.LastAttemptedChoice, this, n"OnDSPLastAttemptedChoice"
    );
}

@wrapMethod(dialogWidgetGameController)
protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_dspLastChoiceBB) {
        this.m_dspLastChoiceBB.UnregisterListenerVariant(
            GetAllBlackboardDefs().UIInteractions.LastAttemptedChoice, this.m_dspLastChoiceCallbackId
        );
    }
    wrappedMethod();
}

@addMethod(dialogWidgetGameController)
protected cb func OnDSPLastAttemptedChoice(value: Variant) -> Bool {
    let gi: GameInstance = this.GetPlayerControlledObject().GetGame();
    let activity: Int32 = DSPActivityChecker.Check(this.m_dspLastSelectedHub, gi);
    if activity > 0 {
        // Report to CET Lua via quest fact: dsp_activity_detected = activity type
        GameInstance.GetQuestsSystem(gi).SetFactStr("dsp_activity_detected", activity);
    }
    this.m_dspLastSelectedHub = "";
}

// Capture hub title for LocKey matching
public class DSPHubTitleUpdatedEvent extends Event {
    public let title: String;

    public static func Create(title: String) -> ref<DSPHubTitleUpdatedEvent> {
        let instance: ref<DSPHubTitleUpdatedEvent> = new DSPHubTitleUpdatedEvent();
        instance.title = title;
        return instance;
    }
}

@addMethod(dialogWidgetGameController)
protected cb func OnDSPHubTitleUpdatedEvent(evt: ref<DSPHubTitleUpdatedEvent>) -> Bool {
    this.m_dspLastSelectedHub = evt.title;
}

@wrapMethod(DialogHubLogicController)
private final func SetupTitle(const title: script_ref<String>, isActive: Bool, isPossessed: Bool) -> Void {
    let titleStr: String = Deref(title);
    if NotEquals(titleStr, "") && isActive {
        this.QueueEvent(DSPHubTitleUpdatedEvent.Create(titleStr));
    }
    wrappedMethod(title, isActive, isPossessed);
}
