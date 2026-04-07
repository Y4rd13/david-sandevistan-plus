// DSPBiomonitorSystem.reds — Biomonitor + Substance Detection panels
// Extracted from DSPHUDSystem. Creates its own fullscreen overlay slot.
// CET Lua calls via immunoblocker_logic.lua + init.lua.

import Codeware.UI.VirtualResolutionWatcher
import AnimatedBiomonitor.AnimatedBiomonitorController

public class DSPBiomonitorSystem extends ScriptableSystem {

    private let m_initialized: Bool;
    private let m_fullScreenSlot: ref<inkCompoundWidget>;
    private let m_biomonitorWidget: wref<inkWidget>;
    private let m_cyberwareWidget: wref<inkWidget>;
    private let m_biomonitorPosX: Float;
    private let m_biomonitorPosY: Float;
    private let m_virtualResolutionWatcher: ref<VirtualResolutionWatcher>;

    // Protocol data (set by CET before ShowBiomonitor)
    private let m_bioRestCompleted: Int32;
    private let m_bioRestRequired: Int32;
    private let m_bioVisitsCompleted: Int32;
    private let m_bioVisitsRequired: Int32;
    private let m_bioDoses: Int32;
    private let m_bioMilestonePct: Int32;

    public static func GetInstance(gi: GameInstance) -> ref<DSPBiomonitorSystem> {
        return GameInstance.GetScriptableSystemsContainer(gi).Get(n"DSPBiomonitorSystem") as DSPBiomonitorSystem;
    }

    public func InitOverlay() -> Void {
        if this.m_initialized { return; }
        this.m_biomonitorPosX = 80.0;
        this.m_biomonitorPosY = 600.0;

        let inkSystem: ref<inkSystem> = GameInstance.GetInkSystem();
        let inkHUD: ref<inkCompoundWidget> = inkSystem.GetLayer(n"inkHUDLayer").GetVirtualWindow();
        if !IsDefined(inkHUD) { return; }

        let root: ref<inkCompoundWidget> = inkHUD.GetWidgetByPathName(n"Root") as inkCompoundWidget;
        if !IsDefined(root) { return; }

        let slot: ref<inkCanvas> = new inkCanvas();
        slot.SetName(n"DSPBiomonitorSlot");
        slot.SetAnchor(inkEAnchor.Fill);
        slot.SetSize(new Vector2(3840.0, 2160.0));
        slot.Reparent(root);

        this.m_fullScreenSlot = slot;

        this.m_virtualResolutionWatcher = new VirtualResolutionWatcher();
        this.m_virtualResolutionWatcher.Initialize(GetGameInstance());
        this.m_virtualResolutionWatcher.ScaleWidget(slot);

        this.m_initialized = true;
    }

    // ---------------------------------------------------------------
    // Setters (called from CET before ShowBiomonitor)
    // ---------------------------------------------------------------

    public func SetBiomonitorPosition(posX: Int32, posY: Int32) -> Void {
        this.m_biomonitorPosX = Cast<Float>(posX);
        this.m_biomonitorPosY = Cast<Float>(posY);
    }

    public func SetBiomonitorProtocolData(restCompleted: Int32, restRequired: Int32, visitsCompleted: Int32, visitsRequired: Int32, doses: Int32, milestonePct: Int32) -> Void {
        this.m_bioRestCompleted = restCompleted;
        this.m_bioRestRequired = restRequired;
        this.m_bioVisitsCompleted = visitsCompleted;
        this.m_bioVisitsRequired = visitsRequired;
        this.m_bioDoses = doses;
        this.m_bioMilestonePct = milestonePct;
    }

    // ---------------------------------------------------------------
    // Biomonitor panel (AnimatedBiomonitor)
    // ---------------------------------------------------------------

