local loreEffects = {}

function loreEffects.attach(dsp)
	print('[DSP] loreEffects.lua attached')

	dsp.UpdateTremor = (function(self, dt)
		if self.isPhotoMode or self.CachedInMenu or self.CachedBrainDance then
			self.tremor.intensity = 0
			return
		end

		-- Target intensity scales with psycho level
		local target = 0
		if self.CyberPsychoWarnings == 1 then target = 0.001
		elseif self.CyberPsychoWarnings == 2 then target = 0.0015
		elseif self.CyberPsychoWarnings == 3 then target = 0.002
		elseif self.CyberPsychoWarnings == 4 then target = 0.004
		elseif self.CyberPsychoWarnings >= 5 then target = 0.008
		end
		-- Overuse adds tremor even before psychosis
		if self.dailyActivations > self:getEffectiveSafeActivations() * 2 then
			target = math.max(target, 0.002)
		end
		-- Low runtime adds tremor (body exhaustion)
		if self.isRunning then
			local rtPct = self:GetRuntimePercent()
			if rtPct < 10 then
				target = math.max(target, 0.006)
			elseif rtPct < 30 then
				target = math.max(target, 0.003)
			end
		end
		-- Comedown tremor at psycho 3+
		if self.comedownTremor then
			target = math.max(target, 0.003)
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

	dsp.UpdateFOVPulse = (function(self, dt)
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

	dsp.UpdateTerminalClarity = (function(self, dt)
		if not self.terminalClarity then return end
		self.terminalClarity.elapsed = self.terminalClarity.elapsed + dt
		if self.terminalClarity.elapsed >= self.terminalClarity.duration then
			self:KillV_Execute()
		end
	 end)

	dsp.Heartbeat = (function(self)
		if self.CachedInMenu or self.CachedBrainDance then return end
		-- Heartbeat at psycho 2+ (constant — David's heart races as psychosis builds)
		local shouldBeat = self.CyberPsychoWarnings >= 2

		if shouldBeat and not self.heartbeatPlaying then
			local V = Game.GetPlayer()
			if not V or not IsDefined(V) then return end
			local evt = SoundPlayEvent.new()
			evt.soundName = "q004_sc_04a_heartbeat"
			V:QueueEvent(evt)
			self.heartbeatPlaying = true
		elseif not shouldBeat and self.heartbeatPlaying then
			self:StopHeartbeat()
		end
	 end)

	dsp.StopHeartbeat = (function(self)
		if not self.heartbeatPlaying then return end
		self.heartbeatPlaying = false
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end
		local evt = SoundStopEvent.new()
		evt.soundName = "q004_sc_04a_heartbeat"
		V:QueueEvent(evt)
	 end)

	dsp.Nosebleed = (function(self)
		-- Nosebleed VFX after overuse or low runtime (David bleeds in Ep 2,3,5,9)
		if not self.cfg.enableCyberpsychosis then return end
		local trigger = false
		-- Overuse: activations beyond safe limit
		if self.dailyActivations > self:getEffectiveSafeActivations() then trigger = true end
		-- Low runtime: activating Sandy when body is exhausted
		if self:GetRuntimePercent() < 30 then trigger = true end
		if trigger then
			self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
		end
	 end)

	-- Blackout wakeup locations with type (ripper vs apartment)
	local blackoutLocations = {
		{ name = "apartment", type = "apartment",
		  pos = { x = -1204.0, y = 1842.0, z = 115.0 }, yaw = 180,
		  strainDrain = 15, runtimeRestore = 0.25, healthRange = {40, 60}, hoursRange = {6, 10},
		  treatmentDose = 0.5,
		  messages = {
			"Home... crashed hard, head's pounding",
			"Woke up in bed... don't remember coming back",
			"Back at the apartment... everything's blurry",
		  }},
		{ name = "viktor", type = "ripper",
		  pos = { x = -1554.434, y = 1239.794, z = 11.520 }, yaw = 0,
		  strainDrain = 25, runtimeRestore = 0.50, healthRange = {60, 70}, hoursRange = {4, 6},
		  treatmentDose = 1.0,
		  messages = {
			"Viktor's clinic... he patched me up again",
			"Woke up at Doc's... head's splitting",
			"\"You collapsed again, kid.\" ...sorry, Doc",
		  }},
		{ name = "kabuki_ripper", type = "ripper",
		  pos = { x = -993.03, y = 1487.29, z = 25.90 }, yaw = -300,
		  strainDrain = 25, runtimeRestore = 0.50, healthRange = {60, 70}, hoursRange = {4, 6},
		  treatmentDose = 1.0,
		  messages = {
			"Some clinic in Kabuki... who brought me here?",
			"Woke up at a ripper's... don't remember the ride",
			"Kabuki... the doc says I was out cold",
		  }},
	}

	-- Find nearest blackout location within maxDist meters
	local function findNearestBlackoutLocation(vPos, maxDist)
		local nearest = nil
		local nearestDist = maxDist + 1
		for _, loc in ipairs(blackoutLocations) do
			local dx = vPos.x - loc.pos.x
			local dy = vPos.y - loc.pos.y
			local dist = math.sqrt(dx*dx + dy*dy)
			if dist < nearestDist then
				nearestDist = dist
				nearest = loc
			end
		end
		if nearestDist <= maxDist then return nearest end
		return nil
	end

	-- Blackout chance by stage
	local blackoutChance = { [0]=0.9, [1]=0.7, [2]=0.4, [3]=0.15 }

	dsp.blackoutToday = false  -- reset on sleep

	dsp.ExhaustionCheck = (function(self)
		-- Exhaustion collapse: David passes out after 8 uses in Ep 2
		-- Trigger at 3x safe activations
		if not self.cfg.enableCyberpsychosis then return end
		local threshold = self:getEffectiveSafeActivations() * 3
		if self.dailyActivations < threshold then return end
		if not self.isRunning then return end

		-- Stage 4-5: no blackout — psychosis/death path
		if self.CyberPsychoWarnings >= 4 then return end

		-- Already blacked out today
		if self.blackoutToday then return end

		-- Stage-based chance
		local chance = blackoutChance[self.CyberPsychoWarnings] or 0
		if math.random() > chance then return end

		-- Pre-blackout VFX (like Wannabe Edgerunner)
		pcall(function()
			local V = Game.GetPlayer()
			if V and IsDefined(V) then
				local evt = SoundPlayEvent.new()
				evt.soundName = "ONO_V_LongPain"
				V:QueueEvent(evt)
			end
		end)
		self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
		self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Light)

		-- End Sandy
		self.sps:EndSandevistan()
		self:RemoveAllPsychoVFX()
		self:StopHeartbeat()
		self:RemoveRuntimeStamina()
		self.runTime = 0

		-- Check distance to nearest safe location (200m max)
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end
		local vPos = V:GetWorldPosition()
		local location = findNearestBlackoutLocation(vPos, 200)

		if not location then
			-- Too far from any safe location: stun only, no teleport
			self:StatusEffect_CheckAndApply('BaseStatusEffect.Stun')
			self.bbs:SendWarning("Body gives out... can't move...", 4.0)
			print('[DSP] ExhaustionCheck: too far for blackout, stun only')
			return
		end

		-- Close enough: full blackout sequence
		self.blackoutToday = true
		self.bbs:SendWarning("Body gives out... everything goes dark", 4.0)
		print('[DSP] ExhaustionCheck: blackout to '..location.name..' at stage '..tostring(self.CyberPsychoWarnings))

		self.blackoutState = {
			phase = 'darken',
			elapsed = 0,
			location = location,
			hoursSkipped = math.random(location.hoursRange[1], location.hoursRange[2]),
		}
	 end)

	-- Blackout sequence phases (called from onUpdate)
	dsp.UpdateBlackout = (function(self, dt)
		if not self.blackoutState then return end
		local bs = self.blackoutState
		bs.elapsed = bs.elapsed + dt

		if bs.phase == 'darken' then
			-- Phase 1: screen goes dark (0.5s after trigger)
			if bs.elapsed >= 0.5 then
				local V = Game.GetPlayer()
				if not V or not IsDefined(V) then return end
				Game.GetStatusEffectSystem():ApplyStatusEffect(V:GetEntityID(),
					TweakDBID.new('BaseStatusEffect.CyberwareInstallationAnimationBlackout'))
				bs.phase = 'teleport'
				bs.elapsed = 0
			end

		elseif bs.phase == 'teleport' then
			-- Phase 2: teleport (1.0s after blackout)
			if bs.elapsed >= 1.0 then
				local V = Game.GetPlayer()
				if not V or not IsDefined(V) then return end
				local loc = bs.location

				-- Fast travel glitch VFX (like Wannabe Edgerunner)
				pcall(function()
					local evt = SoundPlayEvent.new()
					evt.soundName = "fast_travel_glitch"
					V:QueueEvent(evt)
				end)

				-- Clear wanted level
				pcall(function()
					local ps = Game.GetScriptableSystemsContainer():Get(CName.new('PreventionSystem'))
					if ps then ps:ChangeHeatStage(EPreventionHeatStage.Heat_0, CName.new('BLACKOUT')) end
				end)

				-- Teleport
				pcall(function()
					Game.GetTeleportationFacility():Teleport(V,
						Vector4.new(loc.pos.x, loc.pos.y, loc.pos.z, 1.0),
						EulerAngles.new(0, 0, loc.yaw))
				end)

				bs.phase = 'wakeup'
				bs.elapsed = 0
			end

		elseif bs.phase == 'wakeup' then
			-- Phase 3: wake up (2.0s after teleport)
			if bs.elapsed >= 2.0 then
				local V = Game.GetPlayer()
				if not V or not IsDefined(V) then
					self.blackoutState = nil
					return
				end
				local loc = bs.location

				-- Location-specific recovery
				-- Strain drain: ripper drains more than apartment
				self.neuralStrain = math.max((self.neuralStrain or 0) - loc.strainDrain, 0)

				-- Runtime restore: ripper restores more
				local effectiveMax = self:GetEffectiveMaxRuntime()
				self.runTime = math.min(self.runTime + effectiveMax * loc.runtimeRestore, effectiveMax)

				-- Treatment dose: ripper = 1 full dose, apartment = 0.5
				if self.prescribedDoses > 0 then
					self.completedDoses = math.min((self.completedDoses or 0) + loc.treatmentDose, self.prescribedDoses)
				end

				-- Apartment can reduce psycho level (like sleep)
				if loc.type == "apartment" and self.CyberPsychoWarnings > 0 then
					local maxRecovery = self.cfg.maxPsychoRecoveryPerSleep or 1
					self.CyberPsychoWarnings = math.max(self.CyberPsychoWarnings - maxRecovery, 0)
					self:SyncSafetyWithStage()
				end

				-- Reset daily activations (V rested)
				self.dailyActivations = 0
				self.sessionActivations = 0

				-- Restore player state
				pcall(function()
					GameTimeUtils.FastForwardPlayerState(V)
				end)

				-- Advance game time
				pcall(function()
					local ts = Game.GetTimeSystem()
					local now = ts:GetGameTimeStamp()
					ts:SetGameTimeBySeconds(math.floor(now + bs.hoursSkipped * 3600))
				end)

				-- Remove blackout (eyes open)
				Game.GetStatusEffectSystem():RemoveStatusEffect(V:GetEntityID(),
					TweakDBID.new('BaseStatusEffect.CyberwareInstallationAnimationBlackout'))

				-- Brief groggy VFX
				self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)

				-- Health based on location type
				pcall(function()
					local healthPct = math.random(loc.healthRange[1], loc.healthRange[2])
					self.sps:damage(100 - healthPct)
				end)

				-- Wakeup message
				local msg = loc.messages[math.random(#loc.messages)]
				self.bbs:SendWarning(msg, 5.0)

				print('[DSP] Blackout: woke up at '..loc.name..' ('..loc.type..') after '..tostring(bs.hoursSkipped)..'h, strain=-'..tostring(loc.strainDrain))
				self:SaveGame("BlackoutWakeup")
				self.blackoutState = nil
			end
		end
	 end)

	dsp.RandomNosebleed = (function(self)
		-- Random nosebleed at psycho 2+ even when Sandy is off (David bled unprompted — Ep 3,5,9)
		if not self.cfg.enableCyberpsychosis then return end
		if self.CyberPsychoWarnings < 2 then self.nextNosebleedTime = nil return end
		if self.CachedInMenu or self.CachedBrainDance then return end
		if self.lastBreath then return end
		local eff = self:GetImmunoblockerEffectiveness()
		if eff == 'full' then return end

		local now = os.clock()
		if self.nextNosebleedTime == nil then
			local intervals = { [2]=300, [3]=180, [4]=90, [5]=45 }
			local base = intervals[self.CyberPsychoWarnings] or 180
			self.nextNosebleedTime = now + base + math.random(0, base)
			return
		end
		if now < self.nextNosebleedTime then return end

		self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
		local intervals = { [2]=240, [3]=120, [4]=60, [5]=30 }
		local base = intervals[self.CyberPsychoWarnings] or 120
		self.nextNosebleedTime = now + base + math.random(0, base)
	 end)

	-- Stage-based max runtime multiplier: higher psychosis = body endures less
	local stageRuntimeMult = { [0]=1.0, [1]=0.9, [2]=0.8, [3]=0.65, [4]=0.5, [5]=0.35 }

	dsp.GetEffectiveMaxRuntime = (function(self)
		local base = self.MaxRuntime
		-- Stage multiplier: body deteriorates with psychosis
		local stageMult = stageRuntimeMult[self.CyberPsychoWarnings] or 1.0
		base = base * stageMult
		-- Degradation from sustained use
		if self.cfg.enableRuntimeDegradation then
			local degraded = self.maxRuntimeDegraded or 0
			local maxLoss = self.MaxRuntime * 0.5
			if degraded > maxLoss then degraded = maxLoss end
			base = base - degraded
		end
		return math.max(base, self.MaxRuntime * 0.1)
	 end)

	-- Helper: get runtime as percentage of effective max
	dsp.GetRuntimePercent = (function(self)
		local effectiveMax = self:GetEffectiveMaxRuntime()
		if effectiveMax <= 0 then return 0 end
		return (self.runTime / effectiveMax) * 100
	 end)
end

return loreEffects
