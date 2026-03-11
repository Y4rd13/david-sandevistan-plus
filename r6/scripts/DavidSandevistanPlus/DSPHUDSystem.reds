// DSPHUDSystem.reds — Redscript HUD for David Sandevistan Plus
// Fullscreen 3840x2160 canvas with VirtualResolutionWatcher scaling.
// CET Lua calls small setter methods to store data, then RefreshHUD() to render.
// Layout is dynamically positioned — hidden rows collapse so there are no gaps.

import Codeware.UI.VirtualResolutionWatcher

public class DSPHUDSystem extends ScriptableSystem {

    // ---------------------------------------------------------------
    // Widget references
    // ---------------------------------------------------------------
    private let m_initialized: Bool;
    private let m_pulseTimer: Float;
    private let m_fullScreenSlot: ref<inkCompoundWidget>;
    private let m_widgetSlot: ref<inkCompoundWidget>;

    // Runtime row
    private let m_runtimeIcon: ref<inkImage>;
    private let m_runtimeBarBG: ref<inkRectangle>;
    private let m_runtimeBarFill: ref<inkRectangle>;
    private let m_runtimeText: ref<inkText>;
    private let m_dilationText: ref<inkText>;

    // Comedown row
    private let m_comedownIcon: ref<inkImage>;
    private let m_comedownBarBG: ref<inkRectangle>;
    private let m_comedownBarFill: ref<inkRectangle>;

    // Psycho row
    private let m_psychoIcon: ref<inkImage>;
    private let m_psychoBarBG: ref<inkRectangle>;
    private let m_psychoBarFill: ref<inkRectangle>;
    private let m_psychoLine: ref<inkText>;

    // Info row
    private let m_activationsText: ref<inkText>;
    private let m_statusText: ref<inkText>;

    private let m_virtualResolutionWatcher: ref<VirtualResolutionWatcher>;
    private let m_comedownMax: Float;

    // ---------------------------------------------------------------
    // Stored data fields (set by CET via small setter methods)
    // ---------------------------------------------------------------
    private let m_runtime: Float;
    private let m_maxRuntime: Float;
    private let m_dilation: Int32;
    private let m_rechargeNotification: Int32;
    private let m_psychoLevel: Int32;
    private let m_psychoTimer: Float;
    private let m_lastBreathPhase: Int32;
    private let m_isRunning: Bool;
    private let m_isWearing: Bool;
    private let m_showUI: Bool;
    private let m_safetyOn: Bool;
    private let m_dailyActivations: Int32;
    private let m_dailySafe: Int32;
    private let m_comedownTimer: Float;
    private let m_inSafeArea: Bool;
    private let m_inClub: Bool;
    private let m_dfImmuno: Bool;

    // ---------------------------------------------------------------
    // ScriptableSystem lifecycle
    // ---------------------------------------------------------------
    private func OnAttach() -> Void {
        this.m_initialized = false;
        this.m_pulseTimer = 0.0;
    }

    private func OnDetach() -> Void {
        this.m_initialized = false;
    }

    // ---------------------------------------------------------------
    // Static accessor
    // ---------------------------------------------------------------
    public final static func GetInstance(gi: GameInstance) -> ref<DSPHUDSystem> {
        return GameInstance.GetScriptableSystemsContainer(gi).Get(n"DSPHUDSystem") as DSPHUDSystem;
    }

    // ---------------------------------------------------------------
    // Public API — called from CET Lua
    // ---------------------------------------------------------------

