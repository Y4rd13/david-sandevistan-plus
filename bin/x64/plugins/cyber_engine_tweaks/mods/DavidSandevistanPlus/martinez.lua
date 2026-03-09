local martinez = {
	 RecordName = 'Items.MartinezSandevistanPlusPlus'
	,UseDavidsIcon = true -- this is over written by init.lua
	,entEffects = nil -- require('./entEffects.lua')
	,debug = false
}

martinez.UIIcon    = 'UIIcon.MartinezSandevistanPlusPlus'       -- inline0
martinez.Equip1    = martinez.RecordName..'_Equip1_Various'     -- inline0
martinez.Equip1_UI = martinez.RecordName..'_Equip1_Various_UI'  -- inline1
martinez.Equip2    = martinez.RecordName..'_Equip2_Cooldown'    -- inline2
martinez.Equip2_UI = martinez.RecordName..'_Equip2_Cooldown_UI' -- inline3
martinez.Equip3    = martinez.RecordName..'_Equip3_Stats'       -- inline4
martinez.Equip3_SGE= martinez.RecordName..'_Equip3_SGE'         -- inline5
martinez.Equip3_Rec= martinez.RecordName..'_Equip3_PreReq'      -- inline6
martinez.Equip3_SMG= martinez.RecordName..'_Equip3_SMG'         -- inline7
martinez.Equip3_SM1= martinez.RecordName..'_Equip3_SM1'         -- inline8
martinez.Equip3_SM2= martinez.RecordName..'_Equip3_SM2'         -- inline9
martinez.Equip3_SM3= martinez.RecordName..'_Equip3_SM3'         -- inline10
martinez.Equip4    = martinez.RecordName..'_Equip4_OnKill'      -- inline11
martinez.Equip4_AEE= martinez.RecordName..'_Equip4_AEE'         -- inline12
martinez.Equip4_Rec= martinez.RecordName..'_Equip4_PreReq'      -- inline13
martinez.Equip4_SPV= martinez.RecordName..'_Equip4_SPVE'        -- inline14
martinez.Equip4_SP1= martinez.RecordName..'_Equip4_SPU1'        -- HealOnKill 7.5% (This is instead of the duration boost)
martinez.Equip4_SP2= martinez.RecordName..'_Equip4_SPU2'        -- inline15

martinez.Stat_Modifier_01 = martinez.RecordName..'_Stat_Modifier_01'       -- inline16 iconic
martinez.Stat_Modifier_02 = martinez.RecordName..'_Stat_Modifier_02'       -- inline17 HasSandy
martinez.Stat_Modifier_03 = martinez.RecordName..'_Stat_Modifier_03'       -- inline18 TimeDilationDuration
martinez.Stat_Modifier_04 = martinez.RecordName..'_Stat_Modifier_04'       -- inline19 TimeScale
martinez.Stat_Modifier_05 = martinez.RecordName..'_Stat_Modifier_05'       -- inline20 RechargeDuration
martinez.Stat_Modifier_06 = martinez.RecordName..'_Stat_Modifier_06'       -- inline21 CooldownBase
martinez.Stat_Modifier_07 = martinez.RecordName..'_Stat_Modifier_07'       -- inline22 KillRechargeValue(none?)
martinez.Stat_Modifier_08 = martinez.RecordName..'_Stat_Modifier_08'       -- inline23 Sandy Activate Cost
martinez.Stat_Modifier_09 = martinez.RecordName..'_Stat_Modifier_09'       -- inline24 COOL HELPER (combinedStatModifier)
martinez.DavidsJacket     = 'Items.MQ049_martinez_jacket'
martinez.FalcosLootBox    = 'LootTables.mq049_jacket_lt'
martinez.FalcosLootItem1  = 'LootTables.mq049_jacket_loot_item'
martinez.FalcosLootItem2  = 'LootTables.mq049_sandevistan_loot_item'
martinez.FalcosLoot       = { martinez.FalcosLootItem1,martinez.FalcosLootItem2 }

martinez.MartinezFury                = 'BaseStatusEffect.MartinezSandevistan_Fury'
martinez.MartinezFury_LP             = 'BaseStatusEffect.MartinezSandevistan_Fury_LP'
martinez.MartinezFury_SMG            = 'BaseStatusEffect.MartinezSandevistan_Fury_SMG'
martinez.MartinezFury_SM1            = 'BaseStatusEffect.MartinezSandevistan_Fury_SM1'
martinez.MartinezFury_SM2            = 'BaseStatusEffect.MartinezSandevistan_Fury_SM2'
martinez.MartinezFury_FX1            = 'BaseStatusEffect.MartinezSandevistan_Fury_FX1'
martinez.MartinezFury_FX2            = 'BaseStatusEffect.MartinezSandevistan_Fury_FX2'
martinez.MartinezFury_Level5         = 'BaseStatusEffect.MartinezSandevistan_Fury_Lvl5'
martinez.MartinezFury_Level5_LP      = 'BaseStatusEffect.MartinezSandevistan_Fury_Lvl5_LP'
martinez.MartinezFury_Level5_SMG     = 'BaseStatusEffect.MartinezSandevistan_Fury_Lvl5_SMG'
martinez.MartinezFury_Level5_SM1     = 'BaseStatusEffect.MartinezSandevistan_Fury_Lvl5_SM1'
martinez.MartinezFury_Level5_SM2     = 'BaseStatusEffect.MartinezSandevistan_Fury_Lvl5_SM2'
martinez.MartinezFury_Level5_FX1     = 'BaseStatusEffect.MartinezSandevistan_Fury_Lvl5_FX1'

martinez.SafetiesOffStatusEffect     = 'BaseStatusEffect.MartinezSandevistan_NoSafety'
martinez.SafetiesOffStatusEffect_LP  = 'BaseStatusEffect.MartinezSandevistan_NoSafety_LP'
martinez.SafetiesOffStatusEffect_SM  = 'BaseStatusEffect.MartinezSandevistan_NoSafety_SM1'
martinez.SafetiesOffStatusEffect_SFX1= 'BaseStatusEffect.MartinezSandevistan_NoSafety_SFX1'
martinez.SafetiesOffStatusEffect_VFX1= 'BaseStatusEffect.MartinezSandevistan_NoSafety_VFX1'
martinez.SafetiesOffStatusEffect_VFX2= 'BaseStatusEffect.MartinezSandevistan_NoSafety_VFX2'
martinez.SafetiesOffStatusEffect_VFX3= 'BaseStatusEffect.MartinezSandevistan_NoSafety_VFX3'

martinez.BleedingStatusEffect        = 'BaseStatusEffect.MartinezSandevistan_Bleeding'
martinez.BleedingStatusEffect_LP     = 'BaseStatusEffect.MartinezSandevistan_Bleeding_LP'
martinez.BleedingStatusEffect_SM     = 'BaseStatusEffect.MartinezSandevistan_Bleeding_SM'
martinez.BleedingStatusEffect_VFX1   = 'BaseStatusEffect.MartinezSandevistan_Bleeding_VFX1'
martinez.BleedingStatusEffect_VFX2   = 'BaseStatusEffect.MartinezSandevistan_Bleeding_VFX2'
martinez.CyberpsychoStatusEffect     = 'BaseStatusEffect.MartinezSandevistan_Cyberpsycho'
martinez.CyberpsychoStatusEffect_LP  = 'BaseStatusEffect.MartinezSandevistan_Cyberpsycho_LP'
martinez.CyberpsychoStatusEffect_SM  = 'BaseStatusEffect.MartinezSandevistan_Cyberpsycho_SM'
martinez.CyberpsychoStatusEffect_FX1 = 'BaseStatusEffect.MartinezSandevistan_Cyberpsycho_FX1'
martinez.CyberpsychoStatusEffect_FX2 = 'BaseStatusEffect.MartinezSandevistan_Cyberpsycho_FX2'
martinez.CyberpsychoStatusEffect_FX3 = 'BaseStatusEffect.MartinezSandevistan_Cyberpsycho_FX3'
martinez.CyberpsychoStatusEffect_FX4 = 'BaseStatusEffect.MartinezSandevistan_Cyberpsycho_FX4'
martinez.CyberpsychoStatusEffect_FX5 = 'BaseStatusEffect.MartinezSandevistan_Cyberpsycho_FX5'

martinez.CyberpsychoSafetyOffEffect      = 'BaseStatusEffect.MartinezSandevistan_CyberpsychoSafetyOff'
martinez.CyberpsychoSafetyOffEffect_FX1  = 'BaseStatusEffect.MartinezSandevistan_CyberpsychoSafetyOff_FX1'
martinez.CyberpsychoSafetyOffEffect_FX2  = 'BaseStatusEffect.MartinezSandevistan_CyberpsychoSafetyOff_FX2'
martinez.CyberpsychoSafetyOffEffect_FX3  = 'BaseStatusEffect.MartinezSandevistan_CyberpsychoSafetyOff_FX3'
martinez.CyberpsychoSafetyOffEffect_FX4  = 'BaseStatusEffect.MartinezSandevistan_CyberpsychoSafetyOff_FX4'
martinez.CyberpsychoSafetyOffEffect_FX5  = 'BaseStatusEffect.MartinezSandevistan_CyberpsychoSafetyOff_FX5'

martinez.PsychoWarningEffect_Light       = 'BaseStatusEffect.MartinezSandevistan_PsychoWarning_Light'
martinez.PsychoWarningEffect_Light_FX1   = 'BaseStatusEffect.MartinezSandevistan_PsychoWarning_Light_FX1'
martinez.PsychoWarningEffect_Medium      = 'BaseStatusEffect.MartinezSandevistan_PsychoWarning_Medium'
martinez.PsychoWarningEffect_Medium_FX1  = 'BaseStatusEffect.MartinezSandevistan_PsychoWarning_Medium_FX1'
martinez.PsychoWarningEffect_Medium_FX2  = 'BaseStatusEffect.MartinezSandevistan_PsychoWarning_Medium_FX2'

martinez.PsychoLaughEffect              = 'BaseStatusEffect.MartinezSandevistan_PsychoLaugh'
martinez.PsychoLaughEffect_FX1          = 'BaseStatusEffect.MartinezSandevistan_PsychoLaugh_FX1'
martinez.PsychoLaughEffect_SMG          = 'BaseStatusEffect.MartinezSandevistan_PsychoLaugh_SMG'
martinez.PsychoLaughEffect_SM1          = 'BaseStatusEffect.MartinezSandevistan_PsychoLaugh_SM1'

martinez.NosebleedEffect                = 'BaseStatusEffect.MartinezSandevistan_Nosebleed'
martinez.NosebleedEffect_FX1            = 'BaseStatusEffect.MartinezSandevistan_Nosebleed_FX1'
martinez.NosebleedEffect_SMG            = 'BaseStatusEffect.MartinezSandevistan_Nosebleed_SMG'
martinez.NosebleedEffect_SM1            = 'BaseStatusEffect.MartinezSandevistan_Nosebleed_SM1'

