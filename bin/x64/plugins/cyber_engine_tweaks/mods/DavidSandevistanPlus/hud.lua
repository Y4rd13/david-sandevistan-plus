-- hud.lua — CET-to-redscript bridge for DSPHUDSystem
-- All widget creation and rendering is handled by DSPHUDSystem.reds.
-- This file stores data via small setter methods, then calls RefreshHUD().

local hud = {}

hud.Apogee = nil
hud.system = nil  -- ref to DSPHUDSystem ScriptableSystem

----------------------------------------------------------------
-- Init: acquire the redscript system and build the widget tree
----------------------------------------------------------------

hud.Init = (function(self, Apogee, doDebug)
	if Apogee ~= nil then
		self.Apogee = Apogee
	end
	local ok, err = pcall(function()
		local container = Game.GetScriptableSystemsContainer()
		self.system = container:Get(CName.new('DSPHUDSystem'))
	end)
	if not ok then
		print('[DSP-HUD] Failed to get DSPHUDSystem: '..tostring(err))
		self.system = nil
		return
	end
	if self.system == nil then
		print('[DSP-HUD] DSPHUDSystem not found — redscript may not be compiled')
		return
	end
	print('[DSP-HUD] Init: system acquired, calling InitHUD()')
	pcall(function() self.system:InitHUD() end)
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
-- Audio — Last Breath song via Audioware (redscript bridge)
----------------------------------------------------------------

hud.PlaySong = (function(self)
	if self.system then
		pcall(function() self.system:PlayLastBreathSong() end)
	end
end)

hud.StopSong = (function(self)
	if self.system then
		pcall(function() self.system:StopLastBreathSong() end)
	end
end)

----------------------------------------------------------------
-- Visibility control
----------------------------------------------------------------

hud.SetVisible = (function(self, vis)
	if self.system then
		pcall(function() self.system:SetVisible(vis) end)
	end
end)

----------------------------------------------------------------
-- Rebuild (CET reinit path)
----------------------------------------------------------------

hud.Rebuild = (function(self)
	self.system = nil
	self:Init(self.Apogee)
end)

return hud
