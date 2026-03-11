local hud = {}

hud.Apogee = nil
hud.healthbarCtrl = nil
hud.built = false

-- Widget references
hud.w = {}

-- Layout constants
local BAR_WIDTH = 420
local BAR_HEIGHT = 10
local FONT_SIZE_MAIN = 30
local FONT_SIZE_SMALL = 24
local PANEL_TOP_MARGIN = 20
local PANEL_LEFT_OFFSET = 540  -- Right of HP bar (original working position)
local FONT_FAMILY = "base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily"
local FONT_STYLE = "Medium"

-- Colors
local COLOR_BG = { r = 0.12, g = 0.12, b = 0.14, a = 0.70 }
local COLOR_GREEN = { r = 0.18, g = 0.80, b = 0.44, a = 1.0 }
local COLOR_YELLOW = { r = 0.95, g = 0.77, b = 0.06, a = 1.0 }
local COLOR_ORANGE = { r = 1.0, g = 0.6, b = 0.1, a = 1.0 }
local COLOR_RED = { r = 0.91, g = 0.30, b = 0.24, a = 1.0 }
local COLOR_CYAN = { r = 0.25, g = 0.75, b = 1.0, a = 1.0 }
local COLOR_MAGENTA = { r = 0.91, g = 0.20, b = 0.60, a = 1.0 }
local COLOR_WHITE = { r = 0.85, g = 0.85, b = 0.85, a = 1.0 }
local COLOR_DIM = { r = 0.50, g = 0.50, b = 0.50, a = 0.80 }
local COLOR_SAFETY_OFF = { r = 1.0, g = 0.15, b = 0.15, a = 1.0 }

local PSYCHO_LEVELS = {
	[1] = { text = "[I] UNSTABLE",     color = COLOR_CYAN },
	[2] = { text = "[II] GLITCHING",   color = { r = 0.60, g = 0.77, b = 0.53, a = 1.0 } },
	[3] = { text = "[III] LOSING IT",  color = COLOR_YELLOW },
	[4] = { text = "[IV] ON THE EDGE", color = COLOR_ORANGE },
	[5] = { text = "[V] CYBERPSYCHO",  color = COLOR_RED },
}

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------

local function CNameNew(str)
	local ok, cn = pcall(function()
		local c = CName.new(str)
		if c.value ~= str then
			CName.add(str)
			c = CName.new(str)
		end
		return c
	end)
	if ok then return cn end
	return CName.new(str)
end

local function toHDR(c)
	return HDRColor.new({ Red = c.r, Green = c.g, Blue = c.b, Alpha = c.a })
end

local function lerpColor(a, b, t)
	if t < 0 then t = 0 end
	if t > 1 then t = 1 end
	return {
		r = a.r + (b.r - a.r) * t,
		g = a.g + (b.g - a.g) * t,
		b = a.b + (b.b - a.b) * t,
		a = a.a + (b.a - a.a) * t,
	}
end

local function runtimeColor(ratio)
	if ratio > 0.5 then
		return lerpColor(COLOR_YELLOW, COLOR_GREEN, (ratio - 0.5) * 2)
	else
		return lerpColor(COLOR_RED, COLOR_YELLOW, ratio * 2)
	end
end

local function formatTime(seconds)
	local mins = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	if mins > 0 then
		return tostring(mins) .. "m" .. string.format("%02d", secs) .. "s"
	end
	return tostring(secs) .. "s"
end

----------------------------------------------------------------
-- Widget creation helpers (with pcall safety)
----------------------------------------------------------------

local function safeAddChild(parent, widgetType, name)
	local w
	local ok, err = pcall(function()
		w = parent:AddChild(widgetType)
		if w then
			w:SetName(CNameNew(name))
		end
	end)
	if not ok then
		print('[DSP-HUD] safeAddChild("'..widgetType..'", "'..name..'") failed: '..tostring(err))
		return nil
	end
	if w == nil then
		print('[DSP-HUD] safeAddChild("'..widgetType..'", "'..name..'") returned nil')
	end
	return w
end