martinez.HeartbeatEffect                = 'BaseStatusEffect.MartinezSandevistan_Heartbeat'
martinez.HeartbeatEffect_SFX1           = 'BaseStatusEffect.MartinezSandevistan_Heartbeat_SFX1'

martinez.TickingTimeBombEffect              = 'BaseStatusEffect.MartinezSandevistan_TickingTimeBomb'
martinez.TickingTimeBombEffect_FX1          = 'BaseStatusEffect.MartinezSandevistan_TickingTimeBomb_FX1'
martinez.TickingTimeBombEffect_SMG          = 'BaseStatusEffect.MartinezSandevistan_TickingTimeBomb_SMG'
martinez.TickingTimeBombEffect_SM1          = 'BaseStatusEffect.MartinezSandevistan_TickingTimeBomb_SM1'

martinez.BlackwallKillEffect                = 'BaseStatusEffect.MartinezSandevistan_BlackwallKill'
martinez.BlackwallKillEffect_FX1            = 'BaseStatusEffect.MartinezSandevistan_BlackwallKill_FX1'
martinez.BlackwallKillEffect_FX2            = 'BaseStatusEffect.MartinezSandevistan_BlackwallKill_FX2'
martinez.BlackwallKillEffect_SMG            = 'BaseStatusEffect.MartinezSandevistan_BlackwallKill_SMG'
martinez.BlackwallKillEffect_SM1            = 'BaseStatusEffect.MartinezSandevistan_BlackwallKill_SM1'

martinez.OverclockStatusEffect       = 'BaseStatusEffect.MartinezSandevistan_Overclock'
martinez.Overclock_LP                = 'BaseStatusEffect.MartinezSandevistan_Overclock_LP'

martinez.CyberpsychoKiroshiOff_LP    = 'BaseStatusEffect.MartinezSandevistan_KiroshiOff_LP'
martinez.CyberpsychoKiroshiOff_SM1    = 'BaseStatusEffect.MartinezSandevistan_KiroshiOff_SM1'
martinez.CyberpsychoKiroshiOff_SM2    = 'BaseStatusEffect.MartinezSandevistan_KiroshiOff_SM2'
martinez.CyberpsychoKiroshiOff_SM3    = 'BaseStatusEffect.MartinezSandevistan_KiroshiOff_SM3'
martinez.CyberpsychoKiroshiOff_SM4    = 'BaseStatusEffect.MartinezSandevistan_KiroshiOff_SM4'
martinez.CyberpsychoKiroshiOff_SM5    = 'BaseStatusEffect.MartinezSandevistan_KiroshiOff_SM5'
martinez.CyberpsychoKiroshiOff_SM6    = 'BaseStatusEffect.MartinezSandevistan_KiroshiOff_SM6'
martinez.CyberpsychoKiroshiOff_SM7    = 'BaseStatusEffect.MartinezSandevistan_KiroshiOff_SM7'

martinez.CyberpsychoNPCStatusEffect     = 'BaseStatusEffect.MartinezSandevistan_CyberpsychoNPC'
martinez.CyberpsychoNPCStatusEffect_SMG = 'BaseStatusEffect.MartinezSandevistan_CyberpsychoNPC_SMG'
martinez.CyberpsychoNPCStatusEffect_SM1 = 'BaseStatusEffect.MartinezSandevistan_CyberpsychoNPC_SM1'
martinez.CyberpsychoNPCStatusEffect_FX1 = 'BaseStatusEffect.MartinezSandevistan_CyberpsychoNPC_FX1'

martinez.TimeDilation825StatusEffect = 'BaseStatusEffect.MartinezSandevistan_Dilation825'
martinez.TimeDilation875StatusEffect = 'BaseStatusEffect.MartinezSandevistan_Dilation875'
martinez.TimeDilation900StatusEffect = 'BaseStatusEffect.MartinezSandevistan_Dilation900'
martinez.TimeDilation925StatusEffect = 'BaseStatusEffect.MartinezSandevistan_Dilation925'
martinez.TimeDilation950StatusEffect = 'BaseStatusEffect.MartinezSandevistan_Dilation950'
martinez.TimeDilation975StatusEffect = 'BaseStatusEffect.MartinezSandevistan_Dilation975'
martinez.TimeDilation990StatusEffect  = 'BaseStatusEffect.MartinezSandevistan_Dilation990'
martinez.TimeDilation9925StatusEffect = 'BaseStatusEffect.MartinezSandevistan_Dilation9925'
martinez.TimeDilation9935StatusEffect = 'BaseStatusEffect.MartinezSandevistan_Dilation9935'
martinez.TimeDilation995StatusEffect = 'BaseStatusEffect.MartinezSandevistan_Dilation995'
martinez.TimeDilation825_LP         = 'BaseStatusEffect.MartinezSandevistan_Dilation825_LP'
martinez.TimeDilation875_LP         = 'BaseStatusEffect.MartinezSandevistan_Dilation875_LP'
martinez.TimeDilation900_LP         = 'BaseStatusEffect.MartinezSandevistan_Dilation900_LP'
martinez.TimeDilation925_LP         = 'BaseStatusEffect.MartinezSandevistan_Dilation925_LP'
martinez.TimeDilation950_LP         = 'BaseStatusEffect.MartinezSandevistan_Dilation950_LP'
martinez.TimeDilation975_LP         = 'BaseStatusEffect.MartinezSandevistan_Dilation975_LP'
martinez.TimeDilation990_LP         = 'BaseStatusEffect.MartinezSandevistan_Dilation990_LP'
martinez.TimeDilation9925_LP        = 'BaseStatusEffect.MartinezSandevistan_Dilation9925_LP'
martinez.TimeDilation9935_LP        = 'BaseStatusEffect.MartinezSandevistan_Dilation9935_LP'
martinez.TimeDilation995_LP         = 'BaseStatusEffect.MartinezSandevistan_Dilation995_LP'
martinez.TimeDilation825_SM         = 'BaseStatusEffect.MartinezSandevistan_Dilation825_SM'
martinez.TimeDilation875_SM         = 'BaseStatusEffect.MartinezSandevistan_Dilation875_SM'
martinez.TimeDilation900_SM         = 'BaseStatusEffect.MartinezSandevistan_Dilation900_SM'
martinez.TimeDilation925_SM         = 'BaseStatusEffect.MartinezSandevistan_Dilation925_SM'
martinez.TimeDilation950_SM         = 'BaseStatusEffect.MartinezSandevistan_Dilation950_SM'
martinez.TimeDilation975_SM         = 'BaseStatusEffect.MartinezSandevistan_Dilation975_SM'
martinez.TimeDilation990_SM         = 'BaseStatusEffect.MartinezSandevistan_Dilation990_SM'
martinez.TimeDilation9925_SM        = 'BaseStatusEffect.MartinezSandevistan_Dilation9925_SM'
martinez.TimeDilation9935_SM        = 'BaseStatusEffect.MartinezSandevistan_Dilation9935_SM'
martinez.TimeDilation995_SM         = 'BaseStatusEffect.MartinezSandevistan_Dilation995_SM'

martinez.martinez_fx_onscreen_frame              = 'martinez_fx_onscreen_frame'
martinez.martinez_fx_onscreen_sick_start         = 'martinez_fx_onscreen_sick_start'
martinez.martinez_fx_onscreen_sick_pulse         = 'martinez_fx_onscreen_sick_pulse'
martinez.martinez_fx_onscreen_sick_2023          = 'martinez_fx_onscreen_sick_2023'
martinez.martinez_fx_MAXTAC                      = 'martinez_fx_MAXTAC'

martinez.martinez_npc_optical_blur               = 'martinez_npc_optical_blur'

martinez.TimeDilations = {
	-- td= is configurable; the rest is hard coded don't touch.
	-- In this case i is in increments of 25 for OC calculation
	 {i=825,td=82.5,SE=martinez.TimeDilation825StatusEffect}
	,{i=850,td=85.0,SE=nil} -- this is the default sandy speed
	,{i=875,td=87.5,SE=martinez.TimeDilation875StatusEffect}
	,{i=900,td=90.0,SE=martinez.TimeDilation900StatusEffect}
	,{i=925,td=92.5,SE=martinez.TimeDilation925StatusEffect}
	,{i=950,td=95.0,SE=martinez.TimeDilation950StatusEffect}
	,{i=975,td=97.5,SE=martinez.TimeDilation975StatusEffect}
	,{i=990,td=99.0,SE=martinez.TimeDilation990StatusEffect}
	,{i=9925,td=99.25,SE=martinez.TimeDilation9925StatusEffect}
	,{i=9935,td=99.35,SE=martinez.TimeDilation9935StatusEffect}
	,{i=1000,td=99.5,SE=martinez.TimeDilation995StatusEffect}
	,index = {}
	,GetTimeDilationFromIndex = (function(self,i) -- pass in 825,850,900 etc
		local thisIndex = martinez.TimeDilations.index[tostring(i)]
		if thisIndex == nil then return nil end
		return martinez.TimeDilations[thisIndex].td
	 end)
	,GetStatusEffectFromIndex = (function(self,i) -- pass in 825,850,900 etc
		local thisIndex = martinez.TimeDilations.index[tostring(i)]
		if thisIndex == nil then return nil end
		return martinez.TimeDilations[thisIndex].SE
	 end)
	,GetDataFromIndex = (function(self,i) -- pass in 825,850,900 etc
		local thisIndex = martinez.TimeDilations.index[tostring(i)]
		if thisIndex == nil then return nil, nil end
		return martinez.TimeDilations[thisIndex].td, martinez.TimeDilations[thisIndex].SE
	 end)
	,Init = (function(self) -- loop on initialization, not every frame
		for i,v in ipairs(martinez.TimeDilations) do
			martinez.TimeDilations.index[tostring(v.i)] = i
		end
	 end)
}
martinez.TimeDilations:Init()

martinez.VendorRecord          = 'Vendors.wat_lch_ripperdoc_01'
martinez.Vendor_MultiPrereqs   = 'LootPrereqs.MartinezSandevistan'
martinez.Vendor_LootLevelCheck = 'LootPrereqs.MartinezSandevistan_LevelCheck'

-- Attunements.CoolHeadshotDamage     - 0.2 headshot multiplier
-- Attunements.CoolArmsDamageTextOnly - 0.5 headshot multiplier
martinez.HeadShotMultiplier = 'Attunements.CoolArmsDamageTextOnly'

