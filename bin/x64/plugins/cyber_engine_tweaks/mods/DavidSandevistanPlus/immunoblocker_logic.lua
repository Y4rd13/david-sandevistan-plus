local immunoblocker_logic = {}

function immunoblocker_logic.attach(dsp)
	print('[DSP] immunoblocker_logic.lua attached')

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
				print('[DSP] Tolerance stage advanced to ' .. tostring(self.toleranceStage))
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
		-- Only decay if 24h game-time since last use
		local hoursSinceUse = (now - lastUse) / 3600
		if hoursSinceUse < 24 then return end
		-- Decay: 1.0 per game-day (called once/sec, so divide by 86400)
		local decayPerSec = 1.0 / 86400
		self.toleranceAmount = math.max((self.toleranceAmount or 0) - decayPerSec, 0)
		-- Check stage decrease
		if self.toleranceAmount <= 0 and (self.toleranceStage or 0) > 0 then
			self.toleranceStage = self.toleranceStage - 1
			local prevThresholds = { 0, 4.0, 8.0 }
			self.toleranceAmount = math.max((prevThresholds[self.toleranceStage] or 0) - 0.1, 0)
			print('[DSP] Tolerance stage decreased to ' .. tostring(self.toleranceStage))
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

	-- Returns immunoblocker effectiveness vs current psycho level:
	--   'full'        = within effective range (blocks strain + micro-episodes)
	--   'partial'     = at boundary level (blocks strain, 50% micro-episode suppression)
	--   'ineffective' = neural degradation exceeds dosage (only stat buffs + 25% strain drain)
	--   'none'        = no immunoblocker active
	-- Tier max levels: Common 0-1 (partial 2), Uncommon 0-2 (partial 3), Rare 0-5 (always full)
	dsp.GetImmunoblockerEffectiveness = (function(self)
		local tier = self:GetImmunoblockerTier()
		if tier == 0 then return 'none' end
		-- Tolerance reduces effective tier
		local effectiveTier = math.max(tier - (self.toleranceStage or 0), 0)
		if effectiveTier == 0 then return 'ineffective' end
		local psycho = self.CyberPsychoWarnings
		local maxEffective = { 1, 2, 5 }   -- Common, Uncommon, Rare
		local partialLevel = { 2, 3, -1 }  -- Common partial at 2, Uncommon at 3, Rare never
		if psycho <= maxEffective[effectiveTier] then return 'full' end
		if psycho == partialLevel[effectiveTier] then return 'partial' end
		return 'ineffective'
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

	dsp.ShowImmunoblockerStatus = (function(self, consumedTier)
		local eff = self:GetImmunoblockerEffectiveness()
		local effPct = ({ full = 100, partial = 50, ineffective = 0, none = 0 })[eff] or 0
		local threshold = self:GetStrainThreshold()
		local strainPct = threshold > 0 and math.floor((self.neuralStrain or 0) / threshold * 100) or 0
		local rx = self:GetPrescription(self.CyberPsychoWarnings)
		local rxTotal = math.max(rx.doses, self.prescribedDoses or 0)
		local rxCompleted = self.completedDoses or 0
		-- Activation sound
		playBiomonitorSound("ui_hacking_access_panel")
		playBiomonitorSound("q305_sc_11_medic_scanner_sequence_01")
		self.biomonitorOpen = true
		pcall(function()
			local hudSystem = Game.GetScriptableSystemsContainer():Get(CName.new('DSPHUDSystem'))
			if hudSystem then
				hudSystem:ShowBiomonitorStatus(
					consumedTier,
					self.toleranceStage or 0,
					effPct,
					strainPct,
					self.CyberPsychoWarnings or 0,
					rxCompleted,
					rxTotal
				)
			end
		end)
	 end)

	-- Show treatment protocol biomonitor (Mode 2)
	dsp.ShowBiomonitorProtocol = (function(self)
		local rx = self:GetPrescription(self.CyberPsychoWarnings)
		local rxTotal = math.max(rx.doses, self.prescribedDoses or 0)
		local tierName = tierDisplayNames[rx.minTier] or "Unknown"
		local rxCompleted = self.completedDoses or 0
		local visitsCompleted = self.completedVisits or 0
		local milestonePct = 0
		if rxTotal > 0 then
			local doseP = rxCompleted / rxTotal
			local visitP = rx.visits > 0 and (visitsCompleted / rx.visits) or 1.0
			milestonePct = math.floor((doseP + visitP) / 2.0 * 100)
		end
		-- Activation sound
		playBiomonitorSound("ui_hacking_access_panel")
		playBiomonitorSound("q305_sc_11_medic_scanner_sequence_01")
		self.biomonitorOpen = true
		pcall(function()
			local hudSystem = Game.GetScriptableSystemsContainer():Get(CName.new('DSPHUDSystem'))
			if hudSystem then
				hudSystem:ShowBiomonitorProtocol(
					self.CyberPsychoWarnings or 0,
					rxTotal,
					tierName,
					visitsCompleted,
					rx.visits,
					self.toleranceStage or 0,
					milestonePct
				)
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
		print('[DSP] Immunoblocker consumed — queued (queue=' .. self.immunoAnimQueue .. ')')
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
			print('[DSP] Animation triggered (remaining=' .. self.immunoAnimQueue .. ')')
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
		-- VFX
		if tier >= 3 then
			self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Medium)
			self.tremor.intensity = math.max(self.tremor.intensity, 0.012)
		elseif tier >= 2 then
			self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
		else
			self.tremor.intensity = math.max(self.tremor.intensity, 0.008)
		end
		-- Message
		local msgs = reboundMessages[tier]
		if msgs then
			local msg = msgs[math.random(#msgs)]
			self.bbs:SendWarning(msg, 3.0)
		end
		print('[DSP] Immunoblocker rebound: tier=' .. tostring(tier) .. ' strain=+' .. tostring(math.floor(baseStrain * mult)) .. ' tolerance=' .. tostring(self.toleranceStage or 0))
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
		print('[DSP] TryAutoInject: Military-Grade Immunoblocker consumed, effect applied')
		return true
	 end)
end

return immunoblocker_logic