    public func InitHUD() -> Void {
        if this.m_initialized {
            return;
        }

        let inkSystem: ref<inkSystem> = GameInstance.GetInkSystem();
        let inkHUD: ref<inkCompoundWidget> = inkSystem.GetLayer(n"inkHUDLayer").GetVirtualWindow();
        if !IsDefined(inkHUD) { return; }

        let root: ref<inkCompoundWidget> = inkHUD.GetWidgetByPathName(n"Root") as inkCompoundWidget;
        if !IsDefined(root) { return; }

        let existing: ref<inkWidget> = inkHUD.GetWidgetByPathName(n"Root/DSPFullScreenSlot");
        if IsDefined(existing) {
            root.RemoveChild(existing);
        }

        let fullScreenSlot: ref<inkCanvas> = new inkCanvas();
        fullScreenSlot.SetName(n"DSPFullScreenSlot");
        fullScreenSlot.SetSize(Vector2(3840.0, 2160.0));
        fullScreenSlot.SetRenderTransformPivot(Vector2(0.0, 0.0));
        fullScreenSlot.Reparent(root);
        this.m_fullScreenSlot = fullScreenSlot;

        let widgetSlot: ref<inkCanvas> = new inkCanvas();
        widgetSlot.SetName(n"DSPWidgetSlot");
        widgetSlot.SetFitToContent(true);
        widgetSlot.SetTranslation(70.0, 410.0);
        widgetSlot.Reparent(fullScreenSlot);
        this.m_widgetSlot = widgetSlot;

        this.CreateWidgets();

        this.m_virtualResolutionWatcher = new VirtualResolutionWatcher();
        this.m_virtualResolutionWatcher.Initialize(GetGameInstance());
        this.m_virtualResolutionWatcher.ScaleWidget(fullScreenSlot);

        this.m_initialized = true;
    }

    // --- Small setter methods (3-6 params each) ---

    public func SetBarData(runtime: Float, maxRuntime: Float, dilation: Int32, rechargeNotification: Int32) -> Void {
        this.m_runtime = runtime;
        this.m_maxRuntime = maxRuntime;
        this.m_dilation = dilation;
        this.m_rechargeNotification = rechargeNotification;
    }

    public func SetPsychoData(psychoLevel: Int32, psychoTimer: Float, lastBreathPhase: Int32) -> Void {
        this.m_psychoLevel = psychoLevel;
        this.m_psychoTimer = psychoTimer;
        this.m_lastBreathPhase = lastBreathPhase;
    }

    public func SetState(isRunning: Bool, isWearing: Bool, showUI: Bool, safetyOn: Bool) -> Void {
        this.m_isRunning = isRunning;
        this.m_isWearing = isWearing;
        this.m_showUI = showUI;
        this.m_safetyOn = safetyOn;
    }

    public func SetContext(dailyActivations: Int32, dailySafe: Int32, comedownTimer: Float, inSafeArea: Bool, inClub: Bool, dfImmuno: Bool) -> Void {
        this.m_dailyActivations = dailyActivations;
        this.m_dailySafe = dailySafe;
        this.m_comedownTimer = comedownTimer;
        this.m_inSafeArea = inSafeArea;
        this.m_inClub = inClub;
        this.m_dfImmuno = dfImmuno;
    }