    public func ShowBiomonitor(tier: Int32, toleranceStage: Int32, efficacyPct: Int32, strainPct: Int32, psychoStage: Int32, rxCompleted: Int32, rxTotal: Int32, opt manualOpen: Bool) -> Void {
        if !this.m_initialized || !IsDefined(this.m_fullScreenSlot) { return; }

        this.ForceRemoveBiomonitor();

        let tierName: String;
        if tier == 3 { tierName = "MILITARY GRADE"; }
        else if tier == 2 { tierName = "UNCOMMON"; }
        else if tier == 1 { tierName = "COMMON"; }
        else { tierName = "NONE"; }

        let tolName: String;
        if toleranceStage == 0 { tolName = "None"; }
        else if toleranceStage == 1 { tolName = "Mild"; }
        else if toleranceStage == 2 { tolName = "Moderate"; }
        else { tolName = "Severe"; }

        let psychoName: String;
        if psychoStage <= 0 { psychoName = "Clear"; }
        else if psychoStage == 1 { psychoName = "Stage I"; }
        else if psychoStage == 2 { psychoName = "Stage II"; }
        else if psychoStage == 3 { psychoName = "Stage III"; }
        else if psychoStage == 4 { psychoName = "Stage IV"; }
        else { psychoName = "Stage V"; }

        let rxText: String;
        if rxTotal > 0 {
            let pct: Int32 = (rxCompleted * 100) / rxTotal;
            rxText = "RX " + IntToString(rxCompleted) + "/" + IntToString(rxTotal) + " — " + IntToString(pct) + "%";
        } else {
            rxText = "No active protocol";
        }

        let restText: String;
        if this.m_bioRestRequired > 0 {
            restText = IntToString(this.m_bioRestCompleted) + "/" + IntToString(this.m_bioRestRequired) + "h";
        } else {
            restText = "—";
        }

        let visitsText: String;
        if this.m_bioVisitsRequired > 0 {
            visitsText = IntToString(this.m_bioVisitsCompleted) + "/" + IntToString(this.m_bioVisitsRequired);
            let questsSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(GetGameInstance());
            let visitCooldownUntil: Int32 = questsSystem.GetFactStr("dsp_visit_cooldown_until");
            if visitCooldownUntil > 0 {
                let now: Float = GameInstance.GetTimeSystem(GetGameInstance()).GetGameTimeStamp();
                let remaining: Float = Cast<Float>(visitCooldownUntil) - now;
                if remaining > 0.0 {
                    let hoursLeft: Int32 = Cast<Int32>(remaining / 3600.0) + 1;
                    visitsText = visitsText + " (next in " + IntToString(hoursLeft) + "h)";
                };
            };
        } else {
            visitsText = "—";
        }

        let prescribedText: String;
        if this.m_bioDoses > 0 {
            prescribedText = IntToString(this.m_bioDoses) + " doses " + tierName;
        } else {
            prescribedText = "—";
        }

        let milestoneText: String;
        if this.m_bioMilestonePct <= 0 { milestoneText = "Not started"; }
        else if this.m_bioMilestonePct < 33 { milestoneText = "In progress"; }
        else if this.m_bioMilestonePct < 66 { milestoneText = IntToString(this.m_bioMilestonePct) + "% — Stabilizing"; }
        else if this.m_bioMilestonePct < 100 { milestoneText = IntToString(this.m_bioMilestonePct) + "% — Improving"; }
        else { milestoneText = "Complete"; }

        let bioCanvas: ref<inkCanvas> = new inkCanvas();
        bioCanvas.SetName(n"DSPBiomonitor");
        bioCanvas.SetAnchor(inkEAnchor.TopLeft);
        bioCanvas.SetAnchorPoint(new Vector2(0.0, 0.0));
        bioCanvas.SetSize(new Vector2(950.0, 600.0));
        bioCanvas.SetMargin(new inkMargin(this.m_biomonitorPosX, this.m_biomonitorPosY, 0.0, 0.0));
        bioCanvas.Reparent(this.m_fullScreenSlot);
        this.m_biomonitorWidget = bioCanvas;

        let controller: ref<AnimatedBiomonitorController> = new AnimatedBiomonitorController();
        bioCanvas.AttachController(controller);

        controller.m_footerText1 = s"Client: V";
        controller.m_footerText2 = s"Viktor Vektor Medical";
        controller.m_textSize = 28;
        controller.m_loadingAnimDuration = 0.2;
        controller.m_expandAnimDuration = 0.15;
        controller.m_listItemAnimDuration = 0.08;
        if manualOpen {
            controller.m_fadeOutDelay = 9999.0;
        } else {
            controller.m_fadeOutDelay = 10.0;
        }
        controller.m_fadeOutDuration = 0.5;

        ArrayPush(controller.m_items, new MonitorListItem("Milestone:", -1.00, milestoneText, ""));
        ArrayPush(controller.m_items, new MonitorListItem("Rest:", -1.00, restText, ""));
        ArrayPush(controller.m_items, new MonitorListItem("Visits:", -1.00, visitsText, ""));
        ArrayPush(controller.m_items, new MonitorListItem("Prescribed:", -1.00, prescribedText, ""));
        ArrayPush(controller.m_items, new MonitorListItem("Treatment:", -1.00, rxText, ""));
        ArrayPush(controller.m_items, new MonitorListItem("Cyberpsychosis:", -1.00, psychoName, ""));
        ArrayPush(controller.m_items, new MonitorListItem("Neural Load:", -1.00, IntToString(strainPct) + "%", ""));
        ArrayPush(controller.m_items, new MonitorListItem("Efficacy:", -1.00, IntToString(efficacyPct) + "%", ""));
        ArrayPush(controller.m_items, new MonitorListItem("Tolerance:", -1.00, tolName, ""));
        ArrayPush(controller.m_items, new MonitorListItem("BIOMONITOR STATUS", -1.00, "", ""));

        controller.StartAnimation();
    }

