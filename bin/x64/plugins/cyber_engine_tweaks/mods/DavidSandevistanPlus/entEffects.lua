-- Custom entEffects --
-- Custom entEffects for DavidSandevistanPlus --

local CNameNew = function(self,theString)
	-- find or create a CName
	local output = CName.new(theString)
	if output.value ~= theString then
		CName.add(theString)
		output = CName.new(theString)
	end
	return output
end

local entEffects = {
	 Listeners = nil
	,CNameNew = CNameNew
	,Player_fx_custom_name = nil
	,NPC_fx_custom_name = nil
	,CustomEffects = {}
	,Spawners = {}
}

-- Add .EffectPath to array to save later
-- EffectFor: player or npc, all lower case
entEffects.CreateCustomEffect = function(self,EffectFor,EffectName,EffectPath,wCEI_EffectInfo)
	if EffectFor ~= 'player' and EffectFor ~= 'npc' then return end
	local EffectCName = self:CNameNew(EffectName) -- make a new CName or the search wont work!
	local CustomEffect = entEffectDesc.new()
	CustomEffect.effectName = EffectCName
	CustomEffect.effect = EffectPath
	if wCEI_EffectInfo ~= nil and wCEI_EffectInfo._type == 'wCEI' then
		CustomEffect.compiledEffectInfo = wCEI_EffectInfo.EffectInfo
	end
	
	self.CustomEffects[EffectFor][EffectName] = CustomEffect
	self:dprint('entEffects.CreateCustomEffect()  Queued: '..EffectName)
end
-- Once all the effects are added for player and/or npc; call this function for each.
entEffects.Finalize = function(self,EffectsFor)
	if EffectsFor ~= 'player' and EffectsFor ~= 'npc' then return end
	local ThisSpawner = self.Spawners[EffectsFor]
	local effectDescs = ThisSpawner.effectDescs
	local AddedEffects = false
	for EffectName,Effect in pairs(self.CustomEffects[EffectsFor]) do
		local isFound = false
		for i,v in ipairs(effectDescs) do
			if v.effectName.value == EffectName then
				isFound = true
				break
			end
		end
		if not isFound then
			table.insert(effectDescs,Effect)
			AddedEffects = true
			self:dprint('AddCustomEffectsToFX_Custom: '..EffectName..' ADDED')
		else
			self:dprint('AddCustomEffectsToFX_Custom: '..EffectName..' EXISTS')
		end
	end
	if AddedEffects then
		ThisSpawner.effectDescs = effectDescs
		self:dprint('AddCustomEffectsToFX_Custom: SAVED')
	end
end

-- Custom worldCompiledEffectInfo --
-- Custom worldCompiledEffectInfo for DavidSandevistanPlus --
entEffects.new_wCEI = function()
	-- actually return a new instance every time!
	-- Remember to call wCEI:Finished() !
	-- The good news is: if you mess this up the game will flatline.
	local newWCEI = {
		 _type = 'wCEI'
		,CNameNew = CNameNew
		,EffectInfo = nil
		,RUT_List = {}
		,PlacementTags = {}
		,RelativePositions = {}
		,RelativeRotations = {}
		,PlacementInfos = {}
	}
	newWCEI.AddPlacementTag = function(self,PlacementTag)
		local PlacementTagCName = self:CNameNew(PlacementTag)
		table.insert(self.PlacementTags,PlacementTagCName)
	end
	newWCEI.AddRelativePositions = function(self,up,back,right) -- positive numbers are...
		table.insert(self.RelativePositions,Vector3.new(up,back,right))
	end
	newWCEI.AddRelativeRotations = function(self,one,two,three,four)
		table.insert(self.RelativeRotations,Quaternion.new(one,two,three,four))
	end
	-- All Index parameters are ZERO based!
	newWCEI.AddPlacementInfo = function(self,TagIndex,PositionIndex,RotationIndex,flags)
		local NewEffectPlacementInfo = worldCompiledEffectPlacementInfo.new()
		NewEffectPlacementInfo.placementTagIndex = TagIndex
		NewEffectPlacementInfo.relativePositionIndex = PositionIndex
		NewEffectPlacementInfo.relativeRotationIndex = RotationIndex
		NewEffectPlacementInfo.flags = flags -- dunno? USE THREE (or 4 or 9?)
		table.insert(self.PlacementInfos,NewEffectPlacementInfo)
	end
	newWCEI.AddEffectEventInfo = function(self,eventRUID,placementIndexMask,flags)
		local EffectEventInfo = worldCompiledEffectEventInfo.new()
		EffectEventInfo.eventRUID = eventRUID
		EffectEventInfo.placementIndexMask = placementIndexMask
		EffectEventInfo.componentIndexMask = 0
		EffectEventInfo.flags = flags -- Probably Use One; wrong flags will flatline the game
		table.insert(self.RUT_List,EffectEventInfo)
	end
	newWCEI.Finished = function(self)
		local EffectInfo = worldCompiledEffectInfo.new()
		EffectInfo.componentNames = {}
		local arCName = {}
		EffectInfo.placementTags = self.PlacementTags --arCName
		EffectInfo.relativePositions = self.RelativePositions
		EffectInfo.relativeRotations = self.RelativeRotations
		EffectInfo.placementInfos = self.PlacementInfos
		EffectInfo.eventsSortedByRUID = self.RUT_List
		self.EffectInfo = EffectInfo
	end
	return newWCEI