    // ---------------------------------------------------------------
    // RefreshHUD — dynamic vertical layout, hidden rows collapse
    // ---------------------------------------------------------------
    public func RefreshHUD() -> Void {
        if !this.m_initialized || !IsDefined(this.m_widgetSlot) {
            return;
        }

        this.m_pulseTimer += 1.0;

        if !this.m_isWearing || !this.m_showUI {
            this.m_widgetSlot.SetVisible(false);
            return;
        }
        this.m_widgetSlot.SetVisible(true);

        let rowY: Float = 0.0;

        // =============================================================
        // ROW: Runtime bar (always visible)
        // =============================================================
        let maxRT: Float = this.m_maxRuntime;
        if maxRT <= 0.0 { maxRT = 1.0; }
        let ratio: Float = ClampF(this.m_runtime / maxRT, 0.0, 1.0);
        let fillWidth: Float = 620.0 * ratio;
        if fillWidth < 1.0 && this.m_runtime > 0.0 { fillWidth = 1.0; }

        let rtColor: HDRColor = this.RuntimeColor(ratio);
        this.m_runtimeIcon.SetMargin(inkMargin(0.0, rowY - 15.0, 0.0, 0.0));
        this.m_runtimeIcon.SetTintColor(rtColor);
        this.m_runtimeBarBG.SetMargin(inkMargin(46.0, rowY, 0.0, 0.0));
        this.m_runtimeBarFill.SetMargin(inkMargin(46.0, rowY, 0.0, 0.0));
        this.m_runtimeBarFill.SetSize(Vector2(fillWidth, 10.0));
        this.m_runtimeBarFill.SetTintColor(rtColor);

        // Dilation — to the right of bar
        this.m_dilationText.SetMargin(inkMargin(680.0, rowY - 4.0, 0.0, 0.0));
        this.m_dilationText.SetText(IntToString(this.m_dilation) + "%");
        if this.m_isRunning {
            this.m_dilationText.SetTintColor(this.Color(0.85, 0.85, 0.85, 1.0));
        } else {
            this.m_dilationText.SetTintColor(this.Color(0.50, 0.50, 0.50, 0.80));
        }

        rowY += 16.0;

        // Runtime text
        let rtText: String = IntToString(Cast<Int32>(this.m_runtime)) + "/" + IntToString(Cast<Int32>(maxRT)) + "s";
        if this.m_rechargeNotification > 0 {
            rtText = "+" + IntToString(this.m_rechargeNotification) + "s  " + rtText;
            this.m_runtimeText.SetTintColor(this.Color(0.18, 0.80, 0.44, 1.0));
        } else {
            this.m_runtimeText.SetTintColor(this.Color(0.85, 0.85, 0.85, 1.0));
        }
        this.m_runtimeText.SetMargin(inkMargin(50.0, rowY, 0.0, 0.0));
        this.m_runtimeText.SetText(rtText);

        rowY += 28.0;

        // =============================================================
        // ROW: Comedown bar (visible only during comedown)
        // =============================================================
        if this.m_comedownTimer > 0.0 {
            if this.m_comedownTimer > this.m_comedownMax {
                this.m_comedownMax = this.m_comedownTimer;
            }
            let cdRatio: Float = ClampF(this.m_comedownTimer / this.m_comedownMax, 0.0, 1.0);
            let cdWidth: Float = 620.0 * cdRatio;
            if cdWidth < 1.0 { cdWidth = 1.0; }

            this.m_comedownIcon.SetMargin(inkMargin(0.0, rowY - 16.0, 0.0, 0.0));
            this.m_comedownIcon.SetVisible(true);
            this.m_comedownBarBG.SetMargin(inkMargin(46.0, rowY, 0.0, 0.0));
            this.m_comedownBarBG.SetVisible(true);
            this.m_comedownBarFill.SetMargin(inkMargin(46.0, rowY, 0.0, 0.0));
            this.m_comedownBarFill.SetSize(Vector2(cdWidth, 8.0));
            this.m_comedownBarFill.SetVisible(true);

            rowY += 18.0;
        } else {
            this.m_comedownIcon.SetVisible(false);
            this.m_comedownBarBG.SetVisible(false);
            this.m_comedownBarFill.SetVisible(false);
            this.m_comedownMax = 0.0;
        }

        // =============================================================
        // ROW: Psycho bar (visible when psychoLevel > 0 or lastBreath)
        // =============================================================
        let showPsycho: Bool = this.m_lastBreathPhase > 0 || (this.m_psychoLevel > 0 && this.m_psychoTimer >= 0.0);
        if showPsycho {
            let psColor: HDRColor;
            let psFill: Float;

            if this.m_lastBreathPhase > 0 {
                // Last Breath: bar shows remaining runtime as ratio of initial last breath runtime
                psFill = ClampF(this.m_runtime / maxRT, 0.0, 1.0);
                if this.m_lastBreathPhase == 2 {
                    let pulse: Float = AbsF(SinF(this.m_pulseTimer * 0.5));
                    psColor = this.LerpColor(
                        this.Color(0.91, 0.30, 0.24, 1.0),
                        this.Color(0.85, 0.85, 0.85, 1.0),
                        pulse
                    );
                } else {
                    psColor = this.Color(0.85, 0.85, 0.85, 1.0);
                }
            } else {
                // Normal psycho: bar shows distance from episode (timer/3600)
                psFill = ClampF(this.m_psychoTimer / 3600.0, 0.0, 1.0);
                psColor = this.PsychoLevelColor(this.m_psychoLevel);
            }

            let psWidth: Float = 620.0 * psFill;
            if psWidth < 1.0 && psFill > 0.0 { psWidth = 1.0; }

            this.m_psychoIcon.SetMargin(inkMargin(0.0, rowY - 15.0, 0.0, 0.0));
            this.m_psychoIcon.SetTintColor(psColor);
            this.m_psychoIcon.SetVisible(true);
            this.m_psychoBarBG.SetMargin(inkMargin(46.0, rowY, 0.0, 0.0));
            this.m_psychoBarBG.SetVisible(true);
            this.m_psychoBarFill.SetMargin(inkMargin(46.0, rowY, 0.0, 0.0));
            this.m_psychoBarFill.SetSize(Vector2(psWidth, 10.0));
            this.m_psychoBarFill.SetTintColor(psColor);
            this.m_psychoBarFill.SetVisible(true);

            rowY += 14.0;

            // Psycho text line
            this.m_psychoLine.SetMargin(inkMargin(50.0, rowY, 0.0, 0.0));
            this.m_psychoLine.SetVisible(true);
            if this.m_lastBreathPhase > 0 {
                this.m_psychoLine.SetText("[VI] LAST BREATH  " + this.FormatTime(this.m_runtime));
                this.m_psychoLine.SetTintColor(psColor);
            } else {
                this.m_psychoLine.SetText(this.PsychoLevelText(this.m_psychoLevel) + "  " + this.FormatTime(this.m_psychoTimer));
                this.m_psychoLine.SetTintColor(psColor);
            }

            rowY += 28.0;
        } else {
            this.m_psychoIcon.SetVisible(false);
            this.m_psychoBarBG.SetVisible(false);
            this.m_psychoBarFill.SetVisible(false);
            this.m_psychoLine.SetVisible(false);
        }

        // =============================================================
        // ROW: Info (activations + status)
        // =============================================================
        let actText: String = IntToString(this.m_dailyActivations) + "/" + IntToString(this.m_dailySafe);
        if this.m_dailyActivations > this.m_dailySafe {
            actText = actText + " OVERUSE";
            this.m_activationsText.SetTintColor(this.Color(1.0, 0.6, 0.1, 1.0));
        } else {
            this.m_activationsText.SetTintColor(this.Color(0.50, 0.50, 0.50, 0.80));
        }
        this.m_activationsText.SetMargin(inkMargin(0.0, rowY, 0.0, 0.0));
        this.m_activationsText.SetText(actText);

        let status: String = "";
        let statusColor: HDRColor = this.Color(0.85, 0.85, 0.85, 1.0);
        if this.m_lastBreathPhase == 1 {
            status = "LAST BREATH";
        } else if this.m_lastBreathPhase == 2 {
            status = "LAST BREATH — FADING";
            statusColor = this.Color(0.91, 0.30, 0.24, 1.0);
        } else if !this.m_safetyOn {
            status = "SAFETY OFF";
            statusColor = this.Color(1.0, 0.15, 0.15, 1.0);
        } else if this.m_comedownTimer > 0.0 {
            let whole: Int32 = Cast<Int32>(this.m_comedownTimer);
            let frac: Int32 = Cast<Int32>((this.m_comedownTimer - Cast<Float>(whole)) * 10.0);
            if frac < 0 { frac = 0; }
            status = "COMEDOWN " + IntToString(whole) + "." + IntToString(frac) + "s";
            statusColor = this.Color(1.0, 0.6, 0.1, 1.0);
        } else if (this.m_inSafeArea || this.m_inClub) && this.m_psychoLevel > 0 {
            status = "RECOVERING";
            statusColor = this.Color(0.18, 0.80, 0.44, 1.0);
        } else if this.m_dfImmuno {
            status = "STABILIZED";
            statusColor = this.Color(0.18, 0.80, 0.44, 1.0);
        } else if this.m_isRunning && this.m_psychoLevel > 0 {
            status = "ACCELERATING";
            statusColor = this.Color(0.95, 0.77, 0.06, 1.0);
        }
        this.m_statusText.SetMargin(inkMargin(170.0, rowY, 0.0, 0.0));
        this.m_statusText.SetText(status);
        this.m_statusText.SetTintColor(statusColor);
    }