function martinez.CreateSandevistan(self)
	local err = nil
	self.entEffects , err = require('./entEffects.lua')
	if err ~= nil then print('martinez.CreateSandevistan:entEffects(): '..tostring(err)) end
	self.entEffects:Init(false,'martinez','martinez_fx_effects','martinez_npc_fx_effects')

	self:CreateRecord(self.RecordName,'gamedataItem_Record')

	local Sandy_Equip_Records = { self.Equip1, self.Equip2, self.Equip3, self.Equip4, self.HeadShotMultiplier }
	local Sandy_BuyPrice_Records = { } -- TO DO
	local Sandy_Object_Actions = {
		 'CyberwareAction.DisableSandevistan'
		,'CyberwareAction.DisableCorruptedSandevistan'
		,'CyberwareAction.UseCooldownedSandevistan'
		,'CyberwareAction.UseCooldownedCorruptedSandevistan'	
	}
	local Sandy_Sell_Price = { } -- TO DO
	local Sandy_Stat_Modifiers = {
		 self.Stat_Modifier_01
		,self.Stat_Modifier_02
		,self.Stat_Modifier_03
		,self.Stat_Modifier_04
		,self.Stat_Modifier_05
		,self.Stat_Modifier_06
		,self.Stat_Modifier_07
		,self.Stat_Modifier_08
		,self.Stat_Modifier_09
	}
	local Sandy_Tags = { 'Cyberware', 'HideInBackpackUI', 'Sandevistan', 'Iconic_OS_CW' }
	local Sandevistan_TimeDilation825  = martinez.TimeDilations[1].td
	local Sandevistan_TimeDilation850  = martinez.TimeDilations[2].td
	local Sandevistan_TimeDilation875  = martinez.TimeDilations[3].td
	local Sandevistan_TimeDilation900  = martinez.TimeDilations[4].td
	local Sandevistan_TimeDilation925  = martinez.TimeDilations[5].td
	local Sandevistan_TimeDilation950  = martinez.TimeDilations[6].td
	local Sandevistan_TimeDilation975  = martinez.TimeDilations[7].td
	local Sandevistan_TimeDilation990  = martinez.TimeDilations[8].td
	local Sandevistan_TimeDilation9925 = martinez.TimeDilations[9].td
	local Sandevistan_TimeDilation9935 = martinez.TimeDilations[10].td
	local Sandevistan_TimeDilation995  = martinez.TimeDilations[11].td
	
	---- let noPhone: Bool = StatusEffectSystem.ObjectHasStatusEffectWithTag(localPlayer, n"NoPhone");
	
	TweakDB:SetFlat(self.RecordName..'.OnAttach', {})
	TweakDB:SetFlat(self.RecordName..'.OnEquip', Sandy_Equip_Records)
	TweakDB:SetFlat(self.RecordName..'.OnLooted', {})
	TweakDB:SetFlat(self.RecordName..'.animFeatureName', 'ItemData')
	TweakDB:SetFlat(self.RecordName..'.animName', 'ui_garment_pose')
	TweakDB:SetFlat(self.RecordName..'.blueprint', 'Items.SandevistanBlueprint')
	TweakDB:SetFlat(self.RecordName..'.buyPrice', Sandy_BuyPrice_Records)
	TweakDB:SetFlat(self.RecordName..'.canDrop', false)
	TweakDB:SetFlat(self.RecordName..'.crosshair', 'Crosshairs.None')
	TweakDB:SetFlat(self.RecordName..'.cyberwareType', CName('Sandevistan'))
	TweakDB:SetFlat(self.RecordName..'.displayName', LocKey('DavidSandevistanPlus-Name'))
	TweakDB:SetFlat(self.RecordName..'.dropObject', 'None')
	TweakDB:SetFlat(self.RecordName..'.entityName', 'cyberware_dummy')
	TweakDB:SetFlat(self.RecordName..'.equipArea', 'EquipmentArea.SystemReplacementCW')
	TweakDB:SetFlat(self.RecordName..'.friendlyName', 'David Sandevistan Plus')
	TweakDB:SetFlat(self.RecordName..'.gameplayRestrictions', {'GameplayRestriction.VehicleCombatNoInterruptions'})
	if self.UseDavidsIcon then
		TweakDB:SetFlat(self.RecordName..'.icon', 'UIIcon.MartinezSandevistanPlusPlus')
		TweakDB:SetFlat(self.RecordName..'.iconPath', 'MartinezSandevistanPlusPlus')
	else
		TweakDB:SetFlat(self.RecordName..'.icon', 'UIIcon.ItemIcon')
		TweakDB:SetFlat(self.RecordName..'.iconPath', 'cw_system_sandevistanedgerunner')
	end
	TweakDB:SetFlat(self.RecordName..'.isCoreCW', true)
	TweakDB:SetFlat(self.RecordName..'.itemCategory', 'ItemCategory.Cyberware')
	TweakDB:SetFlat(self.RecordName..'.itemType', 'ItemType.Cyberware')
	TweakDB:SetFlat(self.RecordName..'.localizedDescription', LocKey('DavidSandevistanPlus-Desc'))
	TweakDB:SetFlat(self.RecordName..'.mass', 1.0)
	TweakDB:SetFlat(self.RecordName..'.minigameInstance', 'minigame_v2.DefaultItemMinigame')
	--TweakDB:SetFlat(self.RecordName..'.nextUpgradeItem', '')
	TweakDB:SetFlat(self.RecordName..'.objectActions', Sandy_Object_Actions )
	TweakDB:SetFlat(self.RecordName..'.placementSlots', {  'CyberwareSlots.Sandevistan' })
	TweakDB:SetFlat(self.RecordName..'.quality', 'Quality.LegendaryPlusPlus')
	TweakDB:SetFlat(self.RecordName..'.sellPrice', Sandy_Sell_Price )
	TweakDB:SetFlat(self.RecordName..'.slotPartList', {'Items.GenericRootSlotItem'})
	TweakDB:SetFlat(self.RecordName..'.statModifiers', Sandy_Stat_Modifiers )
	TweakDB:SetFlat(self.RecordName..'.tags', Sandy_Tags )
	TweakDB:SetFlat(self.RecordName..'.upgradeCostMult', 2.5)
	TweakDB:SetFlat(self.RecordName..'.usesVariants', true)
	TweakDB:SetFlat(self.RecordName..'.variants', {'Variants.Humanity44Cost'})

	--[[ UI Icon ]]
	self:CreateUIIcon(self.UIIcon, { 'davidsandevistanplus\\icons.inkatlas', 'David_Sandevistan_Plus' })
	
	--[[ UI STATS ]]
	self:CreateLogicPackage(self.Equip1, { self.Equip1_UI, {}, {}, {}, 'None', false, {}, {} })
	self:CreateLogicPackageUIData(self.Equip1_UI, { { Sandevistan_TimeDilation850,20,20,20,5,22,300 }, 'None', {}, 'LocKey#91021', '', {}, {} })
	self:CreateLogicPackage(self.Equip2, { self.Equip2_UI, {}, {}, {}, 'None', false, {}, {} })
	self:CreateLogicPackageUIData(self.Equip2_UI, { { 2 }, 'None', {}, 'LocKey#93182', '', {}, {} })

	--[[ Effector Stats ]]
	self:CreateLogicPackage(self.Equip3, {'', {}, {self.Equip3_SGE}, {}, 'None', false, {}, {} })
	self:CreateApplyStatGroupEffector(self.Equip3_SGE, { 'None', 'ApplyStatGroupEffector', self.Equip3_Rec, false, false, true, self.Equip3_SMG, {} })
	self:CreateTimeDilationPSMPrereq(self.Equip3_Rec, { true, false, 'Sandevistan' })
	local Equip3_Records = { self.Equip3_SM1,self.Equip3_SM2,self.Equip3_SM3 }
	self:CreateStatModifierGroup(self.Equip3_SMG, { false, false, {}, false, Equip3_Records, -1, '' })
	self:CreateConstantStatModifier(self.Equip3_SM1, { 'Additive', 'BaseStats.CritChance', 20.0 })
	self:CreateConstantStatModifier(self.Equip3_SM2, { 'Additive', 'BaseStats.CritDamage', 20.0 })
	self:CreateConstantStatModifier(self.Equip3_SM3, { 'Multiplier', 'BaseStats.HeadshotDamageMultiplier', 1.2 })

	--[[ On Kill Effects ; we add heal-on-kill because duration-on-kill wont have any effect because duration is infinite ]]
	self:CreateLogicPackage(self.Equip4, {'', {}, {self.Equip4_AEE}, {}, 'None', false, {}, {} })
	self:CreateApplyEffectorEffector(self.Equip4_AEE, { 'None', 'ApplyEffectorEffector', self.Equip4_SPV, self.Equip4_Rec, false, false, {} })
	self:CreateTimeDilationPSMPrereq(self.Equip4_Rec, { true, false, 'Sandevistan' })
	local Equip4_Records = { self.Equip4_SP1, self.Equip4_SP2 }
	self:CreateModifyStatPoolValueEffector(self.Equip4_SPV, { 'ModifyStatPoolValueEffector', 'Prereqs.AnyTakedownOrKill', false, false, false, {}, Equip4_Records, true })
	self:CreateStatPoolUpdate(self.Equip4_SP1, { {} , 'BaseStatPools.Health' , 5 }) -- heal-on-kill has to go first to get the benefit of 'IsPercent', don't know why.
	self:CreateStatPoolUpdate(self.Equip4_SP2, { {} , 'BaseStatPools.Stamina' , 22.0 }) -- this might be adding 22 stamina instead of 22% but... deal with it.
	
	self:CreateConstantStatModifier(self.Stat_Modifier_01, { 'Additive', 'BaseStats.IsItemIconic', 1.0 })
	self:CreateConstantStatModifier(self.Stat_Modifier_02, { 'Additive', 'BaseStats.HasSandevistan', 1.0 })
	self:CreateConstantStatModifier(self.Stat_Modifier_03, { 'Additive', 'BaseStats.TimeDilationSandevistanDuration', 300.0 })
	self:CreateConstantStatModifier(self.Stat_Modifier_04, { 'Additive', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(0,Sandevistan_TimeDilation850) })
	self:CreateConstantStatModifier(self.Stat_Modifier_05, { 'Additive', 'BaseStats.TimeDilationSandevistanRechargeDuration', 2.0 })
	self:CreateConstantStatModifier(self.Stat_Modifier_06, { 'Additive', 'BaseStats.TimeDilationSandevistanCooldownBase', 1.0 })
	self:CreateConstantStatModifier(self.Stat_Modifier_07, { 'Additive', 'BaseStats.SandevistanKillRechargeValue', 0.0 })
	self:CreateConstantStatModifier(self.Stat_Modifier_08, { 'Additive', 'BaseStats.TimeDilationSandevistanEnterCost', 0.1 })

	local LockFuryIcon = 'NewPerks.RipAndTearQuickmelee_Buff_inline10'
	local SandevistanIcon = TweakDB:GetFlat('BaseStatusEffect.SandevistanCooldown.uiData')
	local CyberpsychoIcon = TweakDB:GetFlat('BaseStatusEffect.JohnnySicknessAbstract.uiData')
	local OverclockIcon = TweakDB:GetFlat('BaseStatusEffect.ReflexRecorderPlayerBuffBase.uiData')
	local EMPIcon = TweakDB:GetFlat('BaseStatusEffect.BaseEMP.uiData')
	local BleedingIcon = TweakDB:GetFlat('BaseStatusEffect.PlayerCyberwareCooldown.uiData')
	local RunningIcon = nil -- TweakDB:GetFlat('BaseStatusEffect.LoseControlPerkCooldown.uiData')
	
	
	local VFX_SuperHacked = 'BaseStatusEffect.NetwatcherGeneral_inline0' -- Used to clone all the VFX records
	local p_electrocuted = 'BaseStatusEffect.ElectrocutedNoDamage'

	local FuryTechBuff  = {'BaseStatusEffect.Tech_Master_Perk_3_Buff_inline6','BaseStatusEffect.Tech_Master_Perk_3_Buff_inline7'} -- LP.Effectors
	local FuryCritBuffs = {'BaseStatusEffect.Tech_Master_Perk_3_Buff_inline4','BaseStatusEffect.Tech_Master_Perk_3_Buff_inline5'} -- LP.stats
	local FuryRAGE = {'BaseStatusEffect.Tech_Master_Perk_3_Buff_inline14'} -- LP.Effector
	
	-- Disable Edgerunner/Fury because we're changing it to cyberpsycho, crit change/damage buff is added to lift safeties
	TweakDB:SetFlat('BaseStatusEffect.Tech_Master_Perk_3_Buff.packages',{})
	TweakDB:SetFlat('BaseStatusEffect.Tech_Master_Perk_3_Buff.gameplayTags',{'Buff'})
	TweakDB:SetFlat('BaseStatusEffect.Tech_Master_Perk_3_Buff.uiData',nil)
	TweakDB:SetFlat('BaseStatusEffect.Tech_Master_Perk_3_Buff_inline2.value',1) -- fury now lasts 1 sec; because it does nothing now; and it's hidden so...

	local CyberpsychosisCName = self:CNameNew('Cyberpsychosis')
	
	self:CreateGameplayTagsPrereq('BaseStatusEffect.MartinezSandevistan_HasCyberpsychosis',{{'Cyberpsychosis'},false,'GameplayTagsPrereq'})
	self:CreateStatusEffectPrereq('BaseStatusEffect.MartinezSandevistan_PlayerHasCyberpsychosis',{
		 'CheckType.Tag' -- checkType
		,true -- evaluateOnRegister
		,false -- invert
		,'Player' -- objectToCheck
		,'StatusEffectPrereq' --prereqClassName
		,nil --statusEffect
		,'Cyberpsychosis' --tagToCheck
	})
	
	-- VISION GLITCH FOR NPCS IN COMBAT
	self:CreateStatusEffect(self.CyberpsychoNPCStatusEffect,{
		 '' --AIData
		,{} --SFX
		,{self.CyberpsychoNPCStatusEffect_FX1} --VFX
		,'' --additionalParam
		,{} --debugTags
		,nil --- duration // nil // 'BaseStats.InfiniteDuration' // self.CyberpsychoNPCStatusEffect_SMG
		,false --dynamicDuration
		,{'Debuff'} --gameplayTags
		,{} --immunityStats BaseStats.BurningImmunity
		,true --isAffectedByTimeDilationNPC
		,true --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{} --packages 
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.PassiveBuff' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,nil --uiData
	})
	
	self:CreateStatModifierGroup(self.CyberpsychoNPCStatusEffect_SMG, { false, false, {}, false, {self.CyberpsychoNPCStatusEffect_SM1}, -1, nil })
	self:CreateConstantStatModifier(self.CyberpsychoNPCStatusEffect_SM1, { 'Additive', 'BaseStats.MaxDuration', 60 })
	self:CloneRecord(self.CyberpsychoNPCStatusEffect_FX1,VFX_SuperHacked)
	TweakDB:SetFlat(self.CyberpsychoNPCStatusEffect_FX1..'.name', self.martinez_npc_optical_blur)

	local CyberpsychoKiroshiOff_SM_List = {
		 self.CyberpsychoKiroshiOff_SM1
		,self.CyberpsychoKiroshiOff_SM2
		,self.CyberpsychoKiroshiOff_SM3
		,self.CyberpsychoKiroshiOff_SM4
		,self.CyberpsychoKiroshiOff_SM5
		,self.CyberpsychoKiroshiOff_SM6
		,self.CyberpsychoKiroshiOff_SM7
	} -- Turning off Kiroshi's during Fury & Cyberpsycho
	self:CreateLogicPackage(self.CyberpsychoKiroshiOff_LP, { '', {}, {}, {}, '' , false, {}, CyberpsychoKiroshiOff_SM_List })
	self:CreateConstantStatModifier(self.CyberpsychoKiroshiOff_SM1, { 'Multiplier', 'BaseStats.CanUseZoom', 0.0 })
	self:CreateConstantStatModifier(self.CyberpsychoKiroshiOff_SM2, { 'Multiplier', 'BaseStats.CanSeeThroughWalls', 0.0 })
	self:CreateConstantStatModifier(self.CyberpsychoKiroshiOff_SM3, { 'Multiplier', 'BaseStats.HasCybereye', 0.0 })
	self:CreateConstantStatModifier(self.CyberpsychoKiroshiOff_SM4, { 'Multiplier', 'BaseStats.KiroshiMaxZoomLevel', 0.0 })
	self:CreateConstantStatModifier(self.CyberpsychoKiroshiOff_SM5, { 'Multiplier', 'BaseStats.KiroshiPierceScanRange', 0.0 })
	self:CreateConstantStatModifier(self.CyberpsychoKiroshiOff_SM6, { 'Multiplier', 'BaseStats.TechPierceHighlightsEnabled', 0.0 })
	self:CreateConstantStatModifier(self.CyberpsychoKiroshiOff_SM7, { 'Multiplier', 'BaseStats.HasKiroshiOpticsFragment', 0.0 })
	-- New FuryRage Buff
	self:CreateStatusEffect(self.MartinezFury,{
		 '' --AIData
		,{} --SFX
		,{self.MartinezFury_FX1,self.MartinezFury_FX2} --VFX
		,'' --additionalParam
		,{} --debugTags
		,self.MartinezFury_SMG --duration
		,false --dynamicDuration
		,{'Buff','InFury','PreventLowHealthOverlay','Cyberpsychosis'} --gameplayTags
		,{} --immunityStats
		,true --isAffectedByTimeDilationNPC
		,true --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{self.MartinezFury_LP,self.CyberpsychoKiroshiOff_LP} --packages
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,CyberpsychoIcon --uiData
	})
	self:CreateLogicPackage(self.MartinezFury_LP, { '', {}, {}, {}, '' , false, {}, {self.MartinezFury_SM2} }) -- removed FuryRAGE from effectors
	self:CreateStatModifierGroup(self.MartinezFury_SMG, { false, false, {}, false, {self.MartinezFury_SM1}, -1, nil })
	self:CreateConstantStatModifier(self.MartinezFury_SM1, { 'Additive', 'BaseStats.MaxDuration', 12.0 })
	self:CreateConstantStatModifier(self.MartinezFury_SM2, { 'Multiplier', 'BaseStats.HasSandevistan', 0.0 })
	self:CloneRecord(self.MartinezFury_FX1,VFX_SuperHacked)
	self:CloneRecord(self.MartinezFury_FX2,VFX_SuperHacked)
	TweakDB:SetFlat(self.MartinezFury_FX1..'.name', 'perk_edgerunner_player')
	TweakDB:SetFlat(self.MartinezFury_FX2..'.name', 'afterimage_glitch') -- makes shit dark!'

	-- New FuryRage Buff without Darkness
	self:CreateStatusEffect(self.MartinezFury_Level5,{
		 '' --AIData
		,{} --SFX
		,{self.MartinezFury_Level5_FX1} --VFX
		,'' --additionalParam
		,{} --debugTags
		,self.MartinezFury_Level5_SMG --duration
		,false --dynamicDuration
		,{'Buff','InFury','PreventLowHealthOverlay','Cyberpsychosis'} --gameplayTags
		,{} --immunityStats
		,true --isAffectedByTimeDilationNPC
		,true --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{self.MartinezFury_Level5_LP} --packages // Do not put Kiroshi blocker here, it's on Cyberpsycho and they will conflict
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,CyberpsychoIcon --uiData
	})
	self:CreateLogicPackage(self.MartinezFury_Level5_LP, { '', {}, FuryRAGE, {}, '' , false, {}, {self.MartinezFury_Level5_SM2} }) -- Keep FuryRAGE for zIndex fighting
	self:CreateStatModifierGroup(self.MartinezFury_Level5_SMG, { false, false, {}, false, {self.MartinezFury_Level5_SM1}, -1, nil })
	self:CreateConstantStatModifier(self.MartinezFury_Level5_SM1, { 'Additive', 'BaseStats.MaxDuration', 12.0 })
	self:CreateConstantStatModifier(self.MartinezFury_Level5_SM2, { 'Multiplier', 'BaseStats.HasSandevistan', 0.0 })
	self:CloneRecord(self.MartinezFury_Level5_FX1,VFX_SuperHacked)
	TweakDB:SetFlat(self.MartinezFury_Level5_FX1..'.name', '') -- Keep this empty to get the zIndex fighting going on.

	self:CreateStatusEffect(self.SafetiesOffStatusEffect,{
		 '' --AIData
		,{self.SafetiesOffStatusEffect_SFX1} --SFX
		,{self.SafetiesOffStatusEffect_VFX1,self.SafetiesOffStatusEffect_VFX2,self.SafetiesOffStatusEffect_VFX3} -- VFX
		,'' --additionalParam
		,{} --debugTags
		,nil --duration
		,false --dynamicDuration
		,{'Buff','PreventLowHealthOverlay'} --gameplayTags
		,{} --immunityStats
		,true --isAffectedByTimeDilationNPC
		,true --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{self.SafetiesOffStatusEffect_LP} --Package_Cyberpsycho
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,EMPIcon --uiData
	})
	self:CreateLogicPackage(self.SafetiesOffStatusEffect_LP, { '', {}, {}, {}, '' , false, {}, FuryCritBuffs })
	self:CloneRecord(self.SafetiesOffStatusEffect_SFX1,VFX_SuperHacked)
	self:CloneRecord(self.SafetiesOffStatusEffect_VFX1,VFX_SuperHacked)
	self:CloneRecord(self.SafetiesOffStatusEffect_VFX2,VFX_SuperHacked)
	self:CloneRecord(self.SafetiesOffStatusEffect_VFX3,VFX_SuperHacked)
	TweakDB:SetFlat(self.SafetiesOffStatusEffect_SFX1..'.name', 'quickhack_shortcircuit') -- quickhack electrocute sound
	TweakDB:SetFlat(self.SafetiesOffStatusEffect_VFX1..'.name', self.martinez_fx_onscreen_sick_start) -- blackwall fuzzy squares at the start up
	TweakDB:SetFlat(self.SafetiesOffStatusEffect_VFX2..'.name', self.martinez_fx_onscreen_frame) -- red buzzing at the edges to replace electrocute effect
	TweakDB:SetFlat(self.SafetiesOffStatusEffect_VFX3..'.name', 'status_drugged_heavy') -- Ultra Vivid with RGB split around the edges
	
	self:CreateStatusEffect(self.BleedingStatusEffect,{
		 '' --AIData
		,{} --SFX
		,{self.BleedingStatusEffect_VFX1,self.BleedingStatusEffect_VFX2} --VFX
		,'' --additionalParam
		,{} --debugTags
		,nil --duration
		,false --dynamicDuration
		,{'Debuff'} --gameplayTags
		,{} --immunityStats
		,false --isAffectedByTimeDilationNPC
		,false --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{} --packages --
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,BleedingIcon --uiData
	})
	self:CloneRecord(self.BleedingStatusEffect_VFX1,VFX_SuperHacked)
	self:CloneRecord(self.BleedingStatusEffect_VFX2,VFX_SuperHacked)
	TweakDB:SetFlat(self.BleedingStatusEffect_VFX1..'.name', martinez.martinez_fx_onscreen_sick_2023)
	TweakDB:SetFlat(self.BleedingStatusEffect_VFX2..'.name', 'hacking_glitch_low')-- hacking_glitch_low

	self:CreateStatusEffect(self.CyberpsychoStatusEffect,{
		 '' --AIData
		,{} --SFX
		,{self.CyberpsychoStatusEffect_FX1,self.CyberpsychoStatusEffect_FX2,self.CyberpsychoStatusEffect_FX3,self.CyberpsychoStatusEffect_FX4,self.CyberpsychoStatusEffect_FX5}
		,'' --additionalParam
		,{} --debugTags
		,nil --duration
		,false --dynamicDuration
		,{'Debuff','Cyberpsychosis','PreventLowHealthOverlay'} --gameplayTags ,'Cyberpsycho'
		,{'BaseStats.StunImmunity','BaseStats.HasCritImmunity','BaseStats.WoundedImmunity','BaseStats.VulnerableImmunity'} --immunityStats
		,false --isAffectedByTimeDilationNPC
		,false --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{self.CyberpsychoStatusEffect_LP,self.CyberpsychoKiroshiOff_LP}
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,CyberpsychoIcon --uiData
	})
	self:CreateLogicPackage(self.CyberpsychoStatusEffect_LP, { '', {}, {}, {}, '' , false, {}, {self.CyberpsychoStatusEffect_SM} })
	self:CreateConstantStatModifier(self.CyberpsychoStatusEffect_SM, { 'Multiplier', 'BaseStats.HasSandevistan', 0.0 })

	self:CloneRecord(self.CyberpsychoStatusEffect_FX1,VFX_SuperHacked) -- no idea why creating a new record doesn't work
	self:CloneRecord(self.CyberpsychoStatusEffect_FX2,VFX_SuperHacked) -- but cloning an existing one does work
	self:CloneRecord(self.CyberpsychoStatusEffect_FX3,VFX_SuperHacked) -- so that's what we'll do!
	self:CloneRecord(self.CyberpsychoStatusEffect_FX4,VFX_SuperHacked)
	self:CloneRecord(self.CyberpsychoStatusEffect_FX5,VFX_SuperHacked)

	-- blackout;  afterimage_glitch
	-- dark; blue; fisheye; braindance_sound_vision_mode
	-- Netwatch Agent Hack: hacking_glitch_low
	-- spooky blackwall!  q305_cerberus_blackwall_glitch_low
	--                    q305_cerberus_blackwall_glitch_medium
	--                    q305_cerberus_blackwall_glitch_heavy
	-- Magic Mushrooms:  status_drugged_heavy
	-- Relic transition: burnout_glitch

	TweakDB:SetFlat(self.CyberpsychoStatusEffect_FX1..'.name', 'hacking_glitch_low')
	TweakDB:SetFlat(self.CyberpsychoStatusEffect_FX2..'.name', 'braindance_sound_vision_mode')
	TweakDB:SetFlat(self.CyberpsychoStatusEffect_FX3..'.name', 'status_drugged_medium') -- Can't use Heavy here it will conflict with Safeties Off
	TweakDB:SetFlat(self.CyberpsychoStatusEffect_FX4..'.name', 'q305_cerberus_blackwall_glitch_medium')
	TweakDB:SetFlat(self.CyberpsychoStatusEffect_FX5..'.name', self.martinez_fx_onscreen_frame) -- vertical red distortion

	-- CyberpsychoSafetyOffEffect: same VFX as CyberpsychoStatusEffect but Sandy still works, no Kiroshi OFF
	self:CreateStatusEffect(self.CyberpsychoSafetyOffEffect,{
		 '' --AIData
		,{} --SFX
		,{self.CyberpsychoSafetyOffEffect_FX1,self.CyberpsychoSafetyOffEffect_FX2,self.CyberpsychoSafetyOffEffect_FX3,self.CyberpsychoSafetyOffEffect_FX4,self.CyberpsychoSafetyOffEffect_FX5}
		,'' --additionalParam
		,{} --debugTags
		,nil --duration
		,false --dynamicDuration
		,{'Debuff','Cyberpsychosis','PreventLowHealthOverlay'} --gameplayTags
		,{'BaseStats.StunImmunity','BaseStats.HasCritImmunity','BaseStats.WoundedImmunity','BaseStats.VulnerableImmunity'} --immunityStats
		,false --isAffectedByTimeDilationNPC
		,false --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{} --packages (NO HasSandevistan=0, NO KiroshiOff)
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,CyberpsychoIcon --uiData
	})
	self:CloneRecord(self.CyberpsychoSafetyOffEffect_FX1,VFX_SuperHacked)
	self:CloneRecord(self.CyberpsychoSafetyOffEffect_FX2,VFX_SuperHacked)
	self:CloneRecord(self.CyberpsychoSafetyOffEffect_FX3,VFX_SuperHacked)
	self:CloneRecord(self.CyberpsychoSafetyOffEffect_FX4,VFX_SuperHacked)
	self:CloneRecord(self.CyberpsychoSafetyOffEffect_FX5,VFX_SuperHacked)
	TweakDB:SetFlat(self.CyberpsychoSafetyOffEffect_FX1..'.name', 'hacking_glitch_low')
	TweakDB:SetFlat(self.CyberpsychoSafetyOffEffect_FX2..'.name', 'braindance_sound_vision_mode')
	TweakDB:SetFlat(self.CyberpsychoSafetyOffEffect_FX3..'.name', 'status_drugged_medium')
	TweakDB:SetFlat(self.CyberpsychoSafetyOffEffect_FX4..'.name', 'q305_cerberus_blackwall_glitch_medium')
	TweakDB:SetFlat(self.CyberpsychoSafetyOffEffect_FX5..'.name', self.martinez_fx_onscreen_frame) -- vertical red distortion

	-- PsychoWarningEffect_Light: subtle persistent VFX at psycho level 3
	self:CreateStatusEffect(self.PsychoWarningEffect_Light,{
		 '' --AIData
		,{} --SFX
		,{self.PsychoWarningEffect_Light_FX1} --VFX
		,'' --additionalParam
		,{} --debugTags
		,nil --duration
		,false --dynamicDuration
		,{'Debuff','Cyberpsychosis'} --gameplayTags
		,{} --immunityStats
		,false --isAffectedByTimeDilationNPC
		,false --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{} --packages
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,CyberpsychoIcon --uiData
	})
	self:CloneRecord(self.PsychoWarningEffect_Light_FX1,VFX_SuperHacked)
	TweakDB:SetFlat(self.PsychoWarningEffect_Light_FX1..'.name', 'hacking_glitch_low')

	-- PsychoWarningEffect_Medium: medium persistent VFX at psycho level 4
	self:CreateStatusEffect(self.PsychoWarningEffect_Medium,{
		 '' --AIData
		,{} --SFX
		,{self.PsychoWarningEffect_Medium_FX1,self.PsychoWarningEffect_Medium_FX2} --VFX
		,'' --additionalParam
		,{} --debugTags
		,nil --duration
		,false --dynamicDuration
		,{'Debuff','Cyberpsychosis'} --gameplayTags
		,{} --immunityStats
		,false --isAffectedByTimeDilationNPC
		,false --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{} --packages
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,CyberpsychoIcon --uiData
	})
	self:CloneRecord(self.PsychoWarningEffect_Medium_FX1,VFX_SuperHacked)
	self:CloneRecord(self.PsychoWarningEffect_Medium_FX2,VFX_SuperHacked)
	TweakDB:SetFlat(self.PsychoWarningEffect_Medium_FX1..'.name', 'hacking_glitch_low')
	TweakDB:SetFlat(self.PsychoWarningEffect_Medium_FX2..'.name', 'status_drugged_medium')

	-- PsychoLaughEffect: perk_edgerunner_player VFX only (the laugh), 3s, no Sandy block
	self:CreateStatusEffect(self.PsychoLaughEffect,{
		 '' --AIData
		,{} --SFX
		,{self.PsychoLaughEffect_FX1} --VFX
		,'' --additionalParam
		,{} --debugTags
		,self.PsychoLaughEffect_SMG --duration
		,false --dynamicDuration
		,{'Buff','InFury'} --gameplayTags
		,{} --immunityStats
		,true --isAffectedByTimeDilationNPC
		,true --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{} --packages (no Sandy block, no Kiroshi off)
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,nil --uiData (no icon — ambient effect)
	})
	self:CreateStatModifierGroup(self.PsychoLaughEffect_SMG, { false, false, {}, false, {self.PsychoLaughEffect_SM1}, -1, nil })
	self:CreateConstantStatModifier(self.PsychoLaughEffect_SM1, { 'Additive', 'BaseStats.MaxDuration', 3.0 })
	self:CloneRecord(self.PsychoLaughEffect_FX1,VFX_SuperHacked)
	TweakDB:SetFlat(self.PsychoLaughEffect_FX1..'.name', 'perk_edgerunner_player')

	-- NosebleedEffect: brief red VFX pulse on overuse (3s)
	self:CreateStatusEffect(self.NosebleedEffect,{
		 '' --AIData
		,{} --SFX
		,{self.NosebleedEffect_FX1} --VFX
		,'' --additionalParam
		,{} --debugTags
		,self.NosebleedEffect_SMG --duration
		,false --dynamicDuration
		,{'Debuff'} --gameplayTags
		,{} --immunityStats
		,false --isAffectedByTimeDilationNPC
		,false --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{} --packages
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,nil --uiData
	})
	self:CreateStatModifierGroup(self.NosebleedEffect_SMG, { false, false, {}, false, {self.NosebleedEffect_SM1}, -1, nil })
	self:CreateConstantStatModifier(self.NosebleedEffect_SM1, { 'Additive', 'BaseStats.MaxDuration', 3.0 })
	self:CloneRecord(self.NosebleedEffect_FX1,VFX_SuperHacked)
	TweakDB:SetFlat(self.NosebleedEffect_FX1..'.name', 'burnout_glitch')

	-- HeartbeatEffect: persistent SFX for psycho level 3+ tension (apply once, remove when done)
	self:CreateStatusEffect(self.HeartbeatEffect,{
		 '' --AIData
		,{self.HeartbeatEffect_SFX1} --SFX
		,{} --VFX
		,'' --additionalParam
		,{} --debugTags
		,nil --duration (infinite — removed manually)
		,false --dynamicDuration
		,{'Buff'} --gameplayTags
		,{} --immunityStats
		,false --isAffectedByTimeDilationNPC
		,false --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{} --packages
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,nil --uiData
	})
	self:CloneRecord(self.HeartbeatEffect_SFX1,VFX_SuperHacked)
	TweakDB:SetFlat(self.HeartbeatEffect_SFX1..'.name', 'q005_sc_01_heart_beating')

	-- TickingTimeBombEffect: EMP VFX burst on V (4s), Stage 5-6 ability
	self:CreateStatusEffect(self.TickingTimeBombEffect,{
		 '' --AIData
		,{} --SFX
		,{self.TickingTimeBombEffect_FX1} --VFX
		,'' --additionalParam
		,{} --debugTags
		,self.TickingTimeBombEffect_SMG --duration
		,false --dynamicDuration
		,{'Buff'} --gameplayTags
		,{} --immunityStats
		,false --isAffectedByTimeDilationNPC
		,false --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{} --packages
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,nil --uiData
	})
	self:CreateStatModifierGroup(self.TickingTimeBombEffect_SMG, { false, false, {}, false, {self.TickingTimeBombEffect_SM1}, -1, nil })
	self:CreateConstantStatModifier(self.TickingTimeBombEffect_SM1, { 'Additive', 'BaseStats.MaxDuration', 4.0 })
	self:CloneRecord(self.TickingTimeBombEffect_FX1,VFX_SuperHacked)
	TweakDB:SetFlat(self.TickingTimeBombEffect_FX1..'.name', 'q305_cerberus_blackwall_glitch_low')

	-- BlackwallKillEffect: heavy Blackwall VFX burst on V (3s), Stage 6 kill ability
	self:CreateStatusEffect(self.BlackwallKillEffect,{
		 '' --AIData
		,{} --SFX
		,{self.BlackwallKillEffect_FX1,self.BlackwallKillEffect_FX2} --VFX
		,'' --additionalParam
		,{} --debugTags
		,self.BlackwallKillEffect_SMG --duration
		,false --dynamicDuration
		,{'Buff'} --gameplayTags
		,{} --immunityStats
		,false --isAffectedByTimeDilationNPC
		,false --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{} --packages
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,nil --uiData
	})
	self:CreateStatModifierGroup(self.BlackwallKillEffect_SMG, { false, false, {}, false, {self.BlackwallKillEffect_SM1}, -1, nil })
	self:CreateConstantStatModifier(self.BlackwallKillEffect_SM1, { 'Additive', 'BaseStats.MaxDuration', 3.0 })
	self:CloneRecord(self.BlackwallKillEffect_FX1,VFX_SuperHacked)
	self:CloneRecord(self.BlackwallKillEffect_FX2,VFX_SuperHacked)
	TweakDB:SetFlat(self.BlackwallKillEffect_FX1..'.name', 'q305_cerberus_blackwall_glitch_heavy')
	TweakDB:SetFlat(self.BlackwallKillEffect_FX2..'.name', self.martinez_fx_onscreen_sick_start)

	self:CreateStatusEffect(self.OverclockStatusEffect,{
		 '' --AIData
		,{} --SFX
		,{} --VFX
		,'' --additionalParam
		,{} --debugTags
		,nil --duration
		,false --dynamicDuration
		,{'Buff'} --gameplayTags
		,{} --immunityStats
		,true --isAffectedByTimeDilationNPC
		,true --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{self.Overclock_LP} --packages
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,OverclockIcon --uiData
	})

	local overclock_Effectors = {'BaseStatusEffect.Intelligence_Central_Milestone_3_Overclock_Buff_inline4'}
	self:CreateLogicPackage(self.Overclock_LP, { '', {}, overclock_Effectors, {}, 'None', false, {}, {} })
	
	self:CreateStatusEffect(self.TimeDilation900StatusEffect,{
		 '' --AIData
		,{} --SFX
		,{} --VFX
		,'' --additionalParam
		,{} --debugTags
		,nil --duration
		,false --dynamicDuration
		,{'Buff'} --gameplayTags
		,{} --immunityStats
		,true --isAffectedByTimeDilationNPC
		,true --isAffectedByTimeDilationPlayer
		,'RTDB.StatusEffect_inline0' --maxStacks
		,{self.TimeDilation900_LP} --packages
		,nil --playerData
		,false --reapplyPackagesOnMaxStacks
		,false --removeAllStacksWhenDurationEnds
		,nil --removeAllStacksWhenDurationEndsStatModifiers
		,false --removeOnStoryTier
		,false --replicated
		,false --savable
		,'BaseStatusEffectTypes.Misc' --statusEffectType
		,true --stopActiveSfxOnDeactivate
		,RunningIcon --uiData
	})
	
	self:CloneRecord(self.TimeDilation825StatusEffect,self.TimeDilation900StatusEffect)
	self:CloneRecord(self.TimeDilation875StatusEffect,self.TimeDilation900StatusEffect)
	self:CloneRecord(self.TimeDilation925StatusEffect,self.TimeDilation900StatusEffect)
	self:CloneRecord(self.TimeDilation950StatusEffect,self.TimeDilation900StatusEffect)
	self:CloneRecord(self.TimeDilation975StatusEffect,self.TimeDilation900StatusEffect)
	self:CloneRecord(self.TimeDilation990StatusEffect,self.TimeDilation900StatusEffect)
	self:CloneRecord(self.TimeDilation9925StatusEffect,self.TimeDilation900StatusEffect)
	self:CloneRecord(self.TimeDilation9935StatusEffect,self.TimeDilation900StatusEffect)
	self:CloneRecord(self.TimeDilation995StatusEffect,self.TimeDilation900StatusEffect)

	TweakDB:SetFlat(self.TimeDilation825StatusEffect..'.uiData', RunningIcon)
	TweakDB:SetFlat(self.TimeDilation875StatusEffect..'.uiData', RunningIcon)
	TweakDB:SetFlat(self.TimeDilation900StatusEffect..'.uiData', RunningIcon)
	TweakDB:SetFlat(self.TimeDilation925StatusEffect..'.uiData', RunningIcon)
	TweakDB:SetFlat(self.TimeDilation950StatusEffect..'.uiData', RunningIcon)
	TweakDB:SetFlat(self.TimeDilation975StatusEffect..'.uiData', RunningIcon)
	TweakDB:SetFlat(self.TimeDilation990StatusEffect..'.uiData', RunningIcon)
	TweakDB:SetFlat(self.TimeDilation9925StatusEffect..'.uiData', RunningIcon)
	TweakDB:SetFlat(self.TimeDilation9935StatusEffect..'.uiData', RunningIcon)
	TweakDB:SetFlat(self.TimeDilation995StatusEffect..'.uiData', RunningIcon)

	TweakDB:SetFlat(self.TimeDilation825StatusEffect..'.packages', {self.TimeDilation825_LP})
	TweakDB:SetFlat(self.TimeDilation875StatusEffect..'.packages', {self.TimeDilation875_LP})
	TweakDB:SetFlat(self.TimeDilation900StatusEffect..'.packages', {self.TimeDilation900_LP})
	TweakDB:SetFlat(self.TimeDilation925StatusEffect..'.packages', {self.TimeDilation925_LP})
	TweakDB:SetFlat(self.TimeDilation950StatusEffect..'.packages', {self.TimeDilation950_LP})
	TweakDB:SetFlat(self.TimeDilation975StatusEffect..'.packages', {self.TimeDilation975_LP})
	TweakDB:SetFlat(self.TimeDilation990StatusEffect..'.packages', {self.TimeDilation990_LP})
	TweakDB:SetFlat(self.TimeDilation9925StatusEffect..'.packages', {self.TimeDilation9925_LP})
	TweakDB:SetFlat(self.TimeDilation9935StatusEffect..'.packages', {self.TimeDilation9935_LP})
	TweakDB:SetFlat(self.TimeDilation995StatusEffect..'.packages', {self.TimeDilation995_LP})
	
	self:CreateLogicPackage(self.TimeDilation825_LP, { '', {}, {}, {}, '' , false, {}, {self.TimeDilation825_SM} })
	self:CreateConstantStatModifier(self.TimeDilation825_SM, { 'Multiplier', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(Sandevistan_TimeDilation850,Sandevistan_TimeDilation825) })
	self:CreateLogicPackage(self.TimeDilation875_LP, { '', {}, {}, {}, '' , false, {}, {self.TimeDilation875_SM} })
	self:CreateConstantStatModifier(self.TimeDilation875_SM, { 'Multiplier', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(Sandevistan_TimeDilation850,Sandevistan_TimeDilation875) })
	self:CreateLogicPackage(self.TimeDilation900_LP, { '', {}, {}, {}, '' , false, {}, {self.TimeDilation900_SM} })
	self:CreateConstantStatModifier(self.TimeDilation900_SM, { 'Multiplier', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(Sandevistan_TimeDilation850,Sandevistan_TimeDilation900) })
	self:CreateLogicPackage(self.TimeDilation925_LP, { '', {}, {}, {}, '' , false, {}, {self.TimeDilation925_SM} })
	self:CreateConstantStatModifier(self.TimeDilation925_SM, { 'Multiplier', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(Sandevistan_TimeDilation850,Sandevistan_TimeDilation925) })
	self:CreateLogicPackage(self.TimeDilation950_LP, { '', {}, {}, {}, '' , false, {}, {self.TimeDilation950_SM} })
	self:CreateConstantStatModifier(self.TimeDilation950_SM, { 'Multiplier', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(Sandevistan_TimeDilation850,Sandevistan_TimeDilation950) })
	self:CreateLogicPackage(self.TimeDilation975_LP, { '', {}, {}, {}, '' , false, {}, {self.TimeDilation975_SM} })
	self:CreateConstantStatModifier(self.TimeDilation975_SM, { 'Multiplier', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(Sandevistan_TimeDilation850,Sandevistan_TimeDilation975) })
	self:CreateLogicPackage(self.TimeDilation990_LP, { '', {}, {}, {}, '' , false, {}, {self.TimeDilation990_SM} })
	self:CreateConstantStatModifier(self.TimeDilation990_SM, { 'Multiplier', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(Sandevistan_TimeDilation850,Sandevistan_TimeDilation990) })
	self:CreateLogicPackage(self.TimeDilation9925_LP, { '', {}, {}, {}, '' , false, {}, {self.TimeDilation9925_SM} })
	self:CreateConstantStatModifier(self.TimeDilation9925_SM, { 'Multiplier', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(Sandevistan_TimeDilation850,Sandevistan_TimeDilation9925) })
	self:CreateLogicPackage(self.TimeDilation9935_LP, { '', {}, {}, {}, '' , false, {}, {self.TimeDilation9935_SM} })
	self:CreateConstantStatModifier(self.TimeDilation9935_SM, { 'Multiplier', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(Sandevistan_TimeDilation850,Sandevistan_TimeDilation9935) })
	self:CreateLogicPackage(self.TimeDilation995_LP, { '', {}, {}, {}, '' , false, {}, {self.TimeDilation995_SM} })
	self:CreateConstantStatModifier(self.TimeDilation995_SM, { 'Multiplier', 'BaseStats.TimeDilationSandevistanTimeScale', self.TimeDilationCalculation(Sandevistan_TimeDilation850,Sandevistan_TimeDilation995) })

	--[[ End of time dilation ]]--
	local Modifier_09_HeadShotMultiplier = self:GetHeadShotMultiplier()
	self:CreateCombinedStatModifier(self.Stat_Modifier_09, { 'Additive', '*', 'Player', 'BaseStats.Cool', 'BaseStats.AttunementHelper', Modifier_09_HeadShotMultiplier })
	self:TweakViktorsShop()