    public func RemoveBiomonitorWidget() -> Void {
        if IsDefined(this.m_biomonitorWidget) && IsDefined(this.m_fullScreenSlot) {
            let slideOut: ref<inkAnimDef> = new inkAnimDef();
            let sizeInterp: ref<inkAnimSize> = new inkAnimSize();
            sizeInterp.SetDuration(0.3);
            sizeInterp.SetStartSize(new Vector2(950.0, 500.0));
            sizeInterp.SetEndSize(new Vector2(0.0, 0.0));
            sizeInterp.SetType(inkanimInterpolationType.Linear);
            sizeInterp.SetMode(inkanimInterpolationMode.EasyOut);
            slideOut.AddInterpolator(sizeInterp);
            let fadeInterp: ref<inkAnimTransparency> = new inkAnimTransparency();
            fadeInterp.SetDuration(0.3);
            fadeInterp.SetStartTransparency(1.0);
            fadeInterp.SetEndTransparency(0.0);
            fadeInterp.SetType(inkanimInterpolationType.Linear);
            fadeInterp.SetMode(inkanimInterpolationMode.EasyOut);
            slideOut.AddInterpolator(fadeInterp);
            (this.m_biomonitorWidget as inkCompoundWidget).PlayAnimation(slideOut);

            let cb: ref<DSPBioRemoveCallback> = new DSPBioRemoveCallback();
            cb.system = this;
            GameInstance.GetDelaySystem(GetGameInstance()).DelayCallback(cb, 0.35, false);
        }
    }

    public func ForceRemoveBiomonitor() -> Void {
        if IsDefined(this.m_biomonitorWidget) && IsDefined(this.m_fullScreenSlot) {
            this.m_fullScreenSlot.RemoveChild(this.m_biomonitorWidget);
            this.m_biomonitorWidget = null;
        }
    }

    // ---------------------------------------------------------------
    // Substance Detection panel (cyan theme)
    // ---------------------------------------------------------------

    public func ShowSubstanceDetection(tierName: String, feedbackMsg: String) -> Void {
        if !this.m_initialized || !IsDefined(this.m_fullScreenSlot) { return; }

        if IsDefined(this.m_cyberwareWidget) {
            this.m_fullScreenSlot.RemoveChild(this.m_cyberwareWidget);
            this.m_cyberwareWidget = null;
        }

        let cwCanvas: ref<inkCanvas> = new inkCanvas();
        cwCanvas.SetName(n"DSPSubstanceDetection");
        cwCanvas.SetAnchor(inkEAnchor.TopLeft);
        cwCanvas.SetAnchorPoint(new Vector2(0.0, 0.0));
        cwCanvas.SetSize(new Vector2(700.0, 300.0));
        cwCanvas.SetMargin(new inkMargin(this.m_biomonitorPosX, this.m_biomonitorPosY + 520.0, 0.0, 0.0));
        cwCanvas.Reparent(this.m_fullScreenSlot);
        this.m_cyberwareWidget = cwCanvas;

        let controller: ref<AnimatedBiomonitorController> = new AnimatedBiomonitorController();
        cwCanvas.AttachController(controller);

        controller.m_textColor = new HDRColor(0.3686, 0.9647, 1.0, 1.0);
        controller.m_logoColor = new HDRColor(0.3686, 0.9647, 1.0, 1.0);
        controller.m_loadingBarColor = new HDRColor(0.3686, 0.9647, 1.0, 1.0);
        controller.m_headerColor = new HDRColor(0.1583, 1.3033, 1.4142, 1.0);
        controller.m_backgroundColor = new HDRColor(0.0902, 0.1725, 0.1804, 1.0);
        controller.m_borderColor = new HDRColor(0.3686, 0.9647, 1.0, 1.0);

        controller.m_footerText1 = s"";
        controller.m_footerText2 = s"Substance Analysis";
        controller.m_textSize = 26;
        controller.m_loadingAnimDuration = 0.4;
        controller.m_expandAnimDuration = 0.4;
        controller.m_listItemAnimDuration = 0.3;
        controller.m_fadeOutDelay = 8.0;
        controller.m_fadeOutDuration = 0.5;

        ArrayPush(controller.m_items, new MonitorListItem(feedbackMsg, -1.00, "", ""));
        ArrayPush(controller.m_items, new MonitorListItem("Immunoblocker " + tierName, -1.00, "", ""));
        ArrayPush(controller.m_items, new MonitorListItem("SUBSTANCE DETECTED", -1.00, "", ""));

        controller.StartAnimation();
    }

    public func RemoveCyberwareWidget() -> Void {
        if IsDefined(this.m_cyberwareWidget) && IsDefined(this.m_fullScreenSlot) {
            this.m_fullScreenSlot.RemoveChild(this.m_cyberwareWidget);
            this.m_cyberwareWidget = null;
        }
    }
}

// Callback to remove biomonitor after slide-out animation
public class DSPBioRemoveCallback extends DelayCallback {
    public let system: wref<DSPBiomonitorSystem>;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.ForceRemoveBiomonitor();
        }
    }
}
