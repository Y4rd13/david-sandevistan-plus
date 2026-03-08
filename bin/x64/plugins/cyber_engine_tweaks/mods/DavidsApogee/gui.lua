local gui = { }

gui.showUIWindow = false
gui.Apogee = nil -- pointer to davidsapogee model
gui.DebugViksStock = "DebugViksStock Not Found"

gui.Init = (function(self,Apogee)
	self.Apogee = Apogee
	self.DebugViksStock = self.Apogee.Localization.Debug_Section2_CheckNotChecked
end)

gui.Draw = (function(self)
    if self.showUIWindow then
        self:drawUIWindow()
    end
end)

gui.ShowWindow = (function(self,show)
    self.showUIWindow = show and true or false
end)

gui.ResetSMS = (function(self,hasFalcosReward)
	if self.Apogee ~= nil then
		self.Apogee:UnsendViksMessage(hasFalcosReward)
	end
end)

gui.drawUIWindow = (function(self)
	local WindowWidth, WindowHeight = ImGui.CalcTextSize('This is some long text that I hope you\'ll never see, but fear not') -- it just sets the default size of the window!

    ImGui.SetNextWindowPos(WindowWidth/2, WindowWidth*2, ImGuiCond.FirstUseEver)
	ImGui.PushStyleVar(ImGuiStyleVar.WindowMinSize, WindowWidth, WindowHeight*6)
	ImGui.SetNextWindowSize(WindowWidth, WindowHeight*6, ImGuiCond.FirstUseEver)
	
	local l = self.Apogee.Localization
	local sandevistandebug = self.Apogee:SandevistanDebug()
	local isEdgeRunner = self.Apogee.sps:IsEdgeRunner()
	if isEdgeRunner == nil then isEdgeRunner = false end
	local NetRunnerLevels = self.Apogee.sps:NetRunnerLevel()
	local NetRunnerLevelText = l['Debug_SectionRunner_'..NetRunnerLevels.str]
	local IsWearingApogee = NetRunnerLevels.IsWearingApogee
	local mfloor = math.floor
	local sliderRAMOrig = mfloor(self.Apogee.HealthRAMBalance/10)
	local sliderRAM = sliderRAMOrig
	local sliderBrakeOrig = self.Apogee.HealthBrake
	local checkSpilloverOrig = self.Apogee.Spillover
	local checkSpillover = checkSpilloverOrig
	local sliderBrake = sliderBrakeOrig
	local CanBribeNCPD = self.Apogee:CanBribeNCPD()
	self.Apogee:CalcDamage(NetRunnerLevels)
	
	if ImGui.Begin(l.Debug_Title, ImGuiWindowFlags.None) then
		if not NetRunnerLevels.GameLoaded then
			ImGui.TextColored(1, 0, 0, 1, l.Debug_Loading)
			return
		end
		if not IsWearingApogee and ImGui.CollapsingHeader(l.Debug_Section1_Title, ImGuiTreeNodeFlags.DefaultOpen) then
			ImGui.TextColored(1, 0, 0, 1, l.Debug_Missing)
		end
		if IsWearingApogee and ImGui.CollapsingHeader(l.Debug_Section1_Title, ImGuiTreeNodeFlags.DefaultOpen) then
			if self.Apogee.PsychoOutburst ~= nil and self.Apogee.PsychoOutburst > 0 then
				local OutOf = 60
				local TheTime = self.Apogee.PsychoOutburst
				-- calculate each time segment 1hr/30min/15min/5min/60s based on 0-100% of that time segment
				    if self.Apogee.PsychoOutburst > 1800 then TheTime = TheTime - 1800; OutOf = 1800 -- 1hr section: 30min time segment
				elseif self.Apogee.PsychoOutburst > 900 then TheTime = TheTime - 900; OutOf = 900 -- 30min section: 15min time segment
				elseif self.Apogee.PsychoOutburst > 300 then TheTime = TheTime - 300; OutOf = 600 -- 15min section: 10min time segment
				elseif self.Apogee.PsychoOutburst > 60 then TheTime = TheTime - 60; OutOf = 240 -- 5min section: 4min time segment
				end
				--[[ Cyan->Magenta ]]--
				local cR = (self.Apogee.PsychoOutburst/3600)
				local cG = (((3600-self.Apogee.PsychoOutburst)-900)/2700)
				if cG < 0 then cG = 0 end
				local cB = (math.abs((3600-self.Apogee.PsychoOutburst)-1800)/3600)+0.5
				
				ImGui.PushStyleColor(ImGuiCol.PlotHistogram, cR, cG, cB, 1.0) -- Orange outline when "ON"
				local psychosis_meter = (TheTime / OutOf)
				ImGui.ProgressBar(psychosis_meter, -1, WindowHeight/3,"## PsychoMeter")
			end
			if not NetRunnerLevels.SafetyOn then
				ImGui.TextColored(1, 0, 0, 1, l.Debug_Section3_SafetyOff1)
				if self.Apogee.CyberPsychoWarnings==0 then
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_Section3_SafetyOff2a)
				else
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_Section3_SafetyOff2b)
				end
				if ImGui.Button(l.Debug_Section3_SafetyOff4) then
					self.Apogee:Safety(true)
				end
			else
				local MaxRuntime = sandevistandebug.MaxRuntime
				local runTime = sandevistandebug.runTime
				if runTime < 0 then runTime = 0 end -- runtime can run into negatives
				--local MaxRuntime = isEdgeRunner and sandevistandebug.MaxRuntime or math.floor(sandevistandebug.MaxRuntime*0.333)
				local NonEdgeRunnerClip = math.floor(sandevistandebug.MaxRuntime*self.Apogee.sps.EdgeRunnerRuntimeModifier)+1
				local clipped = ""
				if not isEdgeRunner and runTime > NonEdgeRunnerClip then runTime = NonEdgeRunnerClip; if self.Apogee.dev_mode then clipped = " ("..l.Debug_Section1_Clipped..")" end end
				ImGui.Text(l.Debug_Section1_RunTime..clipped.." => "..tostring(runTime).."/"..tostring(MaxRuntime).." "..l.Debug_Section1_SecondsRemaining)
				
				if NetRunnerLevels.ApogeeReducedRuntime then
					if self.Apogee.HealthRAMBalance ~= 100 and NetRunnerLevels.Rules.CanUnlockOverClock then
						ImGui.Text(l.Debug_Section1_Overclock)
					else
						ImGui.Text(l.Debug_Section1_NotEdgeRunner)
					end
				else
					ImGui.Text(l.Debug_Section1_IsEdgeRunner)
				end
				
				local value = self.Apogee.bbs:GetThatValueString(self.Apogee:GetHeatLevel())
				if CanBribeNCPD and ImGui.Button(l.Debug_SectionNetrunner_BribeNCPD.." ¢$"..value) then
					ImGui.Separator()
					self.Apogee:BRIBE_NCPD()
				end
				if self.Apogee.CyberPsychoWarnings == 1 then
					ImGui.Separator()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Psychoa)
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_PsychoWarningOne)
					if ImGui.Button(l.Debug_Section3_SafetyOff5) then
						self.Apogee:Safety(false)
					end
				elseif self.Apogee.CyberPsychoWarnings == 2 then
					ImGui.Separator()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Psychob)
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_PsychoWarningTwo)
					if ImGui.Button(l.Debug_Section3_SafetyOff5) then
						self.Apogee:Safety(false)
					end
				elseif self.Apogee.CyberPsychoWarnings == 3 then
					ImGui.Separator()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Psychoc)
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_PsychoWarningThree)
					if ImGui.Button(l.Debug_Section3_SafetyOff5) then
						self.Apogee:Safety(false)
					end
				elseif self.Apogee.CyberPsychoWarnings == 4 then
					ImGui.Separator()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Psychod)
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_PsychoWarningFour)
					if ImGui.Button(l.Debug_Section3_SafetyOff5) then
						self.Apogee:Safety(false)
					end
				elseif self.Apogee.CyberPsychoWarnings == 5 then
					ImGui.Separator()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Psychoe)
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_PsychoLastWarning)
					if ImGui.Button(l.Debug_SectionRunner_Psycho2) then
						self.Apogee:Safety(false)
					end
				else
					ImGui.Separator()
					if ImGui.Button(l.Debug_Section3_SafetyOff5) then
						self.Apogee:Safety(false)
					end
				end
			end
		end
		if IsWearingApogee and isEdgeRunner and ImGui.CollapsingHeader(l.Debug_SectionRunner_Monitor_Title, ImGuiTreeNodeFlags.DefaultOpen) then
			if not NetRunnerLevels.SafetyOn then
				if self.Apogee.CyberPsychoWarnings==0 then
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_Section3_SafetyOff3a)
				else
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_Section3_SafetyOff3b)
				end
			else
				local RAMText = l.Debug_SectionRunner_Perk_RequiresCyberdeck
				local TimeDilation = 850
				local ActualDilation = 85
				local DilationText = ''
				Dilation, ActualDilation, StatusText = self.Apogee:TimeDilationCalculator(true)
				if NetRunnerLevels.IsWearingCyberDeck then
					RAMText = tostring(mfloor(self.Apogee.sps:getRAM()*10)/10)
				end
				ImGui.Text(l.Debug_Section1_TimeDilation..' '..tostring(ActualDilation)..'%')
				ImGui.Text(l.Debug_SectionRunner_Monitor_Health..":"..tostring(mfloor(self.Apogee.sps:getHealth(true)*10)/10).."%")
				ImGui.SameLine()
				ImGui.Text(l.Debug_SectionRunner_Monitor_RAM..":"..RAMText)
				ImGui.Text(l.Debug_SectionRunner_Monitor_DamagePerTick..":"..tostring(mfloor(self.Apogee.DamagePerTick*10)/10).."% (Max:10%)")
				local HealthMarginText = l.Debug_SectionRunner_Monitor_HealthMargin..":"..tostring(mfloor((self.Apogee.RequiredHealth-self.Apogee.DamagePerTick)*10)/10).."% / "..tostring(sliderBrakeOrig-10).."%"
				if sliderBrakeOrig-10 < 13 then
					ImGui.TextColored(1, 0, 0, 1, HealthMarginText)
				elseif sliderBrakeOrig-10 < 25 then
					ImGui.TextColored(1, 0.6, 0.1, 1, HealthMarginText)
				else
					ImGui.Text(HealthMarginText)
				end
				
				local HackBrakeLocked = ''
				if not NetRunnerLevels.Rules.CanHackBrake then
					HackBrakeLocked = ' '..l.Debug_SectionRunner_Locked
				end
				
				ImGui.Separator()
				ImGui.Text(l.Debug_SectionRunner_BrakeDesc..HackBrakeLocked)
				ImGui.PushItemWidth(-1)
				sliderBrake = ImGui.SliderInt('## '..l.Debug_SectionRunner_BRAKE, sliderBrake, 15, 50, "%d")
				if type(sliderBrake) == 'number' and NetRunnerLevels.Rules.CanEditParameters then
					if sliderBrakeOrig ~= sliderBrake then
						self.Apogee.HealthBrake = mfloor(sliderBrake)
						self.Apogee:SaveGame('gui:Brake '..tostring(sliderBrakeOrig)..'=>'..tostring(sliderBrake))
					end
				end
				
				ImGui.Separator()
				ImGui.Text(l.Debug_SectionRunner_AdrenalineRushDesc)
				if NetRunnerLevels.Rules.CanBoostAdrenaline then
					local Text_orange = {   1,  0.6, 0.1, 1, l.Debug_SectionRunner_AdrenalinesFullDesc}
					local Text_cyan   = {0.25, 0.75,   1, 1, l.Debug_SectionRunner_AdrenalinesFullDesc}
					local ColouredText = {}
					
					local checkAdrenalineRushOrig = self.Apogee.AdrenalineRush
					local checkAdrenalineRush = checkAdrenalineRushOrig
					checkAdrenalineRush = ImGui.Checkbox(l.Debug_SectionRunner_AdrenalinesEnable, checkAdrenalineRushOrig)
					if checkAdrenalineRushOrig ~= checkAdrenalineRush and NetRunnerLevels.Rules.CanEditParameters then
						self.Apogee.AdrenalineRush = checkAdrenalineRush
						self.Apogee:SaveGame('gui=>AdrenalineRush '..tostring(checkAdrenalineRushOrig)..'=>'..tostring(checkAdrenalineRush))
					end
					if not self.Apogee.AdrenalineRush then
						ColouredText = Text_orange
						ImGui.SameLine()
						ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Disabled)
					else
						ColouredText = Text_cyan
						ImGui.SameLine()
						if NetRunnerLevels.Rules.CanBoostAdrenalineBonus then
							ImGui.Text(l.Debug_SectionRunner_AdrenalinesDesc)
						else
							ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Perk_CalmMind)
						end
					end
					ImGui.TextColored(table.unpack(ColouredText))
				else
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Disabled)
					if NetRunnerLevels.AdrenalineRush < 3 then
						ImGui.SameLine()
						ImGui.Text(l.Debug_SectionRunner_Perk_AdrenalineRush)
					end
					if NetRunnerLevels.AdrenalineRush < 4 then
						ImGui.SameLine()
						ImGui.Text(l.Debug_SectionRunner_Perk_CalmMind)
					end
					if self.Apogee.runTime == 0 then
						ImGui.SameLine()
						ImGui.Text(l.Debug_SectionRunner_Perk_RequiresRuntime)
					end
				end
			end
		end
		if IsWearingApogee and isEdgeRunner and NetRunnerLevels.Rules.CanUnlockNetRunnerPort and ImGui.CollapsingHeader(l.Debug_SectionRunner_Title, ImGuiTreeNodeFlags.DefaultOpen) then
			ImGui.Text(l.Debug_SectionRunner_SkillLevel..":"..NetRunnerLevelText)

			if not NetRunnerLevels.Rules.CanEditCyberdeck then
				ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_RuntimeLock)
			end

			ImGui.Separator()
			ImGui.Text(l.Debug_SectionRunner_OverclockDesc)
			if NetRunnerLevels.Rules.CanUnlockOverClock then
				ImGui.Text(l.Debug_SectionRunner_RAM)
				ImGui.SameLine()
				local HealthSize, _ = ImGui.CalcTextSize(l.Debug_SectionRunner_HEALTH)
				local padding = ImGui.GetStyle().ItemSpacing.x * 1.5
				ImGui.PushItemWidth((HealthSize+padding)*-1)
				sliderRAM = ImGui.SliderInt('## '..l.Debug_SectionRunner_HEALTH, sliderRAM, 0, 10, "%d")
				if type(sliderRAM) == 'number' and NetRunnerLevels.Rules.CanEditCyberdeck then
					if sliderRAMOrig ~= sliderRAM then
						self.Apogee.HealthRAMBalance = sliderRAM*10
						self.Apogee:SaveGame('gui=>RAM '..tostring(sliderRAMOrig)..'=>'..tostring(sliderRAM))
					end
				end
				ImGui.SameLine()
				ImGui.Text(l.Debug_SectionRunner_HEALTH)
				ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_OverclockExtra)
			else
				ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Disabled)
				if not NetRunnerLevels.IsWearingCyberDeck then
					ImGui.SameLine()
					ImGui.Text(l.Debug_SectionRunner_Perk_RequiresCyberdeck)
				end
				if NetRunnerLevels.OverClocker < 3 then
					ImGui.SameLine()
					ImGui.Text(l.Debug_SectionRunner_Perk_OverClock3)
				end
				if self.Apogee.runTime == 0 then
					ImGui.SameLine()
					ImGui.Text(l.Debug_SectionRunner_Perk_RequiresRuntime)
				end
			end
			
			ImGui.Separator()
			ImGui.Text(l.Debug_SectionRunner_SpilloverDesc)
			if NetRunnerLevels.Rules.CanRunTimeSpillOver then
				local Text_orange = {   1,  0.6, 0.1, 1, l.Debug_SectionRunner_SpilloverFullDesc}
				local Text_cyan   = {0.25, 0.75,   1, 1, l.Debug_SectionRunner_SpilloverFullDesc}
				local ColouredText = {}
				local checkSpilloverOrig = self.Apogee.Spillover
				local checkSpillover = checkSpilloverOrig
				checkSpillover = ImGui.Checkbox(l.Debug_SectionRunner_SpilloverEnable, checkSpilloverOrig)
				if checkSpilloverOrig ~= checkSpillover and NetRunnerLevels.Rules.CanEditCyberdeck then
					self.Apogee.Spillover = checkSpillover
					self.Apogee:SaveGame('gui=>Spillover '..tostring(checkSpilloverOrig)..'=>'..tostring(checkSpillover))
				end
				if not self.Apogee.Spillover then
					ColouredText = Text_orange
					ImGui.SameLine()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Disabled)
				else
					ColouredText = Text_cyan
				end
				ImGui.TextColored(table.unpack(ColouredText))
			else
				ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Disabled)
				if not NetRunnerLevels.IsWearingCyberDeck then
					ImGui.SameLine()
					ImGui.Text(l.Debug_SectionRunner_Perk_RequiresCyberdeck)
				end
				if NetRunnerLevels.Queuer < 4 then
					ImGui.SameLine()
					ImGui.Text(l.Debug_SectionRunner_Perk_QueueMastery)
				end
				if NetRunnerLevels.OverClocker < 4 then
					ImGui.SameLine()
					ImGui.Text(l.Debug_SectionRunner_Perk_Spillover)
				end
				if self.Apogee.runTime == 0 then
					ImGui.SameLine()
					ImGui.Text(l.Debug_SectionRunner_Perk_RequiresRuntime)
				end
			end
		end
		if IsWearingApogee and isEdgeRunner and (not NetRunnerLevels.Rules.CanUnlockNetRunnerPort) and ImGui.CollapsingHeader(l.Debug_SectionRunner_Title_Locked) then
			ImGui.Text(l.Debug_SectionRunner_SkillLevel..":"..NetRunnerLevelText)
			ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Disabled)
			if NetRunnerLevels.Queuer < 3 then
				ImGui.SameLine()
				ImGui.Text(l.Debug_SectionRunner_Perk_QueueAcceleration3)
			end
			if not NetRunnerLevels.IsWearingCyberDeck then
				ImGui.SameLine()
				ImGui.Text(l.Debug_SectionRunner_Perk_RequiresCyberdeck)
			end
		end
		if self.Apogee.dev_mode and self.Apogee.dev_mode.gui then self.Apogee.dev_mode:gui(self.Apogee) end
		if self.Apogee.debug and ImGui.CollapsingHeader(l.Debug_Section2_Title, ImGuiTreeNodeFlags.DefaultOpen) then
			ImGui.Text(l.Debug_Section2_IsLvl40.." => "..tostring(sandevistandebug.IsPlayerLevel40))
			ImGui.Text(l.Debug_Section2_FalcoReward.." => "..tostring(sandevistandebug.hasFalcosReward))
			ImGui.Text(l.Debug_Section2_smsSent.." => "..tostring(sandevistandebug.smsSent))
			ImGui.Text(l.Debug_Section2_ViktorLvl.." => "..tostring(sandevistandebug.LevelCheck))
			ImGui.Text(l.Debug_Section2_ViktorStock.." => "..tostring(self.DebugViksStock))

			if sandevistandebug.smsSent then
				if ImGui.Button(l.Debug_Section2_UnsendSMS) then
					self:ResetSMS(sandevistandebug.hasFalcosReward)
				end
				ImGui.SameLine()
			end
			
			if ImGui.Button(l.Debug_Section2_Check) then
				local ViksStock = false
				if self.Apogee.martinez:DebugViksStock() then
					ViksStock = true
				end
				if ViksStock then
					self.DebugViksStock = l.Debug_Section2_CheckFound
				else
					self.DebugViksStock = l.Debug_Section2_CheckMissing
				end
			end
		end
		
		if self.Apogee.debug and ImGui.CollapsingHeader(l.Debug_Section3_Title, ImGuiTreeNodeFlags.DefaultOpen) then
			local mq049_progress = self.Apogee.qs:mq049_progress()
			for k,v in pairs(mq049_progress) do
				ImGui.Text(tostring(k).." => "..tostring(v))
			end
		end
		
		if self.Apogee.dev_mode and self.Apogee.dev_mode.gui_facts then self.Apogee.dev_mode:gui_facts(self.Apogee) end
		ImGui.End()
	end
end)

return gui