    public func SetVisible(visible: Bool) -> Void {
        if this.m_initialized && IsDefined(this.m_widgetSlot) {
            this.m_widgetSlot.SetVisible(visible);
        }
    }

    public func TeardownHUD() -> Void {
        if !this.m_initialized { return; }
        if IsDefined(this.m_fullScreenSlot) {
            let parent: ref<inkCompoundWidget> = this.m_fullScreenSlot.GetParentWidget() as inkCompoundWidget;
            if IsDefined(parent) {
                parent.RemoveChild(this.m_fullScreenSlot);
            }
        }
        this.m_fullScreenSlot = null;
        this.m_widgetSlot = null;
        this.m_runtimeIcon = null;
        this.m_runtimeBarBG = null;
        this.m_runtimeBarFill = null;
        this.m_runtimeText = null;
        this.m_dilationText = null;
        this.m_comedownIcon = null;
        this.m_comedownBarBG = null;
        this.m_comedownBarFill = null;
        this.m_psychoIcon = null;
        this.m_psychoBarBG = null;
        this.m_psychoBarFill = null;
        this.m_psychoLine = null;
        this.m_activationsText = null;
        this.m_statusText = null;
        this.m_initialized = false;
    }

    // ---------------------------------------------------------------
    // Private — widget construction
    // ---------------------------------------------------------------
    private func CreateWidgets() -> Void {
        let slot: ref<inkCompoundWidget> = this.m_widgetSlot;

        // --- Runtime icon ---
        let rtIcon: ref<inkImage> = new inkImage();
        rtIcon.SetName(n"DSPRuntimeIcon");
        rtIcon.SetSize(Vector2(40.0, 40.0));
        rtIcon.SetHAlign(inkEHorizontalAlign.Left);
        rtIcon.SetVAlign(inkEVerticalAlign.Top);
        rtIcon.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\healthbar\\atlas_buffinfo.inkatlas");
        rtIcon.SetTexturePart(n"sandevistan_buff_icon");
        rtIcon.SetTintColor(this.Color(0.18, 0.80, 0.44, 1.0));
        rtIcon.Reparent(slot);
        this.m_runtimeIcon = rtIcon;

        // --- Runtime bar BG ---
        let runtimeBG: ref<inkRectangle> = new inkRectangle();
        runtimeBG.SetName(n"DSPRuntimeBarBG");
        runtimeBG.SetSize(Vector2(620.0, 10.0));
        runtimeBG.SetHAlign(inkEHorizontalAlign.Left);
        runtimeBG.SetVAlign(inkEVerticalAlign.Top);
        runtimeBG.SetTintColor(this.Color(0.12, 0.12, 0.14, 0.40));
        runtimeBG.Reparent(slot);
        this.m_runtimeBarBG = runtimeBG;

        // --- Runtime bar fill ---
        let runtimeFill: ref<inkRectangle> = new inkRectangle();
        runtimeFill.SetName(n"DSPRuntimeBarFill");
        runtimeFill.SetSize(Vector2(620.0, 10.0));
        runtimeFill.SetHAlign(inkEHorizontalAlign.Left);
        runtimeFill.SetVAlign(inkEVerticalAlign.Top);
        runtimeFill.SetTintColor(this.Color(0.18, 0.80, 0.44, 1.0));
        runtimeFill.Reparent(slot);
        this.m_runtimeBarFill = runtimeFill;

        // --- Runtime text ---
        let runtimeText: ref<inkText> = new inkText();
        runtimeText.SetName(n"DSPRuntimeText");
        runtimeText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        runtimeText.SetFontStyle(n"Medium");
        runtimeText.SetFontSize(24);
        runtimeText.SetTintColor(this.Color(0.85, 0.85, 0.85, 1.0));
        runtimeText.SetHorizontalAlignment(textHorizontalAlignment.Left);
        runtimeText.SetText("");
        runtimeText.Reparent(slot);
        this.m_runtimeText = runtimeText;

        // --- Dilation text ---
        let dilationText: ref<inkText> = new inkText();
        dilationText.SetName(n"DSPDilationText");
        dilationText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        dilationText.SetFontStyle(n"Medium");
        dilationText.SetFontSize(30);
        dilationText.SetTintColor(this.Color(0.85, 0.85, 0.85, 1.0));
        dilationText.SetHorizontalAlignment(textHorizontalAlignment.Left);
        dilationText.SetText("");
        dilationText.Reparent(slot);
        this.m_dilationText = dilationText;

        // --- Comedown icon ---
        let cdIcon: ref<inkImage> = new inkImage();
        cdIcon.SetName(n"DSPComedownIcon");
        cdIcon.SetSize(Vector2(40.0, 40.0));
        cdIcon.SetHAlign(inkEHorizontalAlign.Left);
        cdIcon.SetVAlign(inkEVerticalAlign.Top);
        cdIcon.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\healthbar\\atlas_buffinfo.inkatlas");
        cdIcon.SetTexturePart(n"synaptic_accelerator");
        cdIcon.SetTintColor(this.Color(1.0, 0.6, 0.1, 1.0));
        cdIcon.SetVisible(false);
        cdIcon.Reparent(slot);
        this.m_comedownIcon = cdIcon;

        // --- Comedown bar BG ---
        let comedownBG: ref<inkRectangle> = new inkRectangle();
        comedownBG.SetName(n"DSPComedownBarBG");
        comedownBG.SetSize(Vector2(620.0, 8.0));
        comedownBG.SetHAlign(inkEHorizontalAlign.Left);
        comedownBG.SetVAlign(inkEVerticalAlign.Top);
        comedownBG.SetTintColor(this.Color(0.12, 0.12, 0.14, 0.40));
        comedownBG.SetVisible(false);
        comedownBG.Reparent(slot);
        this.m_comedownBarBG = comedownBG;

        // --- Comedown bar fill ---
        let comedownFill: ref<inkRectangle> = new inkRectangle();
        comedownFill.SetName(n"DSPComedownBarFill");
        comedownFill.SetSize(Vector2(620.0, 8.0));
        comedownFill.SetHAlign(inkEHorizontalAlign.Left);
        comedownFill.SetVAlign(inkEVerticalAlign.Top);
        comedownFill.SetTintColor(this.Color(1.0, 0.6, 0.1, 1.0));
        comedownFill.SetVisible(false);
        comedownFill.Reparent(slot);
        this.m_comedownBarFill = comedownFill;

        // --- Psycho icon ---
        let psIcon: ref<inkImage> = new inkImage();
        psIcon.SetName(n"DSPPsychoIcon");
        psIcon.SetSize(Vector2(40.0, 40.0));
        psIcon.SetHAlign(inkEHorizontalAlign.Left);
        psIcon.SetVAlign(inkEVerticalAlign.Top);
        psIcon.SetAtlasResource(r"base\\gameplay\\gui\\common\\icons\\quickhacks_icons.inkatlas");
        psIcon.SetTexturePart(n"Cyberpsychosis");
        psIcon.SetTintColor(this.Color(0.25, 0.75, 1.0, 1.0));
        psIcon.SetVisible(false);
        psIcon.Reparent(slot);
        this.m_psychoIcon = psIcon;

        // --- Psycho bar BG ---
        let psychoBG: ref<inkRectangle> = new inkRectangle();
        psychoBG.SetName(n"DSPPsychoBarBG");
        psychoBG.SetSize(Vector2(620.0, 10.0));
        psychoBG.SetHAlign(inkEHorizontalAlign.Left);
        psychoBG.SetVAlign(inkEVerticalAlign.Top);
        psychoBG.SetTintColor(this.Color(0.12, 0.12, 0.14, 0.40));
        psychoBG.SetVisible(false);
        psychoBG.Reparent(slot);
        this.m_psychoBarBG = psychoBG;

        // --- Psycho bar fill ---
        let psychoFill: ref<inkRectangle> = new inkRectangle();
        psychoFill.SetName(n"DSPPsychoBarFill");
        psychoFill.SetSize(Vector2(620.0, 10.0));
        psychoFill.SetHAlign(inkEHorizontalAlign.Left);
        psychoFill.SetVAlign(inkEVerticalAlign.Top);
        psychoFill.SetTintColor(this.Color(0.25, 0.75, 1.0, 1.0));
        psychoFill.SetVisible(false);
        psychoFill.Reparent(slot);
        this.m_psychoBarFill = psychoFill;

        // --- Psycho text line ---
        let psychoLine: ref<inkText> = new inkText();
        psychoLine.SetName(n"DSPPsychoLine");
        psychoLine.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        psychoLine.SetFontStyle(n"Medium");
        psychoLine.SetFontSize(24);
        psychoLine.SetTintColor(this.Color(0.25, 0.75, 1.0, 1.0));
        psychoLine.SetHorizontalAlignment(textHorizontalAlignment.Left);
        psychoLine.SetText("");
        psychoLine.SetVisible(false);
        psychoLine.Reparent(slot);
        this.m_psychoLine = psychoLine;

        // --- Activations text ---
        let activationsText: ref<inkText> = new inkText();
        activationsText.SetName(n"DSPActivationsText");
        activationsText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        activationsText.SetFontStyle(n"Medium");
        activationsText.SetFontSize(24);
        activationsText.SetTintColor(this.Color(0.50, 0.50, 0.50, 0.80));
        activationsText.SetHorizontalAlignment(textHorizontalAlignment.Left);
        activationsText.SetText("");
        activationsText.Reparent(slot);
        this.m_activationsText = activationsText;

        // --- Status text ---
        let statusText: ref<inkText> = new inkText();
        statusText.SetName(n"DSPStatusText");
        statusText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        statusText.SetFontStyle(n"Medium");
        statusText.SetFontSize(24);
        statusText.SetTintColor(this.Color(0.85, 0.85, 0.85, 1.0));
        statusText.SetHorizontalAlignment(textHorizontalAlignment.Left);
        statusText.SetText("");
        statusText.Reparent(slot);
        this.m_statusText = statusText;
    }

