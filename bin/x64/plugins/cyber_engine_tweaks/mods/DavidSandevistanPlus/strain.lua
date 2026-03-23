local strain = {}

function strain.attach(dsp)
	print('[DSP] strain.lua attached')

	-- Thresholds: higher at low stages (slow progression), lower at high stages (dangerous)
	-- Stages 0-1 have NO guaranteed ceiling — only dice rolls
	dsp.GetStrainThreshold = (function(self)
		local thresholds = { [0]=80, [1]=70, [2]=60, [3]=50, [4]=40, [5]=30 }
		return thresholds[self.CyberPsychoWarnings] or 80
	 end)

	dsp.GetStrainGuaranteed = (function(self)
		-- Stages 0-1: no guaranteed (nil = dice only, never forced)
		-- Stage 5: guaranteed exists (point of no return)
		local guaranteed = { [2]=100, [3]=90, [4]=80, [5]=70 }
		return guaranteed[self.CyberPsychoWarnings]
	 end)

	-- Stage-based strain multiplier: body resists at low stages, normal at high
	local stageStrainMult = { [0]=0.5, [1]=0.5, [2]=0.75, [3]=1.0, [4]=1.0, [5]=1.0 }

	-- Passive strain per second at high stages (chrome consuming you)
	local passiveStrainPerSec = { [4]=0.1, [5]=0.2 }

	-- AddStrain: raw=true bypasses stage multiplier (kills, runtime stress — psychological/physical, not tolerance)
	-- AddStrain: raw=false applies stage multiplier (Sandy activation, overuse — body tolerance)
	dsp.AddStrain = (function(self, amount, raw)
		if not self.cfg.enableCyberpsychosis then return end
		if self.lastBreath then return end
		local eff = self:GetImmunoblockerEffectiveness()
		-- Immunoblocker reduces strain accumulation: full=80%, partial=50%, ineffective/none=0%
		local immunoReduction = { full = 0.8, partial = 0.5 }
		local reduction = immunoReduction[eff] or 0
		local effective = amount * (1 - reduction)
		-- Stage multiplier only for tolerance-based strain (Sandy use), not for kills/runtime
		local mult = self.cfg.strainBuildupMultiplier or 1.0
		if not raw then
			mult = mult * (stageStrainMult[self.CyberPsychoWarnings] or 1.0)
		end
		self.neuralStrain = self.neuralStrain + (effective * mult)
		-- Cap at guaranteed if it exists, otherwise cap at 100
		local guaranteed = self:GetStrainGuaranteed()
		local cap = guaranteed or 100
		if self.neuralStrain > cap then self.neuralStrain = cap end
	 end)

	-- Passive strain tick: called once per second from displayTick
	dsp.UpdatePassiveStrain = (function(self)
		if not self.cfg.enableCyberpsychosis then return end
		if self.lastBreath then return end
		local passive = passiveStrainPerSec[self.CyberPsychoWarnings]
		if not passive then return end
		-- Immunoblocker reduces passive strain too
		local eff = self:GetImmunoblockerEffectiveness()
		local immunoReduction = { full = 0.8, partial = 0.5 }
		local reduction = immunoReduction[eff] or 0
		local effective = passive * (1 - reduction) * (self.cfg.strainBuildupMultiplier or 1.0)
		self.neuralStrain = self.neuralStrain + effective
		local guaranteed = self:GetStrainGuaranteed()
		local cap = guaranteed or 100
		if self.neuralStrain > cap then self.neuralStrain = cap end
	 end)

	dsp.CheckStrainEpisode = (function(self)
		-- Called once per second in displayTick. Returns true if episode fires.
		if not self.cfg.enableCyberpsychosis then return false end
		if self.lastBreath then return false end
		local threshold = self:GetStrainThreshold()
		local guaranteed = self:GetStrainGuaranteed()
		if self.neuralStrain < threshold then return false end

		-- Stage 5 guaranteed: forced episode (point of no return)
		if guaranteed and self.CyberPsychoWarnings >= 5 and self.neuralStrain >= guaranteed then
			self:TriggerStrainEpisode()
			return true
		end

		-- Stages 2-4 at guaranteed: 75% chance per second (never 100% inevitable)
		if guaranteed and self.neuralStrain >= guaranteed then
			if math.random() < 0.75 then
				self:TriggerStrainEpisode()
				return true
			end
			return false
		end

		-- Between threshold and guaranteed (or threshold and 100 for stages 0-1):
		-- Progressive dice roll, slower than before
		local ceiling = guaranteed or 100
		local range = ceiling - threshold
		if range <= 0 then return false end
		local progress = (self.neuralStrain - threshold) / range
		-- Max 5% per second at top of range (was ~20% before)
		local chance = progress * 0.05
		if math.random() < chance then
			self:TriggerStrainEpisode()
			return true
		end
		return false
	 end)

	dsp.TriggerStrainEpisode = (function(self)
		-- Fire a psycho episode: escalate level, MartinezFury, reset strain
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
			pcall(function() Game.GetAudioSystem():Play(CName.new("quickhack_cyberpsychosis_mech")) end)
			self:Safety(true,true)
			self:BleedingEffect()
		end
	 end)
end

return strain
