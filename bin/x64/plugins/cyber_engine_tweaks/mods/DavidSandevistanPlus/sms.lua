local sms = {}

local VIKTOR_HASH = 77701

-- Vendor zones: proximity-triggered Viktor SMS (fires once per zone per save)
-- V enters radius → Viktor sends a tip about local immunoblocker availability
local vendorZones = {
	{ id = "kabuki",
	  pos = { x = -993.0, y = 1487.0 }, radius = 200,
	  tiers = "Common + Uncommon",
	  messages = {
		"V, you're near Kabuki. There's a street medic who sets up shop in the alleys — keeps immunoblockers in stock. Common and Uncommon grade. Discreet, no questions asked. Look for the guy with the nurse scrubs and the bad attitude.",
		"Hey, since you're in Kabuki — I know a civilian medic who operates out of that market area. He carries standard and Uncommon immunoblockers. Independent, not gang-affiliated. Tell him Vik sent you.",
		"Kabuki, huh? There's a medical supplier working the back alleys near the market. Keeps Common and Uncommon immunoblockers. Quality is decent — I've checked his stock before. Better than what you'd find in Pacifica.",
	  }},
	{ id = "wellsprings",
	  pos = { x = -1450.0, y = -1230.0 }, radius = 250,
	  tiers = "Common + Uncommon",
	  messages = {
		"You're in Wellsprings. The Valentinos run a medical supply line through there — one of their intermediaries moves immunoblockers on the side. Common and Uncommon. He's reliable, just don't haggle too hard.",
		"V, Wellsprings — there's a Valentino contact who deals in medical supplies. Carries Common and Uncommon immunoblockers for the neighborhood. He's not a ripper but he knows what he's selling.",
		"Since you're in Heywood — the Valentinos have a guy in Wellsprings who moves pharmaceutical stock. Immunoblockers, Common and Uncommon grade. He keeps it quiet but the locals know where to find him.",
	  }},
	{ id = "rancho_coronado",
	  pos = { x = 1700.0, y = -830.0 }, radius = 250,
	  tiers = "Common",
	  messages = {
		"V, you're near Rancho Coronado. There's a 6th Street vet who sells medical surplus from a garage out there. Only Common grade immunoblockers — military surplus stock. Cheap but it does the job.",
		"Rancho Coronado — I know an ex-military type in the industrial zone. 6th Street guy, sells surplus medical supplies. He's got Common immunoblockers. Not fancy, but the compound is legit military stock.",
		"Since you're in Santo Domingo — there's a veteran in Rancho Coronado who moves military medical surplus. Common grade immunoblockers. He doesn't carry anything stronger but his stock is consistent.",
	  }},
	{ id = "pacifica",
	  pos = { x = -2900.0, y = -2100.0 }, radius = 300,
	  tiers = "Common",
	  messages = {
		"Pacifica. Watch yourself. There's a dealer who operates near the old resort ruins — sells Common immunoblockers. Quality is... variable. But when you're desperate, you're desperate. Only go there if you can't find anything else.",
		"V, I see you're in Pacifica. There's a street dealer out there — sketchy, but he carries Common immunoblockers. Check the expiration dates. I'm serious. Some of that Pacifica stock has been sitting in crates since before the combat zone designation.",
		"Pacifica, huh? I know a guy who sells medical supplies near West Wind. Common grade only, and I wouldn't vouch for the storage conditions. But it's better than nothing if you're in a tight spot.",
	  }},
	{ id = "japantown",
	  pos = { x = -1030.0, y = 590.0 }, radius = 200,
	  tiers = "Common + Uncommon",
	  messages = {
		"V, you're in Japantown. The Tyger Claws run a pharma supply line through the club district. One of their dealers carries Common and Uncommon immunoblockers alongside the recreational stuff. Nighttime hours, near the clubs.",
		"Japantown — the Tyger Claws have a supplier who operates near the nightlife strip. Carries immunoblockers, Common and Uncommon grade. He marks them up a bit but always has stock. Part of Fingers' distribution network.",
		"Since you're in Westbrook — there's a Tyger Claw affiliated dealer in Japantown. Works the club scene, sells Common and Uncommon immunoblockers. More commercial than the street dealers, prices to match.",
	  }},
	{ id = "arroyo",
	  pos = { x = 2050.0, y = -1720.0 }, radius = 200,
	  tiers = "Rare (Military Grade)",
	  messages = {
		"V, you're near Arroyo. I've got a contact there — trained under me, runs a clean operation. He's one of the only people in Night City who stocks Military Grade immunoblockers. Expensive, but this is the real thing.",
		"Arroyo — there's a ripperdoc there I trust. Used to be one of my students. He carries Military Grade immunoblockers. The compound is pharmaceutical-grade, same spec I use. If you need Rare, that's your source outside my clinic.",
		"Since you're near Arroyo — my colleague there keeps Military Grade immunoblockers in stock. He's discreet and the product is genuine. Only other place I'd send you besides my own clinic.",
	  }},
	{ id = "dogtown",
	  pos = { x = -2200.0, y = 540.0 }, radius = 250,
	  tiers = "Rare (Military Grade)",
	  messages = {
		"V, Dogtown. The Barghest run a black market military supply operation in there. They stock Military Grade immunoblockers — diverted from corporate medical shipments. It's expensive and they don't ask where you got the eddies. Neither should you.",
		"Dogtown — the Barghest have a supplier who moves military medical equipment. Military Grade immunoblockers included. Black market prices, but the compound is genuine mil-spec. Watch your back in there.",
		"Since you're in Dogtown — there's a Barghest arms dealer who also moves medical supplies. Military Grade immunoblockers, diverted from Militech shipments. You'll pay through the nose but it's the real thing.",
	  }},
}