    // ---------------------------------------------------------------
    // Private — color helpers
    // ---------------------------------------------------------------
    private func Color(r: Float, g: Float, b: Float, a: Float) -> HDRColor {
        let c: HDRColor;
        c.Red = r;
        c.Green = g;
        c.Blue = b;
        c.Alpha = a;
        return c;
    }

    private func LerpColor(a: HDRColor, b: HDRColor, t: Float) -> HDRColor {
        let ct: Float = ClampF(t, 0.0, 1.0);
        let c: HDRColor;
        c.Red = a.Red + (b.Red - a.Red) * ct;
        c.Green = a.Green + (b.Green - a.Green) * ct;
        c.Blue = a.Blue + (b.Blue - a.Blue) * ct;
        c.Alpha = a.Alpha + (b.Alpha - a.Alpha) * ct;
        return c;
    }

    private func RuntimeColor(ratio: Float) -> HDRColor {
        if ratio > 0.5 {
            return this.LerpColor(
                this.Color(0.95, 0.77, 0.06, 1.0),
                this.Color(0.18, 0.80, 0.44, 1.0),
                (ratio - 0.5) * 2.0
            );
        }
        return this.LerpColor(
            this.Color(0.91, 0.30, 0.24, 1.0),
            this.Color(0.95, 0.77, 0.06, 1.0),
            ratio * 2.0
        );
    }

