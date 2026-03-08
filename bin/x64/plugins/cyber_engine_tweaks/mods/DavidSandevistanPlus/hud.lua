local hud = {}

hud.Apogee = nil
hud.healthbarCtrl = nil
hud.staminabarCtrl = nil
hud.staminabarRoot = nil
hud.built = false

-- Widget references
hud.w = {}

-- Layout constants
local BAR_WIDTH = 420
local BAR_HEIGHT = 10
local ROW_GAP = 6
local FONT_SIZE_MAIN = 30
local FONT_SIZE_SMALL = 24
local PANEL_TOP_MARGIN = 20
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
	local cn = CName.new(str)
	if cn.value ~= str then
		CName.add(str)
		cn = CName.new(str)
	end
	return cn
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

local function psychoColor(ratio)
	if ratio > 0.5 then
		return lerpColor(COLOR_YELLOW, COLOR_CYAN, (ratio - 0.5) * 2)
	else
		return lerpColor(COLOR_MAGENTA, COLOR_YELLOW, ratio * 2)
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
-- Widget creation helpers
----------------------------------------------------------------

local function createCanvas(parent, name, marginTop)
	local w = parent:AddChild("inkCanvasWidget")
	w:SetName(CNameNew(name))
	w:SetMargin(0, marginTop or 0, 0, 0)
	w:SetAnchor(inkEAnchor.TopLeft)
	w:SetAnchorPoint(0.0, 0.0)
	return w
end

local function createRect(parent, name, width, height, color)
	local w = parent:AddChild("inkRectangleWidget")
	w:SetName(CNameNew(name))
	w:SetSize(width, height)
	w:SetAnchor(inkEAnchor.TopLeft)
	w:SetAnchorPoint(0.0, 0.0)
	w:SetTintColor(toHDR(color))
	w:SetVisible(true)
	return w
end

local function createText(parent, name, fontSize, color, hAlign)
	local w = parent:AddChild("inkTextWidget")
	w:SetName(CNameNew(name))
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
	return w
end

----------------------------------------------------------------
-- Init: find game controllers
----------------------------------------------------------------

hud.Init = (function(self, Apogee, doDebug)
	if Apogee ~= nil then
		self.Apogee = Apogee
	end

	local inkSystem = GameInstance.GetInkSystem()
	local layers = inkSystem:GetLayers()
	for _, layer in pairs(layers) do
		local layerName = tostring(layer:GetLayerName().value)
		if layerName == "inkHUDLayer" then
			for _, controller in pairs(layer:GetGameControllers()) do
				local cn = controller:GetClassName().value
				if cn == "gameuiHudHealthbarGameController" then
					self.healthbarCtrl = controller
				elseif cn == "StaminabarWidgetGameController" then
					self.staminabarCtrl = controller
					self.staminabarRoot = controller:GetRootCompoundWidget()
				end
			end
		end
	end

	self:Build()
end)

----------------------------------------------------------------
-- Build: create all widgets once
----------------------------------------------------------------

hud.Build = (function(self)
	if self.healthbarCtrl == nil or not IsDefined(self.healthbarCtrl) then return end
	if self.built then return end

	local RCW = self.healthbarCtrl:GetRootCompoundWidget()
	local buffsHolder = RCW:GetWidgetByPathName("buffsHolder")
	local barsLayout = buffsHolder:GetWidgetByPathName("barsLayout")

	-- Remove old panel if exists
	local oldPanel = barsLayout:GetWidgetByPathName("DavidMartinezPanel")
	if oldPanel ~= nil then
		barsLayout:RemoveChild(oldPanel)
	end

	local TextMargin = (self.Apogee and self.Apogee.OverrideTextMargin) or PANEL_TOP_MARGIN
	local panel = createCanvas(barsLayout, "DavidMartinezPanel", TextMargin)
	self.w.panel = panel

	-- Row 1: Runtime bar + dilation text
	local row1 = createCanvas(panel, "DSP_Row1", 0)
	self.w.row1 = row1
	self.w.runtimeBg   = createRect(row1, "DSP_RuntimeBg", BAR_WIDTH, BAR_HEIGHT, COLOR_BG)
	self.w.runtimeFill = createRect(row1, "DSP_RuntimeFill", BAR_WIDTH, BAR_HEIGHT, COLOR_GREEN)
	self.w.runtimeText = createText(row1, "DSP_RuntimeText", FONT_SIZE_SMALL, COLOR_WHITE, textHorizontalAlignment.Left)
	self.w.runtimeText:SetMargin(4, BAR_HEIGHT + 4, 0, 0)
	self.w.dilationText = createText(row1, "DSP_DilationText", FONT_SIZE_MAIN, COLOR_WHITE, textHorizontalAlignment.Left)
	self.w.dilationText:SetMargin(BAR_WIDTH + 14, -4, 0, 0)

	-- Row 2: Status line (activations + context + recharge)
	local row2Y = BAR_HEIGHT + FONT_SIZE_SMALL + 16
	local row2 = createCanvas(panel, "DSP_Row2", row2Y)
	self.w.row2 = row2
	self.w.activationsText = createText(row2, "DSP_Activations", FONT_SIZE_SMALL, COLOR_DIM, textHorizontalAlignment.Left)
	self.w.statusText = createText(row2, "DSP_Status", FONT_SIZE_SMALL, COLOR_WHITE, textHorizontalAlignment.Left)
	self.w.statusText:SetMargin(100, 0, 0, 0)

	-- Row 3: Psycho bar + level + timer (hidden by default)
	local row3Y = row2Y + FONT_SIZE_SMALL + 14
	local row3 = createCanvas(panel, "DSP_Row3", row3Y)
	self.w.row3 = row3
	self.w.psychoBg    = createRect(row3, "DSP_PsychoBg", BAR_WIDTH, BAR_HEIGHT, COLOR_BG)
	self.w.psychoFill  = createRect(row3, "DSP_PsychoFill", BAR_WIDTH, BAR_HEIGHT, COLOR_CYAN)
	self.w.psychoLevel = createText(row3, "DSP_PsychoLevel", FONT_SIZE_SMALL, COLOR_CYAN, textHorizontalAlignment.Left)
	self.w.psychoLevel:SetMargin(4, BAR_HEIGHT + 4, 0, 0)
	self.w.psychoTimer = createText(row3, "DSP_PsychoTimer", FONT_SIZE_SMALL, COLOR_DIM, textHorizontalAlignment.Left)
	self.w.psychoTimer:SetMargin(BAR_WIDTH + 14, BAR_HEIGHT + 4, 0, 0)
	row3:SetVisible(false)

	self.built = true
end)

