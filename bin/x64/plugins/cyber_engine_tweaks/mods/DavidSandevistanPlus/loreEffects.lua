local loreEffects = {}

function loreEffects.attach(apogee)
	print('[DSP] loreEffects.lua attached')

	apogee.UpdateTremor = (function(self, dt)
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

	apogee.UpdateFOVPulse = (function(self, dt)
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

	apogee.UpdateTerminalClarity = (function(self, dt)
		if not self.terminalClarity then return end
		self.terminalClarity.elapsed = self.terminalClarity.elapsed + dt
		if self.terminalClarity.elapsed >= self.terminalClarity.duration then
			self:KillV_Execute()
		end
	 end)

	apogee.Heartbeat = (function(self)
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

	apogee.StopHeartbeat = (function(self)
		if not self.heartbeatPlaying then return end
		self.heartbeatPlaying = false
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end
		local evt = SoundStopEvent.new()
		evt.soundName = "q004_sc_04a_heartbeat"
		V:QueueEvent(evt)
	 end)

	apogee.Nosebleed = (function(self)
		-- Nosebleed VFX after overuse (David bleeds from the nose in Ep 2,3,5,9)
		if not self.cfg.enableCyberpsychosis then return end
		if self.dailyActivations <= self:getEffectiveSafeActivations() then return end
		self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
	 end)

	apogee.ExhaustionCheck = (function(self)
		-- Exhaustion collapse: David passes out after 8 uses in Ep 2
		-- Trigger at 3x safe activations — forced deactivation + stagger
		if not self.cfg.enableCyberpsychosis then return end
		local threshold = self:getEffectiveSafeActivations() * 3
		if self.dailyActivations < threshold then return end
		if not self.isRunning then return end

		self.sps:EndSandevistan()
		self:StatusEffect_CheckAndApply('BaseStatusEffect.Stun')
		self.bbs:SendWarning("Body gives out... pushed too far today", 4.0)
		-- Force a brief cooldown by draining some runtime
		self.runTime = math.max(self.runTime - 30, 0)
		self:SaveGame("ExhaustionCollapse")
	 end)

	apogee.RandomNosebleed = (function(self)
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

	apogee.GetEffectiveMaxRuntime = (function(self)
		if not self.cfg.enableRuntimeDegradation then return self.MaxRuntime end
		local degraded = self.maxRuntimeDegraded or 0
		local maxLoss = self.MaxRuntime * 0.5
		if degraded > maxLoss then degraded = maxLoss end
		return math.max(self.MaxRuntime - degraded, self.MaxRuntime * 0.5)
	 end)
end

return loreEffects