function sms.attach(dsp)
	dlog('[DSP] sms.lua attached')

	-- Track which vendor zones have been discovered (persists via quest facts)
	dsp.vendorZonesDiscovered = {}

	-- Load discovered zones from quest facts on game load
	dsp.LoadVendorDiscovery = (function(self)
		local QS = Game.GetQuestsSystem()
		if not QS then return end
		for _, zone in ipairs(vendorZones) do
			local factName = "dsp_vendor_discovered_" .. zone.id
			local v = QS:GetFactStr(factName)
			self.vendorZonesDiscovered[zone.id] = (v > 0)
		end
		dlog('[DSP] Vendor discovery loaded: ' .. tostring(#vendorZones) .. ' zones')
	 end)

	-- Save a zone as discovered
	local function markZoneDiscovered(self, zoneId)
		self.vendorZonesDiscovered[zoneId] = true
		pcall(function()
			local QS = Game.GetQuestsSystem()
			QS:SetFactStr("dsp_vendor_discovered_" .. zoneId, 1)
		end)
	end

	-- Check vendor proximity (called once per ~5s from displayTick)
	dsp.vendorProximityAccum = 0
	dsp.CheckVendorProximity = (function(self)
		if not self.cfg.enableCyberpsychosis then return end
		if self.CyberPsychoWarnings < 1 then return end
		if self.CachedInMenu or self.CachedBrainDance then return end
		if not self.VIsInControl then return end

		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end
		local vPos = V:GetWorldPosition()

		for _, zone in ipairs(vendorZones) do
			if not self.vendorZonesDiscovered[zone.id] then
				local dx = vPos.x - zone.pos.x
				local dy = vPos.y - zone.pos.y
				local dist = math.sqrt(dx*dx + dy*dy)
				if dist <= zone.radius then
					-- First time near this vendor zone — Viktor sends a tip
					markZoneDiscovered(self, zone.id)
					local msg = zone.messages[math.random(#zone.messages)]
					-- Delay 30-90s so it doesn't fire immediately on zone entry
					self.pendingVendorTip = { timer = 30 + math.random(0, 60), msg = msg }
					dlog('[DSP] Vendor zone discovered: ' .. zone.id .. ' (dist=' .. string.format("%.0f", dist) .. ')')
					return  -- only one discovery per check
				end
			end
		end
	 end)

	-- Send Viktor SMS via DSPViktorBridge ScriptableSystem
	dsp.ViktorSMS = (function(self, messageText, duration)
		local ok, err = pcall(function()
			local bridge = Game.GetScriptableSystemsContainer():Get(CName.new("DSPViktorBridge"))
			if not bridge then error("DSPViktorBridge not found") end
			bridge:NotifyViktor(messageText)
			dlog('[DSP] Viktor SMS sent: ' .. messageText)
		end)

		if not ok then
			dlog('[DSP] Viktor SMS fallback (' .. tostring(err) .. '): ' .. messageText)
			local V = Game.GetPlayer()
			if V and IsDefined(V) then
				pcall(function() V:SetWarningMessage("Viktor: " .. messageText) end)
			end
		end
	 end)
end

return sms