    private func PsychoLevelText(level: Int32) -> String {
        if level == 1 { return "[I] UNSTABLE"; }
        if level == 2 { return "[II] GLITCHING"; }
        if level == 3 { return "[III] LOSING IT"; }
        if level == 4 { return "[IV] ON THE EDGE"; }
        if level == 5 { return "[V] CYBERPSYCHO"; }
        return "[" + IntToString(level) + "]";
    }

    private func PsychoLevelColor(level: Int32) -> HDRColor {
        if level == 1 { return this.Color(0.25, 0.75, 1.0, 1.0); }
        if level == 2 { return this.Color(0.60, 0.77, 0.53, 1.0); }
        if level == 3 { return this.Color(0.95, 0.77, 0.06, 1.0); }
        if level == 4 { return this.Color(1.0, 0.6, 0.1, 1.0); }
        if level == 5 { return this.Color(0.91, 0.30, 0.24, 1.0); }
        return this.Color(0.25, 0.75, 1.0, 1.0);
    }

    private func FormatTime(seconds: Float) -> String {
        let totalSecs: Int32 = Cast<Int32>(seconds);
        if totalSecs < 0 { totalSecs = 0; }
        let mins: Int32 = totalSecs / 60;
        let secs: Int32 = totalSecs - (mins * 60);
        if mins > 0 {
            let secStr: String;
            if secs < 10 {
                secStr = "0" + IntToString(secs);
            } else {
                secStr = IntToString(secs);
            }
            return IntToString(mins) + "m" + secStr + "s";
        }
        return IntToString(totalSecs) + "s";
    }
}
