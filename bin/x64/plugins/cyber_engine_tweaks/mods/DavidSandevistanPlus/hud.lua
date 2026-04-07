-- hud.lua — CET-to-redscript bridge for DSP systems
-- DSPHUDSystem: HUD rendering + kill strain
-- DSPAudioBridge: audio, voice, SFX, subtitles
-- DSPBiomonitorSystem: biomonitor, substance detection

local hud = {}

hud.DSP = nil
hud.system = nil    -- ref to DSPHUDSystem
hud.audio = nil     -- ref to DSPAudioBridge
hud.biomonitor = nil -- ref to DSPBiomonitorSystem

----------------------------------------------------------------
-- Init: acquire the 3 redscript systems
----------------------------------------------------------------

hud.Init = (function(self, DSP, doDebug)
	if DSP ~= nil then
		self.DSP = DSP
	end
	local ok, err = pcall(function()
		local container = Game.GetScriptableSystemsContainer()
		self.system = container:Get(CName.new('DSPHUDSystem'))
		self.audio = container:Get(CName.new('DSPAudioBridge'))
		self.biomonitor = container:Get(CName.new('DSPBiomonitorSystem'))
	end)
	if not ok then
		print('[DSP-HUD] Failed to get systems: '..tostring(err))
		self.system = nil
		return
	end
	if self.system == nil then
		print('[DSP-HUD] DSPHUDSystem not found — redscript may not be compiled')
		return
	end
	print('[DSP-HUD] Init: system acquired, calling InitHUD()')
	pcall(function() self.system:InitHUD() end)
	-- Init biomonitor overlay
	pcall(function()
		if self.biomonitor then
			self.biomonitor:InitOverlay()
		end
	end)
	-- Set biomonitor position from config
	pcall(function()
		if self.DSP and self.DSP.cfg and self.biomonitor then
			self.biomonitor:SetBiomonitorPosition(self.DSP.cfg.biomonitorPosX or 80, self.DSP.cfg.biomonitorPosY or 600)
		end
	end)
end)

----------------------------------------------------------------
-- Update: store data via small setters, then refresh
----------------------------------------------------------------

hud.Update = (function(self, data)
	if self.system == nil then return end

	local runtime = math.floor(data.runTime or 0)
	local maxRuntime = math.floor(data.MaxRunTime or 300)
	local dilation = math.floor(data.dilation or 85)
	local rechargeNotification = math.floor(data.rechargeNotification or 0)

	local psychoLevel = math.floor(data.psychoWarnings or 0)
	local lastBreathPhase = 0
	if data.lastBreath then
		if data.lastBreath.phase == "peace" then
			lastBreathPhase = 1
		else
			lastBreathPhase = 2
		end
	end
	local prescribedDoses = math.floor(data.prescribedDoses or 0)
	local completedDoses = math.floor(data.completedDoses or 0)

	local isRunning = data.isRunning or false
	local isWearing = data.isWearing or false
	local showUI = data.showUI or false
	local safetyOn = data.SafetyOn
	if safetyOn == nil then safetyOn = true end

	local dailyActivations = data.dailyActivations or 0
	local dailySafe = data.dailySafe or 5
	local comedownTimer = math.floor((data.comedownTimer or -1) * 10)
	local inSafeArea = data.inSafeArea or false
	local inClub = data.inClub or false
	local dfImmuno = data.dfImmuno or false

	-- Neural Strain data (×10 + math.floor for CET→redscript Int32 safety)
	local neuralStrain = math.floor((data.neuralStrain or 0) * 10)
	local strainThreshold = math.floor((data.strainThreshold or 60) * 10)
	local strainGuaranteed = math.floor((data.strainGuaranteed or 100) * 10)
	local immunoblockerActive = data.immunoblockerActive or false

	local ok, err = pcall(function()
		self.system:SetBarData(runtime, maxRuntime, dilation, rechargeNotification)
		self.system:SetPsychoData(psychoLevel, lastBreathPhase, prescribedDoses, completedDoses)
		self.system:SetState(isRunning, isWearing, showUI, safetyOn)
		self.system:SetContext(dailyActivations, dailySafe, comedownTimer, inSafeArea, inClub, dfImmuno)
		self.system:SetStrainData(neuralStrain, strainThreshold, strainGuaranteed, immunoblockerActive)
		self.system:RefreshHUD()
	end)
	if not ok then
		print('[DSP-HUD] Update error: '..tostring(err))
	end
end)

----------------------------------------------------------------
-- Audio — via DSPAudioBridge
----------------------------------------------------------------

hud.PlaySong = (function(self)
	if self.audio then
		pcall(function() self.audio:PlayLastBreathSong() end)
	end
end)

hud.StopSong = (function(self)
	if self.audio then
		pcall(function() self.audio:StopLastBreathSong() end)
	end
end)

----------------------------------------------------------------
-- Voice lines — via DSPAudioBridge
----------------------------------------------------------------

hud.PlayVoiceLine = (function(self, eventName)
	if self.audio then
		pcall(function() self.audio:PlayVoiceLine(CName.new(eventName)) end)
	end
end)

hud.StopVoiceLine = (function(self)
	if self.audio then
		pcall(function() self.audio:StopVoiceLine() end)
	end
end)

----------------------------------------------------------------
-- Cycled SFX — via DSPAudioBridge
----------------------------------------------------------------

hud.StartCycledVfx = (function(self, vfxName, interval)
	if self.audio then
		pcall(function() self.audio:StartCycledVfx(CName.new(vfxName), interval or 4.0) end)
	end
end)

hud.StopCycledVfx = (function(self, vfxName)
	if self.audio then
		pcall(function() self.audio:StopCycledVfx(CName.new(vfxName)) end)
	end
end)

----------------------------------------------------------------
-- Subtitles — via DSPAudioBridge
----------------------------------------------------------------

hud.ShowSubtitle = (function(self, text, speakerName, duration)
	if self.audio then
		pcall(function() self.audio:ShowSubtitle(text, speakerName or "V", duration or 3.0) end)
	end
end)

hud.HideSubtitle = (function(self)
	if self.audio then
		pcall(function() self.audio:HideSubtitle() end)
	end
end)

return hud