end

function martinez.EditHeat5Strategy(self)
	local heat5_Record = TweakDB:GetFlat('PreventionData.NCPDDataMatrix.heat5').value
	TweakDB:SetFlat(heat5_Record..'.stateBlinkingStarTime',30)
	TweakDB:SetFlat(heat5_Record..'.heatCrimeScoreResetTime',1800)
	TweakDB:SetFlat(heat5_Record..'.stateBufferTimer',1800)
	TweakDB:SetFlat(heat5_Record..'.stateGreyStarTime',1800)
end

function martinez.CreateNew_FX_Status_Effects(self)
	self.entEffects:CreateCustomEffect('player',self.martinez_fx_onscreen_frame,"ep1\\fx\\quest\\q303\\pyramid_club\\q303_blackwall_fullscreen_strong.effect")
	self.entEffects:CreateCustomEffect('player',self.martinez_fx_onscreen_sick_start,"ep1\\fx\\quest\\q301\\border\\trailer2023\\q301_blackwall_onscreen_extreme_short_trailer2023.effect")
	self.entEffects:CreateCustomEffect('player',self.martinez_fx_onscreen_sick_pulse,"ep1\\fx\\quest\\q301\\border\\q301_blackwall_onscreen_analog_sick_soft_pulse.effect")
	self.entEffects:CreateCustomEffect('player',self.martinez_fx_onscreen_sick_2023,"ep1\\fx\\quest\\q301\\border\\trailer2023\\q301_blackwall_onscreen_analog_sick_trailer2023.effect")
	self.entEffects:CreateCustomEffect('player',self.martinez_fx_MAXTAC,"base\\fx\\quest\\q003\\intro\\q003_intro_screen_scanning.effect")
	self.entEffects:Finalize('player')
	
    local AllPlacementTags = {'Head','Neck','Neck1','Spine2','Spine3','LeftShoulder','RightShoulder','LeftForeArm','RightForeArm','LeftHand','RightHand','RightUpLeg','LeftUpLeg','LeftLeg','RightLeg'}
	
	local wCEI_npc_optical_blur = self.entEffects.new_wCEI()
	wCEI_npc_optical_blur:AddPlacementTag('Head') -- We need one PlacementInfo per PlacementTag assigning a Position and Rotation to that tag
	wCEI_npc_optical_blur:AddPlacementTag('Spine3') --3a
	wCEI_npc_optical_blur:AddPlacementTag('Spine3') --3b
	wCEI_npc_optical_blur:AddPlacementTag('LeftUpLeg')
	wCEI_npc_optical_blur:AddPlacementTag('RightUpLeg')
	wCEI_npc_optical_blur:AddRelativePositions(-0.02,0.0,0.0) -- shift the head down a bit
	wCEI_npc_optical_blur:AddRelativePositions(-0.05,-0.1,-0.2) -- shift the spine3 down a bit more and forward a bit, left a bit
	wCEI_npc_optical_blur:AddRelativePositions(-0.05,-0.1,0.2) -- shift the spine3 down a bit more and forward a bit, right a bit
	wCEI_npc_optical_blur:AddRelativePositions(0.3,0.0,-0.1) -- shift the LeftUpLeg down and out
	wCEI_npc_optical_blur:AddRelativePositions(-0.3,0.0,0.1) -- shift the RightUpLeg down and out
	wCEI_npc_optical_blur:AddRelativeRotations(0,0,0,0) -- ONLY PUT IN ONE IT WILL BE REPLACED WITH NPC FACING
	wCEI_npc_optical_blur:AddPlacementInfo(0,0,0,3) -- Head,  use 1st Position, first rotation, flags? ZERO INDEXED
	wCEI_npc_optical_blur:AddPlacementInfo(1,1,0,3) -- Spine3a , use 2nd Position, first rotation, flags? ZERO INDEXED
	wCEI_npc_optical_blur:AddPlacementInfo(2,2,0,3) -- Spine3b , use 3rd Position, first rotation, flags? ZERO INDEXED
	wCEI_npc_optical_blur:AddPlacementInfo(3,3,0,3) -- LeftUpLeg, use 4th Position, first rotation, flags? ZERO INDEXED
	wCEI_npc_optical_blur:AddPlacementInfo(4,4,0,3) -- RightUpLeg, use 5th Position, first rotation, flags? ZERO INDEXED
	-- Need to add every particle effect with the correct RUT from the .effect file:close
	-- and add them to the Tags where you want the effect to show up, one per RUT
	-- Add FX To Placement Tags : Head+Spine3+Spine3+LeftUpLeg+RightUpLeg = 1+2+4+8+16 = 31 (ONE INDEXED)
	wCEI_npc_optical_blur:AddEffectEventInfo(CreateCRUID(2849061056490119168),31,1) -- PlacementSlot MASK: 1+2+4+8+16+32...
	wCEI_npc_optical_blur:Finished()

	self.entEffects:CreateCustomEffect('npc',self.martinez_npc_optical_blur,"davidsandevistanplus\\martinez_npc_blur.effect",wCEI_npc_optical_blur)
	
	self.entEffects:Finalize('npc')
