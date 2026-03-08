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
	local sliderBrakeOrig = self.Apogee.HealthBrake
	local sliderBrake = sliderBrakeOrig
	local CanBribeNCPD = self.Apogee:CanBribeNCPD()
	self.Apogee:CalcDamage()
	
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
					ImGui.Text(l.Debug_Section1_NotEdgeRunner)
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
					local timeScale, StatusText = self.Apogee:TimeDilationCalculator(true)
				local ActualDilation = math.floor((1 - timeScale) * 1000 + 0.5) / 10
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
