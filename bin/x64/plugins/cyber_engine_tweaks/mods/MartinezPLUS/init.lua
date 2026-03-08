-- MartinezPLUS - Tuner for David's Apogee (Martinez Sandevistan)
-- Requires: nativeSettings, DavidsApogee

local RecordName = "Items.MartinezSandevistanPlusPlus"

local defaults = {
	timedilationSpeed = 0.15,
	timedilationOption = 1,
	sandyDuration = 300,
	rechargeDuration = 2.0,
	cooldownBase = 1.0,
	enterCost = 0.1,
	killRechargeValue = 0.0,
	critChance = 20,
	critDamage = 20,
	headshotDamageMultiplier = 1.2,
	healOnKill = 5,
	staminaOnKill = 22.0,
}

local cfg = {}
for k, v in pairs(defaults) do cfg[k] = v end

local configFile = "config.json"
local nativeSettings = nil

-- Persistence

local function loadConfig()
	local file = io.open(configFile, "r")
	if file ~= nil then
		local ok, loaded = pcall(json.decode, file:read("*a"))
		file:close()
		if ok and type(loaded) == "table" then
			for k, v in pairs(loaded) do cfg[k] = v end
		end
	end
	cfg.timedilationSpeed = tonumber(cfg.timedilationSpeed) or defaults.timedilationSpeed
end

local function saveConfig()
	local toSave = {}
	for k, v in pairs(cfg) do toSave[k] = v end
	toSave.timedilationSpeed = string.format("%.8f", cfg.timedilationSpeed)
	local file = io.open(configFile, "w")
	if file ~= nil then
		file:write(json.encode(toSave))
		file:close()
	end
end

-- TweakDB

local function setFlatAndUpdate(name, value)
	TweakDB:SetFlat(name, value)
	TweakDB:Update(name)
end

local function setTweaks()
	if type(cfg.timedilationSpeed) == "string" then
		cfg.timedilationSpeed = tonumber(cfg.timedilationSpeed)
	end

	-- Time Dilation
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_04.value", cfg.timedilationSpeed)

	-- Duration & Cooldown
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_03.value", cfg.sandyDuration * 1.0)
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_05.value", cfg.rechargeDuration * 1.0)
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_06.value", cfg.cooldownBase * 1.0)
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_07.value", cfg.killRechargeValue * 1.0)
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_08.value", cfg.enterCost * 1.0)

	-- Combat Stats
	setFlatAndUpdate(RecordName .. "_Equip3_SM1.value", cfg.critChance * 1.0)
	setFlatAndUpdate(RecordName .. "_Equip3_SM2.value", cfg.critDamage * 1.0)
	setFlatAndUpdate(RecordName .. "_Equip3_SM3.value", cfg.headshotDamageMultiplier * 1.0)

	-- On-Kill Effects
	setFlatAndUpdate(RecordName .. "_Equip4_SPU1.statPoolValue", cfg.healOnKill * 1.0)
	setFlatAndUpdate(RecordName .. "_Equip4_SPU2.statPoolValue", cfg.staminaOnKill * 1.0)
end

-- UI