end

function martinez.TimeDilationCalculation(Origin,Desired)
	--[[
	Martinez Sandevistan Time Dilation Calculator by Beckylou
	---------------------------------------------------------
	Origin: 0-100 visual display of sandevistan
	Desired: 0-100 the desired time dilation of the buff
	Usage1: TimeDilationCalculation(0,85) will result in 0.15 which you can slot into the Sandevistan creation
	Usage2: TimeDilationCalculation(85,99.5) will result in 0.0333 which when applied to 0.15(85%) will result in 0.005(99.5%)
			This is used to apply a buff to V which modifies the sandevistan time dilation
	]]--
	local OriginBackwards = 100-Origin
	local DesiredBackwards = 100-Desired
	if OriginBackwards == 0 then OriginBackwards = 0.001 end
	if DesiredBackwards == 0 then DesiredBackwards = 0.001 end
	return DesiredBackwards / OriginBackwards
end


function martinez.TweakViktorsShop(self)
	local VendorItemRecordName = self.VendorRecord..'_MartinezSandevistan'
	self:CreateRecord(VendorItemRecordName, "gamedataVendorItem_Record")
	TweakDB:SetFlatNoUpdate(VendorItemRecordName..".generationPrereqs", { self.Vendor_MultiPrereqs })
	TweakDB:SetFlatNoUpdate(VendorItemRecordName..".item", self.RecordName)
	TweakDB:SetFlatNoUpdate(VendorItemRecordName..".quantity", {'Vendors.Always_Present'})
	TweakDB:Update(VendorItemRecordName)
	
	local ViktorsStock = TweakDB:GetFlat(self.VendorRecord..".itemStock")
	if not self:SearchInventory(ViktorsStock,VendorItemRecordName) then
		table.insert(ViktorsStock, VendorItemRecordName)
		TweakDB:SetFlat(self.VendorRecord..".itemStock", ViktorsStock)
	end
	
	self:CreateMultiPrereq(self.Vendor_MultiPrereqs, { 'AND', { self.Vendor_LootLevelCheck } , 'gameMultiPrereq' })
	self:CreateStatPrereq(self.Vendor_LootLevelCheck, { 'GreaterOrEqual', false, false, 'Owner', 'StatPrereq', {}, 'Level', 999 })
