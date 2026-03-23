-- voice.lua — Voice line playback system for David Sandevistan Plus
-- Plays generated voice lines via Audioware when messages are displayed.
-- Gender detection: uses V's gender to select male/female voice bank.

local voice = {}

voice.enabled = true
voice.gender = nil  -- "vm" or "vf", detected on init

----------------------------------------------------------------
-- Gender detection
----------------------------------------------------------------

voice.DetectGender = (function(self)
	local ok, result = pcall(function()
		local V = Game.GetPlayer()
		if not IsDefined(V) then return nil end
		local gender = V:GetResolvedGenderName()
		if gender == CName.new("Female") then
			return "vf"
		end
		return "vm"
	end)
	if ok and result then
		self.gender = result
	else
		self.gender = "vm"
	end
end)

----------------------------------------------------------------
-- Playback
----------------------------------------------------------------

voice.Play = (function(self, lineId, hud)
	if not self.enabled then return end
	if not hud then return end
	if not self.gender then self:DetectGender() end

	-- Build Audioware event name: dsp_vm_psycho4_01 or dsp_vf_psycho4_01
	local eventName = "dsp_" .. self.gender .. "_" .. lineId
	hud:PlayVoiceLine(eventName)
end)

voice.Stop = (function(self, hud)
	if hud then
		hud:StopVoiceLine()
	end
end)

return voice
