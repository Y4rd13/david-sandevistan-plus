local death = {}

function death.attach(apogee)
	print('[DSP] death.lua attached')

	apogee.lastBreathPeaceTime = 20  -- 5s wait + 5s ramp + 10s peak, then decay
	apogee.lastBreathRuntime = 245   -- seconds of runtime for the last stand (matches song duration 4:05)

	apogee.KillV = (function(self)
		-- Terminal clarity: David snaps out of psychosis right before death (Ep 10)
		-- Remove all VFX for a brief moment of lucidity before flatline
		self:RemoveAllPsychoVFX()
		self:StatusEffect_CheckAndRemove(self.martinez.SafetiesOffStatusEffect)
		self:StatusEffect_CheckAndRemove(self.martinez.BleedingStatusEffect)
		self.tremor.intensity = 0
		self:StopHeartbeat()
		self.nextLaughTime = nil
		local V = Game.GetPlayer()
		if V and IsDefined(V) then
			pcall(function() V:SetWarningMessage("DAVID... IT'S TIME TO STOP") end)
		end
		self.bbs:SendWarning("DAVID... IT'S TIME TO STOP", 4.0)
		self.terminalClarity = { elapsed = 0, duration = 4.0 }
	 end)

	apogee.KillV_Execute = (function(self)
		self.terminalClarity = nil
		if self.lastBreathDeath then
			-- Permanent death after Last Breath — no second chances
			self.lastBreathDeath = nil
			self.lastBreath = nil
			self.isRunning = false
			self:TimeDilationEffects_AllOff()
			self.bbs:SendWarning("DAVID MARTINEZ — FLATLINED", 6.0)
			self:StatusEffect_CheckAndApply('BaseStatusEffect.HeartAttack')
			self.VIsDead = true
			self.cheatedDeath = false  -- Second Heart already fired, no loop
			self.OutstandingBuff = 6
		else
			self.bbs:SendWarning("SYSTEM FAILURE — NEURAL COLLAPSE", 4.0)
			self:StatusEffect_CheckAndApply('BaseStatusEffect.HeartAttack')
			self.VIsDead = true
			self.cheatedDeath = true
			self.OutstandingBuff = 6
		end
	 end)

	apogee.RemoveDeadV = (function(self)
		local V = Game.GetPlayer()
		if not IsDefined(V) then return end
		self.VIsDead = false
		self:StatusEffect_CheckAndRemove('BaseStatusEffect.HeartAttack')
		if not V.incapacitated then
			self:StatusEffect_CheckAndRemove('GameplayRestriction.BlockAllHubMenu')
		end
		if self.cheatedDeath then
			self.cheatedDeath = false
			self.CyberPsychoWarnings = 5
			self.neuralStrain = 0  -- No more strain — death comes from runtime

			-- Initialize Last Breath state
			self.runTime = math.max(self.runTime, self.lastBreathRuntime)
			local rt = self.runTime
			self.lastBreath = {
				phase = "peace",
				elapsed = 0,
				peaceTime = self.lastBreathPeaceTime,
				totalRuntime = rt,
				songPlaying = false,
				-- Song-synced decay state (see docs/dilation-curves.md)
				nextTimeBombTime = nil,
				nextBlackwallTime = nil,
				nextVLaugh = nil,
				immunityActive = true,   -- 0-31s: Verse 1, health floor 25%
				vfxStarted = false,      -- 35s: Pre-Chorus 1, CyberpsychoSafetyOff VFX
				chorus1Fired = false,    -- 58s: Chorus 1 drop, first TTB+Blackwall
				prechorus2Started = false,-- 126s: Pre-Chorus 2, TTB resumes
				chorus2Fired = false,    -- 149s: Chorus 2, dual TTB+Blackwall
				bridgeStarted = false,   -- 171s: Bridge, moment of clarity
				bridgeEnded = false,     -- 187s: Pre-Chorus 3, VFX return
				peakFired = false,       -- 203s: Final Chorus, PEAK BURST
				outroStarted = false,    -- 221s: Outro, effects fade
			}

			-- Remove ALL effects — moment of peace
			self:RemoveAllPsychoVFX()
			self:StatusEffect_CheckAndRemove(self.martinez.SafetiesOffStatusEffect)
			self:StatusEffect_CheckAndRemove(self.martinez.BleedingStatusEffect)
			self:StatusEffect_CheckAndRemove('BaseStatusEffect.MinorBleeding')
			self:StatusEffect_CheckAndRemove(self.martinez.ComedownEffect)
			self.MinorBleedingOn = false
			self.tremor.intensity = 0
			self:StopHeartbeat()
			self.nextLaughTime = nil
			self.nextPsychoMsgTime = nil
			self.comedownTimer = nil
			self.comedownTremor = false

			-- Sandy and song are DEFERRED — let V breathe after revival
			-- 3s: song starts, 5s: Sandy activates, 15s: decay begins
			self.isRunning = false  -- not yet
			self.sandyStartRuntime = rt
			self.lowRuntimeWarned = false
			self.lastTick = self.TickLength + 0.001
			self.SafetyOn = false

			self.bbs:SendWarning("CYBERPSYCHOSIS VI — UNCLASSIFIED — LAST BREATH", 6.0)

			-- Delayed lore message
			self.lastBreathMessage = { elapsed = 0, duration = 4.0, sent = false }
		end
	 end)

	apogee.PlayLastBreathSong = (function(self)
		self.hud:PlaySong()
		print('[DSP] LastBreath song: Audioware play requested')
		return true
	 end)

	apogee.StopLastBreathSong = (function(self)
		self.hud:StopSong()
		print('[DSP] LastBreath song: Audioware stop requested')
	 end)

	apogee.UpdateLastBreath = (function(self, dt)
		if not self.lastBreath then return end

		self.lastBreath.elapsed = self.lastBreath.elapsed + dt

		-- Force time dilation via TimeSystem directly (bypasses Sandy state machine)
		if self.lastBreath.phase == "peace" then
			local elapsed = self.lastBreath.elapsed

			-- 3s: Start the song
			if elapsed >= 3 and not self.lastBreath.songPlaying then
				self.lastBreath.songPlaying = self:PlayLastBreathSong()
			end

			-- 5s+: Activate Sandy with ramp curve (90% → 99.35% over 5s, then peak)
			if elapsed >= 5 then
				if not self.isRunning then
					self.isRunning = true
					self.lastTick = self.TickLength + 0.001
				end
				local timeScale
				if elapsed < 10 then
					-- Ramp: 90% → 99.35% (timeScale 0.10 → 0.0065) over 5s
					local rampProgress = (elapsed - 5) / 5
					timeScale = 0.10 + (0.0065 - 0.10) * rampProgress
				else
					-- Peak: hold at 99.35%
					timeScale = 0.0065
				end
				pcall(function()
					local ts = Game.GetTimeSystem()
					ts:SetIgnoreTimeDilationOnLocalPlayerZero(true)
					ts:SetTimeDilation("sandevistan", timeScale)
				end)
				pcall(function() self.sps:SandevistanCharge(100) end)
			end

			-- Transition to decay after peaceTime
			if elapsed >= self.lastBreathPeaceTime then
				self.lastBreath.phase = "decay"
				self.lastBreath.elapsed = 0
			end

		elseif self.lastBreath.phase == "decay" then
			-- ================================================================
			-- SONG-SYNCED DECAY (see docs/dilation-curves.md)
			-- Song starts at peace +3s, decay starts at peace +20s = song 0:17
			-- song_time ≈ decayElapsed + 17
			-- ================================================================
			local de = self.lastBreath.elapsed
			local totalRT = self.lastBreath.totalRuntime
			if totalRT <= 0 then totalRT = 1 end
			local rtRatio = self.runTime / totalRT
			if rtRatio < 0 then rtRatio = 0 end
			if rtRatio > 1 then rtRatio = 1 end
			local now = os.clock()

			-- Keep Sandy forced on
			if not self.isRunning then
				self.isRunning = true
				self.lastTick = self.TickLength + 0.001
			end

			-- Update time dilation: degrades from 99.35% → 90% with exp 2.5 curve
			pcall(function()
				local timeScale = 0.10 + (0.0065 - 0.10) * (rtRatio ^ 2.5)
				local ts = Game.GetTimeSystem()
				ts:SetIgnoreTimeDilationOnLocalPlayerZero(true)
				ts:SetTimeDilation("sandevistan", timeScale)
			end)
			pcall(function() self.sps:SandevistanCharge(100) end)

			-- ========================================
			-- IMMUNITY: 0-31s (Song: Verse 1)
			-- ========================================
			if de < 31 then
				self.lastBreath.immunityActive = true
				local health = self.sps:getHealth(true)
				if health < 25 then
					pcall(function()
						local V = Game.GetPlayer()
						local SPS = Game.GetStatPoolsSystem()
						SPS:RequestChangingStatPoolValue(V:GetEntityID(), gamedataStatPoolType.Health, 25 - health, V, true, false)
					end)
				end
			else
				if self.lastBreath.immunityActive then
					self.lastBreath.immunityActive = false
					self.bbs:SendWarning("IMMUNITY FADING", 3.0)
				end
			end

			-- ========================================
			-- PRE-CHORUS 1: 35s (Song 0:52) — VFX begin
			-- ========================================
			if de >= 35 and not self.lastBreath.vfxStarted then
				self.lastBreath.vfxStarted = true
				self:StatusEffect_CheckAndApply(self.martinez.CyberpsychoSafetyOffEffect)
				self.bbs:SendWarning("NEURAL COLLAPSE IMMINENT", 4.0)
				self.tremor.intensity = 0.003
			end

			-- ========================================
			-- CHORUS 1: 58s (Song 1:15) — Beat drops
			-- ========================================
			if de >= 58 and not self.lastBreath.chorus1Fired then
				self.lastBreath.chorus1Fired = true
				self:TickingTimeBomb()
				self.lastBreath.nextBlackwallTime = now + 2
				self.tremor.intensity = 0.006
				self.nextPsychoMsgTime = now + math.random(4, 8)
				self.lastBreath.nextVLaugh = now + math.random(10, 18)
				self.bbs:SendWarning("SYSTEM OVERLOAD", 3.0)
			end

			-- Active window: Chorus 1 → Verse 2 (58-96s)
			if de >= 58 and de < 96 then
				self.tremor.intensity = 0.006
				-- TTB intervals
				if self.lastBreath.nextTimeBombTime == nil then
					self.lastBreath.nextTimeBombTime = now + math.random(15, 25)
				elseif now >= self.lastBreath.nextTimeBombTime then
					self:TickingTimeBomb()
					self.lastBreath.nextTimeBombTime = now + math.random(15, 25)
				end
				-- Blackwall intervals
				if self.lastBreath.nextBlackwallTime and now >= self.lastBreath.nextBlackwallTime then
					self:BlackwallKill()
					self.lastBreath.nextBlackwallTime = now + math.random(25, 40)
				end
			end

			-- ========================================
			-- VERSE 2: 96-126s (Song 1:53) — Calm
			-- ========================================
			if de >= 96 and de < 126 then
				self.tremor.intensity = 0.003
				-- No TTB/Blackwall — window is inactive
				self.lastBreath.nextTimeBombTime = nil
				self.lastBreath.nextBlackwallTime = nil
				-- Slow down messages and laughs during calm
				self.lastBreath.nextVLaugh = nil
				self.nextPsychoMsgTime = now + 9999
			end

			-- ========================================
			-- PRE-CHORUS 2: 126s (Song 2:23) — Tension builds
			-- ========================================
			if de >= 126 and not self.lastBreath.prechorus2Started then
				self.lastBreath.prechorus2Started = true
				self.tremor.intensity = 0.005
				self.lastBreath.nextTimeBombTime = now + math.random(8, 15)
				self.nextPsychoMsgTime = now + math.random(5, 10)
				self.lastBreath.nextVLaugh = now + math.random(10, 20)
			end

			-- Active window: Pre-Chorus 2 → Bridge (126-171s)
			if de >= 126 and de < 171 then
				-- TTB intervals (accelerating)
				if self.lastBreath.nextTimeBombTime and now >= self.lastBreath.nextTimeBombTime then
					self:TickingTimeBomb()
					self.lastBreath.nextTimeBombTime = now + math.random(10, 18)
				end
			end

			-- ========================================
			-- CHORUS 2: 149s (Song 2:46) — Full intensity
			-- ========================================
			if de >= 149 and not self.lastBreath.chorus2Fired then
				self.lastBreath.chorus2Fired = true
				self:TickingTimeBomb()
				self:BlackwallKill()
				self.tremor.intensity = 0.010
				self.lastBreath.nextTimeBombTime = now + math.random(8, 12)
				self.lastBreath.nextBlackwallTime = now + math.random(12, 20)
				self.bbs:SendWarning("NEURAL CASCADE ACCELERATING", 3.0)
			end

			-- Active window: Chorus 2 → Bridge (149-171s)
			if de >= 149 and de < 171 then
				self.tremor.intensity = 0.010
				if self.lastBreath.nextBlackwallTime and now >= self.lastBreath.nextBlackwallTime then
					self:BlackwallKill()
					self.lastBreath.nextBlackwallTime = now + math.random(12, 20)
				end
			end

			-- ========================================
			-- BRIDGE: 171-187s (Song 3:08) — Moment of clarity
			-- ========================================
			if de >= 171 and de < 187 then
				if not self.lastBreath.bridgeStarted then
					self.lastBreath.bridgeStarted = true
					-- Strip EVERYTHING — mirror the peace phase
					self:RemoveAllPsychoVFX()
					self:StatusEffect_CheckAndRemove(self.martinez.CyberpsychoSafetyOffEffect)
					self.tremor.intensity = 0
					-- Block PsychoMessage() re-scheduling during bridge (huge future value)
					self.nextPsychoMsgTime = now + 9999
					self.lastBreath.nextVLaugh = nil
					self.lastBreath.nextTimeBombTime = nil
					self.lastBreath.nextBlackwallTime = nil
					self.bbs:SendWarning("...", 4.0)
				end
				-- Keep effects suppressed during bridge
				self.tremor.intensity = 0
				self.nextPsychoMsgTime = now + 9999
			end

			-- ========================================
			-- PRE-CHORUS 3: 187s (Song 3:24) — Final build
			-- ========================================
			if de >= 187 and not self.lastBreath.bridgeEnded then
				self.lastBreath.bridgeEnded = true
				self:StatusEffect_CheckAndApply(self.martinez.CyberpsychoSafetyOffEffect)
				self.tremor.intensity = 0.006
				self.nextPsychoMsgTime = now + math.random(2, 4)
				self.lastBreath.nextVLaugh = now + math.random(4, 8)
				self.bbs:SendWarning("NO... NOT YET...", 3.0)
			end

			-- Tremor build during Pre-Chorus 3 (187-203s)
			if de >= 187 and de < 203 then
				local buildProgress = (de - 187) / (203 - 187)
				self.tremor.intensity = 0.006 + buildProgress * 0.006
			end

			-- ========================================
			-- FINAL CHORUS: 203s (Song 3:40) — CLIMAX
			-- ========================================
			if de >= 203 and not self.lastBreath.peakFired then
				self.lastBreath.peakFired = true
				self:TickingTimeBomb()
				self:BlackwallKill()
				self.tremor.intensity = 0.015
				self.lastBreath.nextTimeBombTime = now + math.random(4, 8)
				self.lastBreath.nextBlackwallTime = now + math.random(6, 10)
				self.bbs:SendWarning("NEURAL CASCADE — CRITICAL OVERLOAD", 3.0)
			end

			-- Active window: Final Chorus (203-221s) — Maximum intensity
			if de >= 203 and de < 221 then
				self.tremor.intensity = 0.015
				if self.lastBreath.nextTimeBombTime and now >= self.lastBreath.nextTimeBombTime then
					self:TickingTimeBomb()
					self.lastBreath.nextTimeBombTime = now + math.random(4, 8)
				end
				if self.lastBreath.nextBlackwallTime and now >= self.lastBreath.nextBlackwallTime then
					self:BlackwallKill()
					self.lastBreath.nextBlackwallTime = now + math.random(6, 10)
				end
			end

			-- ========================================
			-- OUTRO: 221s+ (Song 3:58) — Fade out
			-- ========================================
			if de >= 221 then
				if not self.lastBreath.outroStarted then
					self.lastBreath.outroStarted = true
					self.lastBreath.nextTimeBombTime = nil
					self.lastBreath.nextBlackwallTime = nil
					self.lastBreath.nextVLaugh = nil
					self.nextPsychoMsgTime = now + 9999
				end
				-- Tremor fades over 10s
				local fadeProgress = math.min((de - 221) / 10, 1.0)
				self.tremor.intensity = 0.015 * (1 - fadeProgress)
			end

			-- ========================================
			-- V's laugh (song-phase aware)
			-- ========================================
			if self.lastBreath.nextVLaugh and now >= self.lastBreath.nextVLaugh then
				local V = Game.GetPlayer()
				if V and IsDefined(V) then
					pcall(function() V:PlaySoundEvent("ono_v_laugh_long") end)
					self:StatusEffect_CheckAndApply(self.martinez.PsychoLaughEffect)
				end
				if de >= 187 and de < 221 then
					-- Pre-Chorus 3 + Final Chorus: frequent laughs
					self.lastBreath.nextVLaugh = now + math.random(6, 12)
				elseif de >= 58 and de < 171 then
					-- Chorus 1 through Chorus 2: moderate laughs
					self.lastBreath.nextVLaugh = now + math.random(12, 22)
				else
					self.lastBreath.nextVLaugh = nil
				end
			end

			-- ========================================
			-- Psycho messages (song-phase aware)
			-- ========================================
			if self.nextPsychoMsgTime and now >= self.nextPsychoMsgTime then
				self:PsychoMessage()
				if de >= 187 and de < 221 then
					-- Final build + chorus: rapid messages
					self.nextPsychoMsgTime = now + math.random(2, 5)
				elseif de >= 58 and de < 171 then
					-- Active phases: moderate
					self.nextPsychoMsgTime = now + math.random(4, 8)
				else
					self.nextPsychoMsgTime = nil
				end
			end

			-- ========================================
			-- DEATH: runtime depleted
			-- ========================================
			if self.runTime <= 0 then
				self:StopLastBreathSong()
				self:StopHeartbeat()
				self.lastBreath = nil
				-- Restore normal time
				pcall(function()
					local ts = Game.GetTimeSystem()
					ts:UnsetTimeDilation("sandevistan")
					ts:SetIgnoreTimeDilationOnLocalPlayerZero(false)
				end)
				self:RemoveAllPsychoVFX()
				self.tremor.intensity = 0
				self.nextLaughTime = nil
				self.nextPsychoMsgTime = nil
				local V = Game.GetPlayer()
				if V and IsDefined(V) then
					pcall(function() V:SetWarningMessage("THE MOON... I CAN SEE IT") end)
				end
				self.bbs:SendWarning("THE MOON... I CAN SEE IT", 3.0)
				self.terminalClarity = { elapsed = 0, duration = 3.0 }
				self.lastBreathDeath = true
			end
		end
	 end)

	apogee.TickingTimeBomb = (function(self)
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end

		-- VFX on V (screen glitch)
		self:StatusEffect_CheckAndApply(self.martinez.TickingTimeBombEffect)

		-- EMP sound
		pcall(function()
			local evt = SoundPlayEvent.new()
			evt.soundName = "quickhack_shortcircuit"
			V:QueueEvent(evt)
		end)

		-- AoE stun on nearby hostile NPCs within 20m
		local vPos = V:GetWorldPosition()
		local stunCount = 0
		local SEE = Game.GetStatusEffectSystem()
		for eid, npc in pairs(self.combatNPCs) do
			pcall(function()
				if npc and IsDefined(npc) and not npc:IsDead() then
					local npcPos = npc:GetWorldPosition()
					local dx = vPos.x - npcPos.x
					local dy = vPos.y - npcPos.y
					local dz = vPos.z - npcPos.z
					local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
					if dist <= 20.0 then
						local npcEID = npc:GetEntityID()
						-- Stun: built-in stun with visible animation
						SEE:ApplyStatusEffect(npcEID, 'BaseStatusEffect.Stun')
						-- EMP: electromagnetic pulse VFX + disables weapons
						SEE:ApplyStatusEffect(npcEID, 'BaseStatusEffect.EMP')
						-- Electrocuted: electrical arcing VFX on the NPC
						SEE:ApplyStatusEffect(npcEID, 'BaseStatusEffect.Electrocuted')
						self:BuffNPCPsychoGlitch(npc, true)
						stunCount = stunCount + 1
					end
				end
			end)
		end

		StimBroadcasterComponent.BroadcastStim(V, gamedataStimType.Explosion, 30.0)

		if stunCount > 0 then
			self.bbs:SendWarning("EMP DISCHARGE — "..tostring(stunCount).." STUNNED", 2.0)
		end
	 end)

	apogee.BlackwallKill = (function(self)
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end

		-- Heavy Blackwall VFX on V (screen distortion)
		self:StatusEffect_CheckAndApply(self.martinez.BlackwallKillEffect)

		-- Blackwall sound
		pcall(function()
			local evt = SoundPlayEvent.new()
			evt.soundName = "quickhack_shortcircuit"
			V:QueueEvent(evt)
		end)

		-- AoE kill on nearby hostile NPCs within 25m
		-- Uses SystemCollapse (quickhack kill with dramatic VFX/animation on each NPC)
		local vPos = V:GetWorldPosition()
		local killCount = 0
		local SEE = Game.GetStatusEffectSystem()
		for eid, npc in pairs(self.combatNPCs) do
			pcall(function()
				if npc and IsDefined(npc) and not npc:IsDead() then
					local npcPos = npc:GetWorldPosition()
					local dx = vPos.x - npcPos.x
					local dy = vPos.y - npcPos.y
					local dz = vPos.z - npcPos.z
					local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
					if dist <= 25.0 then
						local npcEID = npc:GetEntityID()
						-- NetwatcherGeneral: glitch/hacked VFX (digital corruption)
						SEE:ApplyStatusEffect(npcEID, 'BaseStatusEffect.NetwatcherGeneral')
						-- SystemCollapse: quickhack kill with dramatic animation
						SEE:ApplyStatusEffect(npcEID, 'BaseStatusEffect.SystemCollapse')
						-- ForceKill as backup (ensures death even if SystemCollapse doesn't kill)
						SEE:ApplyStatusEffect(npcEID, 'BaseStatusEffect.ForceKill')
						killCount = killCount + 1
					end
				end
			end)
		end

		StimBroadcasterComponent.BroadcastStim(V, gamedataStimType.Explosion, 30.0)

		if killCount > 0 then
			self.bbs:SendWarning("BLACKWALL PROTOCOL — "..tostring(killCount).." FLATLINED", 3.0)
		end
	 end)
end

return death
