local psychosis = {}

-- Data tables (module-local, not on dsp)
local psychoSafeMultiplier = { [0] = 1, [1] = 1.7, [2] = 2.3, [3] = 3, [4] = 4 }

-- Hallucination spawn intervals by stage (seconds)
local hallucinationIntervals = { [3] = {180, 300}, [4] = {60, 180}, [5] = {30, 60} }

-- Helper: schedule next PsychoMessage based on context
local function scheduleNextPsychoMsg(self, now, isLastBreath)
	if isLastBreath then
		self.nextPsychoMsgTime = now + math.random(4, 8)
	elseif self.CyberPsychoWarnings >= 5 then
		self.nextPsychoMsgTime = now + math.random(30, 90)
	else
		self.nextPsychoMsgTime = now + math.random(15, 35)
	end
end

local psychoMessages_lv4 = {
	{ msg = "I CAN STILL GO",             voice = "psycho4_01" },
	{ msg = "JUST ONE MORE TIME",          voice = "psycho4_02" },
	{ msg = "I'M FINE... I'M FINE",        voice = "psycho4_03" },
	{ msg = "DOC SAID THREE TIMES...",     voice = "psycho4_04" },
	{ msg = "I CAN HANDLE IT",            voice = "psycho4_05" },
	{ msg = "I'M BUILT DIFFERENT",         voice = "psycho4_06" },
	{ msg = "NOBODY SETS MY LIMITS",       voice = "psycho4_07" },
	{ msg = "I PROMISED I'D MAKE IT",      voice = "psycho4_08" },
	{ msg = "CAN'T STOP NOW",             voice = "psycho4_09" },
	{ msg = "DAVID... IT'S TIME TO STOP",  voice = "psycho4_10" },
}

local psychoMessages_lv5 = {
	{ msg = "THEY CAN'T KEEP UP WITH ME",  voice = "psycho5_01" },
	{ msg = "LUCY...",                      voice = "psycho5_02" },
	{ msg = "MAINE... IS THAT YOU?",        voice = "psycho5_03" },
	{ msg = "I'M NOT DONE YET",            voice = "psycho5_04" },
	{ msg = "MOM... GLORIA?",              voice = "psycho5_05" },
	{ msg = "MY BODY MOVES ON ITS OWN",    voice = "psycho5_06" },
	{ msg = "EVERYTHING IS SO SLOW",        voice = "psycho5_07" },
	{ msg = "THE CHROME... IT SINGS",       voice = "psycho5_08" },
	{ msg = "WHO'S IN THE MIRROR?",         voice = "psycho5_09" },
	{ msg = "NINE TIMES THE DOSE...",       voice = "psycho5_10" },
	{ msg = "BETTER IN METAL THAN SKIN",    voice = "psycho5_11" },
	{ msg = "KEEP RUNNING DAVID",           voice = "psycho5_12" },
	{ msg = "GLIDING ALONG THE EDGE",       voice = "psycho5_13" },
	{ msg = "YOU'LL END UP LIKE MAINE",     voice = "psycho5_14" },
	{ msg = "THE MOON... I CAN SEE IT",     voice = "psycho5_15" },
	{ msg = "DAVID MARTINEZ DIED HERE",     voice = "psycho5_16" },
	{ msg = "DAVID... IT'S TIME TO STOP",   voice = "psycho4_10" },
	{ msg = "DAVID... IT'S TIME TO STOP",   voice = "psycho4_10" },
}

-- Stage 6 messages: delusional, Lucy-focused, can't recognize self (Ep 10)
-- Last Breath contextual voice lines
-- ctx: tags that determine when this line is eligible
-- decayWeight: 0.0-1.0, minimum decay progress before line becomes eligible
-- weight: base selection weight (higher = more likely)
local lastBreathLines = {
	-- LUCY (emotional core, heavier in late decay)
	{ msg = "LUCY...",                    voice = "lastbreath_01", ctx = {"lucy","generic"},  decayWeight = 0.0, weight = 2 },
	{ msg = "LUCY... WAIT FOR ME",        voice = "lastbreath_02", ctx = {"lucy","running"},  decayWeight = 0.2, weight = 2 },
	{ msg = "LUCY... I CAN SEE THE MOON", voice = "lastbreath_03", ctx = {"lucy","moon"},     decayWeight = 0.4, weight = 3 },
	{ msg = "LUCY... I PROMISED",          voice = "lastbreath_04", ctx = {"lucy","generic"},  decayWeight = 0.3, weight = 2 },
	{ msg = "I PROMISED I'D TAKE YOU",    voice = "lastbreath_18", ctx = {"lucy","moon"},     decayWeight = 0.6, weight = 3 },
	{ msg = "DON'T CRY... LUCY...",       voice = "lastbreath_19", ctx = {"lucy"},            decayWeight = 0.7, weight = 3 },
	-- IDENTITY CRISIS (internal, no env requirement)
	{ msg = "WHERE ARE YOU?",             voice = "lastbreath_05", ctx = {"identity","generic"}, decayWeight = 0.2, weight = 1 },
	{ msg = "WHO AM I?",                  voice = "lastbreath_06", ctx = {"identity"},        decayWeight = 0.4, weight = 2 },
	{ msg = "WHO'S DAVID?",              voice = "lastbreath_07", ctx = {"identity"},        decayWeight = 0.5, weight = 2 },
	{ msg = "IS THAT... ME?",            voice = "lastbreath_08", ctx = {"identity"},        decayWeight = 0.5, weight = 2 },
	-- PHYSICAL (body failing)
	{ msg = "I CAN'T FEEL MY HANDS",     voice = "lastbreath_09", ctx = {"physical"},        decayWeight = 0.3, weight = 1 },
	{ msg = "MY BODY WON'T STOP",        voice = "lastbreath_10", ctx = {"physical","running"}, decayWeight = 0.2, weight = 1 },
	-- RUNNING (movement-aware)
	{ msg = "I'M STILL RUNNING",          voice = "lastbreath_11", ctx = {"running"},          decayWeight = 0.1, weight = 1 },
	{ msg = "I CAN'T STOP RUNNING",       voice = "lastbreath_12", ctx = {"running"},          decayWeight = 0.3, weight = 2 },
	-- EUPHORIA (transcendent, late decay)
	{ msg = "EVERYTHING IS SO BEAUTIFUL",  voice = "lastbreath_13", ctx = {"euphoria","generic"}, decayWeight = 0.5, weight = 2 },
	{ msg = "ALMOST THERE... ALMOST...",   voice = "lastbreath_14", ctx = {"euphoria","running"}, decayWeight = 0.7, weight = 2 },
	{ msg = "I CAN SEE EVERYTHING",        voice = "lastbreath_20", ctx = {"euphoria"},        decayWeight = 0.8, weight = 3 },
	-- GRIEF (regret toward the dead)
	{ msg = "MOM... GLORIA... I'M SORRY",  voice = "lastbreath_15", ctx = {"grief","generic"}, decayWeight = 0.3, weight = 2 },
	{ msg = "MAINE... I UNDERSTAND NOW",   voice = "lastbreath_16", ctx = {"grief"},           decayWeight = 0.4, weight = 2 },
	-- MOON (nighttime + outdoors, very late)
	{ msg = "THE MOON... SO CLOSE",        voice = "lastbreath_17", ctx = {"moon"},            decayWeight = 0.8, weight = 3 },
}

