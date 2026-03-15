local immunoblocker_logic = {}

function immunoblocker_logic.attach(apogee)
	print('[DSP] immunoblocker_logic.lua attached')

	apogee.IsImmunoblockerActive = (function(self)
		return self:StatusEffect_CheckOnly(self.martinez.ImmunoblockerEffect_Common)
			or self:StatusEffect_CheckOnly(self.martinez.ImmunoblockerEffect_Uncommon)
			or self:StatusEffect_CheckOnly(self.martinez.ImmunoblockerEffect_Rare)
	 end)

	-- Returns active immunoblocker tier: 0=none, 1=Common, 2=Uncommon, 3=Rare
	apogee.GetImmunoblockerTier = (function(self)
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
	apogee.GetImmunoblockerEffectiveness = (function(self)
		local tier = self:GetImmunoblockerTier()
		if tier == 0 then return 'none' end
		local psycho = self.CyberPsychoWarnings
		local maxEffective = { 1, 2, 5 }   -- Common, Uncommon, Rare
		local partialLevel = { 2, 3, -1 }  -- Common partial at 2, Uncommon at 3, Rare never
		if psycho <= maxEffective[tier] then return 'full' end
		if psycho == partialLevel[tier] then return 'partial' end
		return 'ineffective'
	 end)

	apogee.immunoLastQty = nil
	apogee.immunoAnimQueue = 0

	-- Shared item name list for qty checks
	local immunoItemNames = {
		apogee.martinez.ImmunoblockerItem_Common,
		apogee.martinez.ImmunoblockerItem_Uncommon,
		apogee.martinez.ImmunoblockerItem_Rare
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
	apogee.TriggerImmunoblockerAnim = (function(self)
		self.immunoAnimQueue = self.immunoAnimQueue + 1
		print('[DSP] Immunoblocker consumed — queued (queue=' .. self.immunoAnimQueue .. ')')
		self:ProcessImmunoblockerAnimQueue()
	 end)

	-- Drain queue: if quest fact is 0 (scene idle) and queue > 0, trigger next scene
	apogee.ProcessImmunoblockerAnimQueue = (function(self)
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
			TweakDBID.new(apogee.martinez.ImmunoblockerEffect_Common),
			TweakDBID.new(apogee.martinez.ImmunoblockerEffect_Uncommon),
			TweakDBID.new(apogee.martinez.ImmunoblockerEffect_Rare)
		}
		ObserveAfter('PlayerPuppet', 'OnStatusEffectApplied', function(this, evt)
			if not davidsapogee then return end
			local ok, recordID = pcall(function() return evt.staticData:GetID() end)
			if not ok or not recordID then return end
			for _, id in ipairs(immunoEffectIDs) do
				if recordID == id then
					davidsapogee:TriggerImmunoblockerAnim()
					-- Sync qty so real-time tick won't double-fire for this consumption
					local qty = getImmunoblockerQty()
					if qty then davidsapogee.immunoLastQty = qty end
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
	apogee.RealTimeImmunoblockerTick = (function(self)
		if not self.PlayerAttached then return end
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
		end
		self.immunoLastQty = totalQty
		self:ProcessImmunoblockerAnimQueue()
	 end)

	-- Legacy no-op (replaced by RealTimeImmunoblockerTick, but init.lua Phase 2 still calls it)
	apogee.CheckImmunoblockerConsumed = (function(self) end)

	apogee.IsAutoInjectorEquipped = (function(self)
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

	apogee.TryAutoInject = (function(self)
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
