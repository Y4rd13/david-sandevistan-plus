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

	-- Blackout wakeup locations
	local blackoutLocations = {
		{ name = "apartment", pos = { x = -1204.0, y = 1842.0, z = 115.0 }, yaw = 180,  chance = 0.6,
		  messages = {
			"Home... don't remember coming back",
			"Woke up in bed... how long was I out?",
			"Back at the apartment... everything's blurry",
		  }},
		{ name = "viktor", pos = { x = -1554.434, y = 1239.794, z = 11.520 }, yaw = 0, chance = 0.3,
		  messages = {
			"Viktor's clinic... he must have found me",
			"Woke up at Doc's... head's splitting",
			"\"You collapsed again, kid.\" ...sorry, Doc",
		  }},
		{ name = "alley", pos = { x = -1286.9, y = -1686.1, z = 44.2 }, yaw = 90, chance = 0.1,
		  messages = {
			"Woke up in an alley... no idea how I got here",
			"Cold concrete... how long was I out?",
			"Some alley... everything hurts",
		  }},
	}

	local function selectBlackoutLocation()
		local roll = math.random()
		local cumulative = 0
		for _, loc in ipairs(blackoutLocations) do
			cumulative = cumulative + loc.chance
			if roll <= cumulative then return loc end
		end
		return blackoutLocations[1]
	end

	dsp.ExhaustionCheck = (function(self)
		-- Exhaustion collapse: David passes out after 8 uses in Ep 2
		-- Trigger at 3x safe activations
		if not self.cfg.enableCyberpsychosis then return end
		local threshold = self:getEffectiveSafeActivations() * 3
		if self.dailyActivations < threshold then return end
		if not self.isRunning then return end

		-- Stage 5 Safety OFF: no blackout — death path (David doesn't pass out, he fights to the end)
		if self.CyberPsychoWarnings >= 5 and not self.SafetyOn then
			return -- handled by TriggerStrainEpisode → KillV
		end

		-- Stages 0-4 (or stage 5 Safety ON): blackout sequence
		self.sps:EndSandevistan()
		self:RemoveAllPsychoVFX()
		self:StopHeartbeat()
		self:RemoveRuntimeStamina()
		self.runTime = 0

		-- Pre-blackout VFX + message
		self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
		self.bbs:SendWarning("Body gives out... everything goes dark", 4.0)
		print('[DSP] ExhaustionCheck: blackout triggered at stage '..tostring(self.CyberPsychoWarnings))

		-- Start blackout sequence (managed via onUpdate timer)
		local location = selectBlackoutLocation()
		local hoursSkipped = math.random(4, 8)
		self.blackoutState = {
			phase = 'darken',
			elapsed = 0,
			location = location,
			hoursSkipped = hoursSkipped,
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
			-- Phase 2: teleport + time skip (1.0s after blackout)
			if bs.elapsed >= 1.0 then
				local V = Game.GetPlayer()
				if not V or not IsDefined(V) then return end
				local loc = bs.location

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

				-- Advance time
				pcall(function()
					local ts = Game.GetTimeSystem()
					local now = ts:GetGameTimeStamp()
					ts:SetGameTimeBySeconds(math.floor(now + bs.hoursSkipped * 3600))
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

				-- Apply sleep recovery
				pcall(function()
					self:Rested(bs.hoursSkipped)
				end)

				-- Restore player state
				pcall(function()
					GameTimeUtils.FastForwardPlayerState(V)
				end)

				-- Remove blackout (eyes open)
				Game.GetStatusEffectSystem():RemoveStatusEffect(V:GetEntityID(),
					TweakDBID.new('BaseStatusEffect.CyberwareInstallationAnimationBlackout'))

				-- Brief groggy VFX
				self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)

				-- Reduce health (didn't rest properly)
				pcall(function()
					local healthPct = math.random(50, 70)
					self.sps:damage(100 - healthPct)
				end)

				-- Wakeup message
				local loc = bs.location
				local msg = loc.messages[math.random(#loc.messages)]
				self.bbs:SendWarning(msg, 5.0)

				print('[DSP] Blackout: woke up at '..loc.name..' after '..tostring(bs.hoursSkipped)..'h')
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
