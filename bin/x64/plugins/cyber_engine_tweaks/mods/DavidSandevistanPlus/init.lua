--[[
CHANGE LOG
2.25.3
	- Fixed Issue where the UI Timer was being turned off every second, even if it was already off.
	- Fixed Issue where V was going from SceneTier2 to SceneTier3 in Psycho mode it would play the Screen Blur effect when it shouldn't.
	- Fixed Sandevistan going BOOP everytime V crosses a scene boundary, or takes a nap.
	- Fixed the Runtime Recharge, it stops at 300 seconds now.
2.25.0
	- Lift Safety Limiters keybinding disabled during game menu.
	- Ressurrected some e3 VFX and found a nice place for them.
	- NPCs in combat are "Ghosted" when V is a Cyberpsycho. Trying to bring Episode 6 of EdgeRunners into Cyberpunk.
	- V's Kiroshi's are on the fritz during Fury and Cyberpsycho; V's having a system overload, things are busted.
	- When V has full blown cyberpsychosis, V can "get it together" by lifting the limiters for a short period of time.
	- Lift Safety Limiters turns gadgets back on when fury ends.
	- full 8 hour sleep required to cure level 5 cyberpsycho; 1-7 hour sleep will bring down to level 1 psychosis.
	- Added psycho bar in the Diagnostics menu pink> not very psycho... cyan> V will soon be in trouble.
	- Sandy slowly recharges when V is in a "Safe Area" & V slowly recovers from psychosis; clubs are a good spot to recharge.
	- If EdgeRunner perk is used; HealthBrake is always used. If not HealthBrake is scaled from 15 to 50% depending on runtime.
	- The sandy will stop if you answer the phone so you can hear the caller in real time.
	- Fixed the CET Menu Size when debugging is turned off and hopefully fixed some scaling issues.
	- Made the Sandevistan Text on the Health bar smaller so the stamina bar does not get chopped.
2.21.0
	- Dialed Cyberpsychosis/Cyberpsycho VFX up to 11; it's like tripping on mushrooms now.
2.20.3
	- Fixed CET Time Dilation readout being incorrect
	- Fixed an issue with Redline glitching on a new game
	- Timers no longer tick in game menus so you wont die while visiting the inventory screen
	- Asking Viktor to replace V's implants will remove cyberpsychosis and give V 8 hours rest (5min cooldown)
2.20.0
	The holy grail of Sandevistan Mods... real-time configuration of time dilation, no more reloading save files.
	The time dilation of the Sandevistan changes based on a combination of what mode it's in and the remaining runtime.
		- Safety Limits Removed - 97.5% / 15% health drain; all other features disabled; extra damage per tick.
		    - Instead of deleting all the runtime when activated, it will use up 5s/tick of run time.
		- Overclock - Configurable from 87.5% up to 95%; the more you over clock it the higher the RAM cost; 33% reduced runtime.
		- Overclock - Time dilation and ram cost degrade during the last 10 seconds of runtime.
		- Spillover - Puts Overclock back into Edgerunner mode, with full runtime, instead of refunding partial ticks.
		- The standerd operating mode of the Sandevistan is still 85%
		- Runtime - When the Sandevistan has run out of Runtime; it has a minor reduction in time dilation to 82.5%
	With the introduction of Safety Limiter Removal, Cyberpsychos can use the Sandy again before sleeping.
	Emergency Brake and Adrenaline Rush have been moved to EdgeRunner functionality. Cyberdeck is no longer required for them.
	By default the Sandevistan will immidiately remove health from V as an Activation Cost.
	    - With Adrenaline Rush enabled, this Activation Cost Shunt will be channelled through V's Adrenaline chip and Provide a buff instead.
	Reworked Fury;
		- While V is having a psychosis episode the Sandevistan will be turned off and limiters turned on.
		- Fury no longer triggers by killing gangoons it's been replaced by Cyberpsychosis.
		- Fury buffs (crit chance/damage etc) are now active when V's Sandevistan has safety limiters removed
		- Tech60: EMP Blast is gone, use grenades or ChainLightning; the Crit buff on demand should more than make up for this.
	Having a Cyberpsychosis episode will make Gangoons and NCPD around you hostile.
	Having one Cyberpsychosis episode can randomly trigger another even without activating the sandevistan. Limiters off will severely speed up Cyberpsychosis episodes.
	The fifth Cyberpsychosis episode will make V a full blown Cyberpsycho, Sandevistan will be disabled without Lifiting the Limiters.
	MAXTAC - Having a cyberpsycho episode is not enough to call maxtac, now you have to go psycho AND kill civilians or NCPD.
	       - Killing gangoons will not call MAXTAC. This should make the mod "quest friendly" and not trigger 5 stars when it shouldn't.
	       - If you don't have an active psycho warning in Diagnosis tool, then normal progression of wanted levels.
	Current Time Dilation & Runtime are displayed below the health bar.
	Runtime is displayed consistently now Runtime Remaining.
	Picked better buff icons for the effects
	Fixed conflict between cyberpsycho buff and sandevistan cooldown; now it's NAILED SHUT.
2.13.7
	Added VFX when Sandevistan is being Overclocked
	Added VFX as Cyberpsycho warning when runtime is expired
	Added VFX after Cyberpsycho episode (until reset/sleep).
	Cyberpsycho Warning 3 now requires user input to see it, but you still need to sleep.
2.13.6
	If V runs out of health and the Sandevistan disables itself and there is no remaining runtime:
	 - The Sandevistan will turn itself off and shut down until V has a sleep.
	 - No more Sandevistan for you cyberpsycho!
	 - If V is Edge Running there is an option to restart it in the Diagnostic Tools; Otherwise take a nap, one hour will reset it.
	With V's outstanding technical ability, found a developer access Netrunner Cyberdeck Socket on the Sandevistan;
	 - To find this Socket V needs to have the EdgeRunner perk in the Tech Tree
	 - This port allows a Vitals Monitor
	 - To use the Socket V needs to have Queue Acceleration III in Intelligence Tree and have a Cyberdeck installed.
	 --- Cyberware-Ex can be used to fit Cyberdeck and Sandevistan at the same time.
	 --- BlackChrome mod has a Zetatech Auxilary Cyberdeck which fits in Frontal Cortex
	 - Once V has a Cyberdeck and Queue Acceleration III more configuration options are available.
	 -- 1. Emergency brake: This controls how much life is maintained before the sandevistan shuts down.
	       This emergency brake setting sets the maximum value for the brake, the minimum setting is always 15%
	 -- 2. Using Overclock III skill will shunt some or all of the system overload that would cause V to take injury through V's cyberdeck
	       Using Overclock will put the Sandevistan into it's 33% runtime mode.
	 -- 3. Using Queue Mastery and Spillover overclock's V's cyberdeck so that the overload that gets run through the Cyberdeck
           half the used runtime of the Sandevistan essentially doubling the maximum runtime if the Sandy is used solely on RAM.
	 -- 4. Adrenaline Rush & Calm Mind; If V is slotted with an Adrenaline chip V can pump some of the excess sandevistan
	       power into the chip to charge it up. Calm mind doubles the charge.
	Overclock, Spillover and Adrenaline Rush all require runtime on the Sandevistan, if you run out these extra features will stop working.
	Removed "HalfTicks" and rewrote CalcDamage to be more simple
	Various Localization Strings Added
2.13.5
	Added Localization capabilities
	Fixed Issue where if CET menu was open during game loading the Log file would be filled with errors.
	Fixed Issue that broke EDGE RUNNER perk requirement.
2.13.4c
	If you run the sandevistan on the very ragged edge, V might have a very bad day.
	Minor bug fixes with IsEdgeRunner()
	Fixed issue where Game.GetPlayer() does not exist during PlayerPuppet/OnGameAttached, run time clipping is instead done in retrospect
	EdgeRunner perk required to recharge to fully; otherwise only the last 1/3rd of the runtime is available.
	Changed Icon to David's Sandevistan image from Edgerunners.
	Fixed initial charge level changing straight away on activation rather than waiting for the next "tick".
	Added debugging CET window (change dsp.debug = true)
2.13.3
	Created MartinezSandevistan from scratch. It's now divorced (mostly) from the DSP except for the icon and most of the localization texts.
	Since duration is infinite... in theory...
		Changed from Reflex(Extra duration) to Cool for Headshot bonus!
		Added 5% heal-on-kill because duration is your life.
	Runtime replenishes fully after 24 hours of rest. Resting will replenish a maximum of 1/3 of the charge after 8 hours.
		Fully charged this Sandy is over powered; so for normal sleep cycles (8 hours per day)
		V will need 3 sleeps of a minimum of 8 hours each for it to recharge to full.
	Once you've recieved Falco's Gift and are Level 40, have a nap.
2.13.2 - Sandevistan runtime persists with savegames, removed some un-needed calls to CalcDamage()
2.13.1 - base functional version

TODO: Deconstruct Cyberpsychosis quickhack to see how it makes NPCs effected by it automatically hostile from everyone else; why it doesn't affect V and then
      make a buff that makes gangoons, ncpd & armed civilians hostile towards V without taking any action and no wanted level.
]]

local configFile = "config.json"
local function loadConfig(cfg)
	local file = io.open(configFile, "r")
	if file then
		local ok, loaded = pcall(json.decode, file:read("*a"))
		file:close()
		if ok and type(loaded) == "table" then
			for k, v in pairs(loaded) do
				if cfg[k] ~= nil then cfg[k] = v end
			end
		end
	end
end