local function initUI()
	nativeSettings = GetMod("nativeSettings")
	if nativeSettings == nil then
		print("[MartinezPLUS] nativeSettings not found!")
		return
	end

	local tab = "/MartinezPLUS"
	local catTD = tab .. "/TimeDilation"
	local catDC = tab .. "/DurationCooldown"
	local catCS = tab .. "/CombatStats"
	local catOK = tab .. "/OnKill"

	if not nativeSettings.pathExists(tab) then
		nativeSettings.addTab(tab, "Martinez Sandy+")
	end

	-- Clean previous subcategories on CET reload
	for _, path in ipairs({catTD, catDC, catCS, catOK}) do
		if nativeSettings.pathExists(path) then
			nativeSettings.removeSubcategory(path)
		end
	end

	------------------------------------------------------------
	-- TIME DILATION
	------------------------------------------------------------
	nativeSettings.addSubcategory(catTD, "Time Dilation")

	local timescaleData = {
		{ label = "85% (Default)",          value = 0.15   },
		{ label = "90%",                    value = 0.10   },
		{ label = "92.5%",                  value = 0.075  },
		{ label = "95%",                    value = 0.05   },
		{ label = "97.5%",                  value = 0.025  },
		{ label = "99%",                    value = 0.01   },
		{ label = "99.25%",                 value = 0.0075 },
		{ label = "99.35% (Recommended)",   value = 0.0065 },
		{ label = "99.5%",                  value = 0.005  },
		{ label = "99.65%",                 value = 0.0035 },
		{ label = "99.9%",                  value = 0.001  },
	}

	local timescaleLabels = {}
	local timescaleValues = {}
	for i, opt in ipairs(timescaleData) do
		timescaleLabels[i] = opt.label
		timescaleValues[i] = opt.value
	end

	nativeSettings.addSelectorString(
		catTD,
		"Time Dilation Speed",
		"How much time slows down while Sandevistan is active. Higher % = slower.\n"
			.. "Default: 85%. Recommended limit: 99.35%.\n"
			.. "Values above 99.35% may cause visual glitches.\n"
			.. "Safety Off and Overclock still stack on top of this.",
		timescaleLabels,
		cfg.timedilationOption,
		defaults.timedilationOption,
		function(value)
			cfg.timedilationOption = value
			cfg.timedilationSpeed = timescaleValues[value]
			setTweaks()
			saveConfig()
		end)

	------------------------------------------------------------
	-- DURATION & COOLDOWN
	------------------------------------------------------------
	nativeSettings.addSubcategory(catDC, "Duration & Cooldown")

	nativeSettings.addRangeInt(
		catDC,
		"Runtime Tank (sec)",
		"Total runtime reservoir for the Sandevistan in seconds. (Default: 300)\n"
			.. "This is NOT real-time duration. It drains at different rates:\n"
			.. "Normal: 1s/tick | Safety Off: 5s/tick | Overclock: 33% reduced.\n"
			.. "Recharges by sleeping, visiting ripperdocs, or staying in safe zones.",
		1, 600, 1,
		cfg.sandyDuration,
		defaults.sandyDuration,
		function(value)
			cfg.sandyDuration = value
			setTweaks()
			saveConfig()
		end)

	nativeSettings.addRangeFloat(
		catDC,
		"Recharge Duration",
		"Base recharge time in seconds after Sandevistan deactivates. (Default: 2.0)",
		0.5, 30.0, 0.5, "%.1f",
		cfg.rechargeDuration,
		defaults.rechargeDuration,
		function(value)
			cfg.rechargeDuration = value
			setTweaks()
			saveConfig()
		end)

	nativeSettings.addRangeFloat(
		catDC,
		"Cooldown Base",
		"Base cooldown multiplier after Sandevistan deactivates. (Default: 1.0)\n"
			.. "Lower values = shorter cooldown between activations.",
		0.1, 10.0, 0.1, "%.1f",
		cfg.cooldownBase,
		defaults.cooldownBase,
		function(value)
			cfg.cooldownBase = value
			setTweaks()
			saveConfig()
		end)

	nativeSettings.addRangeFloat(
		catDC,
		"Activation Cost",
		"Stamina cost when activating the Sandevistan. (Default: 0.1)\n"
			.. "Set to 0 to remove the activation cost entirely.\n"
			.. "With Adrenaline Rush enabled, this cost is shunted through V's chip instead.",
		0.0, 1.0, 0.05, "%.2f",
		cfg.enterCost,
		defaults.enterCost,
		function(value)
			cfg.enterCost = value
			setTweaks()
			saveConfig()
		end)

	nativeSettings.addRangeFloat(
		catDC,
		"Kill Recharge Value",
		"Runtime recharged per enemy killed while Sandevistan is active. (Default: 0.0)",
		0.0, 50.0, 0.5, "%.1f",
		cfg.killRechargeValue,
		defaults.killRechargeValue,
		function(value)
			cfg.killRechargeValue = value
			setTweaks()
			saveConfig()
		end)

	------------------------------------------------------------
	-- COMBAT STATS (active during Sandevistan)
	------------------------------------------------------------
	nativeSettings.addSubcategory(catCS, "Combat Stats (while Sandy active)")

	nativeSettings.addRangeInt(
		catCS,
		"Critical Chance",
		"Bonus critical hit chance while Sandevistan is active. (Default: 20)\n"
			.. "Only applies during time dilation, requires TimeDilation PSM prereq.",
		0, 100, 1,
		cfg.critChance,
		defaults.critChance,
		function(value)
			cfg.critChance = value
			setTweaks()
			saveConfig()
		end)

	nativeSettings.addRangeInt(
		catCS,
		"Critical Damage",
		"Bonus critical hit damage while Sandevistan is active. (Default: 20)\n"
			.. "Only applies during time dilation, requires TimeDilation PSM prereq.",
		0, 500, 1,
		cfg.critDamage,
		defaults.critDamage,
		function(value)
			cfg.critDamage = value
			setTweaks()
			saveConfig()
		end)

	nativeSettings.addRangeFloat(
		catCS,
		"Headshot Damage Multiplier",
		"Multiplier for headshot damage during Sandevistan. (Default: 1.2)\n"
			.. "1.2 = 20% bonus headshot damage. Uses Cool stat scaling.",
		1.0, 5.0, 0.1, "%.1f",
		cfg.headshotDamageMultiplier,
		defaults.headshotDamageMultiplier,
		function(value)
			cfg.headshotDamageMultiplier = value
			setTweaks()
			saveConfig()
		end)

	------------------------------------------------------------
	-- ON-KILL EFFECTS
	------------------------------------------------------------
	nativeSettings.addSubcategory(catOK, "On-Kill Effects (while Sandy active)")

	nativeSettings.addRangeFloat(
		catOK,
		"Heal on Kill (%)",
		"Percentage of V's health restored per kill during Sandevistan. (Default: 5)\n"
			.. "Replaces the standard duration-on-kill since Martinez has infinite duration.",
		0.0, 50.0, 0.5, "%.1f",
		cfg.healOnKill,
		defaults.healOnKill,
		function(value)
			cfg.healOnKill = value
			setTweaks()
			saveConfig()
		end)

	nativeSettings.addRangeFloat(
		catOK,
		"Stamina on Kill",
		"Stamina restored per kill during Sandevistan. (Default: 22)\n"
			.. "Triggered by any takedown or kill while time dilation is active.",
		0.0, 100.0, 1.0, "%.0f",
		cfg.staminaOnKill,
		defaults.staminaOnKill,
		function(value)
			cfg.staminaOnKill = value
			setTweaks()
			saveConfig()
		end)
end

registerForEvent("onInit", function()
	loadConfig()
	initUI()
	setTweaks()
end)