local function createCanvas(parent, name, marginTop)
	local w = safeAddChild(parent, "inkCanvasWidget", name)
	if w == nil then return nil end
	pcall(function()
		w:SetMargin(0, marginTop or 0, 0, 0)
		w:SetAnchor(inkEAnchor.TopLeft)
		w:SetAnchorPoint(0.0, 0.0)
	end)
	return w
end

local function createRect(parent, name, width, height, color)
	local w = safeAddChild(parent, "inkRectangleWidget", name)
	if w == nil then return nil end
	pcall(function()
		w:SetSize(width, height)
		w:SetAnchor(inkEAnchor.TopLeft)
		w:SetAnchorPoint(0.0, 0.0)
		w:SetTintColor(toHDR(color))
		w:SetVisible(true)
	end)
	return w
end

local function createText(parent, name, fontSize, color, hAlign)
	local w = safeAddChild(parent, "inkTextWidget", name)
	if w == nil then return nil end
	pcall(function()
		w:SetFontFamily(FONT_FAMILY)
		w:SetFontSize(fontSize)
		w:SetFontStyle(FONT_STYLE)
		w:SetTintColor(toHDR(color))
		w:SetHorizontalAlignment(hAlign or textHorizontalAlignment.Left)
		w:SetVerticalAlignment(textVerticalAlignment.Top)
		w:SetAnchor(inkEAnchor.TopLeft)
		w:SetAnchorPoint(0.0, 0.0)
		w:SetVisible(true)
		w:SetText("")
	end)
	return w
end

----------------------------------------------------------------
-- Init
----------------------------------------------------------------

hud.Init = (function(self, Apogee, doDebug)
	if Apogee ~= nil then
		self.Apogee = Apogee
	end
	print('[DSP-HUD] Init: healthbarCtrl='..tostring(self.healthbarCtrl ~= nil))
	self:Build()
end)

----------------------------------------------------------------
-- Build: create all widgets once
----------------------------------------------------------------

hud.Build = (function(self)
	if self.built then return end

	-- Check healthbarCtrl
	if self.healthbarCtrl == nil then
		print('[DSP-HUD] Build: healthbarCtrl is nil')
		return
	end

	local ctrlValid = false
	pcall(function() ctrlValid = IsDefined(self.healthbarCtrl) end)
	if not ctrlValid then
		print('[DSP-HUD] Build: healthbarCtrl not valid/defined')
		return
	end

	-- Step 1: Get root compound widget
	local RCW
	local ok, err = pcall(function()
		RCW = self.healthbarCtrl:GetRootCompoundWidget()
	end)
	if not ok then
		print('[DSP-HUD] Build: GetRootCompoundWidget failed: '..tostring(err))
		return
	end
	if RCW == nil then
		print('[DSP-HUD] Build: RCW is nil')
		return
	end
	print('[DSP-HUD] Build: RCW obtained')

	-- Step 2: Find buffsHolder
	local buffsHolder
	ok, err = pcall(function()
		buffsHolder = RCW:GetWidgetByPathName(CNameNew("buffsHolder"))
	end)
	if not ok or buffsHolder == nil then
		print('[DSP-HUD] Build: buffsHolder not found (err='..tostring(err)..'), using RCW as parent')
		buffsHolder = RCW
	else
		print('[DSP-HUD] Build: buffsHolder found')
	end

	-- Step 3: Remove old panel if exists
	pcall(function()
		local oldPanel = buffsHolder:GetWidgetByPathName(CNameNew("DavidMartinezPanel"))
		if oldPanel ~= nil then buffsHolder:RemoveChild(oldPanel) end
	end)

	-- Step 4: Create panel
	local TextMargin = (self.Apogee and self.Apogee.OverrideTextMargin) or PANEL_TOP_MARGIN
	local panel = createCanvas(buffsHolder, "DavidMartinezPanel", 0)
	if panel == nil then
		print('[DSP-HUD] Build: failed to create panel canvas')
		return
	end
	pcall(function()
		panel:SetMargin(PANEL_LEFT_OFFSET, TextMargin, 0, 0)
	end)
	self.w.panel = panel
	print('[DSP-HUD] Build: panel created')

	-- Step 5: Row 1 - Runtime bar + dilation text
	local row1 = createCanvas(panel, "DSP_Row1", 0)
	if row1 == nil then
		print('[DSP-HUD] Build: failed to create row1')
		return
	end
	self.w.row1 = row1

	self.w.runtimeBg   = createRect(row1, "DSP_RuntimeBg", BAR_WIDTH, BAR_HEIGHT, COLOR_BG)
	self.w.runtimeFill = createRect(row1, "DSP_RuntimeFill", BAR_WIDTH, BAR_HEIGHT, COLOR_GREEN)
	self.w.runtimeText = createText(row1, "DSP_RuntimeText", FONT_SIZE_SMALL, COLOR_WHITE, textHorizontalAlignment.Left)
	if self.w.runtimeText then
		pcall(function() self.w.runtimeText:SetMargin(4, BAR_HEIGHT + 4, 0, 0) end)
	end
	self.w.dilationText = createText(row1, "DSP_DilationText", FONT_SIZE_MAIN, COLOR_WHITE, textHorizontalAlignment.Left)
	if self.w.dilationText then
		pcall(function() self.w.dilationText:SetMargin(BAR_WIDTH + 14, -4, 0, 0) end)
	end

	-- Psycho status line
	self.w.psychoLine = createText(row1, "DSP_PsychoLine", FONT_SIZE_SMALL, COLOR_CYAN, textHorizontalAlignment.Left)
	if self.w.psychoLine then
		pcall(function()
			self.w.psychoLine:SetMargin(BAR_WIDTH + 14, FONT_SIZE_MAIN + 2, 0, 0)
			self.w.psychoLine:SetVisible(false)
		end)
	end

	-- Step 6: Row 2 - Status line
	local row2Y = BAR_HEIGHT + FONT_SIZE_SMALL + 16
	local row2 = createCanvas(panel, "DSP_Row2", row2Y)
	self.w.row2 = row2
	if row2 then
		self.w.activationsText = createText(row2, "DSP_Activations", FONT_SIZE_SMALL, COLOR_DIM, textHorizontalAlignment.Left)
		self.w.statusText = createText(row2, "DSP_Status", FONT_SIZE_SMALL, COLOR_WHITE, textHorizontalAlignment.Left)
		if self.w.statusText then
			pcall(function() self.w.statusText:SetMargin(170, 0, 0, 0) end)
		end
	end

	self.built = true
	print('[DSP-HUD] Build: COMPLETE — all widgets created')
end)

