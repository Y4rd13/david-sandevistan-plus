local ncpd = {}

function ncpd.attach(dsp)
	print('[DSP] ncpd.lua attached')

	dsp.GetHeatLevel = (function(self)
		local SSC = Game.GetScriptableSystemsContainer()
		if not IsDefined(SSC) then return 0 end
		local SSCPS = SSC:Get("PreventionSystem")
		if not IsDefined(SSCPS) then return 0 end
		return SSCPS:GetHeatStageAsInt()
	 end)

	dsp.SetHeatLevel = (function(self,HeatLevel,Reason)
		local SSC = Game.GetScriptableSystemsContainer()
		if not IsDefined(SSC) then return end
		local SSCPS = SSC:Get("PreventionSystem")
		if not IsDefined(SSCPS) then return end
		SSCPS:ChangeHeatStage(HeatLevel, Reason)
	 end)

	dsp.NCPDIsWatching = (function(self,SpawnReinforcement)
		local SSC = Game.GetScriptableSystemsContainer()
		if not IsDefined(SSC) then return end
		local SSCPS = SSC:Get("PreventionSystem")
		if not IsDefined(SSCPS) then return end
		local V = Game.GetPlayer()

		SSCPS.CreateNewDamageRequest(V,gamedataAttackType.Ranged,32000,true)
		SSCPS.CrimeWitnessRequestToPreventionSystem(V:GetWorldPosition())
	 end)

	dsp.HeatLevelChanged = (function(self,currentHeatLevel,previousHeatLevel,ChangeReason)
		if self.CyberPsychoWarnings == 0 then
			if self.dev_mode then
				print('Regular NCPD: PreventionSystem/OnHeatChanged(PreviousStage:'..tostring(previousHeatLevel.value)..'=>'..tostring(currentHeatLevel.value)..' Reason:'..tostring(ChangeReason)..')')
			end
			return
		end
		if (ChangeReason == 'KillPrevention' or ChangeReason == 'KillCivilian' or ChangeReason == 'DamagePrevention' or ChangeReason == 'DamageCivilian') then
			if self.dev_mode then print('Cyberpsycho: PreventionSystem/OnHeatChanged(PreviousStage:'..tostring(previousHeatLevel.value)..'=>'..tostring(currentHeatLevel.value)..' Reason:'..tostring(ChangeReason)..')') end
			self:CALLMAXTAC()
		elseif self.dev_mode then
			print('Cyberpsycho: PreventionSystem/OnHeatChanged(PreviousStage:'..tostring(previousHeatLevel.value)..'=>'..tostring(currentHeatLevel.value)..' Reason:'..tostring(ChangeReason)..')')
		end
	 end)

	dsp.CALLMAXTAC = (function(self)
		local MaxTacText = self.Localization.CallMaxTac
		if self:GetHeatLevel() < 5 then
			self:SetHeatLevel(EPreventionHeatStage.Heat_5,"CYBERPSYCHO")
			-- POLICE SCAN MESSAGE --
			self.bbs:PlayShortEffect(self.martinez.martinez_fx_MAXTAC)
			self.bbs:SendMessage(MaxTacText,4.0)
		end
	 end)

	dsp.BRIBE_NCPD = (function(self)
		if not self:CanBribeNCPD() then return end

		local V = Game.GetPlayer()
		if not IsDefined(V) then return end
		local TS = Game.GetTransactionSystem()
		if not IsDefined(TS) then return end
		local HeatLevel = self:GetHeatLevel()
		local TransferSucess = false
		local Bribe =  self.bbs:GetThatValue(self:GetHeatLevel())
		TransferSucess = TS:RemoveMoney(V,Bribe, "money")
		if TransferSucess then
			if HeatLevel == 5 then
				self:SetHeatLevel(EPreventionHeatStage.Heat_3,"NCPD BRIBE")
			else
				self:SetHeatLevel(EPreventionHeatStage.Heat_1,"NCPD BRIBE")
			end
			self.bbs:MoneyTransfer("NCPD BRIBE","BRIBE ACCEPTED - WANTED LEVEL REDUCED")
		else
			self.bbs:MoneyTransfer("NCPD BRIBE","NOT ENOUGH EDDIES CHOOM!")
		end
	 end)

	dsp.GetCredits = (function(self)
		local V = Game.GetPlayer()
		if not IsDefined(V) then return end
		local TS = Game.GetTransactionSystem()
		if not IsDefined(TS) then return end
		return TS:GetItemQuantity(V, MarketSystem.Money())
	 end)

	dsp.CanBribeNCPD = (function(self)
		local NetRunnerLevel = self.sps:NetRunnerLevel()
		local V = Game.GetPlayer()
		local HeatLevel = self:GetHeatLevel()
		local Credits = self:GetCredits()
		local output = (NetRunnerLevel.Rules.CanBribeNCPD) and (not V.inCombat) and (HeatLevel > 1) and (Credits>self.bbs.ThatValue)
		return output
	 end)
end

return ncpd
