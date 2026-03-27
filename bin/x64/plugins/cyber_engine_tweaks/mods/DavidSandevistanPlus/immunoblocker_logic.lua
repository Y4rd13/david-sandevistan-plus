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
				self:ViktorSMS("V, your system's building resistance to the blockers. Effectiveness is dropping. I can flush it at the clinic.")
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

	-- PRIMARY: Immediate detection via observer (fires during inventory pause, new effects only)
	-- TweakDBID may not be available at module load time — create inside pcall
	local obsOk, obsErr = pcall(function()
		local immunoEffectIDs = {
			TweakDBID.new(dsp.martinez.ImmunoblockerEffect_Common),
			TweakDBID.new(dsp.martinez.ImmunoblockerEffect_Uncommon),
			TweakDBID.new(dsp.martinez.ImmunoblockerEffect_Rare)
		}
		ObserveAfter('PlayerPuppet', 'OnStatusEffectApplied', function(this, evt)
			if not dsp then return end
			local ok, recordID = pcall(function() return evt.staticData:GetID() end)
			if not ok or not recordID then return end
			for tier, id in ipairs(immunoEffectIDs) do
				if recordID == id then
					dsp:TriggerImmunoblockerAnim()
					-- Track dose for treatment protocol (tier: 1=Common, 2=Uncommon, 3=Rare)
					dsp:CheckTreatmentDose(tier)
					-- Tolerance buildup on consumption
					dsp:AddToleranceOnConsumption(tier)
					-- Sync qty so real-time tick won't double-fire for this consumption
					local qty = getImmunoblockerQty()
					if qty then dsp.immunoLastQty = qty end
					return
				end
			end
		end)
	end)
	print('[DSP] Immunoblocker observer ' .. (obsOk and 'registered' or ('FAILED: ' .. tostring(obsErr))))

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
			-- Fallback: if observer didn't fire, detect tier and register treatment dose + tolerance
			local tier = self:GetImmunoblockerTier()
			if tier > 0 and consumed > 0 then
				for i = 1, consumed do
					self:CheckTreatmentDose(tier)
					self:AddToleranceOnConsumption(tier)
				end
			end
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