----------------------------------------------------------------
-- Update: refresh all widgets each tick
----------------------------------------------------------------

hud.Update = (function(self, data)
	if not self.built then
		self:Build()
		if not self.built then return end
	end

	-- Visibility: hide everything if not wearing Sandy or UI disabled
	if not data.isWearing or not data.showUI then
		self.w.panel:SetVisible(false)
		self:SetStaminaMargin(0)
		return
	end
	self.w.panel:SetVisible(true)

	-- Row 1: Runtime bar
	local maxRT = data.MaxRunTime
	if maxRT <= 0 then maxRT = 1 end
	local ratio = data.runTime / maxRT
	if ratio < 0 then ratio = 0 end
	if ratio > 1 then ratio = 1 end

	local fillWidth = math.floor(BAR_WIDTH * ratio)
	if fillWidth < 1 and data.runTime > 0 then fillWidth = 1 end
	self.w.runtimeFill:SetSize(fillWidth, BAR_HEIGHT)
	self.w.runtimeFill:SetTintColor(toHDR(runtimeColor(ratio)))

	local rtText = tostring(math.floor(data.runTime)) .. "/" .. tostring(maxRT) .. "s"
	if data.rechargeNotification and data.rechargeNotification > 0 then
		rtText = "+" .. tostring(data.rechargeNotification) .. "s  " .. rtText
		self.w.runtimeText:SetTintColor(toHDR(COLOR_GREEN))
	else
		self.w.runtimeText:SetTintColor(toHDR(COLOR_WHITE))
	end
	self.w.runtimeText:SetText(rtText)

	-- Dilation %
	local dilText = tostring(data.dilation) .. "%"
	self.w.dilationText:SetText(dilText)
	if data.isRunning then
		self.w.dilationText:SetTintColor(toHDR(COLOR_WHITE))
	else
		self.w.dilationText:SetTintColor(toHDR(COLOR_DIM))
	end

	-- Row 2: Activations + contextual status
	local actText = data.dailyActivations .. "/" .. data.dailySafe
	local actColor = COLOR_DIM
	if data.dailyActivations > data.dailySafe then
		actText = actText .. " OVERUSE"
		actColor = COLOR_ORANGE
	end
	self.w.activationsText:SetText(actText)
	self.w.activationsText:SetTintColor(toHDR(actColor))

	local status = ""
	local statusColor = COLOR_WHITE
	if not data.SafetyOn then
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

	-- Row 3: Psycho bar (only visible when psychoWarnings > 0)
	local showPsycho = data.psychoWarnings > 0 and data.psychoOutburst ~= nil
	self.w.row3:SetVisible(showPsycho)

	if showPsycho then
		local pRatio = data.psychoOutburst / 3600
		if pRatio < 0 then pRatio = 0 end
		if pRatio > 1 then pRatio = 1 end

		local pFillWidth = math.floor(BAR_WIDTH * pRatio)
		if pFillWidth < 1 and data.psychoOutburst > 0 then pFillWidth = 1 end
		self.w.psychoFill:SetSize(pFillWidth, BAR_HEIGHT)
		self.w.psychoFill:SetTintColor(toHDR(psychoColor(pRatio)))

		local lvl = PSYCHO_LEVELS[data.psychoWarnings]
		if lvl then
			self.w.psychoLevel:SetText(lvl.text)
			self.w.psychoLevel:SetTintColor(toHDR(lvl.color))
		end

		self.w.psychoTimer:SetText(formatTime(data.psychoOutburst))
	end

	-- Stamina bar margin (matches row positions from Build)
	local margin = BAR_HEIGHT + FONT_SIZE_SMALL + 16 + FONT_SIZE_SMALL + 8
	if showPsycho then
		margin = margin + 14 + BAR_HEIGHT + FONT_SIZE_SMALL + 8
	end
	self:SetStaminaMargin(margin)
end)

----------------------------------------------------------------
-- Stamina bar margin
----------------------------------------------------------------

hud.SetStaminaMargin = (function(self, baseMargin)
	if self.Apogee and self.Apogee.ForceStaminaMargin then
		baseMargin = self.Apogee.ForceStaminaMargin
	elseif self.Apogee and self.Apogee.OverrideStaminaMargin then
		baseMargin = self.Apogee.OverrideStaminaMargin
	end
	if self.staminabarRoot ~= nil and IsDefined(self.staminabarRoot) then
		self.staminabarRoot:SetMargin(0, baseMargin, 0, 0)
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
