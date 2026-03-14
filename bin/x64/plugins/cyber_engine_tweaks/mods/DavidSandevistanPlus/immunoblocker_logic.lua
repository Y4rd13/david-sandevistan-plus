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
