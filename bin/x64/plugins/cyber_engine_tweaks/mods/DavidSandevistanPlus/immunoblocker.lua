local immunoblocker = {}

function immunoblocker.createItems(martinez)
	local SandevistanIcon = TweakDB:GetFlat('BaseStatusEffect.SandevistanCooldown.uiData')

	-- Helper: create one tier of Immunoblocker (status effect + cloned consumable item + vendor)
	local function createTier(effectName, effectSMG, effectSM1, itemName, actionName, oaeName, durationSec, quality, quantityPreset, price, iconAtlas, iconPart, locName, locDesc, logicPackage, vfxRecord)
		-- Duration stat modifier (same pattern as timed status effects)
		martinez:CreateStatModifierGroup(effectSMG, { false, false, {}, false, {effectSM1}, -1, nil })
		martinez:CreateConstantStatModifier(effectSM1, { 'Additive', 'BaseStats.MaxDuration', durationSec * 1.0 })

		-- Injector VFX (reflex_buster — same as InjectorBuff/BounceBack)
		local vfxList = {}
		if vfxRecord then
			martinez:CreateStatusEffectFX(vfxRecord, { 'reflex_buster', false })
			vfxList = {vfxRecord}
		end

		-- Status effect with stat packages active for duration
		local packages = {}
		if logicPackage then packages = {logicPackage} end
		martinez:CreateStatusEffect(effectName,{
			 '' --AIData
			,{} --SFX
			,vfxList --VFX (inhaler intake effect)
			,'' --additionalParam
			,{} --debugTags
			,effectSMG --duration
			,false --dynamicDuration
			,{'Buff','Immunoblocker','InhalerBuff'} --gameplayTags
			,{} --immunityStats
			,false --isAffectedByTimeDilationNPC
			,false --isAffectedByTimeDilationPlayer
			,'RTDB.StatusEffect_inline0' --maxStacks
			,packages --packages (stat buffs while active)
			,nil --playerData
			,false --reapplyPackagesOnMaxStacks
			,false --removeAllStacksWhenDurationEnds
			,nil --removeAllStacksWhenDurationEndsStatModifiers
			,false --removeOnStoryTier
			,false --replicated
			,false --savable
			,'BaseStatusEffectTypes.Misc' --statusEffectType
			,true --stopActiveSfxOnDeactivate
			,SandevistanIcon --uiData
		})

		-- Object Action Effect: bridge between action and status effect
		-- YAML defines OAE with forward ref to CET status effect — skip if exists
		if not martinez:TweakExists(oaeName) then
			martinez:CreateRecord(oaeName, 'gamedataObjectActionEffect_Record')
			TweakDB:SetFlatNoUpdate(oaeName..'.statusEffect', effectName)
			TweakDB:SetFlatNoUpdate(oaeName..'.percentMissing', false)
			TweakDB:SetFlatNoUpdate(oaeName..'.resistanceFlag', 'None')
			TweakDB:SetFlatNoUpdate(oaeName..'.range', 0.0)
			TweakDB:Update(oaeName)
		end

		-- Item Action: clone from Consume — skip if YAML defined it
		if not martinez:TweakExists(actionName) then
			martinez:CloneRecord(actionName, 'ItemAction.Consume')
			TweakDB:SetFlat(actionName..'.completionEffects', {oaeName})
		end

		-- Supporting records (icon, price) — skip if YAML defined them
		local uiIconName = 'UIIcon.'..iconPart
		if not martinez:TweakExists(uiIconName) then
			martinez:CreateUIIcon(uiIconName, { iconAtlas, iconPart })
		end
		local priceSM = itemName..'_Price'
		if not martinez:TweakExists(priceSM) then
			martinez:CreateConstantStatModifier(priceSM, { 'Additive', 'BaseStats.Price', price * 1.0 })
		end

		-- Only modify item if TweakXL didn't create it (fallback for missing YAML)
		if not martinez:TweakExists(itemName) then
			martinez:CloneRecord(itemName, 'Items.HealthBooster')
			TweakDB:SetFlat(itemName..'.displayName', LocKey(locName))
			TweakDB:SetFlat(itemName..'.localizedDescription', LocKey(locDesc))
			TweakDB:SetFlat(itemName..'.quality', quality)
			TweakDB:SetFlat(itemName..'.icon', uiIconName)
			TweakDB:SetFlat(itemName..'.iconPath', iconPart)
			TweakDB:SetFlat(itemName..'.objectActions', {actionName, 'ItemAction.Drop', 'ItemAction.ConsumableDisassemble'})
			TweakDB:SetFlat(itemName..'.tags', {'Consumable', 'Drug', 'Medical', 'LongLasting', 'HasModel', 'Inhaler'})
			TweakDB:SetFlat(itemName..'.statModifiers', {'Items.LongLasting_inline0'})
			TweakDB:SetFlat(itemName..'.statModifierGroups', {'Items.LongLastingConsumableDuration'})
			TweakDB:SetFlat(itemName..'.OnEquip', {})
			TweakDB:SetFlat(itemName..'.buyPrice', {priceSM})
			TweakDB:SetFlat(itemName..'.price', {priceSM})
			print('[DSP] CreateImmunoblockerItems: CET fallback — created '..itemName)
		else
			print('[DSP] CreateImmunoblockerItems: '..itemName..' exists from TweakXL, skipping item modifications')
		end
	end

	-- Per-tier stat modifiers (progressive combat benefits, inspired by Black Lace but medical-grade)
	-- Common: basic neural stabilizer — recovery only
	martinez:CreateConstantStatModifier(martinez.ImmunoblockerSM_StaminaRegen_Common, { 'Multiplier', 'BaseStats.StaminaRegenRate', 1.15 })
	martinez:CreateConstantStatModifier(martinez.ImmunoblockerSM_HealthRegen_Common, { 'Multiplier', 'BaseStats.HealthOutOfCombatRegenRate', 1.1 })
	-- Uncommon: stronger dose — recovery + pain threshold (armor)
	martinez:CreateConstantStatModifier(martinez.ImmunoblockerSM_StaminaRegen_Uncommon, { 'Multiplier', 'BaseStats.StaminaRegenRate', 1.2 })
	martinez:CreateConstantStatModifier(martinez.ImmunoblockerSM_HealthRegen_Uncommon, { 'Multiplier', 'BaseStats.HealthOutOfCombatRegenRate', 1.15 })
	martinez:CreateConstantStatModifier(martinez.ImmunoblockerSM_Armor_Uncommon, { 'Additive', 'BaseStats.Armor', 10.0 })
	-- Rare: military-grade — full combat operative formula (stabilized reflexes = precision)
	martinez:CreateConstantStatModifier(martinez.ImmunoblockerSM_StaminaRegen_Rare, { 'Multiplier', 'BaseStats.StaminaRegenRate', 1.25 })
	martinez:CreateConstantStatModifier(martinez.ImmunoblockerSM_HealthRegen_Rare, { 'Multiplier', 'BaseStats.HealthOutOfCombatRegenRate', 1.2 })
	martinez:CreateConstantStatModifier(martinez.ImmunoblockerSM_Armor_Rare, { 'Additive', 'BaseStats.Armor', 20.0 })
	martinez:CreateConstantStatModifier(martinez.ImmunoblockerSM_CritChance_Rare, { 'Additive', 'BaseStats.CritChance', 5.0 })
	martinez:CreateConstantStatModifier(martinez.ImmunoblockerSM_CritDamage_Rare, { 'Additive', 'BaseStats.CritDamage', 10.0 })

	-- Common: +15% stamina regen, +10% health regen (body relaxes as symptoms subside)
	martinez:CreateLogicPackage(martinez.ImmunoblockerLP_Common, {
		'', {}, {}, {}, '', false, {},
		{ martinez.ImmunoblockerSM_StaminaRegen_Common, martinez.ImmunoblockerSM_HealthRegen_Common }
	})

	-- Uncommon: +20% stamina, +15% health regen, +10 armor (Doc's high dosage — stabilizes pain threshold)
	martinez:CreateLogicPackage(martinez.ImmunoblockerLP_Uncommon, {
		'', {}, {}, {}, '', false, {},
		{ martinez.ImmunoblockerSM_StaminaRegen_Uncommon, martinez.ImmunoblockerSM_HealthRegen_Uncommon, martinez.ImmunoblockerSM_Armor_Uncommon }
	})

	-- Rare: +25% stamina, +20% health regen, +20 armor, +5% crit chance, +10% crit damage (military-grade combat formula)
	martinez:CreateLogicPackage(martinez.ImmunoblockerLP_Rare, {
		'', {}, {}, {}, '', false, {},
		{ martinez.ImmunoblockerSM_StaminaRegen_Rare, martinez.ImmunoblockerSM_HealthRegen_Rare, martinez.ImmunoblockerSM_Armor_Rare, martinez.ImmunoblockerSM_CritChance_Rare, martinez.ImmunoblockerSM_CritDamage_Rare }
	})

	createTier(
		martinez.ImmunoblockerEffect_Common, martinez.ImmunoblockerEffect_Common_SMG, martinez.ImmunoblockerEffect_Common_SM1,
		martinez.ImmunoblockerItem_Common, martinez.ImmunoblockerAction_Common, martinez.ImmunoblockerEffect_Common_OAE,
		180, 'Quality.Common', 'Vendors.Always_Present', 6000,
		'davidsandevistanplus\\immunoblocker_common.inkatlas', 'Immunoblocker_Common',
		'DavidSandevistanPlus-Immunoblocker', 'DavidSandevistanPlus-Immunoblocker-Desc',
		martinez.ImmunoblockerLP_Common, martinez.ImmunoblockerVFX_Common
	)
	createTier(
		martinez.ImmunoblockerEffect_Uncommon, martinez.ImmunoblockerEffect_Uncommon_SMG, martinez.ImmunoblockerEffect_Uncommon_SM1,
		martinez.ImmunoblockerItem_Uncommon, martinez.ImmunoblockerAction_Uncommon, martinez.ImmunoblockerEffect_Uncommon_OAE,
		360, 'Quality.Uncommon', 'Vendors.Commonly_Present', 24000,
		'davidsandevistanplus\\immunoblocker_uncommon.inkatlas', 'Immunoblocker_Uncommon',
		'DavidSandevistanPlus-Immunoblocker-High', 'DavidSandevistanPlus-Immunoblocker-High-Desc',
		martinez.ImmunoblockerLP_Uncommon, martinez.ImmunoblockerVFX_Uncommon
	)
	createTier(
		martinez.ImmunoblockerEffect_Rare, martinez.ImmunoblockerEffect_Rare_SMG, martinez.ImmunoblockerEffect_Rare_SM1,
		martinez.ImmunoblockerItem_Rare, martinez.ImmunoblockerAction_Rare, martinez.ImmunoblockerEffect_Rare_OAE,
		600, 'Quality.Rare', 'Vendors.Uncommonly_Present', 100000,
		'davidsandevistanplus\\immunoblocker_rare.inkatlas', 'Immunoblocker_Rare',
		'DavidSandevistanPlus-Immunoblocker-Mil', 'DavidSandevistanPlus-Immunoblocker-Mil-Desc',
		martinez.ImmunoblockerLP_Rare, martinez.ImmunoblockerVFX_Rare
	)

	-- Custom vendor quantity records (RandomStatModifier with BaseStats.Quantity)
	-- Common: 3-6 units guaranteed (standard prescription, always in stock)
	martinez:CreateRecord(martinez.ImmunoblockerQty_Common, 'gamedataRandomStatModifier_Record')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Common..'.modifierType', 'Additive')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Common..'.statType', 'BaseStats.Quantity')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Common..'.min', 3.0)
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Common..'.max', 6.0)
	TweakDB:Update(martinez.ImmunoblockerQty_Common)

	-- Uncommon: 1-3 units (high dosage, limited supply)
	martinez:CreateRecord(martinez.ImmunoblockerQty_Uncommon, 'gamedataRandomStatModifier_Record')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Uncommon..'.modifierType', 'Additive')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Uncommon..'.statType', 'BaseStats.Quantity')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Uncommon..'.min', 1.0)
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Uncommon..'.max', 3.0)
	TweakDB:Update(martinez.ImmunoblockerQty_Uncommon)

	-- Rare: 0-1 units (~30% chance of no stock — military contraband, very scarce)
	martinez:CreateRecord(martinez.ImmunoblockerQty_Rare, 'gamedataRandomStatModifier_Record')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Rare..'.modifierType', 'Additive')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Rare..'.statType', 'BaseStats.Quantity')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Rare..'.min', 0.3)
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Rare..'.max', 1.3)
	TweakDB:Update(martinez.ImmunoblockerQty_Rare)

	-- Viktor Vektor: Doc's personal stock — higher quantities (he's David's ripperdoc)
	-- Viktor Common: 5-10 units (always well-stocked for his patient)
	martinez:CreateRecord(martinez.ImmunoblockerQty_Viktor_Common, 'gamedataRandomStatModifier_Record')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Common..'.modifierType', 'Additive')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Common..'.statType', 'BaseStats.Quantity')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Common..'.min', 5.0)
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Common..'.max', 10.0)
	TweakDB:Update(martinez.ImmunoblockerQty_Viktor_Common)

	-- Viktor Uncommon: 2-5 units (keeps a personal reserve of the strong stuff)
	martinez:CreateRecord(martinez.ImmunoblockerQty_Viktor_Uncommon, 'gamedataRandomStatModifier_Record')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Uncommon..'.modifierType', 'Additive')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Uncommon..'.statType', 'BaseStats.Quantity')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Uncommon..'.min', 2.0)
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Uncommon..'.max', 5.0)
	TweakDB:Update(martinez.ImmunoblockerQty_Viktor_Uncommon)

	-- Viktor Rare: 1-2 units guaranteed (Doc has contacts — always has at least one)
	martinez:CreateRecord(martinez.ImmunoblockerQty_Viktor_Rare, 'gamedataRandomStatModifier_Record')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Rare..'.modifierType', 'Additive')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Rare..'.statType', 'BaseStats.Quantity')
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Rare..'.min', 1.0)
	TweakDB:SetFlatNoUpdate(martinez.ImmunoblockerQty_Viktor_Rare..'.max', 2.0)
	TweakDB:Update(martinez.ImmunoblockerQty_Viktor_Rare)

	-- Vendor integration is handled by TweakXL (immunoblocker_vendors.yaml)
	-- TweakXL creates inline VendorItems and appends to itemStock at compile time
	-- CET no longer touches vendor stock to avoid interfering with TweakXL
	print('[DSP] CreateImmunoblockerItems: vendor stock managed by TweakXL')

	-- Props.DspImmunoblockerProp — defined via TweakXL YAML ($base: Props.q001_ripperdoc_drug_inhaler)
