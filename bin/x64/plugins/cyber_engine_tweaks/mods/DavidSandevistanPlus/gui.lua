local gui = { }

gui.showUIWindow = false
gui.DSP = nil -- pointer to dsp model
gui.DebugViksStock = "DebugViksStock Not Found"

gui.Init = (function(self,DSP)
	self.DSP = DSP
	self.DebugViksStock = self.DSP.Localization.Debug_Section2_CheckNotChecked
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
	if self.DSP ~= nil then
		self.DSP:UnsendViksMessage(hasFalcosReward)
	end
end)

gui.drawUIWindow = (function(self)
	local WindowWidth, WindowHeight = ImGui.CalcTextSize('This is some long text that I hope you\'ll never see, but fear not') -- it just sets the default size of the window!

    ImGui.SetNextWindowPos(WindowWidth/2, WindowWidth*2, ImGuiCond.FirstUseEver)
	ImGui.PushStyleVar(ImGuiStyleVar.WindowMinSize, WindowWidth, WindowHeight*6)
	ImGui.SetNextWindowSize(WindowWidth, WindowHeight*6, ImGuiCond.FirstUseEver)
	
	local l = self.DSP.Localization
	local sandevistandebug = self.DSP:SandevistanDebug()
	local isEdgeRunner = self.DSP.sps:IsEdgeRunner()
	if isEdgeRunner == nil then isEdgeRunner = false end
	local NetRunnerLevels = self.DSP.sps:NetRunnerLevel()
	local NetRunnerLevelText = l['Debug_SectionRunner_'..NetRunnerLevels.str]
	local IsWearingSandevistan = NetRunnerLevels.IsWearingSandevistan
	local mfloor = math.floor
	local sliderBrakeOrig = self.DSP.HealthBrake
	local sliderBrake = sliderBrakeOrig
	local CanBribeNCPD = self.DSP:CanBribeNCPD()
	self.DSP:CalcDamage()
	
	if ImGui.Begin(l.Debug_Title, ImGuiWindowFlags.None) then
		if not NetRunnerLevels.GameLoaded then
			ImGui.TextColored(1, 0, 0, 1, l.Debug_Loading)
			return
		end
		if not IsWearingSandevistan and ImGui.CollapsingHeader(l.Debug_Section1_Title, ImGuiTreeNodeFlags.DefaultOpen) then
			ImGui.TextColored(1, 0, 0, 1, l.Debug_Missing)
		end
		if IsWearingSandevistan and ImGui.CollapsingHeader(l.Debug_Section1_Title, ImGuiTreeNodeFlags.DefaultOpen) then
			local strain = self.DSP.neuralStrain or 0
			local threshold = self.DSP:GetStrainThreshold()
			local guaranteed = self.DSP:GetStrainGuaranteed()
			if strain > 0 then
				local ratio = strain / guaranteed
				local cR, cG, cB
				if strain < threshold then
					cR, cG, cB = 0.2, 0.5, 1.0
				elseif strain < guaranteed then
					local t = (strain - threshold) / (guaranteed - threshold)
					cR = 0.2 + t * 0.8
					cG = 0.5 * (1 - t)
					cB = 1.0 * (1 - t)
				else
					cR, cG, cB = 1.0, 0.0, 0.0
				end
				ImGui.PushStyleColor(ImGuiCol.PlotHistogram, cR, cG, cB, 1.0)
				ImGui.ProgressBar(ratio, -1, WindowHeight/3, string.format("STRAIN %.1f/%.0f", strain, guaranteed))
				ImGui.PopStyleColor()
			end
			if not NetRunnerLevels.SafetyOn then
				ImGui.TextColored(1, 0, 0, 1, l.Debug_Section3_SafetyOff1)
				if self.DSP.CyberPsychoWarnings==0 then
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_Section3_SafetyOff2a)
				else
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_Section3_SafetyOff2b)
				end
				if ImGui.Button(l.Debug_Section3_SafetyOff4) then
					self.DSP:Safety(true)
				end
			else
				local MaxRuntime = sandevistandebug.MaxRuntime
				local runTime = sandevistandebug.runTime
				if runTime < 0 then runTime = 0 end -- runtime can run into negatives
				--local MaxRuntime = isEdgeRunner and sandevistandebug.MaxRuntime or math.floor(sandevistandebug.MaxRuntime*0.333)
				local NonEdgeRunnerClip = math.floor(sandevistandebug.MaxRuntime*self.DSP.sps.EdgeRunnerRuntimeModifier)+1
				local clipped = ""
				if not isEdgeRunner and runTime > NonEdgeRunnerClip then runTime = NonEdgeRunnerClip; if self.DSP.dev_mode then clipped = " ("..l.Debug_Section1_Clipped..")" end end
				ImGui.Text(l.Debug_Section1_RunTime..clipped.." => "..tostring(runTime).."/"..tostring(MaxRuntime).." "..l.Debug_Section1_SecondsRemaining)
				
				if NetRunnerLevels.ReducedRuntime then
					ImGui.Text(l.Debug_Section1_NotEdgeRunner)
				else
					ImGui.Text(l.Debug_Section1_IsEdgeRunner)
				end
				
				local value = self.DSP.bbs:GetThatValueString(self.DSP:GetHeatLevel())
				if CanBribeNCPD and ImGui.Button(l.Debug_SectionNetrunner_BribeNCPD.." ¢$"..value) then
					ImGui.Separator()
					self.DSP:BRIBE_NCPD()
				end
				if self.DSP.CyberPsychoWarnings == 1 then
					ImGui.Separator()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Psychoa)
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_PsychoWarningOne)
					if ImGui.Button(l.Debug_Section3_SafetyOff5) then
						self.DSP:Safety(false)
					end
				elseif self.DSP.CyberPsychoWarnings == 2 then
					ImGui.Separator()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Psychob)
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_PsychoWarningTwo)
					if ImGui.Button(l.Debug_Section3_SafetyOff5) then
						self.DSP:Safety(false)
					end
				elseif self.DSP.CyberPsychoWarnings == 3 then
					ImGui.Separator()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Psychoc)
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_PsychoWarningThree)
					if ImGui.Button(l.Debug_Section3_SafetyOff5) then
						self.DSP:Safety(false)
					end
				elseif self.DSP.CyberPsychoWarnings == 4 then
					ImGui.Separator()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Psychod)
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_PsychoWarningFour)
					if ImGui.Button(l.Debug_Section3_SafetyOff5) then
						self.DSP:Safety(false)
					end
				elseif self.DSP.CyberPsychoWarnings == 5 then
					ImGui.Separator()
					ImGui.TextColored(1, 0, 0, 1, l.Debug_SectionRunner_Psychoe)
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_SectionRunner_PsychoLastWarning)
					if ImGui.Button(l.Debug_SectionRunner_Psycho2) then
						self.DSP:Safety(false)
					end
				else
					ImGui.Separator()
					if ImGui.Button(l.Debug_Section3_SafetyOff5) then
						self.DSP:Safety(false)
					end
				end
			end
		end
		if IsWearingSandevistan and isEdgeRunner and ImGui.CollapsingHeader(l.Debug_SectionRunner_Monitor_Title, ImGuiTreeNodeFlags.DefaultOpen) then
			if not NetRunnerLevels.SafetyOn then
				if self.DSP.CyberPsychoWarnings==0 then
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_Section3_SafetyOff3a)
				else
					ImGui.TextColored(0.25, 0.75, 1, 1, l.Debug_Section3_SafetyOff3b)
				end
			else
				local RAMText = l.Debug_SectionRunner_Perk_RequiresCyberdeck
					local DilationIdx, StatusText = self.DSP:TimeDilationCalculator(true)
				local ActualDilation = self.DSP.martinez.TimeDilations:GetTimeDilationFromIndex(DilationIdx) or 85
				if NetRunnerLevels.IsWearingCyberDeck then
					RAMText = tostring(mfloor(self.DSP.sps:getRAM()*10)/10)
				end
				ImGui.Text(l.Debug_Section1_TimeDilation..' '..tostring(ActualDilation)..'%')
				ImGui.Text(l.Debug_SectionRunner_Monitor_Health..":"..tostring(mfloor(self.DSP.sps:getHealth(true)*10)/10).."%")
				ImGui.SameLine()
				ImGui.Text(l.Debug_SectionRunner_Monitor_RAM..":"..RAMText)
				ImGui.Text(l.Debug_SectionRunner_Monitor_DamagePerTick..":"..tostring(mfloor(self.DSP.DamagePerTick*10)/10).."% (Max:10%)")
				local HealthMarginText = l.Debug_SectionRunner_Monitor_HealthMargin..":"..tostring(mfloor((self.DSP.RequiredHealth-self.DSP.DamagePerTick)*10)/10).."% / "..tostring(sliderBrakeOrig-10).."%"
				if sliderBrakeOrig-10 < 13 then
					ImGui.TextColored(1, 0, 0, 1, HealthMarginText)
				elseif sliderBrakeOrig-10 < 25 then
					ImGui.TextColored(1, 0.6, 0.1, 1, HealthMarginText)
				else
					ImGui.Text(HealthMarginText)
				end
				
			end
			
		end
		if self.DSP.dev_mode and self.DSP.dev_mode.gui then self.DSP.dev_mode:gui(self.DSP) end
		if self.DSP.debug and ImGui.CollapsingHeader(l.Debug_Section2_Title, ImGuiTreeNodeFlags.DefaultOpen) then
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
				if self.DSP.martinez:DebugViksStock() then
					ViksStock = true
				end
				if ViksStock then
					self.DebugViksStock = l.Debug_Section2_CheckFound
				else
					self.DebugViksStock = l.Debug_Section2_CheckMissing
				end
			end
		end
		
		if self.DSP.debug and ImGui.CollapsingHeader(l.Debug_Section3_Title, ImGuiTreeNodeFlags.DefaultOpen) then
			local mq049_progress = self.DSP.qs:mq049_progress()
			for k,v in pairs(mq049_progress) do
				ImGui.Text(tostring(k).." => "..tostring(v))
			end
		end
		
		if self.DSP.dev_mode and self.DSP.dev_mode.gui_facts then self.DSP.dev_mode:gui_facts(self.DSP) end
		ImGui.End()
	end
end)

return gui
