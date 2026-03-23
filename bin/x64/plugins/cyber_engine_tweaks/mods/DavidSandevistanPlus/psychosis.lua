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
		self.nextPsychoMsgTime = now + math.random(8, 18)
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
local psychoMessages_lastBreath = {
	{ msg = "LUCY...",                      voice = "lastbreath_01" },
	{ msg = "LUCY... WAIT FOR ME",          voice = "lastbreath_02" },
	{ msg = "LUCY... I CAN SEE THE MOON",   voice = "lastbreath_03" },
	{ msg = "LUCY... I PROMISED",            voice = "lastbreath_04" },
	{ msg = "WHERE ARE YOU?",                voice = "lastbreath_05" },
	{ msg = "WHO AM I?",                     voice = "lastbreath_06" },
	{ msg = "WHO'S DAVID?",                  voice = "lastbreath_07" },
	{ msg = "IS THAT... ME?",                voice = "lastbreath_08" },
	{ msg = "I CAN'T FEEL MY HANDS",         voice = "lastbreath_09" },
	{ msg = "MY BODY WON'T STOP",            voice = "lastbreath_10" },
	{ msg = "I'M STILL RUNNING",             voice = "lastbreath_11" },
	{ msg = "I CAN'T STOP RUNNING",          voice = "lastbreath_12" },
	{ msg = "EVERYTHING IS SO BEAUTIFUL",     voice = "lastbreath_13" },
	{ msg = "ALMOST THERE... ALMOST...",      voice = "lastbreath_14" },
	{ msg = "MOM... GLORIA... I'M SORRY",     voice = "lastbreath_15" },
	{ msg = "MAINE... I UNDERSTAND NOW",      voice = "lastbreath_16" },
	{ msg = "THE MOON... SO CLOSE",           voice = "lastbreath_17" },
	{ msg = "I PROMISED I'D TAKE YOU",        voice = "lastbreath_18" },
	{ msg = "DON'T CRY... LUCY...",           voice = "lastbreath_19" },
	{ msg = "I CAN SEE EVERYTHING",           voice = "lastbreath_20" },
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
						local painSfx = SoundPlayEvent.new()
						if self.CyberPsychoWarnings >= 3 then
							painSfx.soundName = "ONO_V_LongPain"
						else
							painSfx.soundName = "ono_v_pain_short"
						end
						V:QueueEvent(painSfx)
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
		if not self.pendingEpisode then return end
		self.pendingEpisode.timer = self.pendingEpisode.timer - dt
		if self.pendingEpisode.timer > 0 then return end

		-- Now fire the actual episode
		self.pendingEpisode = nil

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
		if self.CachedInMenu or self.CachedBrainDance then return end

		local now = os.clock()
		local isLastBreath = (self.lastBreath ~= nil and self.lastBreath.phase == "decay")

		if self.nextPsychoMsgTime == nil then
			scheduleNextPsychoMsg(self, now, isLastBreath)
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
		local entry = msgs[math.random(1, #msgs)]
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
	local phantomRecords = {
		'Character.otr_service_vendor_ma',
		'Character.otr_service_vendor_wa',
		'Character.Grilled_Food',
		'Character.Chinese_Food_Woman',
	}

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

	dsp.phantomNPCs = {}  -- { entityID, despawnTime }
	dsp.nextHallucinationTime = nil

	dsp.UpdateHallucinations = (function(self, dt)
		if not self.cfg.enableCyberpsychosis then return end
		if self.CyberPsychoWarnings < 3 then self.nextHallucinationTime = nil return end
		if self.CachedInMenu or self.CachedBrainDance then return end
		if self.lastBreath then return end
		local eff = self:GetImmunoblockerEffectiveness()
		if eff == 'full' or eff == 'partial' then return end

		local now = os.clock()

		-- Despawn expired phantoms
		local newList = {}
		for _, phantom in ipairs(self.phantomNPCs) do
			if now >= phantom.despawnTime then
				pcall(function()
					local ent = Game.FindEntityByID(phantom.entityID)
					if ent and IsDefined(ent) then
						exEntitySpawner.Despawn(ent)
					end
				end)
				-- Brief VFX on V when ghost vanishes
				pcall(function()
					self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Light)
				end)
			else
				table.insert(newList, phantom)
			end
		end
		self.phantomNPCs = newList

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
		local vFwd = V:GetWorldForward()

		-- Spawn 5-15m in front of V with slight offset
		local dist = 5 + math.random() * 10
		local angleOffset = (math.random() - 0.5) * 2.0  -- ±1 radian lateral offset
		local spawnX = vPos.x + vFwd.x * dist + vFwd.y * angleOffset * 3
		local spawnY = vPos.y + vFwd.y * dist - vFwd.x * angleOffset * 3
		local spawnZ = vPos.z

		local record = phantomRecords[math.random(#phantomRecords)]
		local ok, entityID = pcall(function()
			local transform = Game.GetPlayer():GetWorldTransform()
			local pos = WorldPosition.new()
			WorldPosition.SetVector4(pos, Vector4.new(spawnX, spawnY, spawnZ, 1.0))
			WorldTransform.SetWorldPosition(transform, pos)
			return exEntitySpawner.SpawnRecord(record, transform)
		end)

		if ok and entityID then
			-- Despawn timer: stage-dependent
			local despawnDelays = { [3] = {3, 5}, [4] = {5, 8}, [5] = {2, 4} }
			local delay = despawnDelays[self.CyberPsychoWarnings] or {3, 5}
			local despawnTime = now + delay[1] + math.random() * (delay[2] - delay[1])
			table.insert(self.phantomNPCs, { entityID = entityID, despawnTime = despawnTime })

			-- Apply ghost VFX to spawned NPC (delayed slightly for entity init)
			-- The VFX will be applied in the next despawn check cycle when entity is available

			-- Audio hallucination on V
			pcall(function()
				local evt = SoundPlayEvent.new()
				evt.soundName = "quickhack_shortcircuit"
				V:QueueEvent(evt)
			end)

			-- Message
			local msgs = hallucinationMessages[self.CyberPsychoWarnings] or hallucinationMessages[3]
			local entry = msgs[math.random(#msgs)]
			self.bbs:SendWarning(entry.msg, 3.0, entry.voice)

			print('[DSP] Hallucination: spawned phantom '..record..' at stage '..tostring(self.CyberPsychoWarnings))
		end

		-- Reset timer
		local range = hallucinationIntervals[self.CyberPsychoWarnings] or {180, 300}
		self.nextHallucinationTime = now + range[1] + math.random() * (range[2] - range[1])
	 end)

	-- Cleanup all phantoms (called on game load, death, etc.)
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
