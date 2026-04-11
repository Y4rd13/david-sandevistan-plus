// DSPAudioBridge.reds — Audio/voice/SFX/subtitle bridge for DSP
// Extracted from DSPHUDSystem to separate audio concerns from HUD rendering.
// CET Lua calls these via hud.lua bridge.

import Audioware.AudioSettingsExt
import Audioware.Tween
import Audioware.LinearTween

public class DSPAudioBridge extends ScriptableSystem {

    private let m_songPlaying: Bool;
    private let m_currentVoiceLine: CName;
    private let m_cycledSfxDelayId: DelayID;
    private let m_cycledSfxActive: Bool;
    private let m_subtitleCounter: Int32;

    public static func GetInstance(gi: GameInstance) -> ref<DSPAudioBridge> {
        return GameInstance.GetScriptableSystemsContainer(gi).Get(n"DSPAudioBridge") as DSPAudioBridge;
    }

    // ---------------------------------------------------------------
    // Last Breath song — Audioware
    // ---------------------------------------------------------------

    public func PlayLastBreathSong() -> Void {
        if this.m_songPlaying { return; }
        let audioExt = GameInstance.GetAudioSystemExt(this.GetGameInstance());
        if !IsDefined(audioExt) { return; }
        let player = GetPlayer(this.GetGameInstance());
        if !IsDefined(player) { return; }
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

    // ---------------------------------------------------------------
    // Voice lines — Audioware
    // ---------------------------------------------------------------

    public func PlayVoiceLine(eventName: CName) -> Void {
        let audioExt = GameInstance.GetAudioSystemExt(this.GetGameInstance());
        if !IsDefined(audioExt) { return; }
        let player = GetPlayer(this.GetGameInstance());
        if !IsDefined(player) { return; }
        if IsNameValid(this.m_currentVoiceLine) {
            audioExt.Stop(this.m_currentVoiceLine, player.GetEntityID(), n"", LinearTween.Immediate(0.1));
        }
        let settings = new AudioSettingsExt();
        settings.affectedByTimeDilation = false;
        audioExt.Play(eventName, player.GetEntityID(), n"", scnDialogLineType.Regular, settings);
        this.m_currentVoiceLine = eventName;
    }

    public func StopVoiceLine() -> Void {
        let audioExt = GameInstance.GetAudioSystemExt(this.GetGameInstance());
        if !IsDefined(audioExt) { return; }
        let player = GetPlayer(this.GetGameInstance());
        if !IsDefined(player) { return; }
        if IsNameValid(this.m_currentVoiceLine) {
            audioExt.Stop(this.m_currentVoiceLine, player.GetEntityID(), n"", LinearTween.Immediate(0.1));
            this.m_currentVoiceLine = n"";
        }
    }

    // ---------------------------------------------------------------
    // Cycled SFX — looping VFX via DelayCallbacks
    // ---------------------------------------------------------------

    public func StartCycledVfx(vfxName: CName, interval: Float) -> Void {
        let player = GetPlayer(this.GetGameInstance());
        if !IsDefined(player) { return; }
        GameObjectEffectHelper.StartEffectEvent(player, vfxName, false);
        this.m_cycledSfxActive = true;
        let callback = new DSPAudioCycledSfxCallback();
        callback.system = this;
        callback.sfxName = vfxName;
        callback.interval = interval;
        this.m_cycledSfxDelayId = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(callback, interval, true);
    }

    public func StopCycledVfx(vfxName: CName) -> Void {
        if !this.m_cycledSfxActive { return; }
        this.m_cycledSfxActive = false;
        GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_cycledSfxDelayId);
        let player = GetPlayer(this.GetGameInstance());
        if IsDefined(player) {
            GameObjectEffectHelper.StopEffectEvent(player, vfxName);
        }
    }

    public func OnCycledSfxCallback(sfxName: CName, interval: Float) -> Void {
        if !this.m_cycledSfxActive { return; }
        let player = GetPlayer(this.GetGameInstance());
        if !IsDefined(player) { return; }
        GameObjectEffectHelper.StartEffectEvent(player, sfxName, false);
        let callback = new DSPAudioCycledSfxCallback();
        callback.system = this;
        callback.sfxName = sfxName;
        callback.interval = interval;
        this.m_cycledSfxDelayId = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(callback, interval, true);
    }

    // ---------------------------------------------------------------
    // Subtitles — native game subtitle display
    // ---------------------------------------------------------------

    public func ShowSubtitle(text: String, speakerName: String, duration: Float) -> Void {
        let player = GetPlayer(this.GetGameInstance());
        if !IsDefined(player) { return; }

        if this.m_subtitleCounter > 0 {
            this.HideSubtitle();
        }

        this.m_subtitleCounter += 1;

        let line: scnDialogLineData;
        line.id = CreateCRUID(Cast<Uint64>(this.m_subtitleCounter));
        line.text = text;
        line.speaker = player;
        line.speakerName = speakerName;
        line.type = scnDialogLineType.Regular;
        line.duration = duration;
        line.isPersistent = false;

        let board: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIGameData);
        board.SetVariant(GetAllBlackboardDefs().UIGameData.ShowDialogLine, ToVariant([line]), true);

        let callback = new DSPAudioHideSubtitleCallback();
        callback.system = this;
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(callback, duration, false);
    }

    public func HideSubtitle() -> Void {
        if this.m_subtitleCounter <= 0 { return; }
        let board: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIGameData);
        board.SetVariant(GetAllBlackboardDefs().UIGameData.HideDialogLine, ToVariant([CreateCRUID(Cast<Uint64>(this.m_subtitleCounter))]), true);
    }
}

// Callback to auto-hide subtitle after duration
public class DSPAudioHideSubtitleCallback extends DelayCallback {
    public let system: wref<DSPAudioBridge>;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.HideSubtitle();
        }
    }
}

// Callback to re-play SFX in a loop
public class DSPAudioCycledSfxCallback extends DelayCallback {
    public let system: wref<DSPAudioBridge>;
    public let sfxName: CName;
    public let interval: Float;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.OnCycledSfxCallback(this.sfxName, this.interval);
        }
    }
}
