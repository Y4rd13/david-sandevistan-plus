local psychosis = {}

-- Data tables (module-local, not on dsp)
local psychoSafeMultiplier = { [0] = 1, [1] = 1.7, [2] = 2.3, [3] = 3, [4] = 4 }

local psychoMessages_lv4 = {
	"I CAN STILL GO",
	"JUST ONE MORE TIME",
	"I'M FINE... I'M FINE",
	"DOC SAID THREE TIMES...",
	"I CAN HANDLE IT",
	"I'M BUILT DIFFERENT",
	"NOBODY SETS MY LIMITS",
	"I PROMISED I'D MAKE IT",
	"CAN'T STOP NOW",
	"DAVID... IT'S TIME TO STOP",
}

local psychoMessages_lv5 = {
	"THEY CAN'T KEEP UP WITH ME",
	"LUCY...",
	"MAINE... IS THAT YOU?",
	"I'M NOT DONE YET",
	"MOM... GLORIA?",
	"MY BODY MOVES ON ITS OWN",
	"EVERYTHING IS SO SLOW",
	"THE CHROME... IT SINGS",
	"WHO'S IN THE MIRROR?",
	"NINE TIMES THE DOSE...",
	"BETTER IN METAL THAN SKIN",
	"KEEP RUNNING DAVID",
	"GLIDING ALONG THE EDGE",
	"YOU'LL END UP LIKE MAINE",
	"THE MOON... I CAN SEE IT",
	"DAVID MARTINEZ DIED HERE",
	"DAVID... IT'S TIME TO STOP",
	"DAVID... IT'S TIME TO STOP",
}

-- Stage 6 messages: delusional, Lucy-focused, can't recognize self (Ep 10)
local psychoMessages_lastBreath = {
	"LUCY...",
	"LUCY... WAIT FOR ME",
	"LUCY... I CAN SEE THE MOON",
	"LUCY... I PROMISED",
	"WHERE ARE YOU?",
	"WHO AM I?",
	"WHO'S DAVID?",
	"IS THAT... ME?",
	"I CAN'T FEEL MY HANDS",
	"MY BODY WON'T STOP",
	"I'M STILL RUNNING",
	"I CAN'T STOP RUNNING",
	"EVERYTHING IS SO BEAUTIFUL",
	"ALMOST THERE... ALMOST...",
	"MOM... GLORIA... I'M SORRY",
	"MAINE... I UNDERSTAND NOW",
	"THE MOON... SO CLOSE",
	"I PROMISED I'D TAKE YOU",
	"DON'T CRY... LUCY...",
	"I CAN SEE EVERYTHING",
}

local prescriptionTable = {
	[0] = { 0, 0 },
	[1] = { 1, 0 },
	[2] = { 2, 0 },
	[3] = { 3, 1 },
	[4] = { 5, 2 },
	[5] = { 7, 3 },
}

-- Micro-episode pool: { type, minLevel, weight, effectKey, duration }
local microEpisodePool = {
	{ type = "visual_glitch",  minLevel = 1, weight = 10, duration = { 0.5, 1.5 } },
	{ type = "tremor_burst",   minLevel = 2, weight = 7,  duration = { 1.0, 3.0 } },
	{ type = "nosebleed",      minLevel = 2, weight = 5,  duration = { 3.0, 3.0 } },
	{ type = "manic_laugh",    minLevel = 3, weight = 4,  duration = { 3.0, 3.0 } },
	{ type = "sandy_flash",    minLevel = 3, weight = 3,  duration = { 1.0, 2.0 } },
	{ type = "medium_glitch",  minLevel = 4, weight = 2,  duration = { 1.5, 3.0 } },
}

-- Micro-episode interval ranges by psycho level (min, max in seconds)
local microEpisodeIntervals = {
	[1] = { 300, 600 },   -- 5-10 min
	[2] = { 120, 300 },   -- 2-5 min
	[3] = { 30, 120 },    -- 30s-2min
	[4] = { 15, 60 },     -- 15s-1min
	[5] = { 5, 15 },      -- 5-15s
}

