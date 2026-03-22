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
				-- Pre-Psychosis VFX: pain + glitch before stage change (like Wannabe Edgerunner)
				pcall(function()
					local V = Game.GetPlayer()
					if V and IsDefined(V) then
						-- Pain SFX: short at low stages, long at high stages
						local painSfx = SoundPlayEvent.new()
						if self.CyberPsychoWarnings >= 3 then
							painSfx.soundName = "ONO_V_LongPain"
						else
							painSfx.soundName = "ono_v_pain_short"
						end
						V:QueueEvent(painSfx)
						-- VFX: personal_link_glitch (neural connection distortion)
						GameObjectEffectHelper.StartEffectEvent(V, CName.new('personal_link_glitch'), false, worldEffectBlackboard.new())
					end
				end)
				self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Light)

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
		-- Psychosis SFX + VFX (like Wannabe Edgerunner)
		pcall(function()
			local V = Game.GetPlayer()
			if V and IsDefined(V) then
				-- Panic scream
				local screamEvt = SoundPlayEvent.new()
				screamEvt.soundName = "ono_v_fear_panic_scream"
				V:QueueEvent(screamEvt)
				-- Johnny sickness blackout VFX
				GameObjectEffectHelper.StartEffectEvent(V, CName.new('johnny_sickness_blackout'), false, worldEffectBlackboard.new())
			end
		end)
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
		[3] = { "Did someone just...?", "Thought I saw...", "Shadows moving... just my eyes" },
		[4] = { "They're watching me...", "Who's there?!", "Can't trust what I see anymore" },
		[5] = { "THEY'RE EVERYWHERE", "GET OUT OF MY HEAD", "Lucy...? No... not real" },
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
			local intervals = { [3] = {180, 300}, [4] = {60, 180}, [5] = {30, 60} }
			local range = intervals[self.CyberPsychoWarnings] or {180, 300}
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
			self.bbs:SendWarning(msgs[math.random(#msgs)], 3.0)

			print('[DSP] Hallucination: spawned phantom '..record..' at stage '..tostring(self.CyberPsychoWarnings))
		end

		-- Reset timer
		local intervals = { [3] = {180, 300}, [4] = {60, 180}, [5] = {30, 60} }
		local range = intervals[self.CyberPsychoWarnings] or {180, 300}
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
	-- AUTO-ATTACK: Involuntary attack on nearby NPC (Stage 4-5)
	-- ============================================================

	local autoAttackMessages = {
		[4] = {
			"What did I just do...",
			"I didn't mean to... my hand moved on its own",
			"No... that wasn't me",
		},
		[5] = {
			"THEY WERE LOOKING AT ME",
			"Had to... had to do it",
			"More... need more",
		},
	}

	dsp.nextAutoAttackTime = nil
	dsp.autoAttackCooldown = 0

	dsp.CheckAutoAttack = (function(self)
		if not self.cfg.enableCyberpsychosis then return end
		if self.CyberPsychoWarnings < 4 then self.nextAutoAttackTime = nil return end
		if self.CachedInMenu or self.CachedBrainDance then return end
		if self.lastBreath then return end
		if not self.isRunning then return end  -- only during Sandy use

		local now = os.clock()
		if self.autoAttackCooldown > now then return end

		-- Chance per check: 15% at stage 4, 35% at stage 5
		local chance = self.CyberPsychoWarnings >= 5 and 0.35 or 0.15
		if math.random() > chance then return end

		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end

		-- Find NPC in front of V
		local target = nil
		pcall(function()
			target = Game.GetTargetingSystem():GetLookAtObject(V, false, false)
		end)
		if not target or not IsDefined(target) then return end
		local isNPC = false
		pcall(function() isNPC = target:IsNPC() end)
		if not isNPC then return end

		-- Check distance
		local tPos = target:GetWorldPosition()
		local vPos = V:GetWorldPosition()
		local dx = vPos.x - tPos.x
		local dy = vPos.y - tPos.y
		local dist = math.sqrt(dx*dx + dy*dy)
		if dist > 15 then return end

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

		-- Force shoot/attack
		pcall(function()
			local bb = V:GetPlayerStateMachineBlackboard()
			bb:SetBool(Game.GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, true)
		end)

		-- Stop shooting after 0.4s (managed in onUpdate)
		self.autoAttackStopTime = now + 0.4

		-- VFX on V
		self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Medium)

		-- Make target hostile toward V
		pcall(function()
			local npcAtt = target:GetAttitudeAgent()
			local playerAtt = V:GetAttitudeAgent()
			npcAtt:SetAttitudeTowards(playerAtt, EAIAttitude.AIA_Hostile)
		end)

		-- Camera shake
		self.tremor.intensity = math.max(self.tremor.intensity, 0.008)

		-- Message
		local msgs = autoAttackMessages[self.CyberPsychoWarnings] or autoAttackMessages[4]
		self.bbs:SendWarning(msgs[math.random(#msgs)], 3.0)

		-- Cooldown 30s
		self.autoAttackCooldown = now + 30

		-- Broadcast gunshot stimulus (NPCs flee, NCPD reacts)
		StimBroadcasterComponent.BroadcastStim(V, gamedataStimType.Gunshot, 30.0)

		print('[DSP] Auto-attack: fired at NPC, stage '..tostring(self.CyberPsychoWarnings))
	 end)

	-- Stop forced shooting (called from onUpdate)
	dsp.UpdateAutoAttack = (function(self)
		if self.autoAttackStopTime and os.clock() >= self.autoAttackStopTime then
			pcall(function()
				local V = Game.GetPlayer()
				if V and IsDefined(V) then
					local bb = V:GetPlayerStateMachineBlackboard()
					bb:SetBool(Game.GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, false)
				end
			end)
			self.autoAttackStopTime = nil
		end
	 end)
end

return psychosis