----------------------------------------------------------------
-- Update: refresh all widgets each tick
----------------------------------------------------------------

hud.Update = (function(self, data)
	if not self.built then
		self:Build()
		if not self.built then return end
	end

	-- One-time debug log after first successful build
	if not self._debugLogged then
		self._debugLogged = true
		print('[DSP-HUD] Update: isWearing='..tostring(data.isWearing)..' showUI='..tostring(data.showUI)..' runTime='..tostring(data.runTime)..' MaxRunTime='..tostring(data.MaxRunTime))
	end

	-- Rebuild if the panel widget was invalidated by the game
	local panelOk = false
	pcall(function()
		panelOk = self.w.panel ~= nil and IsDefined(self.w.panel)
	end)
	if not panelOk then
		self.built = false
		self.w = {}
		self:Build()
		if not self.built then return end
	end

	-- Visibility: hide if not wearing Sandy or UI disabled
	if not data.isWearing or not data.showUI then
		pcall(function() self.w.panel:SetVisible(false) end)
		return
	end
	pcall(function() self.w.panel:SetVisible(true) end)

	-- Row 1: Runtime bar
	local maxRT = data.MaxRunTime
	if maxRT <= 0 then maxRT = 1 end
	local ratio = data.runTime / maxRT
	if ratio < 0 then ratio = 0 end
	if ratio > 1 then ratio = 1 end

	if self.w.runtimeFill then
		pcall(function()
			local fillWidth = math.floor(BAR_WIDTH * ratio)
			if fillWidth < 1 and data.runTime > 0 then fillWidth = 1 end
			self.w.runtimeFill:SetSize(fillWidth, BAR_HEIGHT)
			self.w.runtimeFill:SetTintColor(toHDR(runtimeColor(ratio)))
		end)
	end

	if self.w.runtimeText then
		pcall(function()
			local rtText = tostring(math.floor(data.runTime)) .. "/" .. tostring(maxRT) .. "s"
			if data.rechargeNotification and data.rechargeNotification > 0 then
				rtText = "+" .. tostring(data.rechargeNotification) .. "s  " .. rtText
				self.w.runtimeText:SetTintColor(toHDR(COLOR_GREEN))
			else
				self.w.runtimeText:SetTintColor(toHDR(COLOR_WHITE))
			end
			self.w.runtimeText:SetText(rtText)
		end)
	end

	-- Dilation %
	if self.w.dilationText then
		pcall(function()
			local dilText = tostring(data.dilation) .. "%"
			self.w.dilationText:SetText(dilText)
			if data.isRunning then
				self.w.dilationText:SetTintColor(toHDR(COLOR_WHITE))
			else
				self.w.dilationText:SetTintColor(toHDR(COLOR_DIM))
			end
		end)
	end

	-- Row 2: Activations + contextual status
	if self.w.activationsText then
		pcall(function()
			local actText = data.dailyActivations .. "/" .. data.dailySafe
			local actColor = COLOR_DIM
			if data.dailyActivations > data.dailySafe then
				actText = actText .. " OVERUSE"
				actColor = COLOR_ORANGE
			end
			self.w.activationsText:SetText(actText)
			self.w.activationsText:SetTintColor(toHDR(actColor))
		end)
	end

	if self.w.statusText then
		pcall(function()
			local status = ""
			local statusColor = COLOR_WHITE
			if data.lastBreath then
				if data.lastBreath.phase == "peace" then
					status = "LAST BREATH"
					statusColor = COLOR_WHITE
				else
					status = "LAST BREATH — FADING"
					statusColor = COLOR_RED
				end
			elseif not data.SafetyOn then
				status = "SAFETY OFF"
				statusColor = COLOR_SAFETY_OFF
			elseif data.comedownTimer and data.comedownTimer > 0 then
				status = "COMEDOWN " .. string.format("%.1f", data.comedownTimer) .. "s"
				statusColor = COLOR_ORANGE
			elseif data.inSafeArea or data.inClub then
				if data.psychoWarnings > 0 then
					status = "RECOVERING"
					statusColor = COLOR_GREEN
				end
			elseif data.dfImmuno then
				status = "STABILIZED"
				statusColor = COLOR_GREEN
			elseif data.isRunning and data.psychoWarnings > 0 then
				status = "ACCELERATING"
				statusColor = COLOR_YELLOW
			end
			self.w.statusText:SetText(status)
			self.w.statusText:SetTintColor(toHDR(statusColor))
		end)
	end

	-- Psycho line
	if self.w.psychoLine then
		pcall(function()
			local showPsycho = false
			if data.lastBreath then
				showPsycho = true
			elseif data.psychoWarnings > 0 and data.psychoOutburst ~= nil then
				showPsycho = true
			end
			self.w.psychoLine:SetVisible(showPsycho)

			if showPsycho then
				if data.lastBreath then
					local rt = data.runTime or 0
					self.w.psychoLine:SetText("[VI] LAST BREATH  " .. formatTime(rt))
					if data.lastBreath.phase == "decay" then
						local pulse = math.abs(math.sin(os.clock() * 2))
						local c = lerpColor(COLOR_RED, COLOR_WHITE, pulse)
						self.w.psychoLine:SetTintColor(toHDR(c))
					else
						self.w.psychoLine:SetTintColor(toHDR(COLOR_WHITE))
					end
				else
					local lvl = PSYCHO_LEVELS[data.psychoWarnings]
					local lvlText = lvl and lvl.text or ("["..tostring(data.psychoWarnings).."]")
					local lvlColor = lvl and lvl.color or COLOR_CYAN
					local timerText = formatTime(data.psychoOutburst)
					self.w.psychoLine:SetText(lvlText .. "  " .. timerText)
					self.w.psychoLine:SetTintColor(toHDR(lvlColor))
				end
			end
		end)
	end
end)

----------------------------------------------------------------
-- Rebuild (for CET reinit)
----------------------------------------------------------------

hud.Rebuild = (function(self)
	self.built = false
	self.w = {}
	self:Init()
end)

return hud