end

function martinez.CheckRequiredLevel(self)
	local recordName = self.Vendor_LootLevelCheck
	return TweakDB:GetFlat(recordName..'.valueToCheck')
end

function martinez.CalculateRequiredLevel(self,hasFalcoReward,smsSent)
	local AllowedToSeeMartinezSandevistan = hasFalcoReward and smsSent
	return AllowedToSeeMartinezSandevistan and 40 or 999
end

function martinez.UpdateLootLevelCheck(self,hasFalcoReward,smsSent)
	-- if V has recieved Falco's reward this Cyberware is available from level 40; otherwise it's not available!
	local RequiredLevel = self:CalculateRequiredLevel(hasFalcoReward,smsSent)
	local recordName = self.Vendor_LootLevelCheck
	TweakDB:SetFlat(recordName..'.valueToCheck', RequiredLevel)
end

function martinez.DebugViksStock(self)
	local VendorItemRecordName = self.VendorRecord..'_MartinezSandevistan'
	local ViktorsStock = TweakDB:GetFlat(self.VendorRecord..".itemStock")
	local output = false
	if self:SearchInventory(ViktorsStock,VendorItemRecordName) then
		output = true
	end
	return output
end

function martinez.SearchInventory(self, RecordList, RecordName)
	local output = false
    for k,v in ipairs(RecordList) do
        if v.value == RecordName then
            output = true
			break
        end
    end
	return output
