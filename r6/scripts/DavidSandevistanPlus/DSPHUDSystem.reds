// DSPHUDSystem.reds — Redscript HUD for David Sandevistan Plus
// Fullscreen 3840x2160 canvas with VirtualResolutionWatcher scaling.
// CET Lua calls small setter methods to store data, then RefreshHUD() to render.
// Layout is dynamically positioned — hidden rows collapse so there are no gaps.

import Codeware.UI.VirtualResolutionWatcher
import Audioware.AudioSettingsExt
import Audioware.Tween
import Audioware.LinearTween

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

    // Psycho row
    private let m_psychoIcon: ref<inkImage>;
    private let m_psychoBarBG: ref<inkRectangle>;
    private let m_psychoBarFill: ref<inkRectangle>;
    private let m_psychoLine: ref<inkText>;

    // Strain row
    private let m_strainIcon: ref<inkImage>;
    private let m_strainBarBG: ref<inkRectangle>;
    private let m_strainBarFill: ref<inkRectangle>;
    private let m_strainText: ref<inkText>;

    // Info row
    private let m_activationsText: ref<inkText>;
    private let m_statusText: ref<inkText>;

    private let m_virtualResolutionWatcher: ref<VirtualResolutionWatcher>;

    // ---------------------------------------------------------------
    // Stored data fields (set by CET via small setter methods)
    // ---------------------------------------------------------------
    private let m_runtime: Int32;
    private let m_maxRuntime: Int32;
    private let m_dilation: Int32;
    private let m_rechargeNotification: Int32;
    private let m_psychoLevel: Int32;
    private let m_lastBreathPhase: Int32;
    private let m_prescribedDoses: Int32;
    private let m_completedDoses: Int32;
    private let m_isRunning: Bool;
    private let m_isWearing: Bool;
    private let m_showUI: Bool;
    private let m_safetyOn: Bool;
    private let m_dailyActivations: Int32;
    private let m_dailySafe: Int32;
    private let m_comedownTimerTenths: Int32;
    private let m_inSafeArea: Bool;
    private let m_inClub: Bool;
    private let m_dfImmuno: Bool;

    // Neural Strain data (×10 precision from Lua)
    private let m_neuralStrain: Int32;
    private let m_strainThreshold: Int32;
    private let m_strainGuaranteed: Int32;
    private let m_immunoblockerActive: Bool;

    // Kill strain bridge (written by DSPKillTracker, read by CET Lua)
    private let m_pendingKillStrain: Int32;

    // ---------------------------------------------------------------
    // ScriptableSystem lifecycle
    // ---------------------------------------------------------------
    private func OnAttach() -> Void {
        this.m_initialized = false;
        this.m_pulseTimer = 0.0;
        this.m_pendingKillStrain = 0;
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
    // Kill strain bridge (called by DSPKillTracker.reds)
    // ---------------------------------------------------------------
    public func AddKillStrain(cost: Int32) -> Void {
        this.m_pendingKillStrain += cost;
    }

    public func GetAndClearKillStrain() -> Int32 {
        let val: Int32 = this.m_pendingKillStrain;
        this.m_pendingKillStrain = 0;
        return val;
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

    public func SetBarData(runtime: Int32, maxRuntime: Int32, dilation: Int32, rechargeNotification: Int32) -> Void {
        this.m_runtime = runtime;
        this.m_maxRuntime = maxRuntime;
        this.m_dilation = dilation;
        this.m_rechargeNotification = rechargeNotification;
    }

    public func SetPsychoData(psychoLevel: Int32, lastBreathPhase: Int32, prescribedDoses: Int32, completedDoses: Int32) -> Void {
        this.m_psychoLevel = psychoLevel;
        this.m_lastBreathPhase = lastBreathPhase;
        this.m_prescribedDoses = prescribedDoses;
        this.m_completedDoses = completedDoses;
    }

    public func SetState(isRunning: Bool, isWearing: Bool, showUI: Bool, safetyOn: Bool) -> Void {
        this.m_isRunning = isRunning;
        this.m_isWearing = isWearing;
        this.m_showUI = showUI;
        this.m_safetyOn = safetyOn;
    }

    public func SetContext(dailyActivations: Int32, dailySafe: Int32, comedownTimerTenths: Int32, inSafeArea: Bool, inClub: Bool, dfImmuno: Bool) -> Void {
        this.m_dailyActivations = dailyActivations;
        this.m_dailySafe = dailySafe;
        this.m_comedownTimerTenths = comedownTimerTenths;
        this.m_inSafeArea = inSafeArea;
        this.m_inClub = inClub;
        this.m_dfImmuno = dfImmuno;
    }

    // All values ×10 from Lua (math.floor) for sub-integer precision
    public func SetStrainData(neuralStrain: Int32, strainThreshold: Int32, strainGuaranteed: Int32, immunoblockerActive: Bool) -> Void {
        this.m_neuralStrain = neuralStrain;
        this.m_strainThreshold = strainThreshold;
        this.m_strainGuaranteed = strainGuaranteed;
        this.m_immunoblockerActive = immunoblockerActive;
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
        let maxRT: Float = Cast<Float>(this.m_maxRuntime);
        if maxRT <= 0.0 { maxRT = 1.0; }
        let ratio: Float = ClampF(Cast<Float>(this.m_runtime) / maxRT, 0.0, 1.0);
        let fillWidth: Float = 620.0 * ratio;
        if fillWidth < 1.0 && this.m_runtime > 0 { fillWidth = 1.0; }

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
        let rtText: String = IntToString(this.m_runtime) + "/" + IntToString(this.m_maxRuntime) + "s";
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
        // ROW: Psycho bar (visible when psychoLevel > 0 or lastBreath)
        // =============================================================
        let showPsycho: Bool = this.m_lastBreathPhase > 0 || this.m_psychoLevel > 0;
        if showPsycho {
            let psColor: HDRColor;
            let psFill: Float;

            if this.m_lastBreathPhase > 0 {
                // Last Breath: bar shows remaining runtime as ratio of initial last breath runtime
                psFill = ClampF(Cast<Float>(this.m_runtime) / maxRT, 0.0, 1.0);
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
                // Psycho level indicator: fill based on level/5
                psFill = ClampF(Cast<Float>(this.m_psychoLevel) / 5.0, 0.0, 1.0);
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

            // Psycho text line — level + RX progress (no timer)
            this.m_psychoLine.SetMargin(inkMargin(50.0, rowY, 0.0, 0.0));
            this.m_psychoLine.SetVisible(true);
            if this.m_lastBreathPhase > 0 {
                this.m_psychoLine.SetText("[VI] LAST BREATH  " + this.FormatTime(Cast<Float>(this.m_runtime)));
                this.m_psychoLine.SetTintColor(psColor);
            } else {
                let psychoStr: String = this.PsychoLevelText(this.m_psychoLevel);
                if this.m_prescribedDoses > 0 {
                    psychoStr = psychoStr + "  RX " + IntToString(this.m_completedDoses) + "/" + IntToString(this.m_prescribedDoses);
                }
                this.m_psychoLine.SetText(psychoStr);
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
        // ROW: Strain bar (visible when strain > 0)
        // =============================================================
        let showStrain: Bool = this.m_neuralStrain > 0 && this.m_psychoLevel > 0 && this.m_lastBreathPhase == 0;
        if showStrain {
            let strainF: Float = Cast<Float>(this.m_neuralStrain) / 10.0;
            let guaranteedF: Float = Cast<Float>(this.m_strainGuaranteed) / 10.0;
            if guaranteedF <= 0.0 { guaranteedF = 1.0; }
            let strainRatio: Float = ClampF(strainF / guaranteedF, 0.0, 1.0);
            let strainWidth: Float = 620.0 * strainRatio;
            if strainWidth < 1.0 { strainWidth = 1.0; }

            let threshF: Float = Cast<Float>(this.m_strainThreshold) / 10.0;
            let strainColor: HDRColor;
            if strainF < threshF {
                // Below threshold: blue (safe)
                strainColor = this.Color(0.25, 0.60, 1.0, 1.0);
            } else if strainF < guaranteedF {
                // Between threshold and guaranteed: yellow → red
                let dangerRatio: Float = ClampF((strainF - threshF) / (guaranteedF - threshF), 0.0, 1.0);
                strainColor = this.LerpColor(
                    this.Color(0.95, 0.77, 0.06, 1.0),
                    this.Color(0.91, 0.30, 0.24, 1.0),
                    dangerRatio
                );
            } else {
                // At or above guaranteed: bright red
                strainColor = this.Color(1.0, 0.15, 0.15, 1.0);
            }

            this.m_strainIcon.SetMargin(inkMargin(0.0, rowY - 15.0, 0.0, 0.0));
            this.m_strainIcon.SetTintColor(strainColor);
            this.m_strainIcon.SetVisible(true);
            this.m_strainBarBG.SetMargin(inkMargin(46.0, rowY, 0.0, 0.0));
            this.m_strainBarBG.SetVisible(true);
            this.m_strainBarFill.SetMargin(inkMargin(46.0, rowY, 0.0, 0.0));
            this.m_strainBarFill.SetSize(Vector2(strainWidth, 10.0));
            this.m_strainBarFill.SetTintColor(strainColor);
            this.m_strainBarFill.SetVisible(true);

            rowY += 14.0;

            // Strain text: "STRAIN 45/60" or "STRAIN 45/60 BLOCKED"
            let strainWhole: Int32 = this.m_neuralStrain / 10;
            let threshWhole: Int32 = this.m_strainThreshold / 10;
            let strainStr: String = "STRAIN " + IntToString(strainWhole) + "/" + IntToString(threshWhole);
            if this.m_immunoblockerActive {
                strainStr = strainStr + " BLOCKED";
                this.m_strainText.SetTintColor(this.Color(0.18, 0.80, 0.44, 1.0));
            } else {
                this.m_strainText.SetTintColor(strainColor);
            }
            this.m_strainText.SetMargin(inkMargin(50.0, rowY, 0.0, 0.0));
            this.m_strainText.SetText(strainStr);
            this.m_strainText.SetVisible(true);

            rowY += 28.0;
        } else {
            this.m_strainIcon.SetVisible(false);
            this.m_strainBarBG.SetVisible(false);
            this.m_strainBarFill.SetVisible(false);
            this.m_strainText.SetVisible(false);
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
        } else if this.m_immunoblockerActive {
            status = "IMMUNOBLOCKER";
            statusColor = this.Color(0.18, 0.80, 0.44, 1.0);
        } else if !this.m_safetyOn {
            status = "SAFETY OFF";
            statusColor = this.Color(1.0, 0.15, 0.15, 1.0);
        } else if this.m_comedownTimerTenths > 0 {
            let whole: Int32 = this.m_comedownTimerTenths / 10;
            let frac: Int32 = this.m_comedownTimerTenths - (whole * 10);
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

    // ---------------------------------------------------------------
    // Audio — Last Breath song via Audioware
    // ---------------------------------------------------------------

    private let m_songPlaying: Bool;

    public func PlayLastBreathSong() -> Void {
        if this.m_songPlaying { return; }
        let audioExt = GameInstance.GetAudioSystemExt(this.GetGameInstance());
        if !IsDefined(audioExt) { return; }
        let player = GetPlayer(this.GetGameInstance());
        if !IsDefined(player) { return; }
        // Stop any existing instance to prevent overlapping playback
        audioExt.Stop(n"dsp_last_breath_song", player.GetEntityID(), n"", LinearTween.Immediate(0.0));
        let settings = new AudioSettingsExt();
        settings.affectedByTimeDilation = false;
        settings.fadeIn = LinearTween.Immediate(2.0);
        audioExt.Play(n"dsp_last_breath_song", player.GetEntityID(), n"", scnDialogLineType.Regular, settings);
        this.m_songPlaying = true;
    }

    public func StopLastBreathSong() -> Void {
        this.m_songPlaying = false;
        let audioExt = GameInstance.GetAudioSystemExt(this.GetGameInstance());
        if !IsDefined(audioExt) { return; }
        let fadeOut = LinearTween.Immediate(3.0);
        let player = GetPlayer(this.GetGameInstance());
        if !IsDefined(player) { return; }
        audioExt.Stop(n"dsp_last_breath_song", player.GetEntityID(), n"", fadeOut);
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
        this.m_psychoIcon = null;
        this.m_psychoBarBG = null;
        this.m_psychoBarFill = null;
        this.m_psychoLine = null;
        this.m_strainIcon = null;
        this.m_strainBarBG = null;
        this.m_strainBarFill = null;
        this.m_strainText = null;
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

        // --- Strain icon (reuse quickhack icon for neural activity) ---
        let stIcon: ref<inkImage> = new inkImage();
        stIcon.SetName(n"DSPStrainIcon");
        stIcon.SetSize(Vector2(40.0, 40.0));
        stIcon.SetHAlign(inkEHorizontalAlign.Left);
        stIcon.SetVAlign(inkEVerticalAlign.Top);
        stIcon.SetAtlasResource(r"base\\gameplay\\gui\\common\\icons\\quickhacks_icons.inkatlas");
        stIcon.SetTexturePart(n"ShortCircuit");
        stIcon.SetTintColor(this.Color(0.25, 0.60, 1.0, 1.0));
        stIcon.SetVisible(false);
        stIcon.Reparent(slot);
        this.m_strainIcon = stIcon;

        // --- Strain bar BG ---
        let strainBG: ref<inkRectangle> = new inkRectangle();
        strainBG.SetName(n"DSPStrainBarBG");
        strainBG.SetSize(Vector2(620.0, 10.0));
        strainBG.SetHAlign(inkEHorizontalAlign.Left);
        strainBG.SetVAlign(inkEVerticalAlign.Top);
        strainBG.SetTintColor(this.Color(0.12, 0.12, 0.14, 0.40));
        strainBG.SetVisible(false);
        strainBG.Reparent(slot);
        this.m_strainBarBG = strainBG;

        // --- Strain bar fill ---
        let strainFill: ref<inkRectangle> = new inkRectangle();
        strainFill.SetName(n"DSPStrainBarFill");
        strainFill.SetSize(Vector2(620.0, 10.0));
        strainFill.SetHAlign(inkEHorizontalAlign.Left);
        strainFill.SetVAlign(inkEVerticalAlign.Top);
        strainFill.SetTintColor(this.Color(0.25, 0.60, 1.0, 1.0));
        strainFill.SetVisible(false);
        strainFill.Reparent(slot);
        this.m_strainBarFill = strainFill;

        // --- Strain text ---
        let strainText: ref<inkText> = new inkText();
        strainText.SetName(n"DSPStrainText");
        strainText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        strainText.SetFontStyle(n"Medium");
        strainText.SetFontSize(24);
        strainText.SetTintColor(this.Color(0.25, 0.60, 1.0, 1.0));
        strainText.SetHorizontalAlignment(textHorizontalAlignment.Left);
        strainText.SetText("");
        strainText.SetVisible(false);
        strainText.Reparent(slot);
        this.m_strainText = strainText;

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