end

function immunoblocker.createAutoInjector(martinez)
	local item = martinez.AutoInjectorItem

	-- Create from scratch (same pattern as AdvancedNervousSystemModule)
	martinez:CreateRecord(item, 'gamedataItem_Record')

	-- OnEquip: UIData packages for tooltip display
	local uiLP = item..'_UIPackage'
	martinez:CreateRecord(uiLP, 'gamedataGameplayLogicPackage_Record')
	TweakDB:SetFlatNoUpdate(uiLP..'.UIData', '')
	TweakDB:SetFlatNoUpdate(uiLP..'.animationWrapperOverrides', {})
	TweakDB:SetFlatNoUpdate(uiLP..'.effectors', {})
	TweakDB:SetFlatNoUpdate(uiLP..'.items', {})
	TweakDB:SetFlatNoUpdate(uiLP..'.stackable', '')
	TweakDB:SetFlatNoUpdate(uiLP..'.stackable', false)
	TweakDB:SetFlatNoUpdate(uiLP..'.stats', {})
	TweakDB:Update(uiLP)

	-- UIData for the description line in tooltip
	local uiData = item..'_UIData'
	martinez:CreateRecord(uiData, 'gamedataGameplayLogicPackageUIData_Record')
	TweakDB:SetFlatNoUpdate(uiData..'.localizedDescription', LocKey('DavidSandevistanPlus-AutoInjector-Desc'))
	TweakDB:SetFlatNoUpdate(uiData..'.iconPath', 'ability_silenced')
	TweakDB:Update(uiData)
	TweakDB:SetFlat(uiLP..'.UIData', uiData)

	TweakDB:SetFlat(item..'.OnAttach', {})
	TweakDB:SetFlat(item..'.OnEquip', {uiLP})
	TweakDB:SetFlat(item..'.OnLooted', {})
	TweakDB:SetFlat(item..'.animFeatureName', 'ItemData')
	TweakDB:SetFlat(item..'.animName', 'ui_garment_pose')
	TweakDB:SetFlat(item..'.blueprint', 'Items.GenericShardableCyberwareBlueprint')
	TweakDB:SetFlat(item..'.canDrop', false)
	TweakDB:SetFlat(item..'.crosshair', 'Crosshairs.None')
	TweakDB:SetFlat(item..'.cyberwareType', CName('NervousSystem'))
	TweakDB:SetFlat(item..'.displayName', LocKey('DavidSandevistanPlus-AutoInjector'))
	TweakDB:SetFlat(item..'.localizedDescription', LocKey('DavidSandevistanPlus-AutoInjector-Desc'))
	TweakDB:SetFlat(item..'.dropObject', '')
	TweakDB:SetFlat(item..'.entityName', 'cyberware_dummy')
	TweakDB:SetFlat(item..'.equipArea', 'EquipmentArea.NervousSystemCW')
	TweakDB:SetFlat(item..'.friendlyName', 'Martinez Protocol')
	TweakDB:SetFlat(item..'.gameplayRestrictions', {})
	TweakDB:SetFlat(item..'.isCoreCW', false)
	TweakDB:SetFlat(item..'.itemCategory', 'ItemCategory.Cyberware')
	TweakDB:SetFlat(item..'.itemType', 'ItemType.Cyberware')
	TweakDB:SetFlat(item..'.mass', 1.0)
	TweakDB:SetFlat(item..'.minigameInstance', 'minigame_v2.DefaultItemMinigame')
	TweakDB:SetFlat(item..'.objectActions', {})
	TweakDB:SetFlat(item..'.placementSlots', { 'CyberwareSlots.NervousSystem' })
	TweakDB:SetFlat(item..'.quality', 'Quality.Legendary')
	TweakDB:SetFlat(item..'.buyPrice', {'Price.BaseCyberwarePrice', 'Price.ItemQualityMultiplier', 'Price.CyberwareMultiplier', 'Price.BuyPrice_StreetCred_Discount'})
	TweakDB:SetFlat(item..'.sellPrice', {'Price.BaseCyberwarePrice', 'Price.ItemQualityMultiplier', 'Price.CyberwareMultiplier', 'Price.CyberwareSellMultiplier'})
	TweakDB:SetFlat(item..'.slotPartList', {'Items.GenericRootSlotItem'})
	TweakDB:SetFlat(item..'.slotPartListPreset', {'Items.GenericItemRootPreset'})
	TweakDB:SetFlat(item..'.statModifiers', {})
	TweakDB:SetFlat(item..'.tags', { 'Cyberware', 'HideInBackpackUI' })
	TweakDB:SetFlat(item..'.usesVariants', true)
	TweakDB:SetFlat(item..'.variants', {'Variants.Humanity12Cost'})
	TweakDB:SetFlat(item..'.upgradeCostMult', 1.0)

	-- Custom icon
	martinez:CreateUIIcon(martinez.AutoInjectorUIIcon, { 'davidsandevistanplus\\autoinjector.inkatlas', 'AutoInjector_Icon' })
	TweakDB:SetFlat(item..'.icon', martinez.AutoInjectorUIIcon)
	TweakDB:SetFlat(item..'.iconPath', 'AutoInjector_Icon')

	-- Price: 15,000€$
	local priceSM = item..'_Price'
	martinez:CreateConstantStatModifier(priceSM, { 'Additive', 'BaseStats.Price', 15000.0 })
	TweakDB:SetFlat(item..'.buyPrice', {priceSM})

	-- Vendor item: add to Viktor's CYBERWARE tab during onInit (before MarketSystem caches)
	local vendorItemName = martinez.AutoInjectorVendorItem
	if TweakDB:GetRecord(vendorItemName) == nil then
		TweakDB:CreateRecord(vendorItemName, 'gamedataVendorItem_Record')
		TweakDB:SetFlatNoUpdate(vendorItemName..'.item', TweakDBID.new(item))
		TweakDB:SetFlatNoUpdate(vendorItemName..'.quantity', {TweakDBID.new('Vendors.Always_Present')})
		TweakDB:SetFlatNoUpdate(vendorItemName..'.generationPrereqs', {})
		TweakDB:Update(vendorItemName)
	end
	local vendorRecord = martinez.VendorRecord
	local stock = TweakDB:GetFlat(vendorRecord..'.itemStock')
	if stock then
		local found = false
		for _, v in ipairs(stock) do
			if tostring(v):find('MartinezAutoInjector') then found = true; break end
		end
		if not found then
			table.insert(stock, TweakDBID.new(vendorItemName))
			TweakDB:SetFlat(vendorRecord..'.itemStock', stock)
		end
	end

	print('[DSP] CreateAutoInjector: '..item..' created (from scratch)')
