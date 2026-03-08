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

	local timescaleList = {
		[1]  = "0.15",    -- 85%   (Default)
		[2]  = "0.10",    -- 90%
		[3]  = "0.075",   -- 92.5%
		[4]  = "0.05",    -- 95%
		[5]  = "0.025",   -- 97.5%
		[6]  = "0.01",    -- 99%
		[7]  = "0.0075",  -- 99.25%
		[8]  = "0.0065",  -- 99.35% (Recommended limit)
		[9]  = "0.005",   -- 99.5%
		[10] = "0.0035",  -- 99.65%
		[11] = "0.001",   -- 99.9%
	}

	nativeSettings.addSelectorString(
		catTD,
		"Time Dilation Speed",
		"Base time scale while Sandevistan is active. Lower = slower time.\n"
			.. "Default: 0.15 (85% slowdown).\n"
			.. "Recommended limit: 0.0065 (99.35%). Values below may cause visual glitches.\n"
			.. "Safety Off and Overclock still stack on top of this.",
		timescaleList,
		cfg.timedilationOption,
		defaults.timedilationOption,
		function(value)
			cfg.timedilationOption = value
			cfg.timedilationSpeed = tonumber(timescaleList[value])
			setTweaks()
			saveConfig()
		end)

	------------------------------------------------------------
	-- DURATION & COOLDOWN
	------------------------------------------------------------
	nativeSettings.addSubcategory(catDC, "Duration & Cooldown")

	nativeSettings.addRangeInt(
		catDC,
		"Sandevistan Duration (sec)",
		"How long the Sandevistan stays active in seconds.",
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
		"Time in seconds for the Sandevistan to recharge.",
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
		"Base cooldown multiplier for the Sandevistan.",
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
		"Stamina cost to activate the Sandevistan. Set to 0 to remove.",
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
		"Sandevistan recharge gained per kill.",
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
		"Bonus crit chance while Sandevistan is active.",
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
		"Bonus crit damage while Sandevistan is active.",
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
		"Multiplier applied to headshot damage during Sandevistan.",
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
		"Percentage of health restored when killing an enemy.",
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
		"Stamina restored when killing an enemy.",
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