-- Context detectors
local lastBreathContextDetectors = {
	moon = function(self)
		local ok, result = pcall(function()
			local gt = Game.GetTimeSystem():GetGameTime()
			local hour = GameTime.Hours(gt)
			if hour < 20 and hour >= 5 then return false end
			-- Outdoors check: raycast up for ceiling
			local V = Game.GetPlayer()
			if not V or not IsDefined(V) then return false end
			local pos = V:GetWorldPosition()
			local upTarget = Vector4.new(pos.x, pos.y, pos.z + 50.0, 1.0)
			local hit = Game.GetSpatialQueriesSystem():SyncRaycastByCollisionGroup(pos, upTarget, "Static", false, false)
			return not hit.result
		end)
		return ok and result
	end,
	running = function(self)
		local ok, result = pcall(function()
			local V = Game.GetPlayer()
			if not V or not IsDefined(V) then return true end
			local vel = V:GetLinearVelocity()
			return math.sqrt(vel.x * vel.x + vel.y * vel.y) > 5.0
		end)
		if not ok then return true end
		return result
	end,
	generic = function() return true end,
	identity = function() return true end,
	lucy = function() return true end,
	physical = function() return true end,
	grief = function() return true end,
	euphoria = function() return true end,
}

-- Context weight multipliers
local function lastBreathContextMultiplier(ctx, self)
	if ctx == "moon" then return 4.0 end
	if ctx == "running" then
		local ok, speed = pcall(function()
			local V = Game.GetPlayer()
			local vel = V:GetLinearVelocity()
			return math.sqrt(vel.x * vel.x + vel.y * vel.y)
		end)
		if ok and speed > 8.0 then return 3.0 end
		if ok and speed > 5.0 then return 2.0 end
		return 1.0
	end
	if ctx == "lucy" then
		local de = self.lastBreath and self.lastBreath.elapsed or 0
		local total = self.lastBreath and self.lastBreath.totalRuntime or 245
		local progress = de / total
		if progress > 0.7 then return 3.0 end
		if progress > 0.4 then return 2.0 end
		return 1.0
	end
	if ctx == "physical" then
		local mult = 1.0
		local ok, health = pcall(function() return Game.GetPlayer():GetHealth() end)
		if not ok then health = 100 end
		if health < 30 then mult = mult + 1.5 end
		if self.tremor and self.tremor.intensity > 0.008 then mult = mult + 1.0 end
		return mult
	end
	if ctx == "euphoria" then
		local de = self.lastBreath and self.lastBreath.elapsed or 0
		if de >= 171 and de < 187 then return 4.0 end
		if de >= 221 then return 3.0 end
		return 1.0
	end
	if ctx == "grief" then
		local de = self.lastBreath and self.lastBreath.elapsed or 0
		if de >= 96 and de < 126 then return 3.0 end
		if de >= 171 and de < 187 then return 2.5 end
		return 1.0
	end
	return 1.0
end

local LB_HISTORY_SIZE = 8