end

-- Called at runtime (LoadGamePart1) — safety net re-injection for auto-injector
function immunoblocker.addAutoInjectorToViktor(martinez)
	local vendorRecord = martinez.VendorRecord  -- 'Vendors.wat_lch_ripperdoc_01' (CYBERWARE tab)
	local vendorItemName = martinez.AutoInjectorVendorItem

	if TweakDB:GetRecord(vendorItemName) == nil then
		TweakDB:CreateRecord(vendorItemName, 'gamedataVendorItem_Record')
		TweakDB:SetFlat(vendorItemName..'.item', TweakDBID.new(martinez.AutoInjectorItem))
		TweakDB:SetFlat(vendorItemName..'.quantity', {TweakDBID.new('Vendors.Always_Present')})
		print('[DSP] Created VendorItem: '..vendorItemName)
	end

	local stock = TweakDB:GetFlat(vendorRecord..'.itemStock')
	if stock then
		local found = false
		for _, v in ipairs(stock) do
			if tostring(v):find('MartinezAutoInjector') then found = true; break end
		end
		if not found then
			table.insert(stock, TweakDBID.new(vendorItemName))
			TweakDB:SetFlat(vendorRecord..'.itemStock', stock)
			print('[DSP] AddAutoInjectorToViktor: added to Viktor\'s stock')
		end
	end