end

function martinez.GetHeadShotMultiplier(self)
	local output = 0.2
	if martinez.HeadShotMultiplier == 'Attunements.CoolArmsDamageTextOnly' then
		output = 0.5
	end
	return output
end

function martinez.print(self,message)
	if self.debug then
		print(message)
	end
end

function martinez.CNameNew(self,theString)
	local output = CName.new(theString)
	if output.value ~= theString then
		CName.add(theString)
		output = CName.new(theString)
	end
	return output
end

function martinez.TweakExists(self,recordName)
    local found = false
	if TweakDB:GetRecord(recordName) ~= nil then
		found = true
	end
    return found
end

function martinez.CreateRecord(self,recordName,recordType)
	if not self:TweakExists(recordName) then
		self:print('CreateRecord('..recordName..'/'..recordType..')')
		TweakDB:CreateRecord(recordName,recordType)
		self:print('Created')
	else
		self:print('ExistsRecord('..recordName..'/'..recordType..')')
	end
end
function martinez.CloneRecord(self,recordName,clonedRecordName)
	if not self:TweakExists(recordName) then
		self:print('CloneRecord('..clonedRecordName..'=>'..recordName..')')
		TweakDB:CloneRecord(recordName,clonedRecordName)
		self:print('Cloned')
	else
		self:print('ExistsRecord('..recordName..')')
	end
end

function martinez.DeleteRecord(self,recordName)
	if self:TweakExists(recordName) then
		TweakDB:DeleteRecord(recordName)
	end
end