local function ContextualLastBreathLine(self)
	local de = self.lastBreath and self.lastBreath.elapsed or 0
	local total = self.lastBreath and self.lastBreath.totalRuntime or 245
	local decayProgress = math.min(de / total, 1.0)

	-- Detect active contexts
	local active = {}
	for name, detect in pairs(lastBreathContextDetectors) do
		active[name] = detect(self)
	end

	-- Build eligible pool
	local pool = {}
	local totalWeight = 0
	local history = self.lastBreathVoiceSet or {}

	for _, line in ipairs(lastBreathLines) do
		if decayProgress >= line.decayWeight and not history[line.voice] then
			local bestMult = 0
			local anyActive = false
			for _, ctx in ipairs(line.ctx) do
				if active[ctx] then
					anyActive = true
					local mult = lastBreathContextMultiplier(ctx, self)
					if mult > bestMult then bestMult = mult end
				end
			end
			if anyActive then
				local ew = line.weight * bestMult
				table.insert(pool, { line = line, ew = ew })
				totalWeight = totalWeight + ew
			end
		end
	end

	-- Fallback: clear history if pool empty
	if #pool == 0 then
		self.lastBreathVoiceHistory = {}
		self.lastBreathVoiceSet = {}
		return ContextualLastBreathLine(self)
	end

	-- Weighted random pick
	local roll = math.random() * totalWeight
	local cum = 0
	for _, entry in ipairs(pool) do
		cum = cum + entry.ew
		if roll <= cum then
			-- Record in history
			if not self.lastBreathVoiceHistory then
				self.lastBreathVoiceHistory = {}
				self.lastBreathVoiceSet = {}
			end
			table.insert(self.lastBreathVoiceHistory, entry.line.voice)
			self.lastBreathVoiceSet[entry.line.voice] = true
			if #self.lastBreathVoiceHistory > LB_HISTORY_SIZE then
				local evicted = table.remove(self.lastBreathVoiceHistory, 1)
				local still = false
				for _, v in ipairs(self.lastBreathVoiceHistory) do
					if v == evicted then still = true; break end
				end
				if not still then self.lastBreathVoiceSet[evicted] = nil end
			end
			return entry.line
		end
	end
	return pool[#pool].line
end

-- Treatment protocol: { doses, ripperVisits, minTier }
-- minTier: 1=Common, 2=Uncommon, 3=Rare (Military Grade)
-- Stage reduction only happens when FULL protocol is complete
local prescriptionTable = {
	[0] = { doses = 0, visits = 0, minTier = 0 },
	[1] = { doses = 3, visits = 1, minTier = 1 },
	[2] = { doses = 5, visits = 1, minTier = 1 },
	[3] = { doses = 5, visits = 2, minTier = 2 },
	[4] = { doses = 7, visits = 3, minTier = 3 },
	[5] = { doses = 10, visits = 5, minTier = 3 },
}

local tierNames = { "Common", "Uncommon", "Military Grade" }

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
		if self.pendingEpisode then return end  -- already in pre-psychosis, don't re-trigger
		if self.runTime > 0 and not forcePsycho then
			self:StatusEffect_CheckAndApply('BaseStatusEffect.MinorBleeding')
		else
			if self.cfg.enableCyberpsychosis then
				-- Pre-Psychosis: johnny_sickness_blackout + fx_damage_high VFX (8s)
				-- Then 8s later the actual episode fires via UpdatePendingEpisode
				self:StatusEffect_CheckAndApply(self.martinez.PrePsychosisEffect)
				pcall(function()
					local V = Game.GetPlayer()
					if V and IsDefined(V) then
						if self.CyberPsychoWarnings >= 4 then
							-- Blackwall scream delayed 4s (plays mid-johnny VFX, not immediately)
							self.pendingBlackwallScream = 4.0
						else
							local painSfx = SoundPlayEvent.new()
							if self.CyberPsychoWarnings >= 3 then
								painSfx.soundName = "ONO_V_LongPain"
							else
								painSfx.soundName = "ono_v_pain_short"
							end
							V:QueueEvent(painSfx)
						end
					end
				end)

				-- Delay the actual episode by 8s (matches johnny_sickness_blackout raw VFX duration)
				self.pendingEpisode = {
					timer = 8.0,
					forcePsycho = forcePsycho,
				}
				return  -- episode fires later via UpdatePendingEpisode
			end
			self:DisableSandevistan("BleedingEffect()")
			self:SaveGame("BleedingEffect()")
		end
	 end)

	-- Delayed episode execution (called from onUpdate)
	dsp.UpdatePendingEpisode = (function(self, dt)
		-- Delayed blackwall scream (4s after johnny VFX starts)
		if self.pendingBlackwallScream then
			self.pendingBlackwallScream = self.pendingBlackwallScream - dt
			if self.pendingBlackwallScream <= 0 then
				self.pendingBlackwallScream = nil
				pcall(function() self.hud:PlayVoiceLine("dsp_blackwall_scream") end)
			end
		end
		if not self.pendingEpisode then return end
		self.pendingEpisode.timer = self.pendingEpisode.timer - dt
		if self.pendingEpisode.timer > 0 then return end

		-- Now fire the actual episode
		self.pendingEpisode = nil

		if self.CyberPsychoWarnings < 5 then self.CyberPsychoWarnings = self.CyberPsychoWarnings + 1 end
		-- Viktor SMS: alert on stage change (3 variants per stage for variety)
		local viktorStageAlerts = {
			[1] = {
				"V, your neural readings just flagged on my monitor. Mild instability — nothing critical yet. Come by when you can, I want to run some tests.",
				"Kid, I'm picking up irregularities in your neural interface. Early stage, but don't ignore it. Drop by my clinic when you get a chance.",
				"V, your implant telemetry is showing stress patterns I don't like. Manageable, but come see me. Sooner is better.",
			},
			[2] = {
				"V, your nervous system is showing real degradation. This isn't something you can walk off. Come to the clinic — I need to evaluate you in person.",
				"V, it's Viktor. Your readings jumped again. The degradation is accelerating. I need to see you. Don't wait on this.",
				"Kid, your telemetry just spiked. I don't like what I'm seeing. Get to my clinic before this gets worse.",
			},
			[3] = {
				"V, this is Viktor. Your readings crossed a threshold I was hoping we'd avoid. I need to adjust your treatment. Get here.",
				"Kid, your neural interface is deteriorating faster than expected. The current protocol isn't enough. Come see me — I need to reassess.",
				"Your readings are getting worse. I need to run diagnostics and recalibrate your treatment. Don't put this off, V.",
			},
			[4] = {
				"V, your neural readings are critical. I need you in my clinic. Now. Not tomorrow, not later. Now.",
				"Kid, I've been watching your telemetry and it's bad. Really bad. Drop everything and get here.",
				"V, this is urgent. Your nervous system is on the edge. I can help but only if you come see me immediately.",
			},
			[5] = {
				"V... I've seen these readings before. On Maine. Get to my clinic. I'm not losing another one.",
				"Kid, your neural interface is in freefall. This is it — point of no return if we don't act. Get here NOW.",
				"V, I'm not going to sugarcoat this. You're where Maine was before the end. I have a protocol. But you need to be in my chair. Move.",
			},
		}
		local alertPool = viktorStageAlerts[self.CyberPsychoWarnings]
		local viktorMsg = alertPool and alertPool[math.random(#alertPool)]
		if viktorMsg then
			-- Reset treatment for new stage
			self.treatmentActive = false
			self.completedDoses = 0
			self.completedVisits = 0
			self.prescribedDoses = 0
			-- Delayed SMS: higher stage = Viktor responds faster
			local smsSelf = self
			pcall(function()
				local alertDelays = {
					[1] = { 180, 300 },  -- 3-5 min: routine check
					[2] = { 120, 240 },  -- 2-4 min: paying attention
					[3] = { 60, 180 },   -- 1-3 min: concerned
					[4] = { 30, 90 },    -- 30s-90s: alarmed, real-time monitoring
					[5] = { 10, 30 },    -- 10-30s: emergency, watching readings live
				}
				local range = alertDelays[smsSelf.CyberPsychoWarnings] or { 60, 300 }
				local delay = range[1] + math.random(0, range[2] - range[1])
				smsSelf.pendingViktorSMS = { timer = delay, msg = viktorMsg }
			end)
		end
		self:SyncSafetyWithStage()
		self:FrightenNPCs()
		self:DisableSandevistan("BleedingEffect()")
		self:SaveGame("BleedingEffect()")
	 end)

	dsp.FrightenNPCs = (function(self)
		if self.CyberPsychoWarnings < 5 then
			self:StatusEffect_CheckAndApply(self.martinez.MartinezFury)
		else
			self:StatusEffect_CheckAndApply(self.martinez.MartinezFury_Level5)
		end

		-- Combat buffs during psychosis (David was STRONGER: +50% speed, +100% armor, ×10 health regen)
		self:StatusEffect_CheckAndApply(self.martinez.PsychosisCombatBuff)

		-- Edgerunner SFX via AudioSystem (15s, not entity-bound so it won't get cut)
		pcall(function() Game.GetAudioSystem():Play(CName.new("ui_gmpl_perk_edgerunner")) end)
		self.furyEdgerunnerActive = true

		-- Psychosis SFX (johnny_sickness_blackout already fired in pre-psychosis)
		local V = Game.GetPlayer()
		pcall(function()
			if V and IsDefined(V) then
				-- Panic scream
				local screamEvt = SoundPlayEvent.new()
				screamEvt.soundName = "ono_v_fear_panic_scream"
				V:QueueEvent(screamEvt)
			end
		end)

		-- Force draw weapon (like Wannabe Edgerunner — DrawItemRequest)
		pcall(function()
			if V and IsDefined(V) then
				local es = V:GetEquipmentSystem()
				local drawReq = DrawItemRequest.new()
				local espd = EquipmentSystem.GetData(V)
				drawReq.itemID = espd:GetItemInEquipSlot(gamedataEquipmentArea.WeaponWheel, 0)
				drawReq.owner = V
				es:QueueRequest(drawReq)
			end
		end)

		-- ui_gmpl_perk_edgerunner SFX now handled by MartinezFury status effect
		-- (plays for full 12s duration, stops on deactivate)

		-- Simulate a gunshot event so enemies agro and NPCs run away
		if V and IsDefined(V) then
			StimBroadcasterComponent.BroadcastStim(V, gamedataStimType.Gunshot, 50.0)
		end
		if self:GetHeatLevel() > 0 then
			self:NCPDIsWatching()
		end

		-- Auto-attack chance during stage change: 15/40/60/80% by stage
		local stageAttackChance = { [2]=0.15, [3]=0.40, [4]=0.60, [5]=0.80 }
		self:TryAutoAttack(stageAttackChance[self.CyberPsychoWarnings] or 0.15, false)

		-- Reset strain after episode fires (accumulation starts fresh)
		self.neuralStrain = 0
	 end)

	dsp.PsychoLaugh = (function(self)
		if not self.cfg.enableCyberpsychosis then return end
		if self.CyberPsychoWarnings < 4 then
			self.nextLaughTime = nil
			return
		end
		if self.pendingEpisode then return end  -- don't laugh during pre-psychosis buildup
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
		if self.CachedInMenu or self.CachedBrainDance or (not self.VIsInControl) then return end

		local now = os.clock()
		local isLastBreath = (self.lastBreath ~= nil and self.lastBreath.phase == "decay")

		if self.nextPsychoMsgTime == nil then
			scheduleNextPsychoMsg(self, now, isLastBreath)
			return
		end

		if now < self.nextPsychoMsgTime then return end

		local entry
		if isLastBreath then
			entry = ContextualLastBreathLine(self)
		elseif self.CyberPsychoWarnings >= 5 then
			entry = psychoMessages_lv5[math.random(1, #psychoMessages_lv5)]
		else
			entry = psychoMessages_lv4[math.random(1, #psychoMessages_lv4)]
		end
		if entry.voice then
			self.voice:Play(entry.voice, self.hud)
			self.hud:ShowSubtitle(entry.msg, "V", 3.0)
		else
			local V = Game.GetPlayer()
			if V and IsDefined(V) then
				pcall(function() V:SetWarningMessage(entry.msg) end)
			end
		end

		scheduleNextPsychoMsg(self, now, isLastBreath)
	 end)

	dsp.GetPrescription = (function(self, level)
		local entry = prescriptionTable[level]
		if entry then return entry end
		return { doses = 0, visits = 0, minTier = 0 }
	 end)

	dsp.GetTierName = (function(self, tier)
		return tierNames[tier] or "Unknown"
	 end)

	-- Check if taking an immunoblocker advances the treatment protocol
	dsp.lastTreatmentDoseTime = 0
	dsp.CheckTreatmentDose = (function(self, consumedTier)
		if not self.treatmentActive then return end
		if self.CyberPsychoWarnings < 1 then return end
		-- Debounce: observer + RealTimeTick can both detect the same consumption
		local now = os.clock()
		if now - self.lastTreatmentDoseTime < 2.0 then return end
		self.lastTreatmentDoseTime = now
		local rx = self:GetPrescription(self.CyberPsychoWarnings)
		if rx.minTier == 0 then return end

		if consumedTier < rx.minTier then
			-- Tier too low for protocol
			self:ViktorSMS("That dosage won't cut it at Stage " .. tostring(self.CyberPsychoWarnings) .. ". You need " .. self:GetTierName(rx.minTier) .. " grade.")
			return
		end

		-- Count as treatment dose
		self.completedDoses = math.min((self.completedDoses or 0) + 1, rx.doses)
		local remaining = rx.doses - self.completedDoses
		if remaining > 0 then
			self:ViktorSMS("Treatment dose registered. " .. tostring(remaining) .. " remaining.")
		end
		self:SaveGame("TreatmentDose")

		-- Check if protocol is complete
		self:CheckTreatmentComplete()
	 end)

	-- Check if full treatment protocol is complete (all doses + all visits)
	dsp.CheckTreatmentComplete = (function(self)
		if not self.treatmentActive then return end
		local rx = self:GetPrescription(self.CyberPsychoWarnings)
		if rx.doses == 0 then return end
		local dosesOk = (self.completedDoses or 0) >= rx.doses
		local visitsOk = (self.completedVisits or 0) >= rx.visits
		if dosesOk and visitsOk then
			-- Protocol complete — reduce stage
			local prevLevel = self.CyberPsychoWarnings
			self.CyberPsychoWarnings = math.max(self.CyberPsychoWarnings - 1, 0)
			self.treatmentActive = false
			self.completedDoses = 0
			self.completedVisits = 0
			self.prescribedDoses = 0
			self:SyncSafetyWithStage()
			self:ResetMicroEpisodeTimer()
			self:DisableSandevistan("TreatmentComplete")
			self:SaveGame("TreatmentComplete")

			local stageNames = { "I", "II", "III", "IV", "V" }
			if self.CyberPsychoWarnings > 0 then
				self:ViktorSMS("Treatment complete. You're down to Stage " .. (stageNames[self.CyberPsychoWarnings] or tostring(self.CyberPsychoWarnings)) .. ". Don't make me do this again, kid.", 8.0)
			else
				self:ViktorSMS("Treatment complete. Neural readings are clean. Stay off the chrome for a while.", 8.0)
			end
			print('[DSP] Treatment complete: ' .. tostring(prevLevel) .. ' -> ' .. tostring(self.CyberPsychoWarnings))
		end
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
		if self.CachedInMenu or self.CachedBrainDance or (not self.VIsInControl) then return end
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
			-- Auto-attack chance during manic laugh: 30/50/70% by stage
			local laughAttackChance = { [3]=0.30, [4]=0.50, [5]=0.70 }
			self:TryAutoAttack(laughAttackChance[self.CyberPsychoWarnings] or 0.30, true)
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

	-- ============================================================
	-- HALLUCINATIONS: Phantom NPC spawning (Stage 3-5)
	-- ============================================================

	-- NPC records for phantom spawns (generic crowd types)
	-- Civilian phantoms (frozen, approach, lover_stare)
	local phantomRecords = {
		'Character.otr_service_vendor_ma',
		'Character.otr_service_vendor_wa',
		'Character.Grilled_Food',
		'Character.Chinese_Food_Woman',
	}

	-- Gang members for attack behavior (have full combat AI)
	local attackRecords = {
		'Character.maelstrom_grunt2_melee2_machete_ma',
		'Character.tyger_claws_grunt2_melee2_katana_ma',
		'Character.valentinos_grunt2_ranged2_ajax_ma',
		'Character.sixthstreet_grunt2_melee2_knife_ma',
		'Character.maelstrom_grunt2_ranged2_saratoga_ma',
		'Character.tyger_claws_grunt2_ranged2_shingen_ma',
	}

	-- Horde system config (module-local)
	local hordeConfig = {
		checkInterval = { [4] = 300, [5] = 120 },
		duration = { [4] = {60, 90}, [5] = {90, 120} },
		baseChance = { [4] = 0.3, [5] = 0.5 },
		spawnInterval = { [4] = {3, 5}, [5] = {2, 4} },
		reinforcePerKill = { [4] = {1, 2}, [5] = {1, 3} },
		reinforceDelay = { [4] = {1.5, 3.0}, [5] = {0.8, 2.0} },
		reinforceDist = { [4] = {12, 20}, [5] = {14, 25} },
		maxNPCs = { [4] = 20, [5] = 30 },
		cooldown = { [4] = 600, [5] = 300 },
	}

	-- Lover records mapped to quest facts
	local loverRecords = {
		{ fact = "sq030_judy_lover",  record = "Character.Judy" },
		{ fact = "sq027_panam_lover", record = "Character.Panam" },
		{ fact = "sq029_river_lover", record = "Character.River" },
		{ fact = "sq028_kerry_lover", record = "Character.Kerry" },
	}

	-- Get phantom record pool (includes lover if romance active)
	local function getPhantomPool(self)
		local pool = {}
		for _, r in ipairs(phantomRecords) do
			table.insert(pool, r)
		end
		-- Add lover to pool (higher weight at stage 5)
		pcall(function()
			local QS = Game.GetQuestsSystem()
			for _, lover in ipairs(loverRecords) do
				if QS:GetFactStr(lover.fact) == 1 then
					table.insert(pool, lover.record)
					-- Slight extra weight at stage 5 (David saw Lucy)
					if self.CyberPsychoWarnings >= 5 then
						table.insert(pool, lover.record)
					end
					break  -- only one active romance
				end
			end
		end)
		return pool
	end

	local hallucinationMessages = {
		[3] = {
			{ msg = "Did someone just...?",           voice = "halluc_s3_01" },
			{ msg = "Thought I saw...",               voice = "halluc_s3_02" },
			{ msg = "Shadows moving... just my eyes", voice = "halluc_s3_03" },
		},
		[4] = {
			{ msg = "They're watching me...",           voice = "halluc_s4_01" },
			{ msg = "Who's there?!",                   voice = "halluc_s4_02" },
			{ msg = "Can't trust what I see anymore",  voice = "halluc_s4_03" },
		},
		[5] = {
			{ msg = "THEY'RE EVERYWHERE",  voice = "halluc_s5_01" },
			{ msg = "GET OUT OF MY HEAD",  voice = "halluc_s5_02" },
			{ msg = "Lucy...? No... not real", voice = "halluc_s5_03" },
		},
	}

	dsp.phantomNPCs = {}  -- { entityID, despawnTime, behavior, glitchTime }
	dsp.nextHallucinationTime = nil

	-- Horde state
	dsp.hordeActive = false
	dsp.hordeNPCs = {}
	dsp.hordeEndTime = 0
	dsp.hordeNextSpawn = 0
	dsp.hordeNextCheck = 0
	dsp.hordeCooldownUntil = 0
	dsp.hordeGangRecord = nil
	dsp.hordePendingReinforce = {}
	dsp.hordeKills = 0
	dsp.hordeDespawnTime = nil

	-- Apply phantom behavior after entity initializes (called ~0.5s after spawn)
	local function applyPhantomBehavior(self, phantom)
		local ent = Game.FindEntityByID(phantom.entityID)
		if not ent or not IsDefined(ent) then return end
		local npc = ent
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end
		local isLover = phantom.isLover

		if phantom.behavior == 'frozen' then
			-- Stage 3: frozen in place, staring at V
			pcall(function()
				-- Make NPC stare at V
				local lookAt = LookAtAddEvent.new()
				lookAt:SetEntityTarget(V, CName.new("pla_default_tgt"), Vector4.new(0,0,0,0))
				lookAt:SetStyle(animLookAtStyle.Normal)
				lookAt.request.limits.softLimitDegrees = 360.0
				lookAt.request.limits.hardLimitDegrees = 270.0
				lookAt.request.limits.hardLimitDistance = 1000000.0
				lookAt.request.limits.backLimitDegrees = 210.0
				lookAt.request.calculatePositionInParentSpace = true
				lookAt.bodyPart = CName.new("Eyes")
				local headPart = LookAtPartRequest.new()
				headPart.partName = CName.new("Head")
				headPart.weight = 0.8
				headPart.suppress = 1.0
				headPart.mode = 0
				lookAt:SetAdditionalPartsArray({headPart})
				npc:QueueEvent(lookAt)
			end)
			-- Freeze NPC in current pose
			pcall(function()
				TimeDilationHelper.SetIndividualTimeDilation(npc, CName.new("radialMenu"), 0.0)
			end)
			-- Subtle sound from phantom location
			pcall(function()
				local evt = SoundPlayEvent.new()
				evt.soundName = "quickhack_shortcircuit"
				npc:QueueEvent(evt)
			end)

		elseif phantom.behavior == 'approach' then
			-- Stage 4: walks toward V slowly, creepy expression
			pcall(function()
				-- Facial expression: fear/pain
				local animComp = npc:FindComponentByName(CName.new("AnimationControllerComponent"))
				if animComp then
					local animFeat = NewObject("handle:AnimFeature_FacialReaction")
					animFeat.category = 3  -- pain category
					animFeat.idle = 6
					animComp:ApplyFeature(CName.new("FacialReaction"), animFeat)
				end
			end)
			pcall(function()
				-- Walk toward V
				local vPos = V:GetWorldPosition()
				local dest = NewObject('WorldPosition')
				WorldPosition.SetVector4(dest, vPos)
				local posSpec = NewObject('AIPositionSpec')
				posSpec:SetWorldPosition(posSpec, dest)
				local cmd = NewObject('handle:AIMoveToCommand')
				cmd.movementTarget = posSpec
				cmd.rotateEntityTowardsFacingTarget = false
				cmd.ignoreNavigation = true
				cmd.desiredDistanceFromTarget = 1.5
				cmd.movementType = CName.new("Walk")
				cmd.finishWhenDestinationReached = true
				npc:GetAIControllerComponent():SendCommand(cmd)
			end)
			-- 3D positioned sound from phantom
			pcall(function()
				local evt = SoundPlayEvent.new()
				evt.soundName = "quickhack_cyberpsychosis_mech"
				npc:QueueEvent(evt)
			end)

		elseif phantom.behavior == 'attack' then
			-- Stage 4-5: actively attacks V (AMM pattern: AIRole + OnAttach)
			pcall(function()
				local role = AIRole.new()
				npc:GetAIControllerComponent():SetAIRole(role)
				npc:GetAIControllerComponent():OnAttach()
			end)
			pcall(function()
				npc:GetAttitudeAgent():SetAttitudeGroup(CName.new("Hostile"))
				npc:GetAttitudeAgent():SetAttitudeTowards(V:GetAttitudeAgent(), EAIAttitude.AIA_Hostile)
			end)
			pcall(function()
				npc.isPlayerCompanionCached = false
				npc.isPlayerCompanionCachedTimeStamp = 0
			end)
			pcall(function()
				local sensePreset = TweakDBInterface.GetReactionPresetRecord(TweakDBID.new("ReactionPresets.Ganger_Aggressive"))
				npc.reactionComponent:SetReactionPreset(sensePreset)
				npc.reactionComponent:TriggerCombat(V)
			end)
			pcall(function()
				local evt = SoundPlayEvent.new()
				evt.soundName = "quickhack_cyberpsychosis_mech"
				npc:QueueEvent(evt)
			end)

		elseif phantom.behavior == 'lover_stare' then
			-- Stage 5 lover: just stares at V silently (most disturbing)
			pcall(function()
				local lookAt = LookAtAddEvent.new()
				lookAt:SetEntityTarget(V, CName.new("pla_default_tgt"), Vector4.new(0,0,0,0))
				lookAt:SetStyle(animLookAtStyle.Normal)
				lookAt.request.limits.softLimitDegrees = 360.0
				lookAt.request.limits.hardLimitDegrees = 270.0
				lookAt.request.limits.hardLimitDistance = 1000000.0
				lookAt.request.limits.backLimitDegrees = 210.0
				lookAt.request.calculatePositionInParentSpace = true
				lookAt.bodyPart = CName.new("Eyes")
				local headPart = LookAtPartRequest.new()
				headPart.partName = CName.new("Head")
				headPart.weight = 1.0
				headPart.suppress = 1.0
				headPart.mode = 0
				lookAt:SetAdditionalPartsArray({headPart})
				npc:QueueEvent(lookAt)
			end)
			-- Hold position
			pcall(function()
				local holdCmd = NewObject('handle:AIHoldPositionCommand')
				holdCmd.duration = 10.0
				holdCmd.ignoreInCombat = false
				npc:GetAIControllerComponent():SendCommand(holdCmd)
			end)
		end
	end

	-- Glitch-out despawn effect (called 1-2s before actual despawn)
	local function applyGlitchDespawn(self, phantom)
		local ent = Game.FindEntityByID(phantom.entityID)
		if not ent or not IsDefined(ent) then return end
		pcall(function()
			-- Blackwall corruption VFX on all stages (these aren't real NPCs)
			Game.GetStatusEffectSystem():ApplyStatusEffect(ent:GetEntityID(),
				TweakDBID.new('BaseStatusEffect.HauntedBlackwallForceKill'))
		end)
	end

	-- Spawn a single horde NPC behind/side of V (never in front FOV)
	local function spawnHordeNPC(self, minDist, maxDist)
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return nil end
		local max = hordeConfig.maxNPCs[self.CyberPsychoWarnings] or 20
		if #self.hordeNPCs >= max then return nil end

		local vPos = V:GetWorldPosition()
		local vFwd = V:GetWorldForward()
		local dist = minDist + math.random() * (maxDist - minDist)
		-- Spawn behind/side of V: angle between 90° and 270° relative to V's facing
		local vYaw = math.atan(vFwd.x, vFwd.y)
		local offsetAngle = math.rad(90 + math.random() * 180)  -- 90°-270° behind arc
		local angle = vYaw + offsetAngle
		local spawnX = vPos.x + math.cos(angle) * dist
		local spawnY = vPos.y + math.sin(angle) * dist
		local spawnZ = vPos.z

		local record = self.hordeGangRecord or attackRecords[math.random(#attackRecords)]

		-- Use DynamicEntitySystem (AMM pattern) instead of exEntitySpawner
		-- exEntitySpawner.SpawnRecord has a known CET bug where hostile NPCs don't attack
		local ok, entityID = pcall(function()
			local spec = DynamicEntitySpec.new()
			spec.recordID = TweakDBID.new(record)
			spec.persistState = false
			spec.persistSpawn = false
			spec.alwaysSpawned = false
			spec.spawnInView = true
			spec.position = Vector4.new(spawnX, spawnY, spawnZ, 1.0)
			-- Face toward V
			local dx = vPos.x - spawnX
			local dy = vPos.y - spawnY
			local faceDir = Vector4.new(dx, dy, 0, 0)
			spec.orientation = EulerAngles.ToQuat(Vector4.ToRotation(faceDir))
			return Game.GetDynamicEntitySystem():CreateEntity(spec)
		end)

		if ok and entityID then
			local now = os.clock()
			table.insert(self.hordeNPCs, {
				entityID = entityID,
				spawnTime = now,
				behaviorApplied = false,
			})
			-- VFX on V's vision (brief glitch)
			pcall(function()
				self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Light)
			end)
			return entityID
		end
		return nil
	end

	-- Apply hostile behavior on horde NPC (AMM pattern: AIRole + OnAttach)
	local function applyHordeBehavior(self, hordeNPC)
		local ent = Game.FindEntityByID(hordeNPC.entityID)
		if not ent or not IsDefined(ent) then
			print('[DSP] Horde behavior: entity not found')
			return
		end
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end
		local npc = ent

		-- Initialize AI behavior tree (CRITICAL — without this NPCs aim but don't fire)
		pcall(function()
			local role = AIRole.new()
			npc:GetAIControllerComponent():SetAIRole(role)
			npc:GetAIControllerComponent():OnAttach()
		end)
		-- Set hostile attitude
		pcall(function()
			npc:GetAttitudeAgent():SetAttitudeGroup(CName.new("Hostile"))
			npc:GetAttitudeAgent():SetAttitudeTowards(V:GetAttitudeAgent(), EAIAttitude.AIA_Hostile)
		end)
		-- Clear companion cache
		pcall(function()
			npc.isPlayerCompanionCached = false
			npc.isPlayerCompanionCachedTimeStamp = 0
		end)
		-- Trigger combat
		pcall(function()
			local sensePreset = TweakDBInterface.GetReactionPresetRecord(TweakDBID.new("ReactionPresets.Ganger_Aggressive"))
			npc.reactionComponent:SetReactionPreset(sensePreset)
			npc.reactionComponent:TriggerCombat(V)
		end)
		-- SFX
		pcall(function()
			local evt = SoundPlayEvent.new()
			evt.soundName = "quickhack_cyberpsychosis_mech"
			npc:QueueEvent(evt)
		end)
		print('[DSP] Horde behavior applied')
	end

	dsp.UpdateHallucinations = (function(self, dt)
		if not self.cfg.enableCyberpsychosis then return end
		if self.CyberPsychoWarnings < 3 then self.nextHallucinationTime = nil return end
		if self.CachedInMenu or self.CachedBrainDance then return end
		if not self.VIsInControl then return end
		if self.lastBreath then return end
		local eff = self:GetImmunoblockerEffectiveness()
		if eff == 'full' or eff == 'partial' then return end
		-- Pause normal phantoms while horde is active
		if self.hordeActive then return end

		local now = os.clock()

		-- Process phantom lifecycle (in-place removal, iterate backwards)
		local i = #self.phantomNPCs
		while i >= 1 do
			local phantom = self.phantomNPCs[i]
			-- Apply behavior once entity is ready (~1.0s after spawn)
			if not phantom.behaviorApplied and now >= phantom.spawnTime + 1.0 then
				phantom.behaviorApplied = true
				pcall(function() applyPhantomBehavior(self, phantom) end)
			end
			-- Apply glitch VFX before despawn
			if not phantom.glitchApplied and now >= phantom.glitchTime then
				phantom.glitchApplied = true
				pcall(function() applyGlitchDespawn(self, phantom) end)
			end
			-- Despawn
			if now >= phantom.despawnTime then
				pcall(function()
					local ent = Game.FindEntityByID(phantom.entityID)
					if ent and IsDefined(ent) then
						exEntitySpawner.Despawn(ent)
					end
				end)
				pcall(function()
					self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Light)
				end)
				table.remove(self.phantomNPCs, i)
			end
			i = i - 1
		end

		-- Schedule next hallucination
		if self.nextHallucinationTime == nil then
			local range = hallucinationIntervals[self.CyberPsychoWarnings] or {180, 300}
			self.nextHallucinationTime = now + range[1] + math.random() * (range[2] - range[1])
			return
		end
		if now < self.nextHallucinationTime then return end

		-- Spawn phantom NPC
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end

		local vPos = V:GetWorldPosition()

		-- Spawn 6-14m around V in random 360° direction
		local dist = 6 + math.random() * 8
		local angle = math.random() * 2 * math.pi
		local spawnX = vPos.x + math.cos(angle) * dist
		local spawnY = vPos.y + math.sin(angle) * dist
		-- Raycast to ground
		local spawnZ = vPos.z
		pcall(function()
			local from = Vector4.new(spawnX, spawnY, vPos.z + 5.0, 1.0)
			local to = Vector4.new(spawnX, spawnY, vPos.z - 10.0, 1.0)
			local hit = Game.GetSpatialQueriesSystem():SyncRaycastByCollisionGroup(from, to, "Static", false, false)
			if hit.result then
				spawnZ = hit.position.z
			end
		end)

		-- Choose behavior based on stage first
		local behavior
		local isLover = false
		if self.CyberPsychoWarnings >= 5 then
			behavior = (math.random() < 0.8) and 'attack' or 'frozen'
		elseif self.CyberPsychoWarnings >= 4 then
			behavior = (math.random() < 0.7) and 'attack' or 'approach'
		else
			behavior = 'frozen'
		end

		-- Pick record based on behavior
		local record
		if behavior == 'attack' then
			-- Gang members for attack (have combat AI)
			record = attackRecords[math.random(#attackRecords)]
		else
			-- Civilian pool for non-attack behaviors
			local pool = getPhantomPool(self)
			record = pool[math.random(#pool)]
			-- Check if this is a lover phantom
			pcall(function()
				local QS = Game.GetQuestsSystem()
				for _, lover in ipairs(loverRecords) do
					if record == lover.record and QS:GetFactStr(lover.fact) == 1 then
						isLover = true
						break
					end
				end
			end)
			-- Override behavior for lover
			if isLover and self.CyberPsychoWarnings >= 4 then
				behavior = 'lover_stare'
			end
		end

		-- Despawn timing by stage + behavior (increased durations)
		local despawnDelays = {
			frozen      = { [3] = {6, 10},  [4] = {8, 12},  [5] = {5, 8} },
			approach    = { [3] = {8, 14},  [4] = {10, 16}, [5] = {8, 12} },
			attack      = { [3] = {6, 10},  [4] = {8, 14},  [5] = {6, 10} },
			lover_stare = { [3] = {10, 16}, [4] = {12, 20}, [5] = {10, 16} },
		}
		local delays = despawnDelays[behavior] or despawnDelays.frozen
		local stageDelay = delays[self.CyberPsychoWarnings] or {3, 5}
		local lifetime = stageDelay[1] + math.random() * (stageDelay[2] - stageDelay[1])
		local glitchLeadTime = 1.5  -- glitch VFX starts 1.5s before despawn

		local ok, entityID = pcall(function()
			local transform = V:GetWorldTransform()
			local pos = WorldPosition.new()
			WorldPosition.SetVector4(pos, Vector4.new(spawnX, spawnY, spawnZ, 1.0))
			WorldTransform.SetWorldPosition(transform, pos)
			-- Face toward V (add 180° — NPC model faces -Z by default)
			local dx = vPos.x - spawnX
			local dy = vPos.y - spawnY
			local yaw = math.deg(math.atan(dx, dy)) + 180
			WorldTransform.SetOrientation(transform, EulerAngles.ToQuat(EulerAngles.new(0, 0, yaw)))
			return exEntitySpawner.SpawnRecord(record, transform)
		end)

		if ok and entityID then
			table.insert(self.phantomNPCs, {
				entityID = entityID,
				spawnTime = now,
				despawnTime = now + lifetime,
				glitchTime = now + lifetime - glitchLeadTime,
				behavior = behavior,
				isLover = isLover,
				behaviorApplied = false,
				glitchApplied = false,
			})

			-- Audio hallucination on V
			pcall(function()
				-- Blackwall scream via Audioware (all stages)
				local screamOk = pcall(function() self.hud:PlayVoiceLine("dsp_blackwall_scream") end)
				if not screamOk then
					-- Fallback: game SFX
					local evt = SoundPlayEvent.new()
					evt.soundName = "quickhack_cyberpsychosis"
					V:QueueEvent(evt)
					print('[DSP] Blackwall scream fallback: Audioware failed')
				end
			end)

			-- Message
			local msgs = hallucinationMessages[self.CyberPsychoWarnings] or hallucinationMessages[3]
			local entry = msgs[math.random(#msgs)]
			self.bbs:SendWarning(entry.msg, 3.0, entry.voice)

			print('[DSP] Hallucination: '..behavior..' phantom ('..record..') at stage '..tostring(self.CyberPsychoWarnings)..(isLover and ' [LOVER]' or ''))
		end

		-- Reset timer
		local range = hallucinationIntervals[self.CyberPsychoWarnings] or {180, 300}
		self.nextHallucinationTime = now + range[1] + math.random() * (range[2] - range[1])
	 end)

	-- Cleanup all phantoms (called on game load, death, etc.)
	-- ============================================================
	-- HORDE SYSTEM: Waves of hostile gang NPCs (Stage 4-5)
	-- ============================================================

	dsp.StartHorde = (function(self)
		if self.hordeActive then return end
		local stage = self.CyberPsychoWarnings
		local now = os.clock()

		self.hordeActive = true
		self.hordeNPCs = {}
		self.hordePendingReinforce = {}
		self.hordeKills = 0
		self.hordeDespawnTime = nil

		-- Pick a single gang type for this horde
		self.hordeGangRecord = attackRecords[math.random(#attackRecords)]

		-- Duration
		local durRange = hordeConfig.duration[stage] or {60, 90}
		self.hordeEndTime = now + durRange[1] + math.random() * (durRange[2] - durRange[1])

		-- First spawn timer
		self.hordeNextSpawn = now + 1.0

		-- Blackwall VFX on V
		pcall(function()
			self:StatusEffect_CheckAndApply('BaseStatusEffect.HauntedBlackwallForceKill')
		end)

		-- Warning
		self.bbs:SendWarning("THEY'RE COMING", 3.0, "halluc_s5_01")
		pcall(function() self.hud:PlayVoiceLine("dsp_blackwall_scream") end)

		print('[DSP] Horde started: '..self.hordeGangRecord..' duration='..(math.floor(self.hordeEndTime - now))..'s stage='..tostring(stage))
	 end)

	dsp.EndHorde = (function(self)
		if not self.hordeActive then return end
		local now = os.clock()

		-- Blackwall VFX on all surviving horde NPCs
		for _, h in ipairs(self.hordeNPCs) do
			pcall(function()
				local ent = Game.FindEntityByID(h.entityID)
				if ent and IsDefined(ent) then
					Game.GetStatusEffectSystem():ApplyStatusEffect(ent:GetEntityID(),
						TweakDBID.new('BaseStatusEffect.HauntedBlackwallForceKill'))
				end
			end)
		end

		-- Delayed despawn (let Blackwall VFX play for 2s)
		self.hordeDespawnTime = now + 2.0

		-- Set cooldown
		local stage = self.CyberPsychoWarnings
		local cd = hordeConfig.cooldown[stage] or 300
		self.hordeCooldownUntil = now + cd

		self.hordeActive = false
		self.hordePendingReinforce = {}

		-- Brief Blackwall VFX on V
		pcall(function()
			self:StatusEffect_CheckAndApply('BaseStatusEffect.HauntedBlackwallForceKill')
		end)

		print('[DSP] Horde ended: kills='..tostring(self.hordeKills)..' remaining='..tostring(#self.hordeNPCs))
	 end)

	dsp.UpdateHorde = (function(self, dt)
		if not self.cfg.enableCyberpsychosis then return end
		if self.CyberPsychoWarnings < 4 then return end
		if self.CachedInMenu or self.CachedBrainDance then return end
		if not self.VIsInControl then return end
		if self.lastBreath then return end

		local now = os.clock()
		local stage = self.CyberPsychoWarnings

		-- Process pending despawns from EndHorde
		if self.hordeDespawnTime and now >= self.hordeDespawnTime then
			for _, h in ipairs(self.hordeNPCs) do
				pcall(function()
					Game.GetDynamicEntitySystem():DeleteEntity(h.entityID)
				end)
			end
			self.hordeNPCs = {}
			self.hordeDespawnTime = nil
		end

		-- If horde is active
		if self.hordeActive then
			-- Cancel if immunoblocker taken
			local eff = self:GetImmunoblockerEffectiveness()
			if eff == 'full' or eff == 'partial' then
				self:EndHorde()
				return
			end

			-- Check if time expired
			if now >= self.hordeEndTime then
				self:EndHorde()
				return
			end

			-- Process horde NPC lifecycle
			local i = #self.hordeNPCs
			while i >= 1 do
				local h = self.hordeNPCs[i]
				-- Poll for entity readiness, apply behavior once ready
				if not h.behaviorApplied then
					local ent = nil
					pcall(function() ent = Game.FindEntityByID(h.entityID) end)
					if ent and IsDefined(ent) then
						h.behaviorApplied = true
						pcall(function() applyHordeBehavior(self, h) end)
					elseif now >= h.spawnTime + 10.0 then
						table.remove(self.hordeNPCs, i)
					end
				end
				-- Check if dead (only after behavior applied)
				if h.behaviorApplied then
					local isDead = false
					pcall(function()
						local ent = Game.FindEntityByID(h.entityID)
						if not ent or not IsDefined(ent) then
							isDead = true
						elseif ent:IsDeadNoStatPool() or ent:IsDead() then
							isDead = true
							Game.GetStatusEffectSystem():ApplyStatusEffect(ent:GetEntityID(),
								TweakDBID.new('BaseStatusEffect.HauntedBlackwallForceKill'))
						end
					end)
					if isDead then
						self.hordeKills = self.hordeKills + 1
						table.remove(self.hordeNPCs, i)
						local reinforceRange = hordeConfig.reinforcePerKill[stage] or {1, 2}
						local count = reinforceRange[1] + math.random(0, reinforceRange[2] - reinforceRange[1])
						local delayRange = hordeConfig.reinforceDelay[stage] or {1.0, 2.0}
						for r = 1, count do
							local delay = delayRange[1] + math.random() * (delayRange[2] - delayRange[1])
							table.insert(self.hordePendingReinforce, { time = now + delay + (r - 1) * 0.5 })
						end
					end
				end
				i = i - 1
			end

			-- Process pending reinforcements
			local ri = #self.hordePendingReinforce
			while ri >= 1 do
				if now >= self.hordePendingReinforce[ri].time then
					local distRange = hordeConfig.reinforceDist[stage] or {12, 20}
					spawnHordeNPC(self, distRange[1], distRange[2])
					table.remove(self.hordePendingReinforce, ri)
				end
				ri = ri - 1
			end

			-- Auto-spawn on interval
			if now >= self.hordeNextSpawn then
				local spawnRange = hordeConfig.spawnInterval[stage] or {3, 5}
				self.hordeNextSpawn = now + spawnRange[1] + math.random() * (spawnRange[2] - spawnRange[1])
				local eid = spawnHordeNPC(self, 8, 16)
				if eid then
					print('[DSP] Horde spawn: count='..tostring(#self.hordeNPCs)..' kills='..tostring(self.hordeKills)..' remaining='..(math.floor(self.hordeEndTime - now))..'s')
				end
			end

			return
		end

		-- Not active: roll for horde event
		local eff = self:GetImmunoblockerEffectiveness()
		if eff == 'full' or eff == 'partial' then return end
		if now < self.hordeNextCheck then return end

		local interval = hordeConfig.checkInterval[stage] or 300
		self.hordeNextCheck = now + interval

		if now < self.hordeCooldownUntil then return end

		-- Probability: base chance * strain ratio
		local base = hordeConfig.baseChance[stage] or 0.3
		local threshold = self:GetStrainThreshold()
		local strainRatio = math.min((self.neuralStrain or 0) / threshold, 1.5)
		local chance = base * strainRatio

		if math.random() < chance then
			self:StartHorde()
		end
	 end)

	-- Cleanup all phantoms and horde (called on game load, death, etc.)
	dsp.DespawnAllPhantoms = (function(self)
		for _, phantom in ipairs(self.phantomNPCs) do
			pcall(function()
				local ent = Game.FindEntityByID(phantom.entityID)
				if ent and IsDefined(ent) then
					exEntitySpawner.Despawn(ent)
				end
			end)
		end
		self.phantomNPCs = {}
		self.nextHallucinationTime = nil
		-- Cleanup horde (spawned via DynamicEntitySystem)
		for _, h in ipairs(self.hordeNPCs) do
			pcall(function()
				Game.GetDynamicEntitySystem():DeleteEntity(h.entityID)
			end)
		end
		self.hordeNPCs = {}
		self.hordeActive = false
		self.hordePendingReinforce = {}
		self.hordeDespawnTime = nil
	 end)

	-- ============================================================
	-- AUTO-ATTACK: Involuntary attack on nearby NPC (Stage 3-5)
	-- Triggered by: manic_laugh, stage change, low runtime, nosebleed
	-- ============================================================

	local autoAttackMessages = {
		[2] = {
			{ msg = "What... what just happened?", voice = "attack_s2_01" },
			{ msg = "Did I just...?",              voice = "attack_s2_02" },
			{ msg = "My hand... it twitched",      voice = "attack_s2_03" },
		},
		[3] = {
			{ msg = "What did I just do...",                           voice = "attack_s3_01" },
			{ msg = "I didn't mean to... my hand moved on its own",   voice = "attack_s3_02" },
			{ msg = "No... that wasn't me",                           voice = "attack_s3_03" },
		},
		[4] = {
			{ msg = "Can't control it... something's wrong",  voice = "attack_s4_01" },
			{ msg = "My hand... it moved on its own",         voice = "attack_s4_02" },
			{ msg = "NO... STOP...",                          voice = "attack_s4_03" },
		},
		[5] = {
			{ msg = "THEY WERE LOOKING AT ME",   voice = "attack_s5_01" },
			{ msg = "Had to... had to do it",    voice = "attack_s5_02" },
			{ msg = "More... need more",         voice = "attack_s5_03" },
		},
	}

	dsp.autoAttackCooldown = 0

	-- Core auto-attack function. Called from specific trigger points.
	-- fromLaugh: if true, laugh is already active (don't apply PsychoLaughEffect again)
	-- Strain scaling: violence begets violence — high strain increases auto-attack probability
	dsp.TryAutoAttack = (function(self, chance, fromLaugh)
		if not self.cfg.enableCyberpsychosis then return false end
		if self.CyberPsychoWarnings < 2 then return false end
		if self.CachedInMenu or self.CachedBrainDance then return false end
		if self.lastBreath then return false end

		local now = os.clock()
		if self.autoAttackCooldown > now then return false end

		-- Strain scaling: chance × (1.0 to 2.0) based on strain ratio
		local guaranteed = self:GetStrainGuaranteed()
		local strainRatio = (guaranteed > 0) and (self.neuralStrain / guaranteed) or 0
		local scaledChance = chance * (1.0 + strainRatio)

		if math.random() > scaledChance then return false end

		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return false end

		-- Find NPC in front of V
		local target = nil
		pcall(function()
			target = Game.GetTargetingSystem():GetLookAtObject(V, false, false)
		end)
		if not target or not IsDefined(target) then return false end
		local isNPC = false
		pcall(function() isNPC = target:IsNPC() end)
		if not isNPC then return false end

		-- Check distance
		local tPos = target:GetWorldPosition()
		local vPos = V:GetWorldPosition()
		local dx = vPos.x - tPos.x
		local dy = vPos.y - tPos.y
		local dist = math.sqrt(dx*dx + dy*dy)
		if dist > 15 then return false end

		-- Red outline on target (2s)
		pcall(function()
			local evt = OutlineRequestEvent.new()
			local data = OutlineData.new()
			data.outlineType = EOutlineType.RED
			data.outlineOpacity = 1.0
			evt.outlineRequest = OutlineRequest.CreateRequest(CName.new('cyberpsychosis'), data)
			evt.outlineDuration = 2.0
			target:QueueEvent(evt)
		end)

		-- Draw weapon if not already equipped, then fire
		local weapon = V:GetActiveWeapon()
		if weapon and IsDefined(weapon) then
			-- Already armed — fire immediately + laugh
			pcall(function()
				local simTime = EngineTime.ToFloat(Game.GetSimTime())
				local triggerMode = weapon:GetWeaponRecord():PrimaryTriggerMode():Type()
				AIWeapon.Fire(V, weapon, simTime, 1.0, triggerMode)
				local laughEvt = SoundPlayEvent.new()
				laughEvt.soundName = "ono_v_laughs_hard"
				V:QueueEvent(laughEvt)
			end)
		else
			-- No weapon — draw first, fire after 2s
			pcall(function()
				local es = V:GetEquipmentSystem()
				local drawReq = DrawItemRequest.new()
				local espd = EquipmentSystem.GetData(V)
				drawReq.itemID = espd:GetItemInEquipSlot(gamedataEquipmentArea.WeaponWheel, 0)
				drawReq.owner = V
				es:QueueRequest(drawReq)
			end)
			self.autoAttackFireTime = os.clock() + 2.0
		end

		-- VFX on V
		self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Medium)

		-- Post-attack laugh (only if not already laughing)
		if not fromLaugh then
			self:StatusEffect_CheckAndApply(self.martinez.PsychoLaughEffect)
		end

		-- Make target hostile toward V
		pcall(function()
			local npcAtt = target:GetAttitudeAgent()
			local playerAtt = V:GetAttitudeAgent()
			npcAtt:SetAttitudeTowards(playerAtt, EAIAttitude.AIA_Hostile)
		end)

		-- Camera shake
		self.tremor.intensity = math.max(self.tremor.intensity, 0.008)

		-- Message
		local msgs = autoAttackMessages[self.CyberPsychoWarnings] or autoAttackMessages[3]
		local entry = msgs[math.random(#msgs)]
		self.bbs:SendWarning(entry.msg, 3.0, entry.voice)

		-- Cooldown 30s
		self.autoAttackCooldown = now + 30

		-- Broadcast gunshot stimulus (NPCs flee, NCPD reacts)
		StimBroadcasterComponent.BroadcastStim(V, gamedataStimType.Gunshot, 30.0)

		print('[DSP] Auto-attack: fired at NPC, stage '..tostring(self.CyberPsychoWarnings)..' fromLaugh='..tostring(fromLaugh))
		return true
	 end)

	-- UpdateAutoAttack: fires weapon 2s after draw, then laugh
	dsp.UpdateAutoAttack = (function(self)
		if self.autoAttackFireTime and os.clock() >= self.autoAttackFireTime then
			self.autoAttackFireTime = nil
			pcall(function()
				local V = Game.GetPlayer()
				if V and IsDefined(V) then
					local weapon = V:GetActiveWeapon()
					if weapon and IsDefined(weapon) then
						local simTime = EngineTime.ToFloat(Game.GetSimTime())
						local triggerMode = weapon:GetWeaponRecord():PrimaryTriggerMode():Type()
						AIWeapon.Fire(V, weapon, simTime, 1.0, triggerMode)
						-- Laugh after involuntary shot
						local laughEvt = SoundPlayEvent.new()
						laughEvt.soundName = "ono_v_laughs_hard"
						V:QueueEvent(laughEvt)
					end
				end
			end)
		end
	 end)

	-- Per-second check for low runtime auto-attack (stage 2+, runtime <10%)
	dsp.CheckLowRuntimeAutoAttack = (function(self)
		if not self.isRunning then return end
		if self.CyberPsychoWarnings < 2 then return end
		local rtPct = self:GetRuntimePercent()
		if rtPct >= 10 then return end
		-- Low runtime chances: 5% stage 2, 10% stage 3, 20% stage 4, 35% stage 5
		local chances = { [2]=0.05, [3]=0.10, [4]=0.20, [5]=0.35 }
		local chance = chances[self.CyberPsychoWarnings] or 0.05
		self:TryAutoAttack(chance, false)
	 end)
end

return psychosis
