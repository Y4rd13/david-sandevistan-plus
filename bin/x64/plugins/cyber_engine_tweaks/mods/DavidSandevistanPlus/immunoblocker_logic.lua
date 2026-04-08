local immunoblocker_logic = {}

function immunoblocker_logic.attach(dsp)
	dlog('[DSP] immunoblocker_logic.lua attached')

	-- Tolerance buildup: { chance, amount } per tier
	local toleranceBuildup = {
		[1] = { chance = 0.70, amount = 1.0 },  -- Common
		[2] = { chance = 0.50, amount = 1.0 },  -- Uncommon
		[3] = { chance = 0.30, amount = 0.5 },  -- Rare
	}
	local toleranceThresholds = { 4.0, 8.0, 12.0 }  -- stage 0→1, 1→2, 2→3

	-- Called when immunoblocker is consumed: probabilistic tolerance buildup
	dsp.AddToleranceOnConsumption = (function(self, tier)
		local info = toleranceBuildup[tier]
		if not info then return end
		if math.random() > info.chance then return end  -- probability check failed
		self.toleranceAmount = (self.toleranceAmount or 0) + info.amount
		-- Record game-time of last use (for decay tracking)
		pcall(function()
			self.lastImmunoblockerGameTime = Game.GetTimeSystem():GetGameTimeStamp()
		end)
		-- Check stage advance
		local stage = self.toleranceStage or 0
		if stage < 3 then
			local threshold = toleranceThresholds[stage + 1]
			if threshold and self.toleranceAmount >= threshold then
				self.toleranceStage = stage + 1
				self.toleranceAmount = 0  -- reset for next stage
				local tolNames = { "Mild", "Moderate", "Severe" }
				local tolName = tolNames[self.toleranceStage] or "High"
				-- If treatment is active, recalculate prescription and notify with new count
				if self.treatmentActive then
					local rx = self:GetPrescription(self.CyberPsychoWarnings)
					local newRequired = math.max(rx.doses, self.prescribedDoses or 0)
					if newRequired > (self.prescribedDoses or 0) then
						local extraDoses = newRequired - self.prescribedDoses
						self.prescribedDoses = newRequired
						self:ViktorSMS("V, your body's building resistance to the blockers. Tolerance: " .. tolName .. ". I'm adding " .. tostring(extraDoses) .. " more doses to the protocol. New total: " .. tostring(newRequired) .. ".")
					else
						self:ViktorSMS("V, your system's building resistance. Tolerance: " .. tolName .. ". I can flush it at the clinic.")
					end
				else
					self:ViktorSMS("V, your system's building resistance to the blockers. Tolerance: " .. tolName .. ". I can flush it at the clinic.")
				end
				dlog('[DSP] Tolerance stage advanced to ' .. tostring(self.toleranceStage))
			end
		end
	 end)

	-- Called once per second from displayTick: decays tolerance if no immunoblocker used recently
	dsp.UpdateToleranceDecay = (function(self)
		if (self.toleranceAmount or 0) <= 0 and (self.toleranceStage or 0) <= 0 then return end
		local ok, now = pcall(function() return Game.GetTimeSystem():GetGameTimeStamp() end)
		if not ok then return end
		local lastUse = self.lastImmunoblockerGameTime or 0
		if lastUse == 0 then return end
		-- Only decay if configured threshold of game-time since last use
		local hoursSinceUse = (now - lastUse) / 3600
		if hoursSinceUse < (self.cfg.toleranceDecayHours or 24) then return end
		-- Decay: 1.0 per game-day (called once/sec, so divide by 86400)
		local decayPerSec = 1.0 / 86400
		self.toleranceAmount = math.max((self.toleranceAmount or 0) - decayPerSec, 0)
		-- Check stage decrease
		if self.toleranceAmount <= 0 and (self.toleranceStage or 0) > 0 then
			self.toleranceStage = self.toleranceStage - 1
			local prevThresholds = { 0, 4.0, 8.0 }
			self.toleranceAmount = math.max((prevThresholds[self.toleranceStage] or 0) - 0.1, 0)
			dlog('[DSP] Tolerance stage decreased to ' .. tostring(self.toleranceStage))
		end
	 end)

	dsp.IsImmunoblockerActive = (function(self)
		return self:StatusEffect_CheckOnly(self.martinez.ImmunoblockerEffect_Common)
			or self:StatusEffect_CheckOnly(self.martinez.ImmunoblockerEffect_Uncommon)
			or self:StatusEffect_CheckOnly(self.martinez.ImmunoblockerEffect_Rare)
	 end)

	-- Returns active immunoblocker tier: 0=none, 1=Common, 2=Uncommon, 3=Rare
	dsp.GetImmunoblockerTier = (function(self)
		if self:StatusEffect_CheckOnly(self.martinez.ImmunoblockerEffect_Rare) then return 3 end
		if self:StatusEffect_CheckOnly(self.martinez.ImmunoblockerEffect_Uncommon) then return 2 end
		if self:StatusEffect_CheckOnly(self.martinez.ImmunoblockerEffect_Common) then return 1 end
		return 0
	 end)

	-- Returns the tier to display in biomonitor for auto-triggers (not consumption events).
	-- Priority: active immunoblocker > prescribed tier (treatment) > 0
	dsp.GetBiomonitorDisplayTier = (function(self)
		local activeTier = self:GetImmunoblockerTier()
		if activeTier > 0 then return activeTier end
		if self.treatmentActive then
			local rx = self:GetPrescription(self.CyberPsychoWarnings)
			return rx.minTier
		end
		return 0
	 end)

	-- Returns immunoblocker effectiveness vs current psycho level:
	--   'full'        = within effective range (blocks strain + micro-episodes)
	--   'partial'     = at boundary level (blocks strain, 50% micro-episode suppression)
	--   'ineffective' = neural degradation exceeds dosage (only stat buffs + 25% strain drain)
	--   'none'        = no immunoblocker active
	-- Tier max levels: Common 0-1 (partial 2), Uncommon 0-2 (partial 3), Rare 0-5 (always full)
	dsp.GetImmunoblockerEffectivenessForTier = (function(self, tier)
		if tier == 0 then return 'none' end
		local effectiveTier = math.max(tier - (self.toleranceStage or 0), 0)
		if effectiveTier == 0 then return 'ineffective' end
		local psycho = self.CyberPsychoWarnings
		local maxEffective = { 1, 2, 5 }   -- Common, Uncommon, Rare
		local partialLevel = { 2, 3, -1 }  -- Common partial at 2, Uncommon at 3, Rare never
		if psycho <= maxEffective[effectiveTier] then return 'full' end
		if psycho == partialLevel[effectiveTier] then return 'partial' end
		return 'ineffective'
	 end)
	dsp.GetImmunoblockerEffectiveness = (function(self)
		return self:GetImmunoblockerEffectivenessForTier(self:GetImmunoblockerTier())
	 end)

	-- Show immunoblocker status after consumption (tolerance + efficacy feedback)
	local tierDisplayNames = { "Common", "Uncommon", "Military Grade" }
	local tolStageNames = { [0] = "None", "Mild", "Moderate", "Severe" }
	local effDisplayNames = { full = "100%", partial = "50%", ineffective = "0%", none = "—" }

	-- Biomonitor SFX helper
	local function playBiomonitorSound(soundName)
		pcall(function()
			local V = Game.GetPlayer()
			if V and IsDefined(V) then
				local evt = SoundPlayEvent.new()
				evt.soundName = soundName
				V:QueueEvent(evt)
			end
		end)
	end

	-- Schedule biomonitor SFX sequence (per-line ticks)
	-- Timing: loading 0.5s + expand 0.3s + footer ~0.1s = ~0.9s before items
	-- Each item: 0.08s anim + ~0.08s gap = ~0.16s per item
	local function scheduleBiomonitorSFX(numItems)
		local itemsStart = 0.9   -- loading + expand + footer
		dsp.biomonitorTickTimers = {}
		local t = itemsStart
		for i = 1, numItems do
			table.insert(dsp.biomonitorTickTimers, t)
			t = t + 0.16
		end
	end

	-- Unified biomonitor — shows all status + protocol data in one panel
	dsp.ShowBiomonitor = (function(self, manualOpen)
		local eff = self:GetImmunoblockerEffectiveness()
		local effPct = ({ full = 100, partial = 50, ineffective = 0, none = 0 })[eff] or 0
		local threshold = self:GetStrainThreshold()
		local strainPct = threshold > 0 and math.floor((self.neuralStrain or 0) / threshold * 100) or 0
		local rx = self:GetPrescription(self.CyberPsychoWarnings)
		local rxTotal = math.max(rx.doses, self.prescribedDoses or 0)
		local rxCompleted = self.completedDoses or 0
		local displayTier = self:GetBiomonitorDisplayTier()
		-- Protocol data
		local visitsCompleted = self.completedVisits or 0
		local requiredRest = math.max(rx.restHours, self.prescribedRestHours or 0)
		local completedRest = math.min(self.completedRestHours or 0, requiredRest)
		-- Visit cooldown remaining (hours until next visit allowed)
		local visitCooldownH = 0
		if self.visitCooldownUntil then
			pcall(function()
				local now = Game.GetTimeSystem():GetGameTimeStamp()
				if self.visitCooldownUntil > now then
					visitCooldownH = math.ceil((self.visitCooldownUntil - now) / 3600)
				end
			end)
		end
		local milestonePct = 0
		if rxTotal > 0 then
			local doseP = rxCompleted / rxTotal
			local visitP = rx.visits > 0 and (visitsCompleted / rx.visits) or 1.0
			local restP = requiredRest > 0 and (completedRest / requiredRest) or 1.0
			milestonePct = math.floor((doseP + visitP + restP) / 3.0 * 100)
		end
		-- SFX
		playBiomonitorSound("ui_hacking_access_panel")
		scheduleBiomonitorSFX(10)  -- 10 data lines
		self.biomonitorOpen = true
		pcall(function()
			local bioSystem = Game.GetScriptableSystemsContainer():Get(CName.new('DSPBiomonitorSystem'))
			if bioSystem then
				bioSystem:SetBiomonitorProtocolData(
					math.floor(completedRest),
					math.floor(requiredRest),
					visitsCompleted,
					rx.visits,
					rxTotal,
					milestonePct
				)
				bioSystem:ShowBiomonitor(
					displayTier,
					self.toleranceStage or 0,
					effPct,
					strainPct,
					self.CyberPsychoWarnings or 0,
					rxCompleted,
					rxTotal,
					manualOpen and true or false
				)
			end
		end)
	 end)

	-- Show substance detection biomonitor when immunoblocker is consumed
	-- Replaces Viktor SMS for dosage feedback — more natural than instant text
	local tierDetectionNames = { "COMMON", "UNCOMMON", "MILITARY GRADE" }
	dsp.ShowSubstanceDetection = (function(self, consumedTier)
		local tierName = tierDetectionNames[consumedTier] or "UNKNOWN"
		-- Build dynamic feedback message
		local feedbackMsg = ""
		if self.treatmentActive then
			local rx = self:GetPrescription(self.CyberPsychoWarnings)
			if consumedTier < rx.minTier then
				feedbackMsg = "Insufficient for Stage " .. tostring(self.CyberPsychoWarnings) .. " — " .. self:GetTierName(rx.minTier) .. " required"
			else
				local remaining = math.max((self.prescribedDoses or 0) - (self.completedDoses or 0), 0)
				if remaining > 0 then
					feedbackMsg = "Treatment dose registered — " .. tostring(remaining) .. " remaining"
				else
					feedbackMsg = "Treatment dose registered"
				end
			end
		else
			local eff = self:GetImmunoblockerEffectiveness()
			if eff == 'full' then
				feedbackMsg = "Neural strain suppression active"
			elseif eff == 'partial' then
				feedbackMsg = "Partial suppression — consider higher dosage"
			elseif eff == 'ineffective' then
				feedbackMsg = "Ineffective at current neural degradation"
			else
				feedbackMsg = "Substance administered"
			end
		end
		-- SFX
		playBiomonitorSound("ui_hacking_access_panel")
		scheduleBiomonitorSFX(3)
		pcall(function()
			local bioSystem = Game.GetScriptableSystemsContainer():Get(CName.new('DSPBiomonitorSystem'))
			if bioSystem then
				bioSystem:ShowSubstanceDetection(tierName, feedbackMsg)
			end
		end)
	 end)

	dsp.immunoLastQty = nil
	dsp.immunoAnimQueue = 0

	-- Shared item name list for qty checks
	local immunoItemNames = {
		dsp.martinez.ImmunoblockerItem_Common,
		dsp.martinez.ImmunoblockerItem_Uncommon,
		dsp.martinez.ImmunoblockerItem_Rare
	}

	-- Helper: count total immunoblocker items in inventory
	local function getImmunoblockerQty()
		local V = Game.GetPlayer()
		if not IsDefined(V) then return nil end
		local TS = Game.GetTransactionSystem()
		local total = 0
		for _, itemName in ipairs(immunoItemNames) do
			total = total + TS:GetItemQuantity(V, ItemID.FromTDBID(TweakDBID.new(itemName)))
		end
		return total
	end

	-- Queue-based animation trigger: enqueues and tries to drain immediately
	dsp.TriggerImmunoblockerAnim = (function(self)
		self.immunoAnimQueue = self.immunoAnimQueue + 1
		dlog('[DSP] Immunoblocker consumed — queued (queue=' .. self.immunoAnimQueue .. ')')
		self:ProcessImmunoblockerAnimQueue()
	 end)

	-- Drain queue: if quest fact is 0 (scene idle) and queue > 0, trigger next scene
	dsp.ProcessImmunoblockerAnimQueue = (function(self)
		if self.immunoAnimQueue <= 0 then return end
		local QS = Game.GetQuestsSystem()
		if not QS then return end
		if QS:GetFactStr("dsp_immunoblocker_inject") <= 0 then
			QS:SetFactStr("dsp_immunoblocker_inject", 1)
			self.immunoAnimQueue = self.immunoAnimQueue - 1
			dlog('[DSP] Animation triggered (remaining=' .. self.immunoAnimQueue .. ')')
		end
	 end)

	-- PRIMARY: Immunoblocker observer is registered in init.lua onInit (where TweakDBID is available).
	-- At module load time TweakDBID is nil — the old pcall registration here failed silently.
	-- The onInit observer is the sole source for treatment dose tracking and tolerance buildup.

	-- Rebound/slingshot effect when immunoblocker expires (Doc's warning: "slingshot the other way")
	local reboundStrainByTier = { [1] = 5, [2] = 15, [3] = 30 }
	local reboundMessages = {
		[1] = {
			"Meds wearing off...",
			"Could use another dose...",
			"Starting to feel it again...",
		},
		[2] = {
			"Crash is hitting... need another dose",
			"Body's fighting back... the meds aren't enough",
			"Withdrawal kicking in...",
		},
		[3] = {
			"Doc warned me about this... the slingshot",
			"Nine times the dose... and the crash is nine times worse",
			"The edge... I can feel it pulling",
		},
	}

	dsp.ApplyImmunoblockerRebound = (function(self, tier)
		if self.lastBreath then return end
		if self.CachedInMenu or self.CachedBrainDance then return end
		-- 10s cooldown
		local now = os.clock()
		if now - (self.lastReboundTime or 0) < 10 then return end
		self.lastReboundTime = now
		-- Strain spike (raw, bypasses stage multiplier)
		local baseStrain = reboundStrainByTier[tier] or 5
		local tolMult = { [0]=1.0, [1]=1.3, [2]=1.6, [3]=2.0 }
		local mult = tolMult[self.toleranceStage or 0] or 1.0
		self:AddStrain(baseStrain * mult, true)  -- raw=true
		-- VFX: analog distortion (crisis de abstinencia) + tier-scaled tremor
		self:StatusEffect_CheckAndApply(self.martinez.SandyStrainEffect)
		if tier >= 3 then
			self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
			self.tremor.intensity = math.max(self.tremor.intensity, 0.012)
		elseif tier >= 2 then
			self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
			self.tremor.intensity = math.max(self.tremor.intensity, 0.008)
		else
			self.tremor.intensity = math.max(self.tremor.intensity, 0.006)
		end
		-- Message
		local msgs = reboundMessages[tier]
		if msgs then
			local msg = msgs[math.random(#msgs)]
			self.bbs:SendWarning(msg, 3.0)
		end
		dlog('[DSP] Immunoblocker rebound: tier=' .. tostring(tier) .. ' strain=+' .. tostring(math.floor(baseStrain * mult)) .. ' tolerance=' .. tostring(self.toleranceStage or 0))
	 end)

	-- Real-time immunoblocker tick: runs from onUpdate via os.clock(), works during inventory pause.
	-- Detects qty decreases the observer missed (effect refresh = same tier used again).
	-- Also drains animation queue when scene finishes (fact resets to 0).
	local immunoRealTimeClock = 0
	dsp.RealTimeImmunoblockerTick = (function(self)
		if not self.PlayerAttached then return end
		-- Only poll during menu (immunoblockers are consumed from inventory)
		if not self.CachedInMenu then
			self:ProcessImmunoblockerAnimQueue()
			return
		end
		local now = os.clock()
		if now - immunoRealTimeClock < 0.25 then return end
		immunoRealTimeClock = now

		local totalQty = getImmunoblockerQty()
		if not totalQty then return end
		if self.immunoLastQty and totalQty < self.immunoLastQty then
			local consumed = self.immunoLastQty - totalQty
			for i = 1, consumed do
				self:TriggerImmunoblockerAnim()
			end
			-- NOTE: Treatment dose tracking and tolerance buildup are handled solely by the
			-- OnStatusEffectApplied observer in init.lua onInit. This fallback only triggers
			-- the animation and syncs qty — it cannot reliably detect the consumed tier
			-- (GetImmunoblockerTier returns the ACTIVE effect, not what was just consumed).
		end
		self.immunoLastQty = totalQty
		self:ProcessImmunoblockerAnimQueue()
	 end)

	dsp.IsAutoInjectorEquipped = (function(self)
		if self.autoInjectorEquipped ~= nil then return self.autoInjectorEquipped end
		local V = Game.GetPlayer()
		if not IsDefined(V) then self.autoInjectorEquipped = false; return false end
		for i=0,99 do
			local item = V:GetEquippedItemIdInArea(gamedataEquipmentArea.NervousSystemCW, i)
			if item.id.length == 0 and i > 1 then break end
			if item.id.value == self.martinez.AutoInjectorItem then
				self.autoInjectorEquipped = true
				return true
			end
		end
		self.autoInjectorEquipped = false
		return false
	 end)

	dsp.TryAutoInject = (function(self)
		if not self:IsAutoInjectorEquipped() then return false end
		if self:IsImmunoblockerActive() then return false end
		if self.autoInjectorCooldown > 0 then return false end
		if self.lastBreath then return false end
		if self.CachedInMenu or self.CachedBrainDance then return false end
		if self.CyberPsychoWarnings < 1 then return false end
		-- Check inventory for Military-Grade Immunoblocker (Rare)
		local V = Game.GetPlayer()
		if not IsDefined(V) then return false end
		local TS = Game.GetTransactionSystem()
		local itemID = ItemID.FromTDBID(TweakDBID.new(self.martinez.ImmunoblockerItem_Rare))
		local qty = TS:GetItemQuantity(V, itemID)
		if qty < 1 then return false end
		-- Consume one unit
		TS:RemoveItem(V, itemID, 1)
		-- Apply Immunoblocker Rare status effect
		self:StatusEffect_CheckAndApply(self.martinez.ImmunoblockerEffect_Rare)
		-- Set cooldown (120 seconds, decremented once per ~1s in displayTick)
		self.autoInjectorCooldown = 120
		-- Notification
		self.bbs:SendWarning("MARTINEZ PROTOCOL \xe2\x80\x94 IMMUNOBLOCKER ADMINISTERED", 4.0)
		dlog('[DSP] TryAutoInject: Military-Grade Immunoblocker consumed, effect applied')
		return true
	 end)
end

return immunoblocker_logic
