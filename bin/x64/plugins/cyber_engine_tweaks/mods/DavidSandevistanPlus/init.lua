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
	Added debugging CET window (change davidsapogee.debug = true)
2.13.3
	Created MartinezSandevistan from scratch. It's now divorced (mostly) from the Apogee except for the icon and most of the localization texts.
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

local configFile_apogee = "config.json"
local function loadApogeeConfig(cfg)
	local file = io.open(configFile_apogee, "r")
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

davidsapogee = {
	 version = '2.25.3'
	,debug = false -- change to true to get the CET Debugging UI
	,UseDavidsIcon = true -- change to false to get the old Apogee icon
	,Call_MaxTac = true -- change to false to prevent 5 star wanted level (this only happens now if you kill civilians or NPCD while cyberpsycho)
	,ShowUIText = true -- change to false to hide the dilation/runtime/cyberpsycho text on the health bar
	,OverrideTextSize      = nil -- change the font size of the Sandevistan Text to match your other UI mods.
	,OverrideTextMargin    = nil -- move the Sandevistan Text up or down to match your other UI mods.
	,OverrideStaminaMargin = nil -- move the Stamina Bar Text up or down to match your other UI mods.
	,ForceStaminaMargin    = nil -- instead of the one above to fix the margin regardless of text showing or not.
	,cfg = {
		-- Health Drain
		enableHealthDrain = true,        -- toggle all health drain from sandevistan
		damageMin = 1.0,                 -- minimum damage % per tick (at full runtime)
		damageMax = 15.0,                -- maximum damage % per tick (at zero runtime)

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
		dailySafeActivations = 3,        -- activations per day before psycho acceleration (Doc's warning)
		psychoAccelPerExtraUse = 30,     -- seconds subtracted from PsychoOutburst per extra activation

		-- Safety Off
		safetyOffTimeDilation = 975,     -- time dilation index when safety off (975=97.5%, 950=95%, 1000=99.5%)

		-- Comedown
		enableComedown = true,           -- apply debuff after deactivating sandevistan
		comedownBaseDuration = 3.0,      -- base duration in seconds
		comedownMaxDuration = 8.0,       -- max duration after long sandy use
		comedownRuntimeThreshold = 60,   -- seconds of sandy use before comedown starts scaling

		-- Perk Gates
		requireEdgeRunnerPerk = true,   -- require EdgeRunner perk for full runtime (false = full access from day 1)

		-- Time Dilation
		timeDilationNoPerk = 0.05,       -- time scale without EdgeRunner perk (95%)
		timeDilationWithPerk = 0.0065,   -- time scale with EdgeRunner perk (99.35%)

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
			self.sps:Init(self)
			self.GMGC:Init(self)
			--UI:Init() is done in Load3
			self.TimeSkip.Apogee = self -- give TimeSkip a pointer so we don't have to use callback functions!
			self:CreateDavidsApogee()
			print('[DSP] Init: CreateDavidsApogee() complete')
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
		self.hud:Update({
			isWearing = self:IsWearingApogee() or false,
			showUI = self.ShowUIText,
			isRunning = self.isRunning,
			SafetyOn = self.SafetyOn,
			dilation = dilation,
			runTime = self.runTime,
			MaxRunTime = self.MaxRuntime,
			dailyActivations = self.dailyActivations or 0,
			dailySafe = self.cfg.dailySafeActivations or 3,
			psychoWarnings = self.CyberPsychoWarnings or 0,
			psychoOutburst = self.PsychoOutburst,
			comedownTimer = self.comedownTimer,
			rechargeNotification = self.rechargeNotification,
			inSafeArea = self.PlayerInSafeArea,
			inClub = self.InDaClub,
			dfImmuno = dfImmuno,
		})
	 end)
	,GetApogeeIndex = (function(self)
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
	,IsWearingApogee = (function(self)
		output = self:GetApogeeIndex()
		    if output == nil   then return nil
		elseif output == false then return false
		end
		return true
	 end)
	,RemoveAllPsychoVFX = (function(self)
		self:StatusEffect_CheckAndRemove(self.martinez.PsychoWarningEffect_Light)
		self:StatusEffect_CheckAndRemove(self.martinez.PsychoWarningEffect_Medium)
		self:StatusEffect_CheckAndRemove(self.martinez.CyberpsychoStatusEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.CyberpsychoSafetyOffEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.PsychoLaughEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.NosebleedEffect)
	 end)
	,DisableSandevistan = (function(self,source)
		if type(source) ~= 'string' then source = '' end
		if self.martinez == nil then return end

		if (not self:IsWearingApogee()) and (not self.SafetyOn) then
			self.SafetyOn = true
			self:StatusEffect_CheckAndRemove(self.martinez.SafetiesOffStatusEffect)
			return
		end
		-- Progressive psycho VFX by level (MartinezFury is timed/automatic, these are persistent)
		if (self.PlayerInSafeArea or self.InDaClub or (not self.VIsInControl)) then
			self:RemoveAllPsychoVFX()
			self.sps:ResetNamePlates()
		elseif self.CyberPsychoWarnings <= 2 then
			self:RemoveAllPsychoVFX()
			self.sps:ResetNamePlates()
		elseif self.CyberPsychoWarnings == 3 then
			self:RemoveAllPsychoVFX()
			self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Light)
			self.sps:ResetNamePlates()
		elseif self.CyberPsychoWarnings == 4 then
			self:RemoveAllPsychoVFX()
			self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Medium)
			self.sps:ResetNamePlates()
		elseif self.CyberPsychoWarnings >= 5 and (not self.SafetyOn) then
			self:RemoveAllPsychoVFX()
			self:StatusEffect_CheckAndApply(self.martinez.CyberpsychoSafetyOffEffect)
			self.sps:HideNamePlates()
		elseif self.CyberPsychoWarnings >= 5 then
			self:RemoveAllPsychoVFX()
			self:StatusEffect_CheckAndApply(self.martinez.CyberpsychoStatusEffect)
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
		self:SaveGame('Apogee:Restart()')
	 end)
	,Rested = (function(self,RestedHours)
		RestedHours = math.floor(RestedHours)
		if RestedHours < 1 then return end
		
		local prevPsycho = self.CyberPsychoWarnings
		if RestedHours < self.MaxRechargePerSleep and self.CyberPsychoWarnings == 5 then
			self.CyberPsychoWarnings = 1 -- no free lunch for the cyberpsycho; full night's sleep or the psychosis cycle continues tomorrow.
			self:Calculate_PsychoOutburst() -- reset the timer
			self.bbs:SendWarning("PARTIAL REST — PSYCHOSIS REDUCED TO LEVEL I — FULL NIGHT REQUIRED", 5.0)
		else
			self.CyberPsychoWarnings = 0
			if prevPsycho > 0 then
				self.bbs:SendMessage("FULL REST — PSYCHOSIS CLEARED", 3.0)
			end
		end
		
		self.dailyActivations = 0
		self.qs:SaveDailyActivations(0)

		self:Safety(true)
		self:DisableSandevistan()
		if RestedHours > self.MaxRechargePerSleep then RestedHours = self.MaxRechargePerSleep end
		RestedRuntime = self.MaxRuntime * (RestedHours/self.FullRechargeHours)
		if self.dev_mode then
			print('Apogee:Rested() => Runtime'..tostring(RestedRuntime)..' / '..tostring(self.MaxRuntime)..' - MaxRechargePerSleep:'..tostring(self.MaxRechargePerSleep)..' - FullRechargeHours:'..tostring(self.FullRechargeHours))
		end
		local oldRuntime = self.runTime
		self.runTime = self.runTime + RestedRuntime + 1
		if self.runTime > self.MaxRuntime then self.runTime = self.MaxRuntime end
		self.rechargeNotification = math.floor(self.runTime - oldRuntime)
		self.rechargeNotificationTimer = 8
		if self.rechargeNotification > 0 then
			self.bbs:SendMessage("RECHARGED +"..tostring(self.rechargeNotification).."s — RUNTIME: "..tostring(math.floor(self.runTime)).."/"..tostring(self.MaxRuntime).."s", 3.0)
		end

		self:SaveGame('Apogee:Rested()')
	 end)
	,VisitedRipper = (function(self,VendorName)
		local isRested = ""
		if VendorName == nil then VendorName = "" end
		if VendorName ~= "" and self.ViktorCooldown == nil then -- At Ripper + no cooldown
			self:Rested(8)
			isRested = "Rested(8)"
			self.ViktorCooldown = 300 -- 5min cooldown before you can rest at Viktor's again!
		end
		if self.dev_mode then
			print('Apogee:VisitedRipper("'..VendorName..'") '..tostring(isRested))
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
		if self.martinez == nil then return end
		if not self:IsWearingApogee() then return end

		self.isRunning = true
		self.sandyStartRuntime = self.runTime
		self.lowRuntimeWarned = false
		-- set initial charge level on startup!
		self:SandevistanCharge()

		-- Activation notification
		local dilation = self.TimeDilationActualSpeed or 85
		local activationMsg = "SANDEVISTAN — TIME DILATION "..tostring(dilation).."%"
		if self.CyberPsychoWarnings > 0 then
			local levelNames = { "I", "II", "III", "IV", "V" }
			activationMsg = activationMsg.." | PSYCHOSIS "..tostring(levelNames[self.CyberPsychoWarnings] or self.CyberPsychoWarnings)
		end
		self.bbs:SendMessage(activationMsg, 3.0)

		-- Daily activation counter — accelerate cyberpsychosis on overuse
		if self.cfg.enableCyberpsychosis then
			self.dailyActivations = self.dailyActivations + 1
			-- Dark Future compat: immunosuppressant blocks psycho acceleration from overuse
			local dfImmuno = self:StatusEffect_CheckOnly('DarkFutureStatusEffect.Immunosuppressant')
			if not dfImmuno and self.dailyActivations > self.cfg.dailySafeActivations then
				local extraUses = self.dailyActivations - self.cfg.dailySafeActivations
				if self.PsychoOutburst ~= nil then
					self.PsychoOutburst = self.PsychoOutburst - (self.cfg.psychoAccelPerExtraUse * extraUses)
				elseif self.CyberPsychoWarnings > 0 then
					self:Calculate_PsychoOutburst()
					self.PsychoOutburst = self.PsychoOutburst - (self.cfg.psychoAccelPerExtraUse * extraUses)
				end
				self.bbs:SendWarning("OVERUSE — "..tostring(self.dailyActivations).." ACTIVATIONS TODAY (SAFE: "..tostring(self.cfg.dailySafeActivations)..") — REST RECOMMENDED", 4.0)
				if self.dev_mode then
					print('DailyActivations: '..tostring(self.dailyActivations)..' (safe='..tostring(self.cfg.dailySafeActivations)..') PsychoAccel='..tostring(self.cfg.psychoAccelPerExtraUse * extraUses)..'s')
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
		self.isRunning = false
		if self.martinez == nil then return end
		if not self:IsWearingApogee() then return end

		-- Comedown: apply debuff based on how long the sandy was active
		if self.cfg.enableComedown then
			local runtimeUsed = self.sandyStartRuntime - self.runTime
			if runtimeUsed > 0 then
				local scale = math.min(runtimeUsed / self.cfg.comedownRuntimeThreshold, 1.0)
				local duration = self.cfg.comedownBaseDuration + (self.cfg.comedownMaxDuration - self.cfg.comedownBaseDuration) * scale
				self.comedownTimer = duration
				self:StatusEffect_CheckAndApply('BaseStatusEffect.MinorBleeding')
				self.bbs:SendMessage("SYSTEM COOLDOWN — "..tostring(math.floor(duration)).."s", 2.5)
				if self.dev_mode then
					print('Comedown: runtimeUsed='..tostring(runtimeUsed)..'s duration='..string.format("%.1f",duration)..'s')
				end
			end
		end

		self.runTime = math.floor(self.runTime)
		self:TimeDilationEffects()
		self:OutOfRuntime(false)
		self:UpdateUIText()
		self:SaveGame('Apogee:End()')
	 end)
	,KillV = (function(self)
		-- Terminal clarity: David snaps out of psychosis right before death (Ep 10)
		-- Remove all VFX for a brief moment of lucidity before flatline
		self:RemoveAllPsychoVFX()
		self:StatusEffect_CheckAndRemove(self.martinez.SafetiesOffStatusEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.BleedingStatusEffect)
		self.tremor.intensity = 0
		self:StopHeartbeat()
		self.nextLaughTime = nil
		self.bbs:SendMessage("...", 2.0)
		self.terminalClarity = { elapsed = 0, duration = 2.5 }
	 end)
	,KillV_Execute = (function(self)
		self.terminalClarity = nil
		self.bbs:SendWarning("SYSTEM FAILURE — NEURAL COLLAPSE", 4.0)
		self:StatusEffect_CheckAndApply('BaseStatusEffect.HeartAttack')
		self.VIsDead = true
		self.OutstandingBuff = 6
	 end)
	,RemoveDeadV = (function(self)
		local V = Game.GetPlayer()
		if not IsDefined(V) then return end
		self.VIsDead = false
		-- sometimes V has a second heart and comes back to life
		-- in which case we need to let him/her use the menus again!
		self:StatusEffect_CheckAndRemove('BaseStatusEffect.HeartAttack')
		if not V.incapacitated then
			self:StatusEffect_CheckAndRemove('GameplayRestriction.BlockAllHubMenu')
		end
	 end)
	,Safety = (function(self,SafetyOn,ForceSafe)
		ForceSafe = (ForceSafe == true) and true or false
		if (not SafetyOn) and (not self:IsWearingApogee()) then return end
		if SafetyOn and (not ForceSafe) and self.isRunning and (self.CyberPsychoWarnings > 4) then return end
		
		if SafetyOn then
			self:StatusEffect_CheckAndRemove(self.martinez.SafetiesOffStatusEffect)
			self.SafetyOn = true
		elseif not self:IsFury() then -- and self.VIsInControl 
			self:StatusEffect_CheckAndApply(self.martinez.SafetiesOffStatusEffect)
			self.SafetyOn = false
		end
		self:TimeDilationEffects()
		self:DisableSandevistan("Safety()")
	 end)
	,ToggleSafetyLastKey = false
	,ToggleSafety = (function(self,KeyDown)
		if self.martinez == nil then return end
		if self.bbs:InGameMenu() then return end
		if self.bbs:InBrainDance() then return end
		if not self:IsWearingApogee() then return end
		if not self.VIsInControl and self.SafetyOn then return end
		
		if self.ToggleSafetyLastKey ~= KeyDown then
			self.ToggleSafetyLastKey = KeyDown
			if KeyDown then
				self:Safety(not self.SafetyOn)
			end
		end
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
	,TimeDilationCalculator = (function(self,DebugInfo)
		if DebugInfo == nil then DebugInfo = false end
		local IsEdgeRunner = (self.sps:IsEdgeRunner() == true)
		local timeScale = IsEdgeRunner and self.cfg.timeDilationWithPerk or self.cfg.timeDilationNoPerk
		local Dilation = self:findDilationIndex(timeScale)
		local StatusText = 'Default'
		local outtaTime = (self.runTime < 1)

		if outtaTime then
			Dilation = 950
			StatusText = "Runtime Expired"
		elseif not self.SafetyOn then
			Dilation = self:findDilationIndex((1000 - self.cfg.safetyOffTimeDilation) / 1000)
			StatusText = "Safety Off"
		end

		return Dilation, StatusText
	 end)
	,TimeDilationEffects = (function(self)
		if self.isRunning then
			local Dilation, StatusText = self:TimeDilationCalculator()
			self:TimeDilationEffects_Activate(Dilation,StatusText)
		elseif not self:IsWearingApogee() then
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
	,BuffNPCPsychoGlitch = (function(self,npcPuppet,TurnOn)
		if not IsDefined(npcPuppet) then return end

		local theBuff = self.martinez.CyberpsychoNPCStatusEffect
		if TurnOn then
			if self.CyberPsychoWarnings ~= 5 then return end
			if not npcPuppet:IsNPC() then return end
			if npcPuppet:IsPlayerCompanion() then return end
			if npcPuppet:IsDead() then return end
			if npcPuppet:IsIncapacitated() then return end
			
			self:StatusEffect_CheckAndApply(theBuff,npcPuppet)
		else -- Always turn off the buff
			self:StatusEffect_CheckAndRemove(theBuff,npcPuppet)
		end
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
	,GetHeatLevel = (function(self)
		local SSC = Game.GetScriptableSystemsContainer()
		if not IsDefined(SSC) then return 0 end
		local SSCPS = SSC:Get("PreventionSystem")
		if not IsDefined(SSCPS) then return 0 end
		return SSCPS:GetHeatStageAsInt()
	 end)
	,SetHeatLevel = (function(self,HeatLevel,Reason)
		local SSC = Game.GetScriptableSystemsContainer()
		if not IsDefined(SSC) then return end
		local SSCPS = SSC:Get("PreventionSystem")
		if not IsDefined(SSCPS) then return end
		SSCPS:ChangeHeatStage(HeatLevel, Reason)
	 end)
	,NCPDIsWatching = (function(self,SpawnReinforcement)
		local SSC = Game.GetScriptableSystemsContainer()
		if not IsDefined(SSC) then return end
		local SSCPS = SSC:Get("PreventionSystem")
		if not IsDefined(SSCPS) then return end
		local V = Game.GetPlayer()
		
		SSCPS.CreateNewDamageRequest(V,gamedataAttackType.Ranged,32000,true)
		SSCPS.CrimeWitnessRequestToPreventionSystem(V:GetWorldPosition())
	 end)
	,HeatLevelChanged = (function(self,currentHeatLevel,previousHeatLevel,ChangeReason)
		if self.CyberPsychoWarnings == 0 then
			if self.dev_mode then 
				print('Regular NCPD: PreventionSystem/OnHeatChanged(PreviousStage:'..tostring(previousHeatLevel.value)..'=>'..tostring(currentHeatLevel.value)..' Reason:'..tostring(ChangeReason)..')')
			end
			return
		end
		if (ChangeReason == 'KillPrevention' or ChangeReason == 'KillCivilian' or ChangeReason == 'DamagePrevention' or ChangeReason == 'DamageCivilian') then
			if self.dev_mode then print('Cyberpsycho: PreventionSystem/OnHeatChanged(PreviousStage:'..tostring(previousHeatLevel.value)..'=>'..tostring(currentHeatLevel.value)..' Reason:'..tostring(ChangeReason)..')') end
			self:CALLMAXTAC()
		elseif self.dev_mode then
			print('Cyberpsycho: PreventionSystem/OnHeatChanged(PreviousStage:'..tostring(previousHeatLevel.value)..'=>'..tostring(currentHeatLevel.value)..' Reason:'..tostring(ChangeReason)..')')
		end
	 end)
	,BleedingEffect = (function(self, forcePsycho)
		if self.runTime > 0 and not forcePsycho then
			self:StatusEffect_CheckAndApply('BaseStatusEffect.MinorBleeding')
		else
			if self.cfg.enableCyberpsychosis then
				if self.CyberPsychoWarnings < 5 then self.CyberPsychoWarnings = self.CyberPsychoWarnings + 1 end
				local psychoMessages = {
					[1] = { msg = "CYBERPSYCHOSIS I — NEURAL INSTABILITY DETECTED", dur = 4.0 },
					[2] = { msg = "CYBERPSYCHOSIS II — SENSORY GLITCHES INCREASING", dur = 4.0 },
					[3] = { msg = "CYBERPSYCHOSIS III — LOSING GRIP ON REALITY", dur = 5.0 },
					[4] = { msg = "CYBERPSYCHOSIS IV — CRITICAL — REST NOW", dur = 5.0 },
					[5] = { msg = "CYBERPSYCHO V — POINT OF NO RETURN", dur = 6.0 },
				}
				local entry = psychoMessages[self.CyberPsychoWarnings]
				if entry then self.bbs:SendWarning(entry.msg, entry.dur) end
				self:FrightenNPCs()
			end
			self:DisableSandevistan("BleedingEffect()")
			self:SaveGame("BleedingEffect()")
		end
	 end)
	,CALLMAXTAC = (function(self)
		local MaxTacText = self.Localization.CallMaxTac
		if self:GetHeatLevel() < 5 then
			self:SetHeatLevel(EPreventionHeatStage.Heat_5,"CYBERPSYCHO")
			-- POLICE SCAN MESSAGE --
			self.bbs:PlayShortEffect(self.martinez.martinez_fx_MAXTAC)
			self.bbs:SendMessage(MaxTacText,4.0)
		end
	 end)
	,BRIBE_NCPD = (function(self)
		if not self:CanBribeNCPD() then return end
		
		local V = Game.GetPlayer()
		if not IsDefined(V) then return end
		local TS = Game.GetTransactionSystem()
		if not IsDefined(TS) then return end
		local HeatLevel = self.GetHeatLevel()
		local TransferSucess = false
		local Bribe =  self.Apogee.bbs:GetThatValue(self.Apogee:GetHeatLevel())
		TransferSucess = TS:RemoveMoney(V,Bribe, "money")
		if TransferSucess then
			if HeatLevel == 5 then
				self:SetHeatLevel(EPreventionHeatStage.Heat_3,"NCPD BRIBE")
			else
				self:SetHeatLevel(EPreventionHeatStage.Heat_1,"NCPD BRIBE")
			end
			self.bbs:MoneyTransfer("NCPD BRIBE","BRIBE ACCEPTED - WANTED LEVEL REDUCED")
		else
			self.bbs:MoneyTransfer("NCPD BRIBE","NOT ENOUGH EDDIES CHOOM!")
		end
	 end)
	,GetCredits = (function(self)
		local V = Game.GetPlayer()
		if not IsDefined(V) then return end
		local TS = Game.GetTransactionSystem()
		if not IsDefined(TS) then return end
		return TS:GetItemQuantity(V, MarketSystem.Money())
	 end)
	,CanBribeNCPD = (function(self)
		local NetRunnerLevel = self.sps:NetRunnerLevel()
		local V = Game.GetPlayer()
		local HeatLevel = self.GetHeatLevel()
		local Credits = self:GetCredits()
		local output = (NetRunnerLevel.Rules.CanBribeNCPD) and (not V.inCombat) and (HeatLevel > 1) and (Credits>self.bbs.ThatValue)
		return output
	 end)
	,FrightenNPCs = (function(self)
		if self.CyberPsychoWarnings < 5 then
			self:StatusEffect_CheckAndApply(self.martinez.MartinezFury)
		else
			self:StatusEffect_CheckAndApply(self.martinez.MartinezFury_Level5)
		end
		local V = Game.GetPlayer() -- Simulate a gunshot event so enemies agro and NPCs run away
		StimBroadcasterComponent.BroadcastStim(V, gamedataStimType.Gunshot, 50.0)
		if self:GetHeatLevel() > 0 then
			self:NCPDIsWatching() -- Come find V !
		end
		self:Calculate_PsychoOutburst()
	 end)
	,Calculate_PsychoOutburst = (function(self)
		local FasterPussyCatKillKill = (self.CyberPsychoWarnings+1)/2 ---from:1 to:3.5
		if FasterPussyCatKillKill == 0 then FasterPussyCatKillKill = 1 end -- We NEVER want divide by zero
		self.PsychoOutburst = math.random(300, 3600) -- random 5-60 minute cooldown
		self.PsychoOutburst = self.PsychoOutburst / FasterPussyCatKillKill
	 end)
	,Calculate_SandevistanCharge = (function(self)
		local CooldownBuffer = 0.05 -- the buffer stops the sandevistan from running out of cooldown
		local IsFury = self:IsFury()
		if IsFury then CooldownBuffer = 0 end -- if MAXTAC gets called, sandevistan gives fries a circuit
		local RemainingCharge = (((self.runTime / self.MaxRuntime)) + CooldownBuffer) * 100
		if self.runTime <= 0 and IsFury then
			RemainingCharge = 0 -- disable sandevistan!
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

		if NetRunnerLevel.ApogeeReducedRuntime and self.runTime > (self.MaxRuntime * EdgeRunnerRuntimeModifier) then
			self.runTime = (self.MaxRuntime * EdgeRunnerRuntimeModifier)+1
			NeedsSave = true
			if self.dev_mode then
				print('SandevistanEdgeRunnerCheck => runTime cap applied')
			end
		end
		if NeedsSave and (not saving) then -- if called from SaveGame don't call SaveGame
			self:SaveGame('Apogee:SandevistanEdgeRunnerCheck('..tostring(saving)..')')
		end
	 end)
	,SandevistanCharge = (function(self)
		self:SandevistanEdgeRunnerCheck()
		self.sps:SandevistanCharge(self:Calculate_SandevistanCharge())
	 end)
	----------------------------------------------------------------
	-- Lore effects: camera tremor, FOV pulse, psycho laugh, terminal clarity
	----------------------------------------------------------------
	,UpdateTremor = (function(self, dt)
		if self.isPhotoMode or self.CachedInMenu or self.CachedBrainDance then
			self.tremor.intensity = 0
			return
		end

		-- Target intensity scales with psycho level
		local target = 0
		if self.CyberPsychoWarnings == 3 then target = 0.002
		elseif self.CyberPsychoWarnings == 4 then target = 0.006
		elseif self.CyberPsychoWarnings >= 5 then target = 0.012
		end
		-- Overuse adds tremor even before psychosis
		if self.dailyActivations > (self.cfg.dailySafeActivations or 3) * 2 then
			target = math.max(target, 0.004)
		end

		-- Smooth intensity transitions
		local speed = (target > self.tremor.intensity) and 3.0 or 1.5
		self.tremor.intensity = self.tremor.intensity + (target - self.tremor.intensity) * math.min(speed * dt, 1.0)

		if self.tremor.intensity < 0.0005 then
			self.tremor.intensity = 0
			return
		end

		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end
		local camera = V:GetFPPCameraComponent()
		if not camera then return end

		self.tremor.time = self.tremor.time + dt
		local i = self.tremor.intensity
		-- Layered sine waves for organic tremor
		local x = math.sin(self.tremor.time * 23.7) * i + math.sin(self.tremor.time * 41.3) * i * 0.5
		local y = math.sin(self.tremor.time * 31.1) * i + math.cos(self.tremor.time * 37.9) * i * 0.5
		pcall(function() camera:SetLocalPosition(Vector4.new(x, y, 0, 0)) end)
	 end)
	,UpdateFOVPulse = (function(self, dt)
		if not self.fovPulse then return end

		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then self.fovPulse = nil return end
		local camera = V:GetFPPCameraComponent()
		if not camera then self.fovPulse = nil return end

		-- Capture base FOV on first frame
		if not self.fovPulse.baseFOV then
			local ok, fov = pcall(function() return camera:GetFOV() end)
			if not ok or not fov or fov < 10 then
				self.fovPulse = nil
				return
			end
			self.fovPulse.baseFOV = fov
		end

		self.fovPulse.elapsed = self.fovPulse.elapsed + dt
		local t = self.fovPulse.elapsed / self.fovPulse.duration

		if t >= 1.0 then
			pcall(function() camera:SetFOV(self.fovPulse.baseFOV) end)
			self.fovPulse = nil
		else
			local fovBoost = math.sin(t * math.pi) * 12
			pcall(function() camera:SetFOV(self.fovPulse.baseFOV + fovBoost) end)
		end
	 end)
	,UpdateTerminalClarity = (function(self, dt)
		if not self.terminalClarity then return end
		self.terminalClarity.elapsed = self.terminalClarity.elapsed + dt
		if self.terminalClarity.elapsed >= self.terminalClarity.duration then
			self:KillV_Execute()
		end
	 end)
	,PsychoLaugh = (function(self)
		if not self.cfg.enableCyberpsychosis then return end
		if self.CyberPsychoWarnings < 4 then
			self.nextLaughTime = nil
			return
		end
		if self.CachedInMenu or self.CachedBrainDance or (not self.VIsInControl) then return end

		local now = os.clock()
		if self.nextLaughTime == nil then
			self.nextLaughTime = now + math.random(10, 30)
			return
		end

		if now < self.nextLaughTime then return end

		-- Apply perk_edgerunner_player VFX (the laugh) — same effect as the EdgeRunner perk fury
		self:StatusEffect_CheckAndApply(self.martinez.PsychoLaughEffect)

		if self.CyberPsychoWarnings >= 5 then
			self.nextLaughTime = now + math.random(15, 45)
		else
			self.nextLaughTime = now + math.random(30, 90)
		end
	 end)
	,Heartbeat = (function(self)
		if self.CachedInMenu or self.CachedBrainDance then return end
		-- Heartbeat at psycho 3+ when idle, or during Sandy + low health
		local shouldBeat = false
		if self.CyberPsychoWarnings >= 3 and not self.isRunning then
			shouldBeat = true
		elseif self.isRunning and self.sps:getHealth(true) < 30 then
			shouldBeat = true
		end
		if not shouldBeat then return end

		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end
		pcall(function() V:PlaySoundEvent("gmpl_turret_heartbeat_loop_start") end)
	 end)
	,StopHeartbeat = (function(self)
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end
		pcall(function() V:PlaySoundEvent("gmpl_turret_heartbeat_loop_stop") end)
	 end)
	,Nosebleed = (function(self)
		-- Nosebleed VFX after overuse (David bleeds from the nose in Ep 2,3,5,9)
		if not self.cfg.enableCyberpsychosis then return end
		if self.dailyActivations <= (self.cfg.dailySafeActivations or 3) then return end
		self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
	 end)
	,ExhaustionCheck = (function(self)
		-- Exhaustion collapse: David passes out after 8 uses in Ep 2
		-- Trigger at 3x safe activations — forced deactivation + stagger
		if not self.cfg.enableCyberpsychosis then return end
		local threshold = (self.cfg.dailySafeActivations or 3) * 3
		if self.dailyActivations < threshold then return end
		if not self.isRunning then return end

		self.sps:EndSandevistan()
		self:StatusEffect_CheckAndApply('BaseStatusEffect.Stun')
		self.bbs:SendWarning("NEURAL OVERLOAD — SYSTEM SHUTDOWN", 4.0)
		-- Force a brief cooldown by draining some runtime
		self.runTime = math.max(self.runTime - 30, 0)
		self:SaveGame("ExhaustionCollapse")
	 end)
	,CachedInMenu = true
	,CachedBrainDance = false
	,Running = (function(self,dt)
		if self.isPhotoMode then return end
		if not self.PlayerAttached then return end
		if self.isRunning then
			self.lastTick = self.lastTick + dt
			if self.runTime > 0 then self.runTime = self.runTime - dt end
			if self.runTime < 0 then self.runTime = 0 end
			if self.lastTick >= self.TickLength then -- TickLength is 1.25s
				local thisTick = self.lastTick
				self.lastTick = 0
				
				-- if we're in the menu do nothing
				if self.CachedInMenu or self.CachedBrainDance then
					self.runTime = self.runTime + thisTick -- if in menu then refund tick on runtime
					return
				end
				
				-- if Safeties Lifted Use extra runtime (1.25 already ticked + multiplier)
				if not self.SafetyOn then self.runTime = self.runTime - (self.TickLength*self.cfg.safetyOffDrainMultiplier) end
				if self.runTime < 1 then self.runTime = 0 end

				-- Low runtime warning (once per activation)
				if not self.lowRuntimeWarned and self.runTime > 0 and self.runTime < 30 then
					self.lowRuntimeWarned = true
					self.bbs:SendWarning("LOW RUNTIME: "..tostring(math.floor(self.runTime)).."s — DEACTIVATE OR RISK EPISODE", 3.0)
				end

				self:CalcDamage()
				self:TimeDilationEffects()
				
				local DamagePerTick = self.DamagePerTick
				local RequiredHealth = self.RequiredHealth
				
				local ToDo_DamageHealthPercent = 0
				local VsHealthNow = self.sps:getHealth(true)
				local VsOvershieldNow = self.sps:getAdrenaline(true)/2
				if self.cfg.enableHealthDrain then
					local theDamage = DamagePerTick
					local VsOvershieldDeduction = VsHealthNow - theDamage
					if theDamage >= VsHealthNow then theDamage = VsHealthNow-2 end
					self.sps:damage(theDamage)
					ToDo_DamageHealthPercent = theDamage
					
					if VsOvershieldDeduction < 2 and not self.SafetyOn then -- if safety is off use every ounce of V's health pool.
						theDamage = (VsOvershieldDeduction-2)*-1
						if theDamage >= VsOvershieldNow then theDamage = VsOvershieldNow-2 end
						self.sps:UseAdrenaline(theDamage)
						ToDo_DamageHealthPercent = theDamage
					end
				end
				
				self:SandevistanCharge()
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
					-- Death only comes from PsychoOutburst timer expiring at level 5
					self.sps:EndSandevistan()
					self:BleedingEffect(true)
				elseif self.runTime < (self.TickLength*32) and (not self.MinorBleedingOn) and VsHealthPercent < 99 then
					-- Safety OFF + low runtime + injured: bleeding warning
					self:OutOfRuntime(true)
				end
				--print('Running: '..tostring(self.runTime)..' Damage='..tostring(self.DamagePerTick)..'/'..tostring(self.RequiredHealth)..' - '..tostring(VsHealthPercent))
			end
		end

		-- Comedown timer: count down and remove effect when expired
		if self.comedownTimer ~= nil then
			self.comedownTimer = self.comedownTimer - dt
			if self.comedownTimer <= 0 then
				self.comedownTimer = nil
				self:StatusEffect_CheckAndRemove('BaseStatusEffect.MinorBleeding')
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
			
			-- split the second tick into 4 parts to spread the load evenly
			self.displayTick2 = self.displayTick2 + 1
			if self.displayTick2 > 3 then self.displayTick2 = 0 end

			if self.displayTick2 == 0 then -- 1/sec zero offset
				self.CachedInMenu = self.bbs:InGameMenu() -- only check InGameMenu once per second
				self.CachedBrainDance = self.bbs:InBrainDance() -- only check InBrainDance once per second
				self.VIsInControl = self.sps:InControl()
				if self.CachedInMenu or self.CachedBrainDance then return end
				self:UpdateUIText()
			elseif self.displayTick2 == 1 then -- 1/sec +0.25 offset
				if self.CachedInMenu or self.CachedBrainDance then return end
				if self.PsychoOutburst ~= nil and self.cfg.enableCyberpsychosis then
					-- Dark Future compat: detect DF consumables
					local dfImmuno = self:StatusEffect_CheckOnly('DarkFutureStatusEffect.Immunosuppressant')
					local dfEndotrisine = self:StatusEffect_CheckOnly('DarkFutureStatusEffect.Endotrisine')

					if (self.CyberPsychoWarnings == 0) then
						self.PsychoOutburst = nil
					elseif dfImmuno then
						-- Immunosuppressant: pause psycho progression (recover like safe area)
						self.PsychoOutburst = self.PsychoOutburst + 5
					elseif self.PlayerInSafeArea or self.InDaClub then -- Safe Area
						self.PsychoOutburst = self.PsychoOutburst + (dfEndotrisine and 10 or 5)
					elseif not self.VIsInControl then -- Scene Area
						self.PsychoOutburst = self.PsychoOutburst + (dfEndotrisine and 10 or 5)
					elseif not self.SafetyOn then -- Safety Limiters Lifted = MORE PSYCHO
						self.PsychoOutburst = self.PsychoOutburst - (dfEndotrisine and 5 or 10)
					elseif self.isRunning then
						self.PsychoOutburst = self.PsychoOutburst - (dfEndotrisine and 1 or 2)
					else
						self.PsychoOutburst = self.PsychoOutburst - (dfEndotrisine and 0 or 1)
					end
					
					if self.PsychoOutburst ~= nil and self.PsychoOutburst > 3600 then
						self.CyberPsychoWarnings = self.CyberPsychoWarnings - 1
						if self.CyberPsychoWarnings == 0 then
							self.PsychoOutburst = nil
							self:StopHeartbeat()
							self.bbs:SendMessage("PSYCHOSIS CLEARED — SYSTEMS NOMINAL", 3.0)
						else
							self.PsychoOutburst = 61
							local recLevelNames = { "I", "II", "III", "IV" }
							self.bbs:SendMessage("RECOVERING — PSYCHOSIS LEVEL "..tostring(recLevelNames[self.CyberPsychoWarnings] or self.CyberPsychoWarnings), 3.0)
						end
						if self.CyberPsychoWarnings < 3 then self:StopHeartbeat() end
						self:DisableSandevistan("PsychoOutburst")
						self:SaveGame("Psycho Safe Area")
					elseif self.PsychoOutburst ~= nil and self.PsychoOutburst <= 0 then
						self.PsychoOutburst = nil
						if self:IsWearingApogee() then
							self.runTime = 0
							self.sps:EndSandevistan()
							if self.CyberPsychoWarnings >= 5 and self.cfg.enableSafetyOffKill then
								self:KillV()
							else
								self:Safety(true,true)
								self:BleedingEffect()
							end
						end
					end
					if self.PsychoOutburst ~= nil and (not self.SafetyOn) then
						self.PsychoOutburst_UI = true
						self.bbs:BlackBoardSet('UI_HUDCountdownTimer','Active',true,nil)
						self.bbs:BlackBoardSet('UI_HUDCountdownTimer','Progress',nil,self.PsychoOutburst/10)
					elseif self.PsychoOutburst_UI then
						self.PsychoOutburst_UI = nil
						self.bbs:BlackBoardSet('UI_HUDCountdownTimer','Active',false,nil)
					end
				end
			elseif self.displayTick2 == 2 then -- 1/sec +0.5 offset
				if self.CachedInMenu or self.CachedBrainDance then return end
				if self.OutstandingBuff ~= nil then
					self.OutstandingBuff = self.OutstandingBuff - 1
					if self.OutstandingBuff <= 0 then
						self.OutstandingBuff = 5.0 -- keep checking for sandevistan removal
						if self.PlayerInSafeArea or self.InDaClub or (not self.VIsInControl) and self.runTime < self.MaxRuntime then -- slowly recharge sandevistan in safe area
							self.runTime = self.runTime + 1
							if self.runTime > self.MaxRuntime then self.runTime = self.MaxRuntime end
						end
						if self.VIsDead then self:RemoveDeadV() end
						self:DisableSandevistan("OutstandingBuff")
					end
				end
				if self.ViktorCooldown ~= nil then
					self.ViktorCooldown = self.ViktorCooldown - 1
					if self.ViktorCooldown <= 0 then
						self.ViktorCooldown = nil
					end
				end
				self:Heartbeat()
			elseif self.displayTick2 == 3 then -- 1/sec +0.75 offset
				if self.CachedInMenu or self.CachedBrainDance then return end
				self:PsychoLaugh()
				if self.LoadThreeTimer ~= nil then
					self.LoadThreeTimer = self.LoadThreeTimer - 1
					if self.LoadThreeTimer <= 0 then
						self.LoadThreeTimer = nil
						self:LoadGamePart3()
						if self.dev_mode then
							print('DavidsApogee:LoadGame() GameLoadIndex=3 Completed')
						end
					end
				end
			end
		end
	 end)
	,LoadGamePart1 = (function(self)
		print('[DSP] LoadGamePart1: loading config and updating Viks loot')
		loadApogeeConfig(self.cfg)
		self:UpdateViksLoot()
		print('[DSP] LoadGamePart1: ViksLevelCheck='..tostring(self.martinez:CheckRequiredLevel())..' IsWearing='..tostring(self:IsWearingApogee()))
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
		self.HealthBrake = self.qs:LoadOverClockBrake()
		self.CyberPsychoWarnings = self.qs:LoadCyberPsycho()
		self.dailyActivations = self.qs:LoadDailyActivations()
		if self.HealthBrake == -1 then self.HealthBrake = self.cfg.healthBrakeDefault end
		if self.CyberPsychoWarnings == -1 then self.CyberPsychoWarnings = 0 end
		if self.dev_mode then
			print('DavidsApogee:LoadGame() RunTime='..tostring(self.runTime)..'seconds remaining')
		end
	 end)
	,LoadGamePart2 = (function(self)
		self:Safety(false)
		self:TimeDilationEffects()
		self:SandevistanEdgeRunnerCheck()
		self.LoadGameRun = true
		self.PlayerAttached = true
	 end)
	,LoadGamePart3 = (function(self)
		local doDebug = (self.dev_mode ~= nil)
		self.hud:Init(self,doDebug)
		self:DisableSandevistan("LoadGamePart3")
		self:UpdateUIText()
		self.OutstandingBuff = 5 -- check for sandy
		if self.cfg.enableCyberpsychosis and (self.CyberPsychoWarnings > 0) then
			self:Calculate_PsychoOutburst()
			local levelNames = { "I: UNSTABLE", "II: GLITCHING", "III: LOSING IT", "IV: ON THE EDGE", "V: CYBERPSYCHO" }
			local lvl = levelNames[self.CyberPsychoWarnings] or tostring(self.CyberPsychoWarnings)
			self.bbs:SendWarning("PSYCHOSIS ACTIVE — LEVEL "..lvl, 4.0)
		end
		if self:IsWearingApogee() then
			local rt = math.floor(self.runTime)
			local safetyState = self.SafetyOn and "SAFETY ON" or "SAFETY OFF"
			self.bbs:SendMessage("SANDEVISTAN ONLINE — "..tostring(rt).."/"..tostring(self.MaxRuntime).."s — "..safetyState, 3.5)
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
				print('DavidsApogee:LoadGame() Complete')
			end
		elseif GameLoadIndex == 1 then -- PlayerPuppet/OnGameAttached
			self:LoadGamePart1()
			if self.dev_mode then
				print('DavidsApogee:LoadGame() GameLoadIndex=1 Loading Incomplete')
			end
		elseif GameLoadIndex == 2 then -- EquipmentSystem/OnPlayerAttach
			-- SandevistanEdgeRunnerCheck uses game objects that aren't working through the whole loading process so
			-- We'll do this when we know they will be available
			self:LoadGamePart2()
			if self.dev_mode then
				print('DavidsApogee:LoadGame() GameLoadIndex=2 Complete')
			end
		elseif GameLoadIndex == 3 then -- healthbarWidgetGameController/OnPlayerAttach
			--Make sure UI controllers are up and active!
			self.LoadThreeTimer = 3
		end
	 end)
	,SaveGame = (function(self,source)
		if source == nil then source = 'unknown' end
		if self.dev_mode then
			print('DavidsApogee:SaveGame('..source..') Started')
		end
		self:SandevistanEdgeRunnerCheck(true) -- don't get into an infinite function overflom
		local GetRuntime = math.floor(self.runTime)
		if GetRuntime < 0 then GetRuntime = 0 end
		if GetRuntime > self.MaxRuntime then GetRuntime = self.MaxRuntime end
		self.qs:SaveRuntime(GetRuntime)
		self.qs:SaveOverClockBrake(self.HealthBrake)
		self.qs:SaveCyberPsycho(self.CyberPsychoWarnings)
		self.qs:SaveDailyActivations(self.dailyActivations)
		self:UpdateUIText()
		if self.dev_mode then
			print('DavidsApogee:SaveGame() Completed')
		end
	 end)
	,TimeSkip = {
		 Apogee = nil
		,GameTimeOnReset = 0
		,Reset = (function(self)
			local gts = GetSingleton('gameTimeSystem'):GetGameTime()
			self.GameTimeOnReset = gts.GetSeconds(gts)
		 end)
		,End = (function(self)
			local gts = GetSingleton('gameTimeSystem'):GetGameTime()
			local GameTimeNow = gts.GetSeconds(gts)
			local GameTimeDiffInHours = (GameTimeNow - self.GameTimeOnReset) / 3600
			self.Apogee:Rested(GameTimeDiffInHours)
			self:Reset()
			self.Apogee:UpdateSandevistanChecks()
		 end)
	 }
	--[[ GetStatPoolsSystem ]]
	,sps = {
		 Apogee = nil
		,Init = (function(self,Apogee)
			self.Apogee = Apogee
		 end)
		,InControl = (function(self)
			local V = Game.GetPlayer()
			if not IsDefined(V) then return false end
			local VEntity = V:GetEntityID()
			local SES = Game.GetStatusEffectSystem()
			if not IsDefined(SES) then return false end

			local CombatZone = not SES:HasStatusEffect(VEntity,'GameplayRestriction.NoCombat')
			self.Apogee.InDaClub = SES:HasStatusEffect(VEntity,'GameplayRestriction.InDaClub')
			local NotInSceneTier = (V:GetSceneTier() == 1)
			return NotInSceneTier and CombatZone
		 end)
		,HideNamePlates = (function(self)
			local bbs = self.Apogee.bbs
			bbs:BlackBoardSet('UI_InterfaceOptions','NPCNameplatesEnabled',false)
			bbs:BlackBoardSet('UI_InterfaceOptions','ObjectMarkersEnabled',false)
		 end)
		,ResetNamePlates = (function(self)
			local SS = Game.GetSettingsSystem()
			local npc_nameplates = SS:GetVar('/interface/hud', 'npc_nameplates'):GetValue()
			local object_markers = SS:GetVar('/interface/hud', 'object_markers'):GetValue()
			
			local bbs = self.Apogee.bbs
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
			if self.Apogee.isRunning then
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
			local SafetyOn = self.Apogee.SafetyOn
			local IsWearingCyberDeck = self:IsWearingCyberDeck()
			local IsWearingApogee = self.Apogee:IsWearingApogee()
			local GameLoaded = (IsWearingApogee ~= nil) and (IsEdgeRunner~=nil)
			local CanEdgeRunnerPerks = IsWearingApogee and IsEdgeRunner
			local CanUnbrickSandevistan = IsWearingApogee
			local CanBribeNCPD = IsWearingApogee and IsWearingCyberDeck
			local ApogeeReducedRuntime = (not IsEdgeRunner)
			local str = IsEdgeRunner and 'EdgeRunner' or 'Standard'

			return {
				 GameLoaded=GameLoaded
				,str=str
				,IsEdgeRunner=IsEdgeRunner
				,IsWearingApogee=IsWearingApogee
				,IsWearingCyberDeck=IsWearingCyberDeck
				,SafetyOn = SafetyOn
				,ApogeeReducedRuntime=ApogeeReducedRuntime
				,Rules={
					 CanEdgeRunnerPerks=CanEdgeRunnerPerks
					,CanUnbrickSandevistan=CanUnbrickSandevistan
					,CanBribeNCPD=CanBribeNCPD
				 }
			 }
		 end)
		,IsEdgeRunner = (function(self)
			if not self.Apogee.cfg.requireEdgeRunnerPerk then return true end
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
	,CreateDavidsApogee = (function(self)
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

registerForEvent('onInit', function()
	print('[DSP] onInit: starting, martinez='..tostring(davidsapogee.martinez ~= nil)..', gui='..tostring(davidsapogee.gui ~= nil))
	davidsapogee:Init()
	
    Observe('SandevistanEvents', 'OnEnter', function(self, event)
		if davidsapogee:IsWearingApogee() then
			davidsapogee:Start()
			return false
		end
    end)
	
	Observe('SandevistanEvents', 'OnExit', function(self, event)
		if davidsapogee:IsWearingApogee() then
			davidsapogee:End()
		end
    end)
	
	ObserveAfter('TimeskipGameController', 'OnInitialize', function(this)
		davidsapogee.TimeSkip:Reset()
	end)
	
	ObserveAfter('TimeskipGameController', 'OnCloseAfterFinishing', function(this,proxy)
		davidsapogee.TimeSkip:End()
	end)
	
	ObserveAfter('PlayerPuppet', 'OnGameAttached', function(this)
		if this:IsReplacer() then return end
		if Game.GetSystemRequestsHandler():IsPreGame() then return end
		
		davidsapogee.isRunning = false
		davidsapogee:LoadGame(1)
	end)

	ObserveAfter('PlayerPuppet', 'OnDetach', function(this)
		davidsapogee.PlayerAttached = false
	end)
	
	ObserveAfter('PlayerPuppet', 'OnEnterSafeZone', function(this)
		davidsapogee.sps:InControl()
		davidsapogee:SafeAreaChange(true)
	end)
	
	ObserveAfter('PlayerPuppet', 'OnExitSafeZone', function(this)
		davidsapogee.sps:InControl()
		davidsapogee:SafeAreaChange(false)
	end)
	ObserveAfter('PlayerPuppet', 'OnSceneTierChange', function(this,newState)
		-- Update VIsInControl cache and trigger Outstanding Buff
		local VIsInControl_Previous = davidsapogee.VIsInControl
		davidsapogee.VIsInControl = (newState==1)
		if VIsInControl_Previous and (not davidsapogee.VIsInControl) then -- only if it goes from on to off do we care
			davidsapogee.sps:EndSandevistan()
			davidsapogee:Safety(true,true) -- turn lift limiters off
			if davidsapogee.CyberPsychoWarnings == 5 then 
				davidsapogee.bbs:PlayShortEffect(davidsapogee.martinez.martinez_fx_onscreen_sick_start)
			end
		end
		davidsapogee:DisableSandevistan("PlayerPuppet/OnSceneTierChange")
	end)
	ObserveAfter("PhoneSystem", "OnPickupPhone",function(this, request)
		davidsapogee.sps:EndSandevistan()
	end)
	ObserveAfter("PhoneSystem", "OnUsePhone",function(this, request)
		davidsapogee.sps:EndSandevistan()
	end)

	ObserveAfter('PreventionSystem', 'OnHeatChanged', function(this, previousHeat)
		davidsapogee:HeatLevelChanged(this.heatStage,previousHeat,this.heatChangeReason)
	end)

	ObserveAfter('EquipmentSystem', 'OnPlayerAttach', function(this)
		davidsapogee:LoadGame(2)
	end)
	
	ObserveAfter("healthbarWidgetGameController", "OnPlayerAttach", function(this, value)
		davidsapogee:LoadGame(3)
	end)

	ObserveAfter('RipperDocGameController', 'OnArmorBarFinalizedEvent', function(this,value)
		local VDM = this.VendorDataManager
		if VDM == nil then return end
		local VendorName = GetLocalizedText(VDM:GetVendorName())
		davidsapogee:VisitedRipper(VendorName)
	end)
	
	Observe('NPCPuppet', 'OnAfterDeathOrDefeat', function(npcPuppet,DefeatEvt)
		if not IsDefined(npcPuppet) then return end
		davidsapogee:BuffNPCPsychoGlitch(npcPuppet,false)
	end)
	Observe('NPCPuppet', 'OnPreUninitialize', function(npcPuppet,DefeatEvt)
		if not IsDefined(npcPuppet) then return end
		davidsapogee:BuffNPCPsychoGlitch(npcPuppet,false)
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
		davidsapogee:BuffNPCPsychoGlitch(npcPuppet,TurnOn)
	end)

	Observe('gameuiPhotoModeMenuController', 'OnShow', function()
		davidsapogee.isPhotoMode = true
	end)

	Observe('gameuiPhotoModeMenuController', 'OnHide', function()
		davidsapogee.isPhotoMode = false
	end)
end)

registerForEvent('onUpdate', function(dt)
    davidsapogee:Running(dt)
    davidsapogee:UpdateTremor(dt)
    davidsapogee:UpdateFOVPulse(dt)
    davidsapogee:UpdateTerminalClarity(dt)
end)

registerForEvent("onDraw", function()
	if davidsapogee.gui ~= nil then
		if (not davidsapogee.LoadGameRun) and (not davidsapogee.TriedLoadGameRun) then print('David\'s Apogee Restarted') davidsapogee:LoadGame() end -- this should only happen when CET is restarted
		davidsapogee.gui:Draw()
	end
end)

registerForEvent("onOverlayOpen", function()
	if davidsapogee.gui ~= nil then
		davidsapogee.gui:ShowWindow(true)
	end
end)

registerForEvent("onOverlayClose", function()
	if davidsapogee.gui ~= nil then
		davidsapogee.gui:ShowWindow(false)
	end
end)

registerInput("ToggleSandyNoSafety", 'Toggle Sandevistan Safety On/Off', function(isKeyDown)
    davidsapogee:ToggleSafety(isKeyDown)
end)