dsp = {
	 version = '2.25.3'
	,debug = false -- change to true to get the CET Debugging UI
	,UseDavidsIcon = true -- change to false to get the old DSP icon
	,Call_MaxTac = true -- change to false to prevent 5 star wanted level (this only happens now if you kill civilians or NPCD while cyberpsycho)
	,ShowUIText = true -- change to false to hide the dilation/runtime/cyberpsycho text on the health bar
	,OverrideTextSize      = nil -- change the font size of the Sandevistan Text to match your other UI mods.
	,OverrideTextMargin    = nil -- move the Sandevistan Text up or down to match your other UI mods.
	,OverrideStaminaMargin = nil -- move the Stamina Bar Text up or down to match your other UI mods.
	,ForceStaminaMargin    = nil -- instead of the one above to fix the margin regardless of text showing or not.
	,cfg = {
		-- Health Drain
		enableHealthDrain = true,        -- toggle all health drain from sandevistan
		damageMin = 0.5,                 -- minimum damage % per tick (at full runtime)
		damageMax = 8.0,                 -- maximum damage % per tick (at zero runtime)

		-- Health Brake
		enableHealthBrake = false,       -- auto-stop sandy when V's health gets too low
		healthBrakeDefault = 50,         -- default health brake threshold %
		requiredHealthMin = 15,          -- minimum required health % before brake kicks in

		-- Safety Off
		safetyOffDrainMultiplier = 4,    -- extra tick multiplier for runtime drain (total = 1 + this)
		enableSafetyOffKill = true,      -- V can die when safety off + health depleted
		safetyOffKillThreshold = 2,      -- health % threshold that triggers V's death

		-- Recharge
		fullRechargeHours = 16,          -- hours for full recharge
		maxRechargePerSleep = 10,        -- max hours recharged per sleep session

		-- Cyberpsychosis
		enableCyberpsychosis = true,     -- toggle entire cyberpsychosis system
		dailySafeActivations = 3,        -- activations per day before strain acceleration (Doc's warning)

		-- Neural Strain
		strainPerActivation = 5,         -- strain added per Sandy activation
		strainPerOveruseBonus = 3,       -- extra strain per activation beyond safe limit
		strainPerMinuteActive = 2,       -- strain per 60s of Sandy active time
		strainPerSecSafetyOff = 0.15,    -- strain/sec while Safety OFF
		strainPerKillGang = 2,           -- kill strain: gang members (lowest)
		strainPerKillCorpo = 3,          -- kill strain: corporate security
		strainPerKillNCPD = 5,           -- kill strain: NCPD / NetWatch
		strainPerKillCivilian = 8,       -- kill strain: civilians / unaffiliated (highest)
		strainPerComedown5s = 1,         -- strain per 5s of comedown
		strainDrainSafeArea = 0.05,      -- strain/sec drain in safe areas
		strainDrainSleep = 40,           -- strain drained per sleep (scaled by hours)
		strainDrainRipper = 25,          -- strain drained per ripperdoc visit
		strainDrainImmunoblocker = { 0.08, 0.18, 0.35 },  -- strain/sec drain per tier: Common, Uncommon, Rare
		strainDrainDFImmuno = 0.08,      -- strain/sec drain while DF Immunosuppressant active
		strainBuildupMultiplier = 1.0,   -- global multiplier for all strain accumulation
		strainRecoveryMultiplier = 1.0,  -- global multiplier for all strain drain

		-- Immunoblocker prices (applied to TweakDB at game load)
		immunoblockerPriceCommon = 6000,
		immunoblockerPriceUncommon = 24000,
		immunoblockerPriceRare = 100000,

		-- Safety Off
		safetyOffTimeDilation = 975,     -- time dilation index when safety off (975=97.5%, 950=95%, 1000=99.5%)

		-- Comedown (Enhanced)
		enableComedown = true,           -- apply debuff after deactivating sandevistan
		comedownBaseDuration = 5.0,      -- base duration in seconds (enhanced: was 3.0)
		comedownMaxDuration = 20.0,      -- max duration after long sandy use (enhanced: was 8.0)
		comedownRuntimeThreshold = 60,   -- seconds of sandy use before comedown starts scaling
		comedownBlockSandy = true,       -- can't reactivate during comedown
		comedownPsychoMultiplier = 1.5,  -- duration multiplier at psycho 3+
		comedownTremorAtPsycho = true,   -- tremor during comedown at psycho 3+

		-- Perk Gates
		requireEdgeRunnerPerk = true,   -- require EdgeRunner perk for full runtime (false = full access from day 1)

		-- Time Dilation
		timeDilationNoPerk = 0.05,       -- time scale without EdgeRunner perk (95%)
		timeDilationWithPerk = 0.0065,   -- time scale with EdgeRunner perk (99.35%)

		-- Doc Prescription (Graduated Recovery)
		enablePrescription = true,       -- recovery is a process, not instant
		maxPsychoRecoveryPerSleep = 1,   -- max levels recovered per sleep
		ripperRecoveryLevels = 1,        -- levels per ripperdoc visit

		-- Non-Linear Runtime Drain
		enableNonLinearDrain = true,     -- drain accelerates the longer Sandy is active
		drainExponent = 1.5,             -- acceleration curve exponent
		drainAccelStartSec = 60,         -- seconds before acceleration kicks in

		-- Session Fatigue
		enableSessionFatigue = true,     -- each activation in a session is less effective
		sessionFatiguePenalty = 0.02,    -- dilation loss per overuse activation (2%)
		maxSessionFatiguePenalty = 0.10, -- cap at 10% penalty

		-- Max Runtime Degradation
		enableRuntimeDegradation = true, -- each Sandy session costs max runtime
		sleepRecoveryPercent = 0.75,     -- sleep recovers 75% of degraded max
		ripperFullRestore = true,        -- ripper restores 100% max

		-- Micro-Episodes
		enableMicroEpisodes = true,      -- random involuntary symptoms between episodes
		microEpisodeFrequency = 1.0,     -- multiplier (0.5 = half, 2.0 = double)

		-- Tick
		tickLength = 1.25,               -- main game loop tick interval in seconds
	}
	,martinez = require('./martinez.lua')
	,gui = require('./gui.lua')
	,hud = require('./hud.lua')
	--[[Every variable after this point is a runtime value not configuration, changing them here will have zero effect they are overwritten at runtime]]--
	,isRunning = false
	,lastTick = 0
	,TickLength = -1
	,displayTick = 0
	,displayTick2 = 0
	,MaxRuntime = -1
	,runTime = -1
	,neuralStrain = 0
	,strainComedownAccum = 0  -- accumulator for comedown strain (fires every 5s)
	,strainActiveAccum = 0    -- accumulator for Sandy-active strain (fires every 60s)
	,PsychoMessageWaiting = false
	,HealthBrake = -1
	,FullRechargeHours = -1
	,MaxRechargePerSleep = -1
	,DamagePerTick = -1
	,CyberPsychoWarnings = -1
	,dailyActivations = 0
	,sandyStartRuntime = 0
	,lowRuntimeWarned = false
	,comedownTimer = nil
	,comedownTremor = false
	,PsychoTrigger = -1
	,RequiredHealth = -1
	,MinorBleedingOn = false
	,SafetyOn = false
	,LoadGameRun = false
	,TriedLoadGameRun = false
	,PlayerAttached = false
	,PlayerInSafeArea = false
	,TimeDilationActiveEffect = nil
	,TimeDilationActualSpeed = nil
	,ViktorCooldown = nil
	,isPhotoMode = false
	,VIsDead = false
	,VIsInControl = false
	-- Lore effects state
	,tremor = { intensity = 0, time = 0 }
	,fovPulse = nil  -- { elapsed = 0, duration = 0.4, baseFOV = nil }
	,nextLaughTime = nil  -- os.clock() timestamp for next psycho laugh
	,terminalClarity = nil  -- { elapsed = 0, duration = 2.5 }
	,heartbeatPlaying = false
	,cheatedDeath = false
	,nextPsychoMsgTime = nil
	,lastBreath = nil  -- { phase = "peace"|"decay", elapsed = 0, peaceTime = 20, totalRuntime = N, songPlaying = false }
	,lastBreathDeath = nil  -- true when Last Breath death is pending (permanent death)
	,lastBreathMessage = nil  -- { elapsed = 0, duration = 3, sent = false }
	,combatNPCs = {}  -- tracked hostile NPCs { [entityID_hash] = npcPuppet }
	,nextTimeBombTime = nil  -- os.clock() for next Stage 5 Ticking Time Bomb
	-- Prescription system state
	,prescribedDoses = 0
	,completedDoses = 0
	-- Session fatigue state
	,sessionActivations = 0
	-- Max runtime degradation
	,maxRuntimeDegraded = 0  -- total seconds lost from max runtime
	-- Micro-episodes state
	,microEpisodeTimer = nil
	,lastMicroEpisodeType = nil
	,autoInjectorCooldown = 0
	,autoInjectorEquipped = nil  -- cached per displayTick cycle
	,immunoWarnedThisDose = false  -- one-shot warning per immunoblocker dose
	,Init = (function(self)
		if self.martinez == nil then
			local obj, errors = require('./martinez.lua')
			spdlog.info(tostring(errors))
			print('[DSP] Init: martinez.lua failed to load: '..tostring(errors))
		elseif self.gui == nil then
			local obj, errors = require('./gui.lua')
			spdlog.info(tostring(errors))
			print('[DSP] Init: gui.lua failed to load: '..tostring(errors))
		elseif self.hud == nil then
			local obj, errors = require('./hud.lua')
			spdlog.info(tostring(errors))
			print('[DSP] Init: hud.lua failed to load: '..tostring(errors))
		else
			self.Localization:Init()
			self.bbs:Init()
			self.gui:Init(self)
			print('[DSP] sps:Init skipped (Codeware compat)')
			self.GMGC:Init(self)
			--UI:Init() is done in Load3
			self.TimeSkip.DSP = self -- give TimeSkip a pointer so we don't have to use callback functions!
			self:CreateSandevistan()
			print('[DSP] Init: CreateSandevistan() complete')
			if self.dev_mode then
				if self.dev_mode.Init then self.dev_mode:Init(self) end
				self.debug = true
			end
		end
	 end)
	,dp = (function(self,ThingsList)
		local debug_string = ''
		local commas = ''
		local i = 0
		for k,v in pairs(ThingsList) do
			i = i + 1; if i == 2 then commas = ', ' end
			debug_string = debug_string..commas..k..':'..tostring(v)
		end
		print(debug_string)
	 end)
	,Localization = {
		 getLanguage = (function(self)
			return Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue().value
		 end)
		,Init = (function(self)
			local en_us, errors = require('./localization/en-us.lua')
			for k,v in pairs(en_us) do self[k] = v end -- by default use en-us text; load it all in to create the variables so nothing is missing.
			
			local language = self:getLanguage()
			if language ~= 'en-us' then
				local other_lua, errors = require('./localization/'..language..'.lua')
				if other_lua ~= nil then
					for k,v in pairs(other_lua) do self[k] = v end
				end
			end
		 end)
	 }
	,UpdateUIText = (function(self)
		local dilation = self.TimeDilationActualSpeed
		if dilation == nil then dilation = 85 end
		local dfImmuno = self:StatusEffect_CheckOnly('DarkFutureStatusEffect.Immunosuppressant')
		local immunoblockerActive = self:IsImmunoblockerActive()
		self.hud:Update({
			isWearing = self:IsWearingSandevistan() or false,
			showUI = self.ShowUIText,
			isRunning = self.isRunning,
			SafetyOn = self.SafetyOn,
			dilation = dilation,
			runTime = self.runTime,
			MaxRunTime = self.MaxRuntime,
			dailyActivations = self.dailyActivations or 0,
			dailySafe = self:getEffectiveSafeActivations(),
			psychoWarnings = self.CyberPsychoWarnings or 0,
			comedownTimer = self.comedownTimer,
			rechargeNotification = self.rechargeNotification,
			inSafeArea = self.PlayerInSafeArea,
			inClub = self.InDaClub,
			dfImmuno = dfImmuno,
			lastBreath = self.lastBreath,
			prescribedDoses = self.prescribedDoses or 0,
			completedDoses = self.completedDoses or 0,
			neuralStrain = self.neuralStrain or 0,
			strainThreshold = self:GetStrainThreshold(),
			strainGuaranteed = self:GetStrainGuaranteed(),
			immunoblockerActive = immunoblockerActive,
		})
	 end)
	,GetSandevistanIndex = (function(self)
		local V = Game.GetPlayer()
		if not IsDefined(V) then return nil end
		for i=0,99 do
			local OSItem = V:GetEquippedItemIdInArea(gamedataEquipmentArea.SystemReplacementCW,i)
			if OSItem.id.length == 0 and i>1 then break end -- always check the first two slots
			if OSItem.id.value == self.martinez.RecordName then
				return i
			end
		end
		return false
	 end)
	,IsWearingSandevistan = (function(self)
		output = self:GetSandevistanIndex()
		    if output == nil   then return nil
		elseif output == false then return false
		end
		return true
	 end)
	,RemoveAllPsychoVFX = (function(self)
		self:StatusEffect_CheckAndRemove(self.martinez.PsychoWarningEffect_Light)
		self:StatusEffect_CheckAndRemove(self.martinez.PsychoWarningEffect_Medium)
		self:StatusEffect_CheckAndRemove(self.martinez.PsychoWarningEffect_Heavy)
		self:StatusEffect_CheckAndRemove(self.martinez.PsychoSluggishEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.CyberpsychoStatusEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.CyberpsychoSafetyOffEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.PsychoLaughEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.NosebleedEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.HeartbeatEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.TickingTimeBombEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.BlackwallKillEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.ComedownEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.PsychosisCombatBuff)
		self:StopHeartbeat()
		-- Stop cycled SFX
		pcall(function()
			local V = Game.GetPlayer()
			if V and IsDefined(V) then
				local stopEvt = SoundStopEvent.new()
				stopEvt.soundName = "ui_gmpl_perk_edgerunner"
				V:QueueEvent(stopEvt)
			end
		end)
	 end)
	,DisableSandevistan = (function(self,source)
		if type(source) ~= 'string' then source = '' end
		if self.martinez == nil then return end
		self:UpdatePsychoStamina()

		if (not self:IsWearingSandevistan()) and (not self.SafetyOn) then
			self.SafetyOn = true
			self:StatusEffect_CheckAndRemove(self.martinez.SafetiesOffStatusEffect)
			return
		end
		-- Progressive psycho VFX by level (MartinezFury is timed/automatic, these are persistent)
		if (self.PlayerInSafeArea or self.InDaClub or (not self.VIsInControl)) then
			self:RemoveAllPsychoVFX()
			self.sps:ResetNamePlates()
		elseif self.CyberPsychoWarnings <= 1 then
			self:RemoveAllPsychoVFX()
			self.sps:ResetNamePlates()
		elseif self.CyberPsychoWarnings == 2 then
			self:RemoveAllPsychoVFX()
			self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Light)
			self.sps:ResetNamePlates()
		elseif self.CyberPsychoWarnings == 3 then
			self:RemoveAllPsychoVFX()
			self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Medium)
			self.sps:ResetNamePlates()
		elseif self.CyberPsychoWarnings == 4 then
			self:RemoveAllPsychoVFX()
			self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Heavy)
			self:StatusEffect_CheckAndApply(self.martinez.PsychoSluggishEffect)
			self.sps:ResetNamePlates()
		elseif self.CyberPsychoWarnings >= 5 and (not self.SafetyOn) then
			self:RemoveAllPsychoVFX()
			self:StatusEffect_CheckAndApply(self.martinez.CyberpsychoSafetyOffEffect)
			self:StatusEffect_CheckAndApply(self.martinez.PsychoSluggishEffect)
			self.sps:HideNamePlates()
		elseif self.CyberPsychoWarnings >= 5 then
			self:RemoveAllPsychoVFX()
			self:StatusEffect_CheckAndApply(self.martinez.CyberpsychoStatusEffect)
			self:StatusEffect_CheckAndApply(self.martinez.PsychoSluggishEffect)
			self.sps:HideNamePlates()
		end

		self:UpdateUIText()
	 end)
	,SafeAreaChange = (function(self,SafeArea)
		self.PlayerInSafeArea = SafeArea
		self:DisableSandevistan()
	 end)
	,Restart = (function(self)
		self.runTime = self.MaxRuntime
		self:SaveGame('DSP:Restart()')
	 end)
	,Rested = (function(self,RestedHours)
		RestedHours = math.floor(RestedHours)
		if RestedHours < 1 then return end

		local prevPsycho = self.CyberPsychoWarnings

		if self.cfg.enablePrescription and prevPsycho > 0 then
			-- Graduated recovery: max -1 level per sleep
			local maxRecovery = self.cfg.maxPsychoRecoveryPerSleep or 1
			local requiredDoses, requiredRipper = self:GetPrescription(prevPsycho)
			-- Can't sleep below level that requires ripper visits
			local minLevelFromSleep = 0
			for lvl = prevPsycho, 0, -1 do
				local _, minRip = self:GetPrescription(lvl)
				if minRip > 0 and (self.completedDoses or 0) < requiredRipper then
					minLevelFromSleep = lvl
					break
				end
			end
			local newLevel = math.max(prevPsycho - maxRecovery, minLevelFromSleep, 0)
			-- Count sleep as a dose
			if newLevel < prevPsycho and self.prescribedDoses > 0 then
				self.completedDoses = math.min((self.completedDoses or 0) + 1, self.prescribedDoses)
			end
			self.CyberPsychoWarnings = newLevel
			-- Drain strain on sleep (scaled by hours)
			local recovMult = self.cfg.strainRecoveryMultiplier or 1.0
			local strainDrain = self.cfg.strainDrainSleep * (RestedHours / 8) * recovMult
			self.neuralStrain = math.max((self.neuralStrain or 0) - strainDrain, 0)
			if newLevel > 0 then
				local remaining = self.prescribedDoses - self.completedDoses
				local partialRecovery = {
					"Slept it off a little... but the buzzing's still there",
					"Head's clearer after some sleep... not clear enough",
					"Doc said rest would help... still got "..tostring(remaining).." treatments to go",
					"Better than yesterday... but the Sandy's still in my head",
				}
				self.bbs:SendWarning(partialRecovery[math.random(#partialRecovery)], 5.0)
			else
				self.prescribedDoses = 0
				self.completedDoses = 0
				self.bbs:SendMessage("Head's clear... feels like me again", 3.0)
			end
			-- Reset micro-episode timer for new level
			self:ResetMicroEpisodeTimer()
			self:SyncSafetyWithStage()
		elseif RestedHours < self.MaxRechargePerSleep and self.CyberPsychoWarnings == 5 then
			self.CyberPsychoWarnings = 1
			self.neuralStrain = 0
			self:SyncSafetyWithStage()
			self.bbs:SendWarning("Crashed hard... still twitching. Need a full night", 5.0)
		else
			self.CyberPsychoWarnings = 0
			if prevPsycho > 0 then
				self.bbs:SendMessage("Head's clear... feels like me again", 3.0)
			end
			self.prescribedDoses = 0
			self.completedDoses = 0
		end

		self.dailyActivations = 0
		self.sessionActivations = 0
		self.blackoutToday = false  -- reset blackout daily flag on sleep
		self.cheatedDeath = false
		if self.lastBreath then
			self:StopLastBreathSong()
			pcall(function()
				local ts = Game.GetTimeSystem()
				ts:UnsetTimeDilation("sandevistan")
				ts:SetIgnoreTimeDilationOnLocalPlayerZero(false)
			end)
		end
		self.lastBreath = nil
		self.lastBreathDeath = nil
		self.lastBreathMessage = nil
		self.nextTimeBombTime = nil
		self.combatNPCs = {}
		self.qs:SaveDailyActivations(0)

		-- Clear runtime effects on rest
		self:RemoveRuntimeStamina()

		-- Sleep recovers degraded max runtime (75% by default)
		if self.cfg.enableRuntimeDegradation and (self.maxRuntimeDegraded or 0) > 0 then
			local recovery = self.maxRuntimeDegraded * (self.cfg.sleepRecoveryPercent or 0.75)
			self.maxRuntimeDegraded = self.maxRuntimeDegraded - recovery
			if self.maxRuntimeDegraded < 1 then self.maxRuntimeDegraded = 0 end
		end

		self:Safety(true)
		self:DisableSandevistan()
		if RestedHours > self.MaxRechargePerSleep then RestedHours = self.MaxRechargePerSleep end
		local effectiveMax = self:GetEffectiveMaxRuntime()
		RestedRuntime = self.MaxRuntime * (RestedHours/self.FullRechargeHours)
		if self.dev_mode then
			print('DSP:Rested() => Runtime'..tostring(RestedRuntime)..' / '..tostring(self.MaxRuntime)..' - MaxRechargePerSleep:'..tostring(self.MaxRechargePerSleep)..' - FullRechargeHours:'..tostring(self.FullRechargeHours))
		end
		local oldRuntime = self.runTime
		self.runTime = self.runTime + RestedRuntime + 1
		if self.runTime > effectiveMax then self.runTime = effectiveMax end
		self.rechargeNotification = math.floor(self.runTime - oldRuntime)
		self.rechargeNotificationTimer = 8
		if self.rechargeNotification > 0 then
			local rechargeLines = {
				"Sandy feels charged... spine's humming again",
				"Slept well... Sandy's ready to go",
				"Rest did the trick... implant's back online",
				"Woke up fresh... the Sandy's purring",
			}
			self.bbs:SendMessage(rechargeLines[math.random(#rechargeLines)], 3.0)
		end

		self:SaveGame('DSP:Rested()')
	 end)
	,VisitedRipper = (function(self,VendorName)
		local isRested = ""
		if VendorName == nil then VendorName = "" end
		if VendorName ~= "" and self.ViktorCooldown == nil then -- At Ripper + no cooldown
			-- Prescription system: ripper visit = treatment
			if self.cfg.enablePrescription and self.CyberPsychoWarnings > 0 then
				-- Issue prescription on first visit at this level
				local requiredDoses, requiredRipper = self:GetPrescription(self.CyberPsychoWarnings)
				if self.prescribedDoses == 0 or self.prescribedDoses ~= requiredDoses then
					self.prescribedDoses = requiredDoses
					self.completedDoses = 0
				end
				-- Ripper visit counts as a treatment dose + recovers 1 level
				self.completedDoses = math.min((self.completedDoses or 0) + 1, self.prescribedDoses)
				local recoveryLevels = self.cfg.ripperRecoveryLevels or 1
				local prevLevel = self.CyberPsychoWarnings
				self.CyberPsychoWarnings = math.max(self.CyberPsychoWarnings - recoveryLevels, 0)
				self:SyncSafetyWithStage()
				-- Grant runtime recharge (50% max)
				local oldRuntime = self.runTime
				local effectiveMax = self:GetEffectiveMaxRuntime()
				self.runTime = math.min(self.runTime + effectiveMax * 0.5, effectiveMax)
				self.rechargeNotification = math.floor(self.runTime - oldRuntime)
				self.rechargeNotificationTimer = 8
				-- Full max runtime restore at ripper
				if self.cfg.ripperFullRestore then
					self.maxRuntimeDegraded = 0
				end
				if self.completedDoses >= self.prescribedDoses then
					self.prescribedDoses = 0
					self.completedDoses = 0
					local completeMsgs = {
						"\"You're clean, kid. Don't make me do this again.\"",
						"Doc gives the all-clear... head's finally quiet",
						"\"Treatment's done. Try not to flatline before next visit.\"",
					}
					self.bbs:SendMessage(completeMsgs[math.random(#completeMsgs)], 5.0)
				else
					local remaining = self.prescribedDoses - self.completedDoses
					local progressMsgs = {
						"\"Getting better, but we're not done. "..tostring(remaining).." more sessions.\"",
						"Doc adjusts the implant... some relief, but not enough yet",
						"\"Come back for the rest. "..tostring(remaining).." treatments to go.\"",
						"Spine calibration helps... still "..tostring(remaining).." to go",
					}
					self.bbs:SendMessage(progressMsgs[math.random(#progressMsgs)], 4.0)
				end
				-- Ripper drains strain
				local ripRecovMult = self.cfg.strainRecoveryMultiplier or 1.0
				self.neuralStrain = math.max((self.neuralStrain or 0) - self.cfg.strainDrainRipper * ripRecovMult, 0)
				self:ResetMicroEpisodeTimer()
				self:DisableSandevistan("VisitedRipper")
			else
				self:Rested(8)
			end
			isRested = "Treatment"
			self.ViktorCooldown = 300 -- 5min cooldown
		end
		if self.dev_mode then
			print('DSP:VisitedRipper("'..VendorName..'") '..tostring(isRested)..' prescribedDoses='..tostring(self.prescribedDoses)..' completedDoses='..tostring(self.completedDoses))
		end
	 end)
	,DamageCalculator = (function(self,MaxRuntime,runTime)
		local calcRunTimeProgress = (MaxRuntime-runTime)/MaxRuntime
		local calcDamagePerTick = ((self.cfg.damageMax - self.cfg.damageMin) * calcRunTimeProgress) + self.cfg.damageMin
		local calcRequiredHealth = calcDamagePerTick * 5
		if calcRequiredHealth < self.cfg.requiredHealthMin then calcRequiredHealth = self.cfg.requiredHealthMin end
		return calcDamagePerTick, calcRequiredHealth
	 end)
	,CalcDamage = (function(self)
		local DamagePerTick, RequiredHealth = self:DamageCalculator(self.MaxRuntime,self.runTime)
		self.DamagePerTick = DamagePerTick
		self.RequiredHealth = RequiredHealth
	 end)
	,Start = (function(self)
		if self.martinez == nil then print('[DSP] Start: martinez nil!') return end
		local isWearing = self:IsWearingSandevistan()
		if not isWearing then print('[DSP] Start: IsWearing='..tostring(isWearing)..' — not our Sandy, skipping') return end
		-- Last Breath: Sandy is auto-managed, don't count reactivations
		if self.lastBreath then return end
		print('[DSP] Start: IsWearing=true, dailyActivations='..tostring(self.dailyActivations))

		-- No reactivation block — David can always reactivate (lore-accurate)
		-- The cost is progressive: low runtime = debuffs + strain

		self.isRunning = true
		self.sandyStartRuntime = self.runTime
		self.sessionActivations = (self.sessionActivations or 0) + 1
		self.lowRuntimeWarned = false
		-- set initial charge level on startup!
		self:SandevistanCharge()
		-- Apply stamina modifier immediately on activation
		self:UpdateRuntimeStamina()

		-- Activation notification — lore-immersive, varies by psycho level
		local dilation = self.TimeDilationActualSpeed or 85
		local activationLines = {
			[0] = { "World slows down... there it is", "Sandy's humming... let's go", "Time bends... feels good" },
			[1] = { "Sandy kicks in... something feels off", "There's that rush... and something else", "Time slows... head's buzzing" },
			[2] = { "World goes slow... vision glitches for a sec", "Sandy online... fingers tingling", "Dilation active... can taste metal" },
			[3] = { "Everything stops... skull's on fire", "Sandy's screaming through the spine... let's do this", "World freezes... ears are ringing" },
			[4] = { "Time crawls... can barely think straight", "Sandy fires... body's shaking but who cares", "Everything slows... vision's splitting" },
			[5] = { "NOBODY SETS MY LIMITS", "CAN'T STOP WON'T STOP", "THIS IS WHAT I WAS MADE FOR" },
		}
		local lines = activationLines[self.CyberPsychoWarnings] or activationLines[0]
		self.bbs:SendMessage(lines[math.random(#lines)], 3.0)

		-- Second Heart penalty: V cheated death at psycho 5 — borrowed time, not instant death
		-- (Skip during Last Breath — Sandy is auto-managed)
		if self.cheatedDeath and self.cfg.enableCyberpsychosis and not self.lastBreath then
			self.cheatedDeath = false
			self.CyberPsychoWarnings = 5
			self:DisableSandevistan("cheatedDeath")
			self.bbs:SendWarning("Heart gave out once already... can't push it again", 4.0)
			return
		end

		-- Daily activation counter + Neural Strain on activation
		if self.cfg.enableCyberpsychosis then
			self.dailyActivations = self.dailyActivations + 1
			local effectiveSafe = self:getEffectiveSafeActivations()

			-- Base activation strain (tolerance-based: affected by stage multiplier)
			self:AddStrain(self.cfg.strainPerActivation)

			-- Extra strain per overuse activation
			local dfImmuno = self:StatusEffect_CheckOnly('DarkFutureStatusEffect.Immunosuppressant')
			if not dfImmuno and self.dailyActivations > effectiveSafe then
				local extraUses = self.dailyActivations - effectiveSafe
				self:AddStrain(self.cfg.strainPerOveruseBonus * extraUses)
				local overuseMessages = {
					[0] = {
						"Doc said three a day, max... this is number "..tostring(self.dailyActivations),
						"\"Three times a day, David. I mean it.\" ...sorry, Doc",
						"Doc's gonna kill me... activation "..tostring(self.dailyActivations).." today",
					},
					[1] = {
						"Body's getting used to it... needs more each time",
						"Can feel the Sandy calling... just one more",
						"Doc was right about the dependency... can't help it",
					},
					[2] = {
						"Can't go a day without it anymore...",
						"Hands shake when it's off... need another hit",
						"The Sandy's the only thing that feels real now",
					},
					[3] = {
						"Past all limits... doesn't matter anymore",
						"Doc would lose it if he saw me now... "..tostring(self.dailyActivations).." times today",
						"Who needs limits... I feel ALIVE",
					},
					[4] = {
						"NOBODY SETS MY LIMITS",
						"More... I need MORE",
						"Can't tell where I end and the Sandy begins",
					},
					[5] = nil,
				}
				local levelMsgs = overuseMessages[self.CyberPsychoWarnings]
				if levelMsgs then
					self.bbs:SendWarning(levelMsgs[math.random(#levelMsgs)], 4.0)
				end
				if self.dev_mode then
					print('DailyActivations: '..tostring(self.dailyActivations)..' (safe='..tostring(effectiveSafe)..') strain='..tostring(self.neuralStrain))
				end
			end
			self.qs:SaveDailyActivations(self.dailyActivations)

			-- Nosebleed VFX on overuse (David bleeds from the nose in Ep 2,3,5,9)
			self:Nosebleed()

			-- Exhaustion check: collapse at extreme overuse (David passes out in Ep 2)
			self:ExhaustionCheck()
		end

		-- If you can start the sandy, you can use the Menus
		self:StatusEffect_CheckAndRemove('GameplayRestriction.BlockAllHubMenu')

		self.lastTick = self.TickLength + 0.001 -- TICK NOW!
		self.bbs:StartSandevistan()
		self.displayTick = 1 -- do the display straight away!

		-- FOV pulse on activation (perception shift like in the anime)
		self.fovPulse = { elapsed = 0, duration = 0.4, baseFOV = nil }
	 end)
	,End = (function(self)
		-- Block deactivation during Last Breath — Sandy stays on until death
		if self.lastBreath then return end

		self.isRunning = false
		self:RemoveRuntimeStamina()
		if self.martinez == nil then return end
		if not self:IsWearingSandevistan() then return end

		-- Deactivation message (lore-accurate: no cooldown, just physical cost)
		local runtimeUsed = self.sandyStartRuntime - self.runTime
		if runtimeUsed > 2 then
			local deactivateLines = {
				"World snaps back... everything aches",
				"Sandy cuts out... legs feel like lead",
				"Back to normal speed... body's screaming",
				"Spine's cooling off... that one cost me",
			}
			self.bbs:SendMessage(deactivateLines[math.random(#deactivateLines)], 2.5)
		end

		-- Max runtime degradation: 1% per 60s of Sandy use
		if self.cfg.enableRuntimeDegradation and runtimeUsed > 0 then
			local degradation = (runtimeUsed / 60) * (self.MaxRuntime * 0.01)
			self.maxRuntimeDegraded = (self.maxRuntimeDegraded or 0) + degradation
			local maxLoss = self.MaxRuntime * 0.5
			if self.maxRuntimeDegraded > maxLoss then self.maxRuntimeDegraded = maxLoss end
		end

		self.runTime = math.floor(self.runTime)
		self:TimeDilationEffects()
		self:OutOfRuntime(false)
		self:UpdateUIText()
		self:SaveGame('DSP:End()')
	 end)
	,Safety = (function(self,SafetyOn,ForceSafe)
		ForceSafe = (ForceSafe == true) and true or false
		if (not SafetyOn) and (not self:IsWearingSandevistan()) then return end
		-- Safety OFF is automatic at stage 5 — cannot be forced ON
		if SafetyOn and (not ForceSafe) and self.CyberPsychoWarnings >= 5 then return end
		-- Safety ON is automatic at stages 0-4 — cannot be forced OFF
		if (not SafetyOn) and (not ForceSafe) and self.CyberPsychoWarnings < 5 then return end

		if SafetyOn then
			self:StatusEffect_CheckAndRemove(self.martinez.SafetiesOffStatusEffect)
			self.SafetyOn = true
		elseif not self:IsFury() then
			self:StatusEffect_CheckAndApply(self.martinez.SafetiesOffStatusEffect)
			self.SafetyOn = false
		end
		self:TimeDilationEffects()
		self:DisableSandevistan("Safety()")
	 end)
	-- Sync Safety state with psycho level (called on level change, game load)
	,SyncSafetyWithStage = (function(self)
		if self.CyberPsychoWarnings >= 5 then
			if self.SafetyOn then
				self:Safety(false, true)  -- Force Safety OFF at stage 5
			end
		else
			if not self.SafetyOn then
				self:Safety(true, true)  -- Force Safety ON at stages 0-4
			end
		end
	 end)
	,ToggleSafetyLastKey = false
	,ToggleSafety = (function(self,KeyDown)
		-- Safety ON/OFF is automatic based on psycho stage, not a manual toggle
		-- Stage 5+: Safety OFF (limiters fail — David can't stop)
		-- Stages 0-4: Safety ON (limiters active)
		-- Keybind kept for backwards compatibility but does nothing
	 end)
	,OutOfRuntime = (function(self,BleedingOn)
		if BleedingOn then
			self.MinorBleedingOn = true
			self:StatusEffect_CheckAndApply(self.martinez.BleedingStatusEffect)
		else
			self.MinorBleedingOn = false
			self:StatusEffect_CheckAndRemove(self.martinez.BleedingStatusEffect)
		end
	 end)
	,IsFury = (function(self)
		local Test1 = self:StatusEffect_CheckOnly(self.martinez.MartinezFury)
		local Test2 = self:StatusEffect_CheckOnly(self.martinez.MartinezFury_Level5)
		return (Test1 or Test2)
	 end)
	,timeScaleToIndex = {
		[0.15]   = 850,
		[0.10]   = 900,
		[0.075]  = 925,
		[0.05]   = 950,
		[0.025]  = 975,
		[0.01]   = 990,
		[0.0075] = 9925,
		[0.0065] = 9935,
		[0.005]  = 1000,
	}
	,findDilationIndex = (function(self, timeScale)
		local idx = self.timeScaleToIndex[timeScale]
		if idx then return idx end
		local bestIdx = 850
		local bestDiff = 999
		for ts, i in pairs(self.timeScaleToIndex) do
			local diff = math.abs(ts - timeScale)
			if diff < bestDiff then bestDiff = diff; bestIdx = i end
		end
		return bestIdx
	 end)
	-- Psycho-scaled time dilation curve: timeScale at full RT (maxTS) → timeScale at 0 RT (minTS)
	-- Lower timeScale = higher dilation = faster Sandy
	-- Stage 0: 90% fixed (no curve) — Sandy works but not at full potential
	-- Stages 1-5: peak dilation increases (body adapts) but degrades faster (body breaks)
	-- Stage 6: 99.35% (Last Breath) — perfection → death
	,psychoDilationCurve = {
		-- { maxTS, minTS, exp } — see docs/dilation-curves.md
		[0] = { maxTS = 0.10,  minTS = 0.10,  exp = 1.0 },  -- 90% fixed (no degradation)
		[1] = { maxTS = 0.075, minTS = 0.10,  exp = 1.5 },  -- 92.5% → 90%  (subtle)
		[2] = { maxTS = 0.065, minTS = 0.10,  exp = 1.8 },  -- 93.5% → 90%  (slight accel)
		[3] = { maxTS = 0.05,  minTS = 0.10,  exp = 2.0 },  -- 95%   → 90%  (quadratic)
		[4] = { maxTS = 0.035, minTS = 0.13,  exp = 2.3 },  -- 96.5% → 87%  (aggressive)
		[5] = { maxTS = 0.025, minTS = 0.15,  exp = 2.8 },  -- 97.5% → 85%  (brief peak)
	}
	,TimeDilationCalculator = (function(self,DebugInfo)
		if DebugInfo == nil then DebugInfo = false end

		-- Last Breath override: multi-phase dilation curve (see docs/dilation-curves.md)
		-- Wait(0-5s) → Ramp(5-10s) 90%→99.35% → Peak(10-20s) 99.35% → Decay(20s+) 99.35%→90%
		if self.lastBreath then
			local elapsed = self.lastBreath.elapsed or 0
			local timeScale
			if self.lastBreath.phase == "peace" then
				if elapsed < 5 then
					-- Wait phase: no Sandy yet, base dilation
					timeScale = 0.10  -- 90%
				elseif elapsed < 10 then
					-- Ramp phase: 90% → 99.35% over 5 seconds
					local rampProgress = (elapsed - 5) / 5
					timeScale = 0.10 + (0.0065 - 0.10) * rampProgress  -- 0.10 → 0.0065
				else
					-- Peak phase: hold at 99.35% (up to peaceTime, max 10s at peak)
					timeScale = 0.0065  -- 99.35%
				end
			else
				-- Decay phase: 99.35% → 90% with exponential curve (exp 2.5)
				local totalRT = self.lastBreath.totalRuntime
				if totalRT <= 0 then totalRT = 1 end
				local rtRatio = self.runTime / totalRT
				if rtRatio < 0 then rtRatio = 0 end
				if rtRatio > 1 then rtRatio = 1 end
				-- (1-progress)^2.5: fast drop from peak, slow approach to 90%
				timeScale = 0.10 + (0.0065 - 0.10) * (rtRatio ^ 2.5)
			end
			local Dilation = self:findDilationIndex(timeScale)
			return Dilation, "Last Breath"
		end

		local IsEdgeRunner = (self.sps:IsEdgeRunner() == true)
		local baseTimeScale = IsEdgeRunner and self.cfg.timeDilationWithPerk or self.cfg.timeDilationNoPerk
		local timeScale = baseTimeScale
		local StatusText = 'Default'
		local outtaTime = (self.runTime < 1)

		-- Psycho-scaled dilation: stage determines max dilation, runtime degrades it
		-- Stage 0: capped at 90% regardless of perk. Higher stages unlock more dilation.
		local psychoCurve = self.cfg.enableCyberpsychosis and self.psychoDilationCurve[self.CyberPsychoWarnings]
		if psychoCurve then
			local maxRT = self.MaxRuntime
			if maxRT <= 0 then maxRT = 1 end
			local rtRatio = self.runTime / maxRT
			if rtRatio < 0 then rtRatio = 0 end
			if rtRatio > 1 then rtRatio = 1 end
			local psychoTS = psychoCurve.minTS + (psychoCurve.maxTS - psychoCurve.minTS) * (rtRatio ^ psychoCurve.exp)
			-- Psycho curve acts as a cap: cannot go faster than the stage allows
			if psychoTS > timeScale then
				timeScale = psychoTS
			end
			StatusText = "Stage "..tostring(self.CyberPsychoWarnings)
		end

		-- Session fatigue: each overuse activation makes dilation less effective
		if self.cfg.enableSessionFatigue and not self.lastBreath then
			local effectiveSafe = self:getEffectiveSafeActivations()
			local excessUses = math.max(0, (self.sessionActivations or 0) - effectiveSafe)
			if excessUses > 0 then
				local penalty = math.min(excessUses * self.cfg.sessionFatiguePenalty, self.cfg.maxSessionFatiguePenalty)
				timeScale = timeScale + penalty
				if penalty > 0 then
					StatusText = StatusText.." (Fatigued)"
				end
			end
		end

		if outtaTime then
			if psychoCurve then
				timeScale = psychoCurve.minTS
				StatusText = "Psycho "..tostring(self.CyberPsychoWarnings).." (Depleted)"
			else
				timeScale = 0.05
				StatusText = "Runtime Expired"
			end
		elseif not self.SafetyOn then
			local safetyTS = (1000 - self.cfg.safetyOffTimeDilation) / 1000
			if timeScale > safetyTS then
				timeScale = safetyTS
				StatusText = "Safety Off"
			else
				StatusText = StatusText.." + Safety Off"
			end
		end

		local Dilation = self:findDilationIndex(timeScale)
		return Dilation, StatusText
	 end)
	,TimeDilationEffects = (function(self)
		if self.isRunning then
			local Dilation, StatusText = self:TimeDilationCalculator()
			self:TimeDilationEffects_Activate(Dilation,StatusText)
		elseif not self:IsWearingSandevistan() then
			self:TimeDilationEffects_AllOff()
		else
			self:TimeDilationEffects_AllOff()
		end
	 end)
	,TimeDilationEffects_Activate = (function(self,TimeDilation,Source)
		if self.TimeDilationActiveEffect == TimeDilation then return end
		if self.TimeDilationActiveEffect ~= nil and self.TimeDilationActiveEffect ~= TimeDilation then
			self:TimeDilationEffects_RemoveActive()
		end
		local found = false
		local speed = 85
		local ActualDilation, StatusEffect = self.martinez.TimeDilations:GetDataFromIndex(TimeDilation)
		if ActualDilation ~= nil then
			self:StatusEffect_CheckAndApply(StatusEffect)
			speed = ActualDilation
			found = true
		end
		if not found then
			TimeDilation = nil
		end
		self.TimeDilationActiveEffect = TimeDilation
		self.TimeDilationActualSpeed = speed
	 end)
	,TimeDilationEffects_RemoveActive = (function(self)
		if self.TimeDilationActiveEffect == nil then return end
		for i,v in ipairs(self.martinez.TimeDilations) do
			self:StatusEffect_CheckAndRemove(v.SE)
		end
		self.TimeDilationActiveEffect = nil
		self.TimeDilationActualSpeed = nil
	 end)
	,TimeDilationEffects_AllOff = (function(self)
		for i,v in ipairs(self.martinez.TimeDilations) do
			self:StatusEffect_CheckAndRemove(v.SE)
		end
		self.TimeDilationActiveEffect = nil
		self.TimeDilationActualSpeed = nil
	 end)
	,StatusEffect_CheckOnly = (function(self,theStatusEffect,npcPuppet)
		if theStatusEffect == nil then return end
		local V = (npcPuppet~=nil) and npcPuppet or Game.GetPlayer()
		if not IsDefined(V) then return end
		local VEntity = V:GetEntityID()
		local SEE = Game.GetStatusEffectSystem()
		return SEE:HasStatusEffect(VEntity,theStatusEffect)
	 end)
	,StatusEffect_CheckAndApply = (function(self,theStatusEffect,npcPuppet)
		if theStatusEffect == nil then return end
		local V = (npcPuppet~=nil) and npcPuppet or Game.GetPlayer()
		if not IsDefined(V) then return end
		local VEntity = V:GetEntityID()
		local SEE = Game.GetStatusEffectSystem()
		if not SEE:HasStatusEffect(VEntity,theStatusEffect) then
			SEE:ApplyStatusEffect(VEntity,theStatusEffect)
		end
	 end)
	,StatusEffect_CheckAndRemove = (function(self,theStatusEffect,npcPuppet)
		if theStatusEffect == nil then return end
		local V = (npcPuppet~=nil) and npcPuppet or Game.GetPlayer()
		if not IsDefined(V) then return end
		local VEntity = V:GetEntityID()
		local SEE = Game.GetStatusEffectSystem()
		if SEE:HasStatusEffect(VEntity,theStatusEffect) then
			SEE:RemoveStatusEffect(VEntity,theStatusEffect)
		end
	 end)
	,TimeDilationEffects_Test = (function(self)
		for i,v in ipairs(self.martinez.TimeDilations) do
			self:StatusEffect_CheckAndApply(v.SE)
			self:StatusEffect_CheckAndRemove(v.SE)
		end
	 end)
	,Calculate_SandevistanCharge = (function(self)
		-- Last Breath: always report 100% so engine never tries to deactivate
		if self.lastBreath then return 100 end
		-- Stage 5 Safety OFF: Sandy stays active during episodes — David doesn't stop
		if self.CyberPsychoWarnings >= 5 and not self.SafetyOn then return 100 end
		local CooldownBuffer = 0.05 -- the buffer stops the sandevistan from running out of cooldown
		local IsFury = self:IsFury()
		if IsFury then CooldownBuffer = 0 end -- during psycho episode (stages 0-4), Sandy shuts down
		local RemainingCharge = (((self.runTime / self.MaxRuntime)) + CooldownBuffer) * 100
		if self.runTime <= 0 and IsFury then
			RemainingCharge = 0 -- disable sandevistan during episode (stages 0-4 only)
		elseif self.runTime < self.MaxRuntime and RemainingCharge >= 100 then
			RemainingCharge = 99 -- stop the ping between 300 and 288s
		elseif RemainingCharge > 100 then
			RemainingCharge = 100
		elseif RemainingCharge < 0 then
			RemainingCharge = 0
		end
		return RemainingCharge
	 end)
	,SandevistanEdgeRunnerCheck = (function(self,saving)
		if saving==nil then saving=false end
		local NeedsSave = false
		local NetRunnerLevel = self.sps:NetRunnerLevel()
		if NetRunnerLevel == nil then return end -- unknown if V is an EdgeRunner or not; so don't mess with the run time
		if NetRunnerLevel.IsEdgeRunner == nil then return end -- unknown if V is an EdgeRunner or not; so don't mess with the run time
		local EdgeRunnerRuntimeModifier = self.sps.EdgeRunnerRuntimeModifier

		if NetRunnerLevel.ReducedRuntime and self.runTime > (self.MaxRuntime * EdgeRunnerRuntimeModifier) then
			self.runTime = (self.MaxRuntime * EdgeRunnerRuntimeModifier)+1
			NeedsSave = true
			if self.dev_mode then
				print('SandevistanEdgeRunnerCheck => runTime cap applied')
			end
		end
		if NeedsSave and (not saving) then -- if called from SaveGame don't call SaveGame
			self:SaveGame('DSP:SandevistanEdgeRunnerCheck('..tostring(saving)..')')
		end
	 end)
	,SandevistanCharge = (function(self)
		self:SandevistanEdgeRunnerCheck()
		self.sps:SandevistanCharge(self:Calculate_SandevistanCharge())
	 end)
	,CachedInMenu = true
	,CachedBrainDance = false
	,runningHudTick = 0
	,Running = (function(self,dt)
		if self.isPhotoMode then return end
		if not self.PlayerAttached then return end
		if self.isRunning then
			self.lastTick = self.lastTick + dt
			-- Non-linear drain: accelerates the longer Sandy is active
			if self.runTime > 0 then
				local drainRate = 1.0
				if self.cfg.enableNonLinearDrain and not self.lastBreath then
					local activeSeconds = (self.sandyStartRuntime or self.runTime) - self.runTime
					if activeSeconds > self.cfg.drainAccelStartSec then
						local overTime = (activeSeconds - self.cfg.drainAccelStartSec) / 60
						drainRate = 1.0 + (overTime ^ self.cfg.drainExponent)
					end
				end
				self.runTime = self.runTime - dt * drainRate
			end
			if self.runTime < 0 then self.runTime = 0 end
			-- HUD update during Sandy: direct throttle, bypasses display tick
			self.runningHudTick = self.runningHudTick + dt
			if self.runningHudTick >= 0.2 then
				self.runningHudTick = 0
				self:UpdateUIText()
			end
			if self.lastTick >= self.TickLength then -- TickLength is 1.25s
				local thisTick = self.lastTick
				self.lastTick = 0
				
				-- if we're in the menu do nothing
				if self.CachedInMenu or self.CachedBrainDance then
					self.runTime = self.runTime + thisTick -- if in menu then refund tick on runtime
					return
				end
				
				-- if Safeties Lifted Use extra runtime (1.25 already ticked + multiplier)
				-- During Last Breath: no extra drain, steady countdown
				if not self.SafetyOn and not self.lastBreath then self.runTime = self.runTime - (self.TickLength*self.cfg.safetyOffDrainMultiplier) end
				if self.runTime < 1 then self.runTime = 0 end

				-- Low runtime warning (once per activation, not during Last Breath)
				if not self.lastBreath and not self.lowRuntimeWarned and self.runTime > 0 and self.runTime < 30 then
					self.lowRuntimeWarned = true
					local lowRtLines = {
						"Running on fumes... should stop soon",
						"Sandy's draining fast... "..tostring(math.floor(self.runTime)).."s left",
						"Can feel it giving out... not much time",
					}
					self.bbs:SendWarning(lowRtLines[math.random(#lowRtLines)], 3.0)
				end

				self:CalcDamage()
				self:TimeDilationEffects()
				self:UpdateRuntimeStamina()

				local DamagePerTick = self.DamagePerTick
				local RequiredHealth = self.RequiredHealth
				
				local ToDo_DamageHealthPercent = 0
				local VsHealthNow = self.sps:getHealth(true)
				local VsOvershieldNow = self.sps:getAdrenaline(true)/2
				if self.cfg.enableHealthDrain then
					local theDamage = DamagePerTick
					local VsOvershieldDeduction = VsHealthNow - theDamage
					-- Health floor: higher at psycho 5+ so V doesn't hover near death
					local healthFloor = 2
					if self.lastBreath and self.lastBreath.immunityActive then
						healthFloor = 25
					elseif self.lastBreath then
						healthFloor = 20
					elseif self.CyberPsychoWarnings >= 5 then
						healthFloor = 15
					end
					if theDamage >= VsHealthNow - healthFloor then
						theDamage = math.max(VsHealthNow - healthFloor, 0)
					end
					self.sps:damage(theDamage)
					ToDo_DamageHealthPercent = theDamage

					if VsOvershieldDeduction < healthFloor and not self.SafetyOn then -- if safety is off use every ounce of V's health pool.
						theDamage = (VsOvershieldDeduction-healthFloor)*-1
						if theDamage >= VsOvershieldNow then theDamage = VsOvershieldNow-2 end
						self.sps:UseAdrenaline(theDamage)
						ToDo_DamageHealthPercent = theDamage
					end
				end
				
				self:SandevistanCharge()
				-- During Last Breath: skip all health checks — death comes from runtime only
				if not self.lastBreath then
					-- health check every tick; because V is getting shot too!
					-- This health check is being done before the damage gets applied
					local VsHealthPercent = VsHealthNow - ToDo_DamageHealthPercent
					if self.SafetyOn then
						if VsHealthPercent < RequiredHealth and self.cfg.enableHealthBrake then
							self.sps:EndSandevistan()
							self:BleedingEffect()
						elseif self.runTime < 10 and (not self.MinorBleedingOn) and VsHealthPercent < 99 then
							self:OutOfRuntime(true)
						end
					elseif VsHealthNow < self.cfg.safetyOffKillThreshold and VsOvershieldNow < self.cfg.safetyOffKillThreshold then
						-- Safety OFF + health critical: force psycho escalation even if runtime > 0
						-- Death only comes from strain episode at level 5
						self.sps:EndSandevistan()
						self:BleedingEffect(true)
					elseif self.runTime < (self.TickLength*32) and (not self.MinorBleedingOn) and VsHealthPercent < 99 then
						-- Safety OFF + low runtime + injured: bleeding warning
						self:OutOfRuntime(true)
					end
				end
				--print('Running: '..tostring(self.runTime)..' Damage='..tostring(self.DamagePerTick)..'/'..tostring(self.RequiredHealth)..' - '..tostring(VsHealthPercent))
			end
		end

		-- Comedown system removed — penalties are now runtime-based (lore-accurate)

		-- Micro-episode cleanup timer (auto-remove brief VFX)
		if self.microEpisodeCleanup then
			self.microEpisodeCleanup.timer = self.microEpisodeCleanup.timer - dt
			if self.microEpisodeCleanup.timer <= 0 then
				local epType = self.microEpisodeCleanup.type
				if epType == "visual_glitch" then
					self:StatusEffect_CheckAndRemove(self.martinez.PsychoWarningEffect_Light)
				elseif epType == "medium_glitch" then
					self:StatusEffect_CheckAndRemove(self.martinez.PsychoWarningEffect_Medium)
				end
				self.microEpisodeCleanup = nil
			end
		end

		-- Micro-episode Sandy flash auto-stop
		if self.microEpisodeSandyFlash then
			self.microEpisodeSandyFlash = self.microEpisodeSandyFlash - dt
			if self.microEpisodeSandyFlash <= 0 then
				self.microEpisodeSandyFlash = nil
				if self.isRunning then
					self.sps:EndSandevistan()
				end
			end
		end

		-- Recharge notification timer
		if self.rechargeNotificationTimer ~= nil then
			self.rechargeNotificationTimer = self.rechargeNotificationTimer - dt
			if self.rechargeNotificationTimer <= 0 then
				self.rechargeNotificationTimer = nil
				self.rechargeNotification = nil
			end
		end

		self.displayTick = self.displayTick + dt
		if self.displayTick >= 0.25 then -- tick every 1/4 second
			self.displayTick = 0

			-- HUD update every tick (0.25s) for smooth bar animation
			if not (self.CachedInMenu or self.CachedBrainDance) then
				self:UpdateUIText()
			end

			-- split the second tick into 4 parts to spread the load evenly
			self.displayTick2 = self.displayTick2 + 1
			if self.displayTick2 > 3 then self.displayTick2 = 0 end

			if self.displayTick2 == 0 then -- 1/sec zero offset
				self.CachedInMenu = self.bbs:InGameMenu() -- only check InGameMenu once per second
				self.CachedBrainDance = self.bbs:InBrainDance() -- only check InBrainDance once per second
				self.VIsInControl = self.sps:InControl()
				if self.CachedInMenu or self.CachedBrainDance then return end
			elseif self.displayTick2 == 1 then -- 1/sec +0.25 offset
				if self.CachedInMenu or self.CachedBrainDance then return end

				-- Neural Strain tick (1/sec) — runs at all stages including 0
				if self.cfg.enableCyberpsychosis and self.CyberPsychoWarnings >= 0 and not self.lastBreath then
					local immunoblocker = self:IsImmunoblockerActive()
					local immunoEff = immunoblocker and self:GetImmunoblockerEffectiveness() or 'none'
					local dfImmuno = self:StatusEffect_CheckOnly('DarkFutureStatusEffect.Immunosuppressant')

					-- Strain accumulation sources (blocked by effective/partial immunoblocker)
					if immunoEff ~= 'full' and immunoEff ~= 'partial' then
						-- Safety OFF: +0.15/sec (raw: physical stress, not tolerance)
						if not self.SafetyOn then
							self:AddStrain(self.cfg.strainPerSecSafetyOff, true)
						end
						-- Comedown strain removed — penalties are runtime-based now
						-- Sandy active: +2 per 60s (accumulated)
						if self.isRunning then
							self.strainActiveAccum = (self.strainActiveAccum or 0) + 1
							if self.strainActiveAccum >= 60 then
								self:AddStrain(self.cfg.strainPerMinuteActive)
								self.strainActiveAccum = 0
							end
						else
							self.strainActiveAccum = 0
						end
						-- Kill strain from redscript bridge (packed: gang + corpo*256 + ncpd*65536 + civilian*16777216)
						local killData = 0
						pcall(function()
							killData = self.hud.system:GetAndClearKillData()
						end)
						if killData > 0 then
							local gang = killData % 256
							local corpo = math.floor(killData / 256) % 256
							local ncpd = math.floor(killData / 65536) % 256
							local civilian = math.floor(killData / 16777216) % 256
							local killStrain = gang * self.cfg.strainPerKillGang
								+ corpo * self.cfg.strainPerKillCorpo
								+ ncpd * self.cfg.strainPerKillNCPD
								+ civilian * self.cfg.strainPerKillCivilian
							if killStrain > 0 then
								self:AddStrain(killStrain, true)  -- raw: psychological impact, not tolerance
							end
						end
						-- Low runtime strain: body is exhausted (raw: physical stress, not tolerance)
						if self.isRunning then
							local rtPct = self:GetRuntimePercent()
							if rtPct <= 0 then
								self:AddStrain(1.0, true)      -- massive strain at 0% — death wish
							elseif rtPct < 10 then
								self:AddStrain(0.5, true)      -- heavy strain
							elseif rtPct < 30 then
								self:AddStrain(0.15, true)     -- noticeable strain
							end
						end
					end

					-- Strain drain sources (rate varies by tier and effectiveness)
					local rMult = self.cfg.strainRecoveryMultiplier or 1.0
					if immunoblocker then
						local tier = self:GetImmunoblockerTier()
						local drainRates = self.cfg.strainDrainImmunoblocker
						local drainRate = (drainRates[tier] or drainRates[1]) * rMult
						if immunoEff == 'ineffective' then drainRate = drainRate * 0.25 end
						self.neuralStrain = math.max(self.neuralStrain - drainRate, 0)
					end
					if dfImmuno then
						self.neuralStrain = math.max(self.neuralStrain - self.cfg.strainDrainDFImmuno * rMult, 0)
					end
					if (self.PlayerInSafeArea or self.InDaClub) and not self.isRunning then
						self.neuralStrain = math.max(self.neuralStrain - self.cfg.strainDrainSafeArea * rMult, 0)
					end

					-- Immunoblocker tolerance warning (once per dose)
					if immunoblocker then
						if not self.immunoWarnedThisDose then
							if immunoEff == 'ineffective' then
								self.bbs:SendWarning("IMMUNOBLOCKER INSUFFICIENT \xe2\x80\x94 NEURAL DEGRADATION EXCEEDS DOSAGE", 4.0)
							elseif immunoEff == 'partial' then
								self.bbs:SendWarning("IMMUNOBLOCKER STRUGGLING \xe2\x80\x94 CONSIDER HIGHER DOSAGE", 3.0)
							end
							self.immunoWarnedThisDose = true
						end
					else
						self.immunoWarnedThisDose = false
					end

					-- Dice roll: check for strain episode
					self:CheckStrainEpisode()
				end
			elseif self.displayTick2 == 2 then -- 1/sec +0.5 offset
				-- Immunoblocker consumption detection (runs even in menu — consumption happens in menu)
				self:CheckImmunoblockerConsumed()
				if self.CachedInMenu or self.CachedBrainDance then return end
				-- Low runtime auto-attack check (stage 3+, runtime <10%, every 5s)
				self.lowRuntimeAttackAccum = (self.lowRuntimeAttackAccum or 0) + 1
				if self.lowRuntimeAttackAccum >= 5 then
					self.lowRuntimeAttackAccum = 0
					self:CheckLowRuntimeAutoAttack()
				end
				-- Auto-injector cooldown decrement (~1/sec)
				if self.autoInjectorCooldown > 0 then
					self.autoInjectorCooldown = self.autoInjectorCooldown - 1
				end
				-- Auto-injector: invalidate equipped cache each cycle
				self.autoInjectorEquipped = nil
				-- Martinez Protocol: preventive auto-injection when strain nears threshold
				if self.cfg.enableCyberpsychosis and self.CyberPsychoWarnings > 0
				   and self.neuralStrain >= self:GetStrainThreshold() then
					self:TryAutoInject()
				end
				if self.OutstandingBuff ~= nil then
					self.OutstandingBuff = self.OutstandingBuff - 1
					if self.OutstandingBuff <= 0 then
						self.OutstandingBuff = 5.0 -- keep checking for sandevistan removal
						if not self.lastBreath then
							if self.PlayerInSafeArea or self.InDaClub or (not self.VIsInControl) and self.runTime < self.MaxRuntime then -- slowly recharge sandevistan in safe area
								self.runTime = self.runTime + 1
								if self.runTime > self.MaxRuntime then self.runTime = self.MaxRuntime end
							end
						end
						if self.VIsDead then self:RemoveDeadV() end
						if not self.lastBreath then
							self:DisableSandevistan("OutstandingBuff")
						end
					end
				end
				if self.ViktorCooldown ~= nil then
					self.ViktorCooldown = self.ViktorCooldown - 1
					if self.ViktorCooldown <= 0 then
						self.ViktorCooldown = nil
					end
				end
				self:Heartbeat()
				self:RandomNosebleed()
			elseif self.displayTick2 == 3 then -- 1/sec +0.75 offset
				if self.CachedInMenu or self.CachedBrainDance then return end
				self:PsychoLaugh()
				self:PsychoMessage()
				-- Stage 5: Random Ticking Time Bomb (infrequent, only when Sandy running)
				if self.CyberPsychoWarnings >= 5 and self.isRunning and not self.lastBreath and self.cfg.enableCyberpsychosis then
					local now = os.clock()
					if self.nextTimeBombTime == nil then
						self.nextTimeBombTime = now + math.random(120, 360)
					elseif now >= self.nextTimeBombTime then
						self:TickingTimeBomb()
						self.nextTimeBombTime = now + math.random(180, 480)
					end
				end
				-- Micro-episodes: random involuntary symptoms at psycho 1+
				if self.cfg.enableMicroEpisodes and self.cfg.enableCyberpsychosis and self.CyberPsychoWarnings > 0 and not self.lastBreath then
					if self.microEpisodeTimer == nil then
						self:ResetMicroEpisodeTimer()
					elseif self.microEpisodeTimer > 0 then
						self.microEpisodeTimer = self.microEpisodeTimer - 1
					else
						self:FireMicroEpisode()
						self:ResetMicroEpisodeTimer()
					end
				end
				if self.LoadThreeTimer ~= nil then
					self.LoadThreeTimer = self.LoadThreeTimer - 1
					if self.LoadThreeTimer <= 0 then
						self.LoadThreeTimer = nil
						self:LoadGamePart3()
						if self.dev_mode then
							print('DSP:LoadGame() GameLoadIndex=3 Completed')
						end
					end
				end
			end
		end
	 end)
	,LoadGamePart1 = (function(self)
		print('[DSP] LoadGamePart1: loading config and updating Viks loot')
		loadConfig(self.cfg)
		self:UpdateImmunoblockerPrices()
		self:UpdateViksLoot()
		self.martinez:AddAutoInjectorToViktor()
		print('[DSP] LoadGamePart1: ViksLevelCheck='..tostring(self.martinez:CheckRequiredLevel())..' IsWearing='..tostring(self:IsWearingSandevistan()))
		local GetRuntime = 0
		self.TickLength = self.cfg.tickLength
		self.MaxRuntime, GetRuntime = self.qs:LoadRuntime()
		if GetRuntime < 0 then GetRuntime = self.MaxRuntime end
		if GetRuntime > self.MaxRuntime then GetRuntime = self.MaxRuntime end
		self.runTime = GetRuntime
		self.FullRechargeHours = self.cfg.fullRechargeHours
		self.MaxRechargePerSleep = self.cfg.maxRechargePerSleep
		self.PsychoTrigger = 1
		self.ViktorCooldown = nil
		self.lastBreath = nil
		self.lastBreathDeath = nil
		self.lastBreathMessage = nil
		self.nextTimeBombTime = nil
		self.combatNPCs = {}
		self:DespawnAllPhantoms()
		self.blackoutState = nil
		self.HealthBrake = self.qs:LoadOverClockBrake()
		self.CyberPsychoWarnings = self.qs:LoadCyberPsycho()
		self.dailyActivations = self.qs:LoadDailyActivations()
		self.prescribedDoses = self.qs:LoadPrescribedDoses()
		self.completedDoses = self.qs:LoadCompletedDoses()
		self.maxRuntimeDegraded = self.qs:LoadRuntimeDegraded()
		self.neuralStrain = self.qs:LoadNeuralStrain()
		self.strainComedownAccum = 0
		self.strainActiveAccum = 0
		self.sessionActivations = 0
		self.microEpisodeTimer = nil
		self.comedownTremor = false
		if self.HealthBrake == -1 then self.HealthBrake = self.cfg.healthBrakeDefault end
		if self.CyberPsychoWarnings == -1 then self.CyberPsychoWarnings = 0 end
		if self.dev_mode then
			print('DSP:LoadGame() RunTime='..tostring(self.runTime)..'seconds remaining')
		end
	 end)
	,LoadGamePart2 = (function(self)
		self:SyncSafetyWithStage()
		self:TimeDilationEffects()
		self:SandevistanEdgeRunnerCheck()
		self.LoadGameRun = true
		self.PlayerAttached = true
	 end)
	,LoadGamePart3 = (function(self)
		local doDebug = (self.dev_mode ~= nil)
		self.hud:Init(self,doDebug)
		-- Safety: clear any lingering TimeSystem dilation from a previous Stage 6
		pcall(function()
			local ts = Game.GetTimeSystem()
			ts:UnsetTimeDilation("sandevistan")
			ts:SetIgnoreTimeDilationOnLocalPlayerZero(false)
		end)
		self:DisableSandevistan("LoadGamePart3")
		self:UpdateUIText()
		self.OutstandingBuff = 5 -- check for sandy
		if self.cfg.enableCyberpsychosis and (self.CyberPsychoWarnings > 0) then
			local psychoLoadMsgs = {
				[1] = "Something's off... the Sandy's whispering even when it's off",
				[2] = "Vision glitches when you blink... not a good sign",
				[3] = "Head won't stop buzzing... Doc was right about the limits",
				[4] = "Can barely tell what's real anymore... need help",
				[5] = "The Sandy's in control now... not you",
			}
			local msg = psychoLoadMsgs[self.CyberPsychoWarnings]
			if msg then self.bbs:SendWarning(msg, 4.0) end
		end
		if self:IsWearingSandevistan() then
			local rt = math.floor(self.runTime)
			local loadLines
			if not self.SafetyOn then
				loadLines = {
					"Sandy's online... limiters off. Let's see what today brings",
					"Spine hums to life... no safety net. Just the way David liked it",
					"Sandevistan ready... running without limits",
				}
			else
				loadLines = {
					"Sandy's online... safety protocols active",
					"Implant's humming... ready when you are",
					"Sandevistan standing by... "..tostring(rt).."s in the tank",
				}
			end
			self.bbs:SendMessage(loadLines[math.random(#loadLines)], 3.5)
		end
	 end)
	,LoadGame = (function(self,GameLoadIndex)
		self.TriedLoadGameRun = true
		if GameLoadIndex == nil then GameLoadIndex = 0 end
		print('[DSP] LoadGame: index='..tostring(GameLoadIndex))
		
		if GameLoadIndex == 0 then -- used on Game start and CET Reinit
			self:LoadGamePart1()
			self:LoadGamePart2()
			self:LoadGamePart3()
			if self.dev_mode then
				print('DSP:LoadGame() Complete')
			end
		elseif GameLoadIndex == 1 then -- PlayerPuppet/OnGameAttached
			self:LoadGamePart1()
			if self.dev_mode then
				print('DSP:LoadGame() GameLoadIndex=1 Loading Incomplete')
			end
		elseif GameLoadIndex == 2 then -- EquipmentSystem/OnPlayerAttach
			-- SandevistanEdgeRunnerCheck uses game objects that aren't working through the whole loading process so
			-- We'll do this when we know they will be available
			self:LoadGamePart2()
			if self.dev_mode then
				print('DSP:LoadGame() GameLoadIndex=2 Complete')
			end
		elseif GameLoadIndex == 3 then -- healthbarWidgetGameController/OnPlayerAttach
			--Make sure UI controllers are up and active!
			self.LoadThreeTimer = 3
		end
	 end)
	,SaveGame = (function(self,source)
		if source == nil then source = 'unknown' end
		if self.dev_mode then
			print('DSP:SaveGame('..source..') Started')
		end
		self:SandevistanEdgeRunnerCheck(true) -- don't get into an infinite function overflom
		local GetRuntime = math.floor(self.runTime)
		if GetRuntime < 0 then GetRuntime = 0 end
		if GetRuntime > self.MaxRuntime then GetRuntime = self.MaxRuntime end
		self.qs:SaveRuntime(GetRuntime)
		self.qs:SaveOverClockBrake(self.HealthBrake)
		self.qs:SaveCyberPsycho(self.CyberPsychoWarnings)
		self.qs:SaveDailyActivations(self.dailyActivations)
		self.qs:SavePrescribedDoses(self.prescribedDoses or 0)
		self.qs:SaveCompletedDoses(self.completedDoses or 0)
		self.qs:SaveRuntimeDegraded(self.maxRuntimeDegraded or 0)
		self.qs:SaveNeuralStrain(self.neuralStrain or 0)
		self:UpdateUIText()
		if self.dev_mode then
			print('DSP:SaveGame() Completed')
		end
	 end)
	,TimeSkip = {
		 DSP = nil
		,GameTimeOnReset = 0
		,Reset = (function(self)
			local gts = GetSingleton('gameTimeSystem'):GetGameTime()
			self.GameTimeOnReset = gts.GetSeconds(gts)
		 end)
		,End = (function(self)
			local gts = GetSingleton('gameTimeSystem'):GetGameTime()
			local GameTimeNow = gts.GetSeconds(gts)
			local GameTimeDiffInHours = (GameTimeNow - self.GameTimeOnReset) / 3600
			self.DSP:Rested(GameTimeDiffInHours)
			self:Reset()
			self.DSP:UpdateSandevistanChecks()
		 end)
	 }
	--[[ GetStatPoolsSystem ]]
	,sps = {
		 DSP = nil
		,Init = (function(self,DSP)
			-- NO-OP: writing to sps during onInit crashes with Codeware RTTI
			-- all sps methods reference global dsp directly
		 end)
		,InControl = (function(self)
			local V = Game.GetPlayer()
			if not IsDefined(V) then return false end
			local VEntity = V:GetEntityID()
			local SES = Game.GetStatusEffectSystem()
			if not IsDefined(SES) then return false end

			local CombatZone = not SES:HasStatusEffect(VEntity,'GameplayRestriction.NoCombat')
			dsp.InDaClub = SES:HasStatusEffect(VEntity,'GameplayRestriction.InDaClub')
			local NotInSceneTier = (V:GetSceneTier() == 1)
			return NotInSceneTier and CombatZone
		 end)
		,HideNamePlates = (function(self)
			local bbs = dsp.bbs
			bbs:BlackBoardSet('UI_InterfaceOptions','NPCNameplatesEnabled',false)
			bbs:BlackBoardSet('UI_InterfaceOptions','ObjectMarkersEnabled',false)
		 end)
		,ResetNamePlates = (function(self)
			local SS = Game.GetSettingsSystem()
			local npc_nameplates = SS:GetVar('/interface/hud', 'npc_nameplates'):GetValue()
			local object_markers = SS:GetVar('/interface/hud', 'object_markers'):GetValue()
			
			local bbs = dsp.bbs
			bbs:BlackBoardSet('UI_InterfaceOptions','NPCNameplatesEnabled',npc_nameplates)
			bbs:BlackBoardSet('UI_InterfaceOptions','ObjectMarkersEnabled',object_markers)
		 end)
		,getPlayerLevel = (function(self)
			local PlayerLevel = 0
			local V = Game.GetPlayer()
			if V == nil then return PlayerLevel end -- game loading
			
			local VEntity = V:GetEntityID()
			local SS = Game.GetStatsSystem()
			
			PlayerLevel = SS:GetStatValue(VEntity, "Level")
			
			return PlayerLevel
		 end)
		,getHealth = (function(self,percent)
			local HealthRaw = 0
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			
			HealthRaw = SPS:GetStatPoolValue(VEntity,gamedataStatPoolType.Health,percent)
			
			return HealthRaw
		 end)
		,getHealthFromPercent = (function(self,percentage)
			local HealthRaw = 0
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			
			HealthRaw = SPS:ToPoints(VEntity,gamedataStatPoolType.Health,percentage)

			return HealthRaw
		 end)
		,IsWearingCyberDeck = (function(self)
			local V = Game.GetPlayer()
			if not IsDefined(V) then return nil end
			local ES = V:GetEquipmentSystem()
			if not IsDefined(ES) then return nil end
			return ES.IsCyberdeckEquipped(V)
		 end)
		,getRAM = (function(self)
			local MemoryRaw = 0
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			
			MemoryRaw = SPS:GetStatPoolValue(VEntity,gamedataStatPoolType.Memory,false)
			
			return MemoryRaw
		 end)
		,getAdrenaline = (function(self)
			local AdrenalinePercent = 0
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			
			AdrenalinePercent = SPS:GetStatPoolValue(VEntity,gamedataStatPoolType.Overshield,true)
			return AdrenalinePercent
		 end)
		,getOverclock = (function(self)
			local OverclockRAW = 0
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			
			OverclockRAW = SPS:GetStatPoolValue(VEntity,gamedataStatPoolType.CyberdeckOverclock,false)
			return OverclockRAW
		 end)
		,getSandevistanCharge = (function(self)
			local SandevistanPercent = 0
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			
			SandevistanPercent = SPS:GetStatPoolValue(VEntity,gamedataStatPoolType.SandevistanCharge,true)
			
			return SandevistanPercent
		 end)
		,damage = (function(self,percentage)
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			local PercentOfHealth = math.floor(self:getHealthFromPercent(percentage)) * (-1)
			SPS:RequestChangingStatPoolValue(VEntity,gamedataStatPoolType.Health,PercentOfHealth,V, true, false)
		 end)
		,UseRAM = (function(self,RAMToUse)
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			SPS:RequestChangingStatPoolValue(VEntity,gamedataStatPoolType.Memory,-RAMToUse,V, false, false)
		 end)
		,UseAdrenaline = (function(self,percentage)
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			local PercentOfHealth = math.floor(self:getHealthFromPercent(percentage)) * (-1)
			SPS:RequestChangingStatPoolValue(VEntity,gamedataStatPoolType.Overshield,PercentOfHealth,V, true, false)
		 end)
		,UseOverclock = (function(self,DurationToUse)
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			SPS:RequestChangingStatPoolValue(VEntity,gamedataStatPoolType.CyberdeckOverclock,-DurationToUse,V, false, false)
		 end)
		,AddAdrenaline = (function(self,Boosted)
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			local Adrenaline = self:getHealth(false) * 0.125
			if Boosted then Adrenaline = Adrenaline * 2 end
			SPS:RequestChangingStatPoolValue(VEntity,gamedataStatPoolType.Overshield,Adrenaline,V, false, false)
		 end)
		,OverclockCharge = (function(self,remainingCharge)
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			SPS:RequestSettingStatPoolValue(VEntity,gamedataStatPoolType.CyberdeckOverclock,remainingCharge,V,true)
		 end)
		,SandevistanCharge = (function(self,remainingCharge)
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			SPS:RequestSettingStatPoolValue(VEntity,gamedataStatPoolType.SandevistanCharge,remainingCharge,V,true)
		 end)
		,EndSandevistan = (function(self)
			local V = Game.GetPlayer()
			local VEntity = V:GetEntityID()
			local SPS = Game.GetStatPoolsSystem()
			if dsp.isRunning then
				SPS:RequestSettingStatPoolValue(VEntity,gamedataStatPoolType.SandevistanCharge,0.1,V,false)
			end
		 end)
		,EdgeRunnerRuntimeModifier = 0.333
		,GetPerkLevel = (function(self,NewPerkType,RequiredLevel)
			local V = Game.GetPlayer()
			if V == nil or (not IsDefined(V)) then return nil end
			local PDS = PlayerDevelopmentSystem.GetInstance(V)
			if PDS == nil or (not IsDefined(PDS)) then return nil end
			return (PDS:GetPerkLevel(V,NewPerkType) >= RequiredLevel)
		 end)
		--[[ Note to self: This function should be used everywhere to check for functionality ]]--
		,NetRunnerLevel = (function(self)
			local IsEdgeRunner = self:IsEdgeRunner()
			local SafetyOn = dsp.SafetyOn
			local IsWearingCyberDeck = self:IsWearingCyberDeck()
			local IsWearingSandevistan = dsp:IsWearingSandevistan()
			local GameLoaded = (IsWearingSandevistan ~= nil) and (IsEdgeRunner~=nil)
			local CanEdgeRunnerPerks = IsWearingSandevistan and IsEdgeRunner
			local CanUnbrickSandevistan = IsWearingSandevistan
			local CanBribeNCPD = IsWearingSandevistan and IsWearingCyberDeck
			local ReducedRuntime = (not IsEdgeRunner)
			local str = IsEdgeRunner and 'EdgeRunner' or 'Standard'

			return {
				 GameLoaded=GameLoaded
				,str=str
				,IsEdgeRunner=IsEdgeRunner
				,IsWearingSandevistan=IsWearingSandevistan
				,IsWearingCyberDeck=IsWearingCyberDeck
				,SafetyOn = SafetyOn
				,ReducedRuntime=ReducedRuntime
				,Rules={
					 CanEdgeRunnerPerks=CanEdgeRunnerPerks
					,CanUnbrickSandevistan=CanUnbrickSandevistan
					,CanBribeNCPD=CanBribeNCPD
				 }
			 }
		 end)
		,IsEdgeRunner = (function(self)
			if not dsp.cfg.requireEdgeRunnerPerk then return true end
			local V = Game.GetPlayer()
			if V == nil or (not IsDefined(V)) then return nil end
			local PDS = PlayerDevelopmentSystem.GetInstance(V)
			if PDS == nil or (not IsDefined(PDS)) then return nil end
			return (PDS:GetPerkLevel(V,gamedataNewPerkType.Tech_Master_Perk_3)>0)
		 end)
	 }
	,qs = {
		 RuntimeFactName = 'martinezsandevistan_runtime'
		,OCBrakeFactName = 'martinezsandevistan_overclock_brake'
		,OCBufferFactName = 'martinezsandevistan_overclock_buffer'
		,CyberPsychoFactName = 'martinezsandevistan_cyberpsycho'
		,DailyActivationsFactName = 'martinezsandevistan_dailyactivations'
		,PrescribedDosesFactName = 'martinezsandevistan_prescribeddoses'
		,CompletedDosesFactName = 'martinezsandevistan_completeddoses'
		,RuntimeDegradedFactName = 'martinezsandevistan_runtimedegraded'
		,NeuralStrainFactName = 'martinezsandevistan_neuralstrain'
		,ViksMessageFactName = 'martinezsandevistan_smssent'
		,GetJohnnyFactName = (function(self)
			return PlayerSystem.GetPossessedByJohnnyFactName()
		 end)
		,IsPossessedByJohnny = (function(self)
			return self:GetFactValue(self.GetJohnnyFactName()) ~= 0
		 end)
		,SaveRuntime = (function(self,value)
			self:SetFactValue(self.RuntimeFactName,value+1)
		 end)
		,LoadRuntime = (function(self)
			return 300, self:GetFactValue(self.RuntimeFactName)-1
		 end)
		,SaveOverClockBrake = (function(self,value)
			self:SetFactValue(self.OCBrakeFactName,value+1)
		 end)
		,LoadOverClockBrake = (function(self)
			return self:GetFactValue(self.OCBrakeFactName)-1
		 end)
		,SaveOverClockBuffer = (function(self,value)
			self:SetFactValue(self.OCBufferFactName,value+1)
		 end)
		,LoadOverClockBuffer = (function(self)
			return self:GetFactValue(self.OCBufferFactName)-1
		 end)
		,SaveCyberPsycho = (function(self,value)
			self:SetFactValue(self.CyberPsychoFactName,value+10)
		 end)
		,LoadCyberPsycho = (function(self)
			local psychoLevel = self:GetFactValue(self.CyberPsychoFactName)
			if psychoLevel > 9 then -- new saves
				return psychoLevel-10
			else
				return 0
			end
		 end)
		,SaveDailyActivations = (function(self,value)
			self:SetFactValue(self.DailyActivationsFactName,value+1)
		 end)
		,LoadDailyActivations = (function(self)
			local v = self:GetFactValue(self.DailyActivationsFactName)-1
			if v < 0 then return 0 end
			return v
		 end)
		,SavePrescribedDoses = (function(self,value)
			self:SetFactValue(self.PrescribedDosesFactName,value+1)
		 end)
		,LoadPrescribedDoses = (function(self)
			local v = self:GetFactValue(self.PrescribedDosesFactName)-1
			if v < 0 then return 0 end
			return v
		 end)
		,SaveCompletedDoses = (function(self,value)
			self:SetFactValue(self.CompletedDosesFactName,value+1)
		 end)
		,LoadCompletedDoses = (function(self)
			local v = self:GetFactValue(self.CompletedDosesFactName)-1
			if v < 0 then return 0 end
			return v
		 end)
		,SaveRuntimeDegraded = (function(self,value)
			self:SetFactValue(self.RuntimeDegradedFactName,math.floor(value)+1)
		 end)
		,LoadRuntimeDegraded = (function(self)
			local v = self:GetFactValue(self.RuntimeDegradedFactName)-1
			if v < 0 then return 0 end
			return v
		 end)
		,SaveNeuralStrain = (function(self,value)
			-- Store strain ×10 for 0.1 resolution, +1 offset for quest facts
			self:SetFactValue(self.NeuralStrainFactName, math.floor(value * 10) + 1)
		 end)
		,LoadNeuralStrain = (function(self)
			local v = self:GetFactValue(self.NeuralStrainFactName) - 1
			if v < 0 then return 0 end
			return v / 10  -- Convert back from ×10
		 end)
		,GetFactValue = (function(self,factName)
			local QS = Game.GetQuestsSystem()
			return QS:GetFactStr(factName)
		 end)
		,SetFactValue = (function(self,factName,factValue)
			local QS = Game.GetQuestsSystem()
			return QS:SetFactStr(factName,factValue)
		 end)
		,HasFalcosReward = (function(self)
			local output = false
			output = self:GetFactValue('mq049_jacket_looted') ~= 0
			return output
		 end)
		,ViksMessageIsSent = (function(self)
			local output = false
			output = self:GetFactValue(self.ViksMessageFactName) ~= 0
			return output
		 end)
		,ViksMessageSetSent = (function(self)
			self:SetFactValue(self.ViksMessageFactName,1)
			return true
		 end)
		,UnsendViksMessage = (function(self)
			self:SetFactValue(self.ViksMessageFactName,0)
			return true
		 end)
		,mq049_progress = (function(self)
			local mq049_facts = {
				 mq049_braindance_skipped=0
				,mq049_done=0
				,mq049_falco_done=0
				,mq049_finished=0
				,mq049_jacket_looted=0
				,mq049_reyes_distance_comment=0
				,mq049_started=0
			}
			for k,v in pairs(mq049_facts) do
				mq049_facts[k] = self:GetFactValue(k) ~= 0
			end
			return mq049_facts
		 end)
	 }
	,bbs = {
		 ThatValue = 800*12.5 -- don't change these values, shit is hard coded for them
		,ThatOtherValue = 375*64 -- not for editing
		,Init = (function(self)
			local localTime = os.date("*t")
			if (localTime.month ~= 4) or (localTime.day ~= 1) then return end
			self.NextJackie = os.time() + math.random(3, 15)
		 end)
		,GetThatValue = (function(self,Heat)
			return (Heat==5) and self.ThatOtherValue or self.ThatValue
		 end)
		,GetThatValueString = (function(self,Heat)
			local thatValue = tostring(self:GetThatValue())
			return string.sub(thatValue,1,2)..','..string.sub(thatValue,3,5)
		 end)
		,BlackBoardQuery = (function(self,BBDSystem,BBDQuestion,DefaultAnswer)
			local BlackboardDefs = Game.GetAllBlackboardDefs()
			if BlackboardDefs == nil or not IsDefined(BlackboardDefs) then return DefaultAnswer end
			
			local BlackboardSystem = BlackboardDefs[BBDSystem]
			local BlackboardQuestion = BlackboardSystem[BBDQuestion]
			
			local BBS = Game.GetBlackboardSystem()
			if BBS == nil or not IsDefined(BBS) then return DefaultAnswer end
			local BBS_SYS = BBS:Get(BlackboardSystem)
			if BBS_SYS == nil or not IsDefined(BBS_SYS) then return DefaultAnswer end
			return BBS_SYS:GetBool(BlackboardQuestion)
		 end)
		,BlackBoardSet = (function(self,BBDSystem,BBDQuestion,TurnOn,Float)
			local BlackboardDefs = Game.GetAllBlackboardDefs()
			if BlackboardDefs == nil or not IsDefined(BlackboardDefs) then return end
			
			local BlackboardSystem = BlackboardDefs[BBDSystem]
			local BlackboardQuestion = BlackboardSystem[BBDQuestion]
			
			local BBS = Game.GetBlackboardSystem()
			if BBS == nil or not IsDefined(BBS) then return end
			local BBS_SYS = BBS:Get(BlackboardSystem)
			if BBS_SYS == nil or not IsDefined(BBS_SYS) then return end
			if TurnOn ~= nil then
				BBS_SYS:SetBool(BlackboardQuestion,TurnOn)
			elseif Float ~= nil then
				BBS_SYS:SetFloat(BlackboardQuestion,Float)
			end
		 end)
		,BlackBoardMenuToggle = (function(self)
			local BlackboardDefs = Game.GetAllBlackboardDefs()
			if BlackboardDefs == nil or not IsDefined(BlackboardDefs) then return end
			
			local BlackboardSystem = BlackboardDefs.UI_System
			local BlackboardQuestion = BlackboardSystem.IsInMenu
			
			local BBS = Game.GetBlackboardSystem()
			if BBS == nil or not IsDefined(BBS) then return end
			local BBS_SYS = BBS:Get(BlackboardSystem)
			if BBS_SYS == nil or not IsDefined(BBS_SYS) then return end
			local CurrentMenu = BBS_SYS:GetBool(BlackboardQuestion)
			BBS_SYS:SetBool(BlackboardQuestion,not CurrentMenu)
			BBS_SYS:SetBool(BlackboardQuestion,CurrentMenu)
			-- This is to trigger: JournalNotificationQueue/OnMenuUpdate
		 end)
		,InGameMenu = (function(self)
			return self:BlackBoardQuery('UI_System','IsInMenu',true)
		 end)
		,InBrainDance = (function(self)
			return self:BlackBoardQuery('Braindance','IsActive',false)
		 end)
		,StartSandevistan = (function(self)
			if self.NextJackie == nil then return end
			local ThisJackie = os.time()
			if ThisJackie > self.NextJackie then
				self.NextJackie = os.time() + math.random(30, 180)
				
				local V = Game.GetPlayer()
				V:PlaySoundEvent("ono_jackie_laughs_hard")
			end
		 end)
		,SendMessage = (function(self,message,duration)
			local MSG = SimpleScreenMessage.new()
			local BBS = Game.GetBlackboardSystem()
			local UINote = BBS:Get(GetAllBlackboardDefs().UI_Notifications)
			MSG.message = message
			MSG.isShown = true
			MSG.duration = duration
			UINote:SetVariant(GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(MSG), true)
		 end)
		,SendWarning = (function(self,message,duration)
			local MSG = SimpleScreenMessage.new()
			local BBS = Game.GetBlackboardSystem()
			local UINote = BBS:Get(GetAllBlackboardDefs().UI_Notifications)
			MSG.message = message
			MSG.isShown = true
			MSG.duration = duration or 3.0
			UINote:SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(MSG), true)
		 end)
		,MoneyTransfer = (function(self,title,message)
			local V = Game.GetPlayer()
			V:SetWarningMessage(title..'\n'..message, "Money")
		 end)
		,ShardPopup = (function(self,title,message)
			Game.GetUISystem():QueueEvent(NotifyShardRead.new({title = title, text = message}))
		 end)
		,SendMessageFromVik = (function(self,title,message)
			self:ShardPopup(title,message)
		 end)
		,PlayShortEffect = function(self,EffectName)
			local V = Game.GetPlayer()
			local WEBB = worldEffectBlackboard.new()
			GameObjectEffectHelper.StartEffectEvent(V, EffectName, false, WEBB)
		 end
		,ncpd_dispatch_CALLMAXTAC = (function(self,Start)
			Game.GetPoliceRadioSystem():PoliceRadioRequest("nc_heat_5_start")
		 end)
	 }
	,GMGC = {
		 Controller = nil
		,Listeners = {'OnInitialize','OnPlayerAttach','OnTimeSkipFinishEvent'}
		,Init = (function(self)
			local fn_CallBack = (function() return (function(Controller,optOne) self.Controller = Controller end) end)
			for k,v in ipairs(self.Listeners) do
				Observe('gameuiInGameMenuGameController', v, fn_CallBack())
			end
		 end)
		,SendMessage = (function(self,Message)
			if self.Controller ~= nil then
				local IGNE = UIInGameNotificationEvent.new()
				IGNE.notificationType = UIInGameNotificationType.GenericNotification
				IGNE.overrideCurrentNotification = true
				IGNE.title = Message
				self.Controller:SendNotification(IGNE)
			end
		 end)
	 }
	,CreateSandevistan = (function(self)
		self.martinez.UseDavidsIcon = self.UseDavidsIcon
		self.martinez:CreateSandevistan()
		self.martinez:CreateNew_FX_Status_Effects()
		self.martinez:EditHeat5Strategy()
	 end)
	,UpdateViksLoot = (function(self) -- a shorter version of UpdateSandevistanLevelCheck for GameLoad()
		local hasFalcosReward = self.qs:HasFalcosReward()
		local smsSent = self.qs:ViksMessageIsSent()
		local LevelCheck = self.martinez:UpdateLootLevelCheck(hasFalcosReward,smsSent)
	 end)
	,SandevistanDebug = (function(self)
		local output = { }
		output.IsPlayerLevel40 = self.sps:getPlayerLevel() >= 40
		output.hasFalcosReward = self.qs:HasFalcosReward()
		output.smsSent = self.qs:ViksMessageIsSent()
		output.LevelCheck = self.martinez:CheckRequiredLevel()
		output.MaxRuntime = self.MaxRuntime
		output.runTime = math.floor(self.runTime)
		return output
	 end)
	,UnsendViksMessage = (function(self,hasFalcosReward)
		self.qs:UnsendViksMessage()
		self.martinez:UpdateLootLevelCheck(hasFalcosReward,false)
	 end)
	,UpdateSandevistanChecks = (function(self)
		local IsPlayerLevel40 = self.sps:getPlayerLevel() >= 40
		local hasFalcosReward = self.qs:HasFalcosReward()
		local smsSent = self.qs:ViksMessageIsSent()
		if IsPlayerLevel40 and hasFalcosReward and (not smsSent) then
			self.bbs:SendMessageFromVik(self.Localization.MessageFromVik_Title,self.Localization.MessageFromVik)
			smsSent = self.qs:ViksMessageSetSent()
		end
		self.martinez:UpdateLootLevelCheck(hasFalcosReward,smsSent)
	 end)
}

-- Module attachments (order matters: later modules may call earlier ones)
require('./ncpd.lua').attach(dsp)
require('./strain.lua').attach(dsp)
require('./loreEffects.lua').attach(dsp)
require('./immunoblocker_logic.lua').attach(dsp)

-- Update immunoblocker TweakDB prices from config (called at LoadGamePart1)
dsp.UpdateImmunoblockerPrices = (function(self)
	local prices = {
		{ self.martinez.ImmunoblockerItem_Common  .. '_Price', self.cfg.immunoblockerPriceCommon },
		{ self.martinez.ImmunoblockerItem_Uncommon .. '_Price', self.cfg.immunoblockerPriceUncommon },
		{ self.martinez.ImmunoblockerItem_Rare    .. '_Price', self.cfg.immunoblockerPriceRare },
	}
	for _, p in ipairs(prices) do
		pcall(function()
			TweakDB:SetFlat(p[1] .. '.value', p[2] * 1.0)
			TweakDB:Update(p[1])
		end)
	end
	print('[DSP] Immunoblocker prices updated: ' .. self.cfg.immunoblockerPriceCommon .. '/' .. self.cfg.immunoblockerPriceUncommon .. '/' .. self.cfg.immunoblockerPriceRare)
 end)
-- Runtime-based stamina management (applied during Sandy, removed on End)
dsp.currentStaminaState = nil  -- nil, 'boost', 'drain'

dsp.UpdateRuntimeStamina = (function(self)
	if not self.isRunning then return end
	local rtPct = self:GetRuntimePercent()
	local newState = nil
	if rtPct > 30 then
		newState = 'boost'     -- body energized by Sandy
	elseif rtPct > 10 then
		newState = nil         -- normal (no modifier)
	else
		newState = 'exhausted' -- body failing: stamina drain + speed/armor penalty
	end
	if newState ~= self.currentStaminaState then
		-- Remove all previous
		self:StatusEffect_CheckAndRemove(self.martinez.StaminaBoost)
		self:StatusEffect_CheckAndRemove(self.martinez.StaminaDrain)
		self:StatusEffect_CheckAndRemove(self.martinez.RuntimeExhaustion)
		-- Apply new
		if newState == 'boost' then
			self:StatusEffect_CheckAndApply(self.martinez.StaminaBoost)
		elseif newState == 'exhausted' then
			self:StatusEffect_CheckAndApply(self.martinez.StaminaDrain)
			self:StatusEffect_CheckAndApply(self.martinez.RuntimeExhaustion)
		end
		self.currentStaminaState = newState
	end
 end)

dsp.RemoveRuntimeStamina = (function(self)
	self:StatusEffect_CheckAndRemove(self.martinez.StaminaBoost)
	self:StatusEffect_CheckAndRemove(self.martinez.StaminaDrain)
	self:StatusEffect_CheckAndRemove(self.martinez.RuntimeExhaustion)
	self.currentStaminaState = nil
 end)

-- Psycho stamina debuff: ×0.85 at stage 4-5 (even outside Sandy)
dsp.UpdatePsychoStamina = (function(self)
	if self.CyberPsychoWarnings >= 4 then
		self:StatusEffect_CheckAndApply(self.martinez.PsychoStaminaDebuff)
	else
		self:StatusEffect_CheckAndRemove(self.martinez.PsychoStaminaDebuff)
	end
 end)

require('./psychosis.lua').attach(dsp)
require('./death.lua').attach(dsp)

registerForEvent('onInit', function()
	print('[DSP] onInit: starting, martinez='..tostring(dsp.martinez ~= nil)..', gui='..tostring(dsp.gui ~= nil))
	dsp:Init()
	
    Observe('SandevistanEvents', 'OnEnter', function(self, event)
		local isWearing = dsp:IsWearingSandevistan()
		print('[DSP] SandevistanEvents.OnEnter: IsWearing='..tostring(isWearing)..' PlayerAttached='..tostring(dsp.PlayerAttached)..' LoadGameRun='..tostring(dsp.LoadGameRun))
		if isWearing then
			dsp:Start()
			return false
		end
    end)
	
	Observe('SandevistanEvents', 'OnExit', function(self, event)
		if dsp:IsWearingSandevistan() then
			dsp:End()
		end
    end)
	
	ObserveAfter('TimeskipGameController', 'OnInitialize', function(this)
		dsp.TimeSkip:Reset()
	end)
	
	ObserveAfter('TimeskipGameController', 'OnCloseAfterFinishing', function(this,proxy)
		dsp.TimeSkip:End()
	end)
	
	ObserveAfter('PlayerPuppet', 'OnGameAttached', function(this)
		if this:IsReplacer() then return end
		if Game.GetSystemRequestsHandler():IsPreGame() then return end
		
		dsp.isRunning = false
		dsp:LoadGame(1)
	end)

	ObserveAfter('PlayerPuppet', 'OnDetach', function(this)
		dsp.PlayerAttached = false
	end)
	
	ObserveAfter('PlayerPuppet', 'OnEnterSafeZone', function(this)
		dsp.sps:InControl()
		dsp:SafeAreaChange(true)
	end)
	
	ObserveAfter('PlayerPuppet', 'OnExitSafeZone', function(this)
		dsp.sps:InControl()
		dsp:SafeAreaChange(false)
	end)
	ObserveAfter('PlayerPuppet', 'OnSceneTierChange', function(this,newState)
		-- Update VIsInControl cache and trigger Outstanding Buff
		local VIsInControl_Previous = dsp.VIsInControl
		dsp.VIsInControl = (newState==1)
		if VIsInControl_Previous and (not dsp.VIsInControl) then -- only if it goes from on to off do we care
			if not dsp.lastBreath then
				dsp.sps:EndSandevistan()
				dsp:Safety(true,true) -- turn lift limiters off
			end
			if dsp.CyberPsychoWarnings == 5 then
				dsp.bbs:PlayShortEffect(dsp.martinez.martinez_fx_onscreen_sick_start)
			end
		end
		if not dsp.lastBreath then
			dsp:DisableSandevistan("PlayerPuppet/OnSceneTierChange")
		end
	end)
	ObserveAfter("PhoneSystem", "OnPickupPhone",function(this, request)
		if not dsp.lastBreath then
			dsp.sps:EndSandevistan()
		end
	end)
	ObserveAfter("PhoneSystem", "OnUsePhone",function(this, request)
		if not dsp.lastBreath then
			dsp.sps:EndSandevistan()
		end
	end)

	ObserveAfter('PreventionSystem', 'OnHeatChanged', function(this, previousHeat)
		dsp:HeatLevelChanged(this.heatStage,previousHeat,this.heatChangeReason)
	end)

	ObserveAfter('EquipmentSystem', 'OnPlayerAttach', function(this)
		dsp:LoadGame(2)
	end)
	
	ObserveAfter("healthbarWidgetGameController", "OnPlayerAttach", function(this, value)
		dsp:LoadGame(3)
	end)

	ObserveAfter('RipperDocGameController', 'OnArmorBarFinalizedEvent', function(this,value)
		local VDM = this.VendorDataManager
		if VDM == nil then return end
		local VendorName = GetLocalizedText(VDM:GetVendorName())
		dsp:VisitedRipper(VendorName)
	end)
	
	-- Combat death at psycho 5: trigger Last Breath when Second Heart revives V
	-- OnDeath fires when V dies from any cause — if at psycho 5, mark for Last Breath
	pcall(function()
		Observe('PlayerPuppet', 'OnDeath', function(this)
			if dsp.CyberPsychoWarnings >= 5
				and dsp.cfg.enableCyberpsychosis
				and not dsp.VIsDead
				and not dsp.lastBreath then
				dsp.VIsDead = true
				dsp.cheatedDeath = true
				dsp.OutstandingBuff = 8
			end
		end)
	end)

	Observe('NPCPuppet', 'OnAfterDeathOrDefeat', function(npcPuppet,DefeatEvt)
		if not IsDefined(npcPuppet) then return end
		dsp:BuffNPCPsychoGlitch(npcPuppet,false)
		pcall(function()
			local eid = tostring(npcPuppet:GetEntityID().hash)
			dsp.combatNPCs[eid] = nil
		end)
	end)
	Observe('NPCPuppet', 'OnPreUninitialize', function(npcPuppet,DefeatEvt)
		if not IsDefined(npcPuppet) then return end
		dsp:BuffNPCPsychoGlitch(npcPuppet,false)
		pcall(function()
			local eid = tostring(npcPuppet:GetEntityID().hash)
			dsp.combatNPCs[eid] = nil
		end)
	end)

	ObserveAfter('NPCPuppet', 'OnSignalNPCStateChangeSignal', function(npcPuppet,signalId, newValue, userData)
		-- signalId:int, newValue:bool userData:NPCStateChangeSignal
		if not IsDefined(npcPuppet) then return end
		if not IsDefined(userData) then return end
		if not userData.highLevelStateValid then return end
		-- HighLevelStates is One Indexed || userData.highLevelStateValid is Zero Indexed
		-- Alerted,Any,Combat,Dead,Fear,Relaxed,Stealth,Unconscious,Wounded

		if userData.highLevelState==gamedataNPCHighLevelState.Fear then return end
		if userData.highLevelState==gamedataNPCHighLevelState.Wounded then return end
		if userData.highLevelState==gamedataNPCHighLevelState.Stealth then return end

		local TurnOn = (userData.highLevelState==gamedataNPCHighLevelState.Combat)
		dsp:BuffNPCPsychoGlitch(npcPuppet,TurnOn)
		-- Track combat NPCs for TTB/Blackwall targeting
		pcall(function()
			local eid = tostring(npcPuppet:GetEntityID().hash)
			if TurnOn then
				dsp.combatNPCs[eid] = npcPuppet
			else
				dsp.combatNPCs[eid] = nil
			end
		end)
	end)

	Observe('gameuiPhotoModeMenuController', 'OnShow', function()
		dsp.isPhotoMode = true
	end)

	Observe('gameuiPhotoModeMenuController', 'OnHide', function()
		dsp.isPhotoMode = false
	end)
end)

registerForEvent('onUpdate', function(dt)
    -- CET restart recovery (moved from onDraw: game API calls in onDraw crash with Codeware during Loading world)
    if dsp.gui and (not dsp.LoadGameRun) and (not dsp.TriedLoadGameRun) then
        local V = Game.GetPlayer()
        if V and IsDefined(V) and not Game.GetSystemRequestsHandler():IsPreGame() then
            print('[DSP] CET Restart Recovery: LoadGame()')
            dsp:LoadGame()
        end
    end
    dsp:RealTimeImmunoblockerTick()
    dsp:Running(dt)
    dsp:UpdateTremor(dt)
    dsp:UpdateFOVPulse(dt)
    dsp:UpdateTerminalClarity(dt)
    dsp:UpdateLastBreath(dt)
    dsp:UpdateBlackout(dt)
    dsp:UpdateHallucinations(dt)
    dsp:UpdateAutoAttack()
    dsp:UpdatePendingEpisode(dt)
    -- Last Breath delayed lore message
    if dsp.lastBreathMessage then
        dsp.lastBreathMessage.elapsed = dsp.lastBreathMessage.elapsed + dt
        if not dsp.lastBreathMessage.sent and dsp.lastBreathMessage.elapsed >= dsp.lastBreathMessage.duration then
            dsp.lastBreathMessage.sent = true
            local V = Game.GetPlayer()
            if V and IsDefined(V) then
                pcall(function() V:SetWarningMessage("LUCY... I CAN SEE THE MOON FROM HERE") end)
            end
            dsp.lastBreathMessage = nil
        end
    end
end)

registerForEvent("onDraw", function()
	if dsp.gui ~= nil then
		dsp.gui:Draw()
	end
end)

registerForEvent("onOverlayOpen", function()
	if dsp.gui ~= nil then
		dsp.gui:ShowWindow(true)
	end
end)

registerForEvent("onOverlayClose", function()
	if dsp.gui ~= nil then
		dsp.gui:ShowWindow(false)
	end
end)

registerInput("ToggleSandyNoSafety", 'Toggle Sandevistan Safety On/Off', function(isKeyDown)
    dsp:ToggleSafety(isKeyDown)
end)

registerInput("DebugPsychoUp", 'DEBUG: Psycho Level +1', function(isKeyDown)
	if not isKeyDown then return end
	if dsp.CyberPsychoWarnings < 5 then
		dsp.CyberPsychoWarnings = dsp.CyberPsychoWarnings + 1
	end
	dsp:DisableSandevistan("debug")
	dsp:SaveGame("debug")
	local names = { "I", "II", "III", "IV", "V" }
	dsp.bbs:SendMessage("DEBUG: PSYCHOSIS "..tostring(names[dsp.CyberPsychoWarnings] or dsp.CyberPsychoWarnings), 2.0)
	print("[DSP DEBUG] CyberPsychoWarnings="..tostring(dsp.CyberPsychoWarnings).." strain="..tostring(dsp.neuralStrain))
end)

registerInput("DebugPsychoDown", 'DEBUG: Psycho Level -1', function(isKeyDown)
	if not isKeyDown then return end
	if dsp.CyberPsychoWarnings > 0 then
		dsp.CyberPsychoWarnings = dsp.CyberPsychoWarnings - 1
	end
	if dsp.CyberPsychoWarnings == 0 then
		dsp.neuralStrain = 0
		dsp:StopHeartbeat()
		dsp.nextLaughTime = nil
	end
	dsp:DisableSandevistan("debug")
	dsp:SaveGame("debug")
	local names = { [0] = "CLEAR", "I", "II", "III", "IV", "V" }
	dsp.bbs:SendMessage("DEBUG: PSYCHOSIS "..tostring(names[dsp.CyberPsychoWarnings] or dsp.CyberPsychoWarnings), 2.0)
	print("[DSP DEBUG] CyberPsychoWarnings="..tostring(dsp.CyberPsychoWarnings))
end)

registerInput("DebugPsychoReset", 'DEBUG: Reset All Psycho State', function(isKeyDown)
	if not isKeyDown then return end
	dsp.CyberPsychoWarnings = 0
	dsp.neuralStrain = 0
	dsp.dailyActivations = 0
	dsp.nextLaughTime = nil
	dsp.nextPsychoMsgTime = nil
	dsp.tremor.intensity = 0
	dsp.cheatedDeath = false
	if dsp.lastBreath then
		dsp:StopLastBreathSong()
		pcall(function()
			local ts = Game.GetTimeSystem()
			ts:UnsetTimeDilation("sandevistan")
			ts:SetIgnoreTimeDilationOnLocalPlayerZero(false)
		end)
	end
	dsp.lastBreath = nil
	dsp.lastBreathDeath = nil
	dsp.lastBreathMessage = nil
	dsp:RemoveAllPsychoVFX()
	dsp:StopHeartbeat()
	dsp:DisableSandevistan("debug")
	dsp:SaveGame("debug")
	dsp.bbs:SendMessage("DEBUG: ALL PSYCHO STATE RESET", 2.0)
	print("[DSP DEBUG] All psycho state reset")
end)

registerInput("DebugForceBleed", 'DEBUG: Force BleedingEffect (psycho escalation)', function(isKeyDown)
	if not isKeyDown then return end
	dsp:BleedingEffect(true)
	print("[DSP DEBUG] BleedingEffect(forcePsycho=true) CyberPsychoWarnings="..tostring(dsp.CyberPsychoWarnings))
end)