function psychosis.attach(dsp)
	print('[DSP] psychosis.lua attached')

	-- Psycho-scaled safe activations: higher psycho = higher tolerance
	dsp.getEffectiveSafeActivations = (function(self)
		local base = self.cfg.dailySafeActivations or 3
		if not self.cfg.enableCyberpsychosis then return base end
		if self.CyberPsychoWarnings >= 5 then return 999 end
		local mult = psychoSafeMultiplier[self.CyberPsychoWarnings] or 1
		return math.floor(base * mult)
	 end)

	dsp.BuffNPCPsychoGlitch = (function(self,npcPuppet,TurnOn)
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

	dsp.BleedingEffect = (function(self, forcePsycho)
		if self.runTime > 0 and not forcePsycho then
			self:StatusEffect_CheckAndApply('BaseStatusEffect.MinorBleeding')
		else
			if self.cfg.enableCyberpsychosis then
				if self.CyberPsychoWarnings < 5 then self.CyberPsychoWarnings = self.CyberPsychoWarnings + 1 end
				local psychoMessages = {
					[1] = { msg = "CYBERPSYCHOSIS I \xe2\x80\x94 NEURAL INSTABILITY DETECTED", dur = 4.0 },
					[2] = { msg = "CYBERPSYCHOSIS II \xe2\x80\x94 SENSORY GLITCHES INCREASING", dur = 4.0 },
					[3] = { msg = "CYBERPSYCHOSIS III \xe2\x80\x94 LOSING GRIP ON REALITY", dur = 5.0 },
					[4] = { msg = "CYBERPSYCHOSIS IV \xe2\x80\x94 CRITICAL \xe2\x80\x94 REST NOW", dur = 5.0 },
					[5] = { msg = "CYBERPSYCHO V \xe2\x80\x94 POINT OF NO RETURN", dur = 6.0 },
				}
				local entry = psychoMessages[self.CyberPsychoWarnings]
				if entry then self.bbs:SendWarning(entry.msg, entry.dur) end
				self:FrightenNPCs()
			end
			self:DisableSandevistan("BleedingEffect()")
			self:SaveGame("BleedingEffect()")
		end
	 end)

	dsp.FrightenNPCs = (function(self)
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
		-- Reset strain after episode fires (accumulation starts fresh)
		self.neuralStrain = 0
	 end)

	dsp.PsychoLaugh = (function(self)
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

	dsp.PsychoMessage = (function(self)
		if not self.cfg.enableCyberpsychosis then return end
		if self.CyberPsychoWarnings < 4 and not self.lastBreath then
			self.nextPsychoMsgTime = nil
			return
		end
		if self.CachedInMenu or self.CachedBrainDance then return end

		local now = os.clock()
		local isLastBreath = (self.lastBreath ~= nil and self.lastBreath.phase == "decay")

		if self.nextPsychoMsgTime == nil then
			if isLastBreath then
				self.nextPsychoMsgTime = now + math.random(4, 8)
			elseif self.CyberPsychoWarnings >= 5 then
				self.nextPsychoMsgTime = now + math.random(8, 18)
			else
				self.nextPsychoMsgTime = now + math.random(15, 35)
			end
			return
		end

		if now < self.nextPsychoMsgTime then return end

		local msgs
		if isLastBreath then
			msgs = psychoMessages_lastBreath
		elseif self.CyberPsychoWarnings >= 5 then
			msgs = psychoMessages_lv5
		else
			msgs = psychoMessages_lv4
		end
		local msg = msgs[math.random(1, #msgs)]
		local V = Game.GetPlayer()
		if V and IsDefined(V) then
			pcall(function() V:SetWarningMessage(msg) end)
		end

		if isLastBreath then
			self.nextPsychoMsgTime = now + math.random(4, 8)
		elseif self.CyberPsychoWarnings >= 5 then
			self.nextPsychoMsgTime = now + math.random(8, 18)
		else
			self.nextPsychoMsgTime = now + math.random(15, 35)
		end
	 end)

	dsp.GetPrescription = (function(self, level)
		local entry = prescriptionTable[level]
		if entry then return entry[1], entry[2] end
		return 0, 0
	 end)

	dsp.ResetMicroEpisodeTimer = (function(self)
		if not self.cfg.enableMicroEpisodes then self.microEpisodeTimer = nil return end
		if self.CyberPsychoWarnings < 1 then self.microEpisodeTimer = nil return end
		local interval = microEpisodeIntervals[self.CyberPsychoWarnings]
		if not interval then self.microEpisodeTimer = nil return end
		local freq = self.cfg.microEpisodeFrequency or 1.0
		local minT = interval[1] / freq
		local maxT = interval[2] / freq
		if minT < 3 then minT = 3 end
		if maxT < minT then maxT = minT end
		self.microEpisodeTimer = minT + math.random() * (maxT - minT)
	 end)

	dsp.FireMicroEpisode = (function(self)
		-- Martinez Protocol: reactive auto-injection prevents micro-episode
		if self:TryAutoInject() then return end
		if self.CachedInMenu or self.CachedBrainDance then return end
		if self.comedownTimer then return end
		if self.lastBreath then return end
		local dfImmuno = self:StatusEffect_CheckOnly('DarkFutureStatusEffect.Immunosuppressant')
		if dfImmuno then return end
		local eff = self:GetImmunoblockerEffectiveness()
		if eff == 'full' then return end  -- fully effective: suppresses all micro-episodes
		if eff == 'partial' and math.random() < 0.5 then return end  -- partial: 50% chance to suppress
		-- 'ineffective' or 'none': micro-episodes fire normally

		-- Build eligible pool
		local eligible = {}
		local totalWeight = 0
		for _, ep in ipairs(microEpisodePool) do
			if self.CyberPsychoWarnings >= ep.minLevel and ep.type ~= self.lastMicroEpisodeType then
				totalWeight = totalWeight + ep.weight
				eligible[#eligible + 1] = ep
			end
		end
		if #eligible == 0 then return end

		-- Weighted random selection
		local roll = math.random() * totalWeight
		local cumulative = 0
		local selected = eligible[1]
		for _, ep in ipairs(eligible) do
			cumulative = cumulative + ep.weight
			if roll <= cumulative then selected = ep break end
		end
		self.lastMicroEpisodeType = selected.type

		-- Apply effect
		local dur = selected.duration[1] + math.random() * (selected.duration[2] - selected.duration[1])
		if selected.type == "visual_glitch" then
			self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Light)
		elseif selected.type == "tremor_burst" then
			self.tremor.intensity = math.max(self.tremor.intensity, 0.012)
		elseif selected.type == "nosebleed" then
			self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
		elseif selected.type == "manic_laugh" then
			self:StatusEffect_CheckAndApply(self.martinez.PsychoLaughEffect)
		elseif selected.type == "sandy_flash" then
			if not self.isRunning and self:IsWearingSandevistan() then
				self.bbs:StartSandevistan()
				self.microEpisodeSandyFlash = dur
			end
		elseif selected.type == "medium_glitch" then
			self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Medium)
		end

		-- Auto-remove brief effects after duration
		if selected.type == "visual_glitch" or selected.type == "medium_glitch" then
			self.microEpisodeCleanup = { timer = dur, type = selected.type }
		end

		if self.dev_mode then
			print('[DSP] Micro-episode: '..selected.type..' dur='..string.format("%.1f",dur)..'s psycho='..tostring(self.CyberPsychoWarnings))
		end
	 end)
end

return psychosis