end

-- Called at runtime (LoadGamePart1) — CET fallback for existing saves
-- TweakXL YAML handles new saves; this handles saves where vendor stock is already cached
-- TRADE tab reads from medicstore_01, Pacifica has no medicstore so falls back to ripperdoc_01
function immunoblocker.addImmunoblockersToVendors(martinez)
	local items = {
		martinez.ImmunoblockerItem_Common,
		martinez.ImmunoblockerItem_Uncommon,
		martinez.ImmunoblockerItem_Rare
	}
	local vendors = {
		-- medicstore_01 = TRADE tab (consumables) — this is what the vendor UI reads
		'Vendors.wat_lch_medicstore_01',
		'Vendors.wat_kab_medicstore_01',
		'Vendors.std_arr_medicstore_01',
		'Vendors.hey_spr_medicstore_01',
		'Vendors.wbr_jpn_medicstore_01',
		-- Pacifica has no medicstore, only ripperdoc
		'Vendors.pac_wwd_ripperdoc_01',
	}
	local totalAdded = 0
	for _, vendorRecord in ipairs(vendors) do
		local stock = TweakDB:GetFlat(vendorRecord..'.itemStock')
		if stock then
			local vendorAdded = 0
			for _, itemName in ipairs(items) do
				local viName = vendorRecord..'_'..itemName:gsub('%.', '_')
				local alreadyInStock = false
				for _, v in ipairs(stock) do
					if tostring(v):find(itemName:gsub('%.', '')) then alreadyInStock = true; break end
				end
				if not alreadyInStock then
					if TweakDB:GetRecord(viName) == nil then
						TweakDB:CreateRecord(viName, 'gamedataVendorItem_Record')
						TweakDB:SetFlat(viName..'.item', itemName)
						TweakDB:SetFlat(viName..'.quantity', {'Vendors.Always_Present'})
						TweakDB:SetFlat(viName..'.generationPrereqs', {})
					end
					table.insert(stock, viName)
					vendorAdded = vendorAdded + 1
				end
			end
			if vendorAdded > 0 then
				TweakDB:SetFlat(vendorRecord..'.itemStock', stock)
				totalAdded = totalAdded + vendorAdded
			end
		end
	end
	print('[DSP] AddImmunoblockersToVendors: injected '..totalAdded..' vendor items (CET fallback)')
end

return immunoblocker
