local strain = {}

function strain.attach(apogee)
	print('[DSP] strain.lua attached')

	apogee.GetStrainThreshold = (function(self)
		local thresholds = { [0]=60, [1]=50, [2]=40, [3]=30, [4]=20, [5]=10 }
		return thresholds[self.CyberPsychoWarnings] or 60
	 end)

	apogee.GetStrainGuaranteed = (function(self)
		local guaranteed = { [0]=100, [1]=90, [2]=80, [3]=70, [4]=60, [5]=50 }
		return guaranteed[self.CyberPsychoWarnings] or 100
	 end)

	apogee.AddStrain = (function(self, amount)
		if not self.cfg.enableCyberpsychosis then return end
		if self.lastBreath then return end
		local eff = self:GetImmunoblockerEffectiveness()
		if eff == 'full' or eff == 'partial' then return end  -- effective/partial: blocks strain accumulation
		-- 'ineffective' or 'none': strain accumulates normally
		self.neuralStrain = self.neuralStrain + amount
		local guaranteed = self:GetStrainGuaranteed()
		if self.neuralStrain > guaranteed then self.neuralStrain = guaranteed end
	 end)

	apogee.CheckStrainEpisode = (function(self)
		-- Called once per second in displayTick. Returns true if episode fires.
		if not self.cfg.enableCyberpsychosis then return false end
		if self.CyberPsychoWarnings == 0 then return false end
		if self.lastBreath then return false end
		local threshold = self:GetStrainThreshold()
		local guaranteed = self:GetStrainGuaranteed()
		if self.neuralStrain < threshold then return false end
		-- At or above guaranteed: forced episode
		if self.neuralStrain >= guaranteed then
			self:TriggerStrainEpisode()
			return true
		end
		-- Between threshold and guaranteed: dice roll each second
		local chance = (self.neuralStrain - threshold) / 200
		if math.random() < chance then
			self:TriggerStrainEpisode()
			return true
		end
		return false
	 end)

	apogee.TriggerStrainEpisode = (function(self)
		-- Fire a psycho episode: escalate level, MartinezFury, reset strain
		self.runTime = 0
		self.sps:EndSandevistan()
		if self.CyberPsychoWarnings >= 5 and self.cfg.enableSafetyOffKill then
			self:KillV()
		else
			self:Safety(true,true)
			self:BleedingEffect()
		end
	 end)
end

return strain