end

--[[
Attachement of entEffects; do not worry your socks; it's Automatic.
PlayerPuppet/OnGameAttached
NPCPuppet/OnGameAttached
]]--
entEffects.AddVFXToPuppet = function(self,CallbackFor,puppet)
	local fx_exists = false
	local fx_status_effects = puppet:FindComponentByName("fx_status_effects")
	if IsDefined(fx_status_effects) then
		local fx_effectDescs = fx_status_effects.effectDescs
		for i,v in ipairs(self.Spawners[CallbackFor].effectDescs) do
			if CallbackFor == 'npc' then
				local EffectInfo = v.compiledEffectInfo
				if EffectInfo ~= nil then
					npcFacings = EffectInfo.relativeRotations
					npcFacings[1] = puppet:GetWorldOrientation()
					EffectInfo.relativeRotations = npcFacings
				end
			end
			table.insert(fx_effectDescs,v)
			fx_exists = true
		end
		if fx_exists then
			fx_status_effects.effectDescs = fx_effectDescs
		end
	end
end

entEffects.CreateGameListenerCallbacks = function(self) -- available class functions
	local fn_Puppet_OnGameAttached = function(CallbackFor) -- custom-parameters
		return function(puppet) -- controller-event-parameters
			self:AddVFXToPuppet(CallbackFor,puppet) -- pass custom and controller parameters
		end
	end
	
	self.Listeners:AddCallback('PlayerPuppet','OnGameAttached',fn_Puppet_OnGameAttached('player'),false)
	self.Listeners:AddCallback('NPCPuppet','OnGameAttached',fn_Puppet_OnGameAttached('npc'),false)
end

entEffects.Create_fx_Custom = function(self,SpawnerName,fx_custom_name)
	local fx_custom_CName = self:CNameNew(fx_custom_name)
	self.Spawners[SpawnerName] = entEffectSpawnerComponent.new()
	self.Spawners[SpawnerName].name = fx_custom_CName
	-- needs .id to add to puppet, but since this mod doesn't do that...
	self.Spawners[SpawnerName].renderSceneLayerMask = 1 -- default:cyberspace
	self.Spawners[SpawnerName].isReplicable = false
	self.Spawners[SpawnerName].effectDescs = {}
end

entEffects.Createfx_Customs = function(self,player_fx_custom_name,npc_fx_custom_name)
	self:Create_fx_Custom('player',player_fx_custom_name)
	self.Player_fx_custom_name = player_fx_custom_name
	self:Create_fx_Custom('npc',npc_fx_custom_name)
	self.NPC_fx_custom_name = npc_fx_custom_name
end

entEffects.Init = function(self,isdebug,debug_tag,player_fx_custom_name,npc_fx_custom_name)
	self.debug = isdebug
	self.debug_tag = debug_tag

	local gameListeners , gameListenerError = require('./gameListeners.lua')
	if gameListenerError ~= nil then print('entEffects.lua cannot load gameListeners.lua: '..tostring(gameListenerError)) end
	
	self.Listeners = gameListeners
	self.Listeners:Init(isdebug,debug_tag)
	
	self.Spawners['player'] = {}
	self.Spawners['npc'] = {}
	self.CustomEffects['player'] = {}
	self.CustomEffects['npc'] = {}
	
	self:Createfx_Customs(player_fx_custom_name,npc_fx_custom_name)
	self:CreateGameListenerCallbacks()
end

entEffects.dprint = (function(self,message)
	if not self.debug then return end
	print(self.debug_tag..':entEffects:'..message)
end)

return entEffects