function martinez.CreateStatusEffect(self,recordName, data)
	self:CreateRecord(recordName, 'gamedataStatusEffect_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.AIData'                                       , data[ 1])
	TweakDB:SetFlatNoUpdate(recordName..'.SFX'                                          , data[ 2])
	TweakDB:SetFlatNoUpdate(recordName..'.VFX'                                          , data[ 3])
	TweakDB:SetFlatNoUpdate(recordName..'.additionalParam'                              , data[ 4])
	TweakDB:SetFlatNoUpdate(recordName..'.debugTags'                                    , data[ 5])
	TweakDB:SetFlatNoUpdate(recordName..'.duration'                                     , data[ 6])
	TweakDB:SetFlatNoUpdate(recordName..'.dynamicDuration'                              , data[ 7])
	TweakDB:SetFlatNoUpdate(recordName..'.gameplayTags'                                 , data[ 8])
	TweakDB:SetFlatNoUpdate(recordName..'.immunityStats'                                , data[ 9])
	TweakDB:SetFlatNoUpdate(recordName..'.isAffectedByTimeDilationNPC'                  , data[10])
	TweakDB:SetFlatNoUpdate(recordName..'.isAffectedByTimeDilationPlayer'               , data[11])
	TweakDB:SetFlatNoUpdate(recordName..'.maxStacks'                                    , data[12])
	TweakDB:SetFlatNoUpdate(recordName..'.packages'                                     , data[13])
	TweakDB:SetFlatNoUpdate(recordName..'.playerData'                                   , data[14])
	TweakDB:SetFlatNoUpdate(recordName..'.reapplyPackagesOnMaxStacks'                   , data[15])
	TweakDB:SetFlatNoUpdate(recordName..'.removeAllStacksWhenDurationEnds'              , data[16])
	TweakDB:SetFlatNoUpdate(recordName..'.removeAllStacksWhenDurationEndsStatModifiers' , data[17])
	TweakDB:SetFlatNoUpdate(recordName..'.removeOnStoryTier'                            , data[18])
	TweakDB:SetFlatNoUpdate(recordName..'.replicated'                                   , data[19])
	TweakDB:SetFlatNoUpdate(recordName..'.savable'                                      , data[20])
	TweakDB:SetFlatNoUpdate(recordName..'.statusEffectType'                             , data[21])
	TweakDB:SetFlatNoUpdate(recordName..'.stopActiveSfxOnDeactivate'                    , data[22])
	TweakDB:SetFlatNoUpdate(recordName..'.uiData'                                       , data[23])
	TweakDB:Update(recordName)
end

function martinez.CreateStatusEffectFX(self,recordName, data)
	self:CreateRecord(recordName, 'gamedataStatusEffectFX_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.name'          , CName(data[1]))
	TweakDB:SetFlatNoUpdate(recordName..'.shouldReapply' , data[2])
end

function martinez.CreateLogicPackage(self,recordName, data)
	self:CreateRecord(recordName, 'gamedataGameplayLogicPackage_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.UIData', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.animationWrapperOverrides', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.effectors', data[3])
	TweakDB:SetFlatNoUpdate(recordName..'.items', data[4])
	TweakDB:SetFlatNoUpdate(recordName..'.prereq', data[5])
	TweakDB:SetFlatNoUpdate(recordName..'.stackable', data[6])
	TweakDB:SetFlatNoUpdate(recordName..'.statPools', data[7])
	TweakDB:SetFlatNoUpdate(recordName..'.stats', data[8])
	TweakDB:Update(recordName)
end

function martinez.CreateLogicPackageUIData(self,recordName, data)
    self:CreateRecord(recordName, 'gamedataGameplayLogicPackageUIData_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.floatValues', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.iconPath', CName(data[2]))
	TweakDB:SetFlatNoUpdate(recordName..'.intValues', data[3])
	TweakDB:SetFlatNoUpdate(recordName..'.localizedDescription', data[4])
	TweakDB:SetFlatNoUpdate(recordName..'.localizedName', data[5])
	TweakDB:SetFlatNoUpdate(recordName..'.nameValues', data[6])
	TweakDB:SetFlatNoUpdate(recordName..'.stats', data[7])
	TweakDB:Update(recordName)
end

function martinez.CreateUIIcon(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataUIIcon_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.atlasResourcePath', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.atlasPartName', data[2])
	TweakDB:Update(recordName)
end

function martinez.CreateApplyStatGroupEffector(self,recordName, data)
	self:CreateRecord(recordName, 'gamedataApplyStatGroupEffector_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.applicationTarget', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.effectorClassName', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.prereqRecord', data[3])
	TweakDB:SetFlatNoUpdate(recordName..'.removeAfterActionCall', data[4])
	TweakDB:SetFlatNoUpdate(recordName..'.removeAfterPrereqCheck', data[5])
	TweakDB:SetFlatNoUpdate(recordName..'.removeWithEffector', data[6])
	TweakDB:SetFlatNoUpdate(recordName..'.statGroup', data[7])
	TweakDB:SetFlatNoUpdate(recordName..'.statModifierGroups', data[8])
	TweakDB:Update(recordName)
end

function martinez.CreateStatusEffectPrereq(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataStatusEffectPrereq_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.checkType', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.evaluateOnRegister', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.invert', data[3])
	TweakDB:SetFlatNoUpdate(recordName..'.objectToCheck', data[4])
	TweakDB:SetFlatNoUpdate(recordName..'.prereqClassName', data[5])
	TweakDB:SetFlatNoUpdate(recordName..'.statusEffect', data[6])
	TweakDB:SetFlatNoUpdate(recordName..'.tagToCheck', data[7])
	TweakDB:Update(recordName)
end

function martinez.CreateMultiPrereq(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataMultiPrereq_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.aggregationType', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.nestedPrereqs', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.prereqClassName', data[3])
	TweakDB:Update(recordName)
end

function martinez.CreateTimeDilationPSMPrereq(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataIPrereq_Record')
	TweakDB:SetFlat(recordName..'.prereqClassName', 'TimeDilationPSMPrereq')
	TweakDB:SetFlat(recordName..'.isInState', data[1])
	TweakDB:SetFlat(recordName..'.previousState', data[2])
	TweakDB:SetFlat(recordName..'.stateName', data[3])
end

function martinez.CreateFactValuePrereq(self,recordName,data)
	--[[Creating a new one causes problems; so we'll clone an existing one]]--
	--self:CreateRecord(recordName, 'gamedataIPrereq_Record')
	self:CloneRecord(recordName,'LootPrereqs.EP1Standalone_Started_Prereq')
	TweakDB:SetFlat(recordName..'.prereqClassName', 'FactValuePrereq')
	TweakDB:SetFlat(recordName..'.comparisonType', data[1]) -- Less / LessOrEqual / Equal / GreaterOrEqual / Greater
	TweakDB:SetFlat(recordName..'.fact', data[2])
	TweakDB:SetFlat(recordName..'.repeated', data[3])
	TweakDB:SetFlat(recordName..'.value', data[4]+0.0,'Float')
	TweakDB:Update(recordName)
end

function martinez.CreateStatPrereq(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataStatPrereq_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.comparisonType', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.notifyOnAnyChange', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.notifyOnlyOnStateFulfilled', data[3])
	TweakDB:SetFlatNoUpdate(recordName..'.objectToCheck', data[4])
	TweakDB:SetFlatNoUpdate(recordName..'.prereqClassName', data[5])
	TweakDB:SetFlatNoUpdate(recordName..'.statModifiers', data[6])
	TweakDB:SetFlatNoUpdate(recordName..'.statType', data[7])
	TweakDB:SetFlatNoUpdate(recordName..'.valueToCheck', data[8])
	TweakDB:Update(recordName)
end

function martinez.CreateStatModifierGroup(self,recordName, data)
	self:CreateRecord(recordName, 'gamedataStatModifierGroup_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.drawBasedOnStatType', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.optimiseCombinedModifiers', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.relatedModifierGroups', data[3])
	TweakDB:SetFlatNoUpdate(recordName..'.saveBasedOnStatType', data[4])
	TweakDB:SetFlatNoUpdate(recordName..'.statModifiers', data[5])
	TweakDB:SetFlatNoUpdate(recordName..'.statModsLimit', data[6])
	TweakDB:SetFlatNoUpdate(recordName..'.statModsLimitModifier', data[7])
	TweakDB:Update(recordName)
end

function martinez.CreateConstantStatModifier(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataConstantStatModifier_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.modifierType', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.statType', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.value', data[3])
	TweakDB:Update(recordName)
end

function martinez.CreateApplyEffectorEffector(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataApplyEffectorEffector_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.applicationTarget', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.effectorClassName', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.effectorToApply', data[3])
	TweakDB:SetFlatNoUpdate(recordName..'.prereqRecord', data[4])
	TweakDB:SetFlatNoUpdate(recordName..'.removeAfterActionCall', data[5])
	TweakDB:SetFlatNoUpdate(recordName..'.removeAfterPrereqCheck', data[6])
	TweakDB:SetFlatNoUpdate(recordName..'.statModifierGroups', data[7])
	TweakDB:Update(recordName)
end

function martinez.CreateModifyStatPoolValueEffector(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataModifyStatPoolValueEffector_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.effectorClassName', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.prereqRecord', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.removeAfterActionCall', data[3])
	TweakDB:SetFlatNoUpdate(recordName..'.removeAfterPrereqCheck', data[4])
	TweakDB:SetFlatNoUpdate(recordName..'.setValue', data[5])
	TweakDB:SetFlatNoUpdate(recordName..'.statModifierGroups', data[6])
	TweakDB:SetFlatNoUpdate(recordName..'.statPoolUpdates', data[7])
	TweakDB:SetFlatNoUpdate(recordName..'.usePercent', data[8])
	TweakDB:Update(recordName)
end

function martinez.CreateStatPoolUpdate(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataStatPoolUpdate_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.statModifiers', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.statPoolType', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.statPoolValue', data[3])
	TweakDB:Update(recordName)
end

function martinez.CreateCombinedStatModifier(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataCombinedStatModifier_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.modifierType', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.opSymbol', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.refObject', data[3])
	TweakDB:SetFlatNoUpdate(recordName..'.refStat', data[4])
	TweakDB:SetFlatNoUpdate(recordName..'.statType', data[5])
	TweakDB:SetFlatNoUpdate(recordName..'.value', data[6])
	TweakDB:Update(recordName)
end

function martinez.CreatePlayVFXEffector(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataEffector_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.effectorClassName', 'PlayVFXEffector')
	TweakDB:SetFlatNoUpdate(recordName..'.prereqRecord', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.removeAfterActionCall', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.removeAfterPrereqCheck', data[3])
	TweakDB:SetFlatNoUpdate(recordName..'.statModifierGroups', data[4])
	TweakDB:SetFlatNoUpdate(recordName..'.startOnUninitialize', data[5])
	TweakDB:SetFlatNoUpdate(recordName..'.vfxName', data[6])
	TweakDB:Update(recordName)
end



function martinez.CreateGameplayTagsPrereq(self,recordName,data)
	self:CreateRecord(recordName, 'gamedataGameplayTagsPrereq_Record')
	TweakDB:SetFlatNoUpdate(recordName..'.allowedTags', data[1])
	TweakDB:SetFlatNoUpdate(recordName..'.invert', data[2])
	TweakDB:SetFlatNoUpdate(recordName..'.prereqClassName', data[3])
	TweakDB:Update(recordName)
end


return martinez
