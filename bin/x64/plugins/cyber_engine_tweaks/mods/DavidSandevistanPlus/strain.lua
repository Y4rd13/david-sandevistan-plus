local strain = {}

-- Hoisted tables (created once at require time, not per-call)
local strainThresholds = { [0]=100, [1]=85, [2]=70, [3]=55, [4]=40, [5]=30 }
local strainGuaranteed = { [2]=120, [3]=100, [4]=80, [5]=70 }
local immunoReduction = { full = 0.8, partial = 0.5 }

function strain.attach(dsp)
	print('[DSP] strain.lua attached')

	dsp.GetStrainThreshold = (function(self)
		return strainThresholds[self.CyberPsychoWarnings] or 100
	 end)

	dsp.GetStrainGuaranteed = (function(self)
		return strainGuaranteed[self.CyberPsychoWarnings]
	 end)

	-- Stage-based strain multiplier: body resists at low stages, normal at high
	local stageStrainMult = { [0]=0.5, [1]=0.5, [2]=0.75, [3]=1.0, [4]=1.0, [5]=1.0 }

	-- Passive strain per second at high stages (chrome consuming you)
	-- Tuned so stage 4 reaches threshold (~40) in ~4.8min, stage 5 in ~2.8min (without combat/immunoblocker)
	local passiveStrainPerSec = { [4]=0.04, [5]=0.08 }

	-- Natural strain decay at low stages (body can still recover on its own)
	-- Stage 3+ = no natural decay (needs external help)
	local naturalDecayPerSec = { [0]=-0.03, [1]=-0.02, [2]=-0.01 }

	-- Episode cooldown: minimum in-game hours between stage changes
	-- Prevents speed-running through all stages in one session
	-- Lore: nervous system needs time to destabilize further after each episode
	local episodeCooldownHours = { [1]=48, [2]=36, [3]=24, [4]=12, [5]=6 }

	-- AddStrain: raw=true bypasses stage multiplier (kills, runtime stress — psychological/physical, not tolerance)
	-- AddStrain: raw=false applies stage multiplier (Sandy activation, overuse — body tolerance)
	dsp.AddStrain = (function(self, amount, raw)
		if not self.cfg.enableCyberpsychosis then return end
		if self.lastBreath then return end
		local eff = self:GetImmunoblockerEffectiveness()
		local reduction = immunoReduction[eff] or 0
		local effective = amount * (1 - reduction)
		-- Stage multiplier only for tolerance-based strain (Sandy use), not for kills/runtime
		local mult = self.cfg.strainBuildupMultiplier or 1.0
		if not raw then
			mult = mult * (stageStrainMult[self.CyberPsychoWarnings] or 1.0)
		end
		self.neuralStrain = self.neuralStrain + (effective * mult)
		-- Cap at guaranteed if it exists, otherwise cap at 150 (stages 0-1 need headroom above threshold)
		local guaranteed = self:GetStrainGuaranteed()
		local cap = guaranteed or 150
		if self.neuralStrain > cap then self.neuralStrain = cap end
	 end)

	-- Passive strain tick: called once per second from displayTick
	dsp.UpdatePassiveStrain = (function(self)
		if not self.cfg.enableCyberpsychosis then return end
		if self.lastBreath then return end
		local stage = self.CyberPsychoWarnings

		-- Stages 4-5: strain INCREASES passively (chrome consuming you)
		local passive = passiveStrainPerSec[stage]
		if passive then
			local eff = self:GetImmunoblockerEffectiveness()
			local reduction = immunoReduction[eff] or 0
			local effective = passive * (1 - reduction) * (self.cfg.strainBuildupMultiplier or 1.0)
			-- Treatment milestone reduction
			local milestoneReduction = self.treatmentMilestoneStrainMult or 1.0
			effective = effective * milestoneReduction
			self.neuralStrain = self.neuralStrain + effective
			local guaranteed = self:GetStrainGuaranteed()
			local cap = guaranteed or 150
			if self.neuralStrain > cap then self.neuralStrain = cap end
			return
		end

		-- Stages 0-2: strain DECAYS naturally (body recovers on its own)
		local decay = naturalDecayPerSec[stage]
		if not decay then return end  -- stage 3: no natural decay
		if self.isRunning then return end  -- no decay while Sandy active
		local rate = math.abs(decay) * (self.cfg.strainRecoveryMultiplier or 1.0)
		-- Immunoblocker active: decay rate ×2
		local eff = self:GetImmunoblockerEffectiveness()
		if eff == 'full' or eff == 'partial' then rate = rate * 2.0 end
		-- Treatment milestone reduction (applied as faster decay)
		local milestoneReduction = self.treatmentMilestoneStrainMult or 1.0
		if milestoneReduction < 1.0 then
			rate = rate * (1.0 + (1.0 - milestoneReduction))  -- e.g. 0.7 mult → 1.3x faster decay
		end
		self.neuralStrain = math.max(self.neuralStrain - rate, 0)
	 end)

	dsp.CheckStrainEpisode = (function(self)
		-- Called once per second in displayTick, but dice only roll every 15s
		if not self.cfg.enableCyberpsychosis then return false end
		if self.lastBreath then return false end
		-- Suppress during dialogues/cutscenes — strain builds but episodes wait
		if not self.VIsInControl then return false end
		-- Episode cooldown: nervous system needs time to destabilize after each episode
		-- Treatment milestone DYNAMICALLY extends cooldown (evaluated every check, not just at set time)
		if self.episodeCooldownUntil then
			local ok, now = pcall(function()
				local ts = Game.GetTimeSystem()
				return ts:GetGameTimeStamp()
			end)
			if ok then
				local effectiveEnd = self.episodeCooldownUntil
				if self.treatmentActive and (self.treatmentMilestone or 0) > 0 then
					local nextStage = math.min(self.CyberPsychoWarnings + 1, 5)
					local baseH = episodeCooldownHours[nextStage] or 24
					local factor = 1.0 + ((self.treatmentMilestone or 0) / 3.0) * 2.0
					local extensionSec = (baseH * 3600) * (factor - 1.0)
					effectiveEnd = self.episodeCooldownUntil + extensionSec
				end
				if now < effectiveEnd then return false end
			end
			-- Cooldown expired
			self.episodeCooldownUntil = nil
		end
		local threshold = self:GetStrainThreshold()
		local guaranteed = self:GetStrainGuaranteed()
		if self.neuralStrain < threshold then
			self.nextStrainDiceTime = nil
			return false
		end

		-- Stage 5 guaranteed: forced episode (point of no return)
		if guaranteed and self.CyberPsychoWarnings >= 5 and self.neuralStrain >= guaranteed then
			self:TriggerStrainEpisode()
			return true
		end

		-- Throttle dice rolls to every 15 seconds
		local now = os.clock()
		if not self.nextStrainDiceTime then
			self.nextStrainDiceTime = now + 15
			return false
		end
		if now < self.nextStrainDiceTime then return false end
		self.nextStrainDiceTime = now + 15

		-- Stages 2-4 at guaranteed: 50% chance per roll
		if guaranteed and self.neuralStrain >= guaranteed then
			if math.random() < 0.50 then
				self:TriggerStrainEpisode()
				return true
			end
			return false
		end

		-- Between threshold and guaranteed (or threshold and 150 for stages 0-1):
		-- Progressive dice roll every 15s
		local ceiling = guaranteed or 150
		local range = ceiling - threshold
		if range <= 0 then return false end
		local progress = (self.neuralStrain - threshold) / range
		-- Max 20% per roll (every 15s). At halfway: 10%. Takes several rolls.
		local chance = progress * 0.20
		if math.random() < chance then
			self:TriggerStrainEpisode()
			return true
		end
		return false
	 end)

	dsp.TriggerStrainEpisode = (function(self)
		-- Fire a psycho episode: escalate level, MartinezFury, reset strain
		-- Set episode cooldown (game time) — prevents rapid stage jumping
		-- NOTE: treatment milestone protection is applied dynamically in CheckStrainEpisode
		local nextStage = math.min(self.CyberPsychoWarnings + 1, 5)
		local cooldownH = episodeCooldownHours[nextStage]
		if cooldownH then
			pcall(function()
				local ts = Game.GetTimeSystem()
				local now = ts:GetGameTimeStamp()
				local mult = self.cfg.episodeCooldownMultiplier or 1.0
				self.episodeCooldownUntil = now + (cooldownH * mult * 3600)
				self.qs:SaveEpisodeCooldown(self.episodeCooldownUntil)
			end)
		end

		-- Stage 5 Safety OFF: Sandy stays active — David doesn't stop in Ep 10
		if self.CyberPsychoWarnings >= 5 and not self.SafetyOn then
			-- Sandy stays ON, no runtime drain — episode happens mid-dilation
			self:FrightenNPCs()
			if self.cfg.enableSafetyOffKill then
				self:KillV()
			end
		else
			-- Stages 0-4 (or stage 5 Safety ON): Sandy shuts down
			self.runTime = 0
			self.sps:EndSandevistan()
			pcall(function()
				local V = Game.GetPlayer()
				if V and IsDefined(V) then
					local evt = SoundPlayEvent.new()
					evt.soundName = "quickhack_cyberpsychosis_mech"
					V:QueueEvent(evt)
				end
			end)
			self:Safety(true,true)
			self:BleedingEffect()
		end
	 end)
end

return strain
