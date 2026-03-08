-- MartinezPLUS - Tuner for David Sandevistan Plus
-- Requires: nativeSettings, DavidSandevistanPlus

local RecordName = "Items.MartinezSandevistanPlusPlus"
local apogeeConfigFile = "../DavidSandevistanPlus/config.json"

local defaults = {
	-- TweakDB values
	timedilationSpeed = 0.10,
	timedilationOption = 2,
	sandyDuration = 300,
	rechargeDuration = 2.0,
	cooldownBase = 0.5,
	enterCost = 0.0,
	killRechargeValue = 2.0,
	critChance = 30,
	critDamage = 35,
	headshotDamageMultiplier = 1.5,
	healOnKill = 3,
	staminaOnKill = 22.0,

	-- Gameplay (mirrored from DavidsApogee cfg)
	enableHealthDrain = true,
	damageMin = 1.0,
	damageMax = 15.0,
	safetyOffExtraDamage = 5,
	enableHealthBrake = false,
	healthBrakeDefault = 50,
	requiredHealthMin = 15,
	safetyOffDrainMultiplier = 4,
	enableSafetyOffKill = true,
	safetyOffKillThreshold = 2,
	fullRechargeHours = 16,
	maxRechargePerSleep = 10,
	enableCyberpsychosis = true,
	dailySafeActivations = 3,
	psychoAccelPerExtraUse = 30,
	requireEdgeRunnerPerk = false,
	tickLength = 1.25,
}

local cfg = {}
for k, v in pairs(defaults) do cfg[k] = v end

local nativeSettings = nil

-- Gameplay keys that DavidsApogee reads from config.json
local gameplayKeys = {
	"enableHealthDrain", "damageMin", "damageMax", "safetyOffExtraDamage",
	"enableHealthBrake", "healthBrakeDefault", "requiredHealthMin",
	"safetyOffDrainMultiplier", "enableSafetyOffKill", "safetyOffKillThreshold",
	"fullRechargeHours", "maxRechargePerSleep", "enableCyberpsychosis",
	"dailySafeActivations", "psychoAccelPerExtraUse",
	"requireEdgeRunnerPerk", "tickLength",
}

-- Persistence

local function loadConfig()
	local file = io.open(apogeeConfigFile, "r")
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
	local file = io.open(apogeeConfigFile, "w")
	if file ~= nil then
		file:write(json.encode(toSave))
		file:close()
	end
end

-- Apply gameplay cfg to DavidsApogee at runtime (if global is available)
local function applyGameplayCfg()
	if davidsapogee and davidsapogee.cfg then
		for _, key in ipairs(gameplayKeys) do
			davidsapogee.cfg[key] = cfg[key]
		end
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

	setFlatAndUpdate(RecordName .. "_Stat_Modifier_04.value", cfg.timedilationSpeed)
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_03.value", cfg.sandyDuration * 1.0)
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_05.value", cfg.rechargeDuration * 1.0)
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_06.value", cfg.cooldownBase * 1.0)
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_07.value", cfg.killRechargeValue * 1.0)
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_08.value", cfg.enterCost * 1.0)
	setFlatAndUpdate(RecordName .. "_Equip3_SM1.value", cfg.critChance * 1.0)
	setFlatAndUpdate(RecordName .. "_Equip3_SM2.value", cfg.critDamage * 1.0)
	setFlatAndUpdate(RecordName .. "_Equip3_SM3.value", cfg.headshotDamageMultiplier * 1.0)
	setFlatAndUpdate(RecordName .. "_Equip4_SPU1.statPoolValue", cfg.healOnKill * 1.0)
	setFlatAndUpdate(RecordName .. "_Equip4_SPU2.statPoolValue", cfg.staminaOnKill * 1.0)
end

-- Helper: save + apply all
local function applyAll()
	setTweaks()
	applyGameplayCfg()
	saveConfig()
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
	local catHD = tab .. "/HealthDrain"
	local catHB = tab .. "/HealthBrake"
	local catSO = tab .. "/SafetyOff"
	local catRC = tab .. "/Recharge"
	local catCP = tab .. "/Cyberpsychosis"
	local catPG = tab .. "/PerkGates"

	if not nativeSettings.pathExists(tab) then
		nativeSettings.addTab(tab, "Martinez Sandy+")
	end

	for _, path in ipairs({catTD, catDC, catCS, catOK, catHD, catHB, catSO, catRC, catCP, catPG}) do
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
			.. "Default: 90% (lore-accurate ~10x speed factor). Recommended limit: 99.35%.\n"
			.. "Values above 99.35% may cause visual glitches.\n"
			.. "Safety Off and Overclock still stack on top of this.",
		timescaleLabels,
		cfg.timedilationOption,
		defaults.timedilationOption,
		function(value)
			cfg.timedilationOption = value
			cfg.timedilationSpeed = timescaleValues[value]
			applyAll()
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
			applyAll()
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
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catDC,
		"Cooldown Base",
		"Base cooldown multiplier after Sandevistan deactivates. (Default: 0.5)\n"
			.. "Lower values = shorter cooldown between activations.",
		0.1, 10.0, 0.1, "%.1f",
		cfg.cooldownBase,
		defaults.cooldownBase,
		function(value)
			cfg.cooldownBase = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catDC,
		"Activation Cost",
		"Stamina cost when activating the Sandevistan. (Default: 0.0)\n"
			.. "Lore: David activated with no visible cost — the toll was cumulative (cyberpsychosis).\n"
			.. "With Adrenaline Rush enabled, this cost is shunted through V's chip instead.",
		0.0, 1.0, 0.05, "%.2f",
		cfg.enterCost,
		defaults.enterCost,
		function(value)
			cfg.enterCost = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catDC,
		"Kill Recharge Value",
		"Runtime recharged per enemy killed while Sandevistan is active. (Default: 2.0)\n"
			.. "Lore: David was fueled by combat adrenaline — each kill kept him going.",
		0.0, 50.0, 0.5, "%.1f",
		cfg.killRechargeValue,
		defaults.killRechargeValue,
		function(value)
			cfg.killRechargeValue = value
			applyAll()
		end)

	------------------------------------------------------------
	-- COMBAT STATS (active during Sandevistan)
	------------------------------------------------------------
	nativeSettings.addSubcategory(catCS, "Combat Stats (while Sandy active)")

	nativeSettings.addRangeInt(
		catCS,
		"Critical Chance",
		"Bonus critical hit chance while Sandevistan is active. (Default: 30)\n"
			.. "Only applies during time dilation, requires TimeDilation PSM prereq.",
		0, 100, 1,
		cfg.critChance,
		defaults.critChance,
		function(value)
			cfg.critChance = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catCS,
		"Critical Damage",
		"Bonus critical hit damage while Sandevistan is active. (Default: 35)\n"
			.. "Only applies during time dilation, requires TimeDilation PSM prereq.",
		0, 500, 1,
		cfg.critDamage,
		defaults.critDamage,
		function(value)
			cfg.critDamage = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catCS,
		"Headshot Damage Multiplier",
		"Multiplier for headshot damage during Sandevistan. (Default: 1.5)\n"
			.. "1.5 = 50% bonus headshot damage. Uses Cool stat scaling.",
		1.0, 5.0, 0.1, "%.1f",
		cfg.headshotDamageMultiplier,
		defaults.headshotDamageMultiplier,
		function(value)
			cfg.headshotDamageMultiplier = value
			applyAll()
		end)

	------------------------------------------------------------
	-- ON-KILL EFFECTS
	------------------------------------------------------------
	nativeSettings.addSubcategory(catOK, "On-Kill Effects (while Sandy active)")

	nativeSettings.addRangeFloat(
		catOK,
		"Heal on Kill (%)",
		"Percentage of V's health restored per kill during Sandevistan. (Default: 3)\n"
			.. "Replaces the standard duration-on-kill since Martinez has infinite duration.",
		0.0, 50.0, 0.5, "%.1f",
		cfg.healOnKill,
		defaults.healOnKill,
		function(value)
			cfg.healOnKill = value
			applyAll()
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
			applyAll()
		end)

	------------------------------------------------------------
	-- HEALTH DRAIN
	------------------------------------------------------------
	nativeSettings.addSubcategory(catHD, "Health Drain")

	nativeSettings.addSwitch(
		catHD,
		"Enable Health Drain",
		"Toggle whether the Sandevistan drains V's health over time. (Default: ON)\n"
			.. "When OFF, the Sandy has no health cost at all.",
		cfg.enableHealthDrain,
		defaults.enableHealthDrain,
		function(value)
			cfg.enableHealthDrain = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catHD,
		"Minimum Damage per Tick (%)",
		"Health drained per tick at full runtime (just activated). (Default: 1.0)\n"
			.. "Damage scales up from this value toward maximum as runtime depletes.",
		0.0, 10.0, 0.1, "%.1f",
		cfg.damageMin,
		defaults.damageMin,
		function(value)
			cfg.damageMin = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catHD,
		"Maximum Damage per Tick (%)",
		"Health drained per tick at zero runtime (fully depleted). (Default: 15.0)\n"
			.. "At 5 minutes of use the Sandy takes ~20% health every 2.5s at default settings.",
		0.0, 50.0, 0.5, "%.1f",
		cfg.damageMax,
		defaults.damageMax,
		function(value)
			cfg.damageMax = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catHD,
		"Safety Off Extra Damage",
		"Extra damage per tick when Safety Limiters are OFF. (Default: 5)\n"
			.. "Added on top of the normal scaled damage. Higher = more punishing.",
		0.0, 20.0, 0.5, "%.1f",
		cfg.safetyOffExtraDamage,
		defaults.safetyOffExtraDamage,
		function(value)
			cfg.safetyOffExtraDamage = value
			applyAll()
		end)

	------------------------------------------------------------
	-- HEALTH BRAKE
	------------------------------------------------------------
	nativeSettings.addSubcategory(catHB, "Health Brake (Emergency Stop)")

	nativeSettings.addSwitch(
		catHB,
		"Enable Health Brake",
		"Auto-stop Sandevistan when V's health gets too low. (Default: OFF)\n"
			.. "When ON, the Sandy stops itself when health drops below threshold.\n"
			.. "Lore-accurate: David never had an auto-stop — he pushed to the edge.",
		cfg.enableHealthBrake,
		defaults.enableHealthBrake,
		function(value)
			cfg.enableHealthBrake = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catHB,
		"Health Brake Threshold (%)",
		"Default health percentage where the brake activates. (Default: 50)\n"
			.. "With Netrunner Port, this becomes user-configurable in the CET diagnostics.\n"
			.. "Without, it scales from 15% to this value based on remaining runtime.",
		15, 80, 1,
		cfg.healthBrakeDefault,
		defaults.healthBrakeDefault,
		function(value)
			cfg.healthBrakeDefault = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catHB,
		"Minimum Required Health (%)",
		"Absolute minimum health threshold before brake kicks in. (Default: 15)\n"
			.. "Even if scaled damage is low, brake won't trigger below this.",
		5, 50, 1,
		cfg.requiredHealthMin,
		defaults.requiredHealthMin,
		function(value)
			cfg.requiredHealthMin = value
			applyAll()
		end)

	------------------------------------------------------------
	-- SAFETY OFF
	------------------------------------------------------------
	nativeSettings.addSubcategory(catSO, "Safety Limiters Off")

	nativeSettings.addRangeInt(
		catSO,
		"Runtime Drain Multiplier",
		"Extra runtime ticks consumed per cycle with Safety OFF. (Default: 4)\n"
			.. "Total drain = 1 + this value. Default 4 means 6.25s/tick total.\n"
			.. "Set to 0 for same drain rate as Safety ON.",
		0, 10, 1,
		cfg.safetyOffDrainMultiplier,
		defaults.safetyOffDrainMultiplier,
		function(value)
			cfg.safetyOffDrainMultiplier = value
			applyAll()
		end)

	nativeSettings.addSwitch(
		catSO,
		"V Can Die (Safety Off)",
		"Allow V to die when Safety is OFF and health is fully depleted. (Default: ON)\n"
			.. "When OFF, V survives but the Sandy still deactivates.",
		cfg.enableSafetyOffKill,
		defaults.enableSafetyOffKill,
		function(value)
			cfg.enableSafetyOffKill = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catSO,
		"Kill Threshold (%)",
		"Health percentage at which V dies with Safety OFF. (Default: 2)\n"
			.. "Only applies when 'V Can Die' is enabled.",
		1, 15, 1,
		cfg.safetyOffKillThreshold,
		defaults.safetyOffKillThreshold,
		function(value)
			cfg.safetyOffKillThreshold = value
			applyAll()
		end)

	------------------------------------------------------------
	-- RECHARGE
	------------------------------------------------------------
	nativeSettings.addSubcategory(catRC, "Recharge & Sleep")

	nativeSettings.addRangeInt(
		catRC,
		"Full Recharge Hours",
		"Total hours of sleep needed to fully recharge the Sandevistan. (Default: 16)\n"
			.. "Spread across multiple sleep sessions (see Max Recharge per Sleep).",
		1, 48, 1,
		cfg.fullRechargeHours,
		defaults.fullRechargeHours,
		function(value)
			cfg.fullRechargeHours = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catRC,
		"Max Recharge per Sleep",
		"Maximum hours of recharge credited per single sleep. (Default: 10)\n"
			.. "With defaults: 2 sleeps of 8h each = 16h = full recharge.",
		1, 24, 1,
		cfg.maxRechargePerSleep,
		defaults.maxRechargePerSleep,
		function(value)
			cfg.maxRechargePerSleep = value
			applyAll()
		end)

	------------------------------------------------------------
	-- CYBERPSYCHOSIS
	------------------------------------------------------------
	nativeSettings.addSubcategory(catCP, "Cyberpsychosis")

	nativeSettings.addSwitch(
		catCP,
		"Enable Cyberpsychosis",
		"Toggle the entire Cyberpsychosis system. (Default: ON)\n"
			.. "When OFF: no psycho warnings, no psycho episodes, no NPC frightening.\n"
			.. "Bleeding effects and Sandy shutdown still happen, but without psycho escalation.",
		cfg.enableCyberpsychosis,
		defaults.enableCyberpsychosis,
		function(value)
			cfg.enableCyberpsychosis = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catCP,
		"Safe Activations per Day",
		"How many times V can activate the Sandevistan per day before psycho acceleration. (Default: 3)\n"
			.. "Lore: Doc warned David not to use it more than 3 times a day.\n"
			.. "Every activation beyond this accelerates cyberpsychosis progression.\n"
			.. "Counter resets when V sleeps.",
		1, 20, 1,
		cfg.dailySafeActivations,
		defaults.dailySafeActivations,
		function(value)
			cfg.dailySafeActivations = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catCP,
		"Psycho Acceleration per Extra Use",
		"Seconds subtracted from the Psycho Outburst timer per extra activation. (Default: 30)\n"
			.. "Higher = faster cyberpsychosis progression when overusing the Sandevistan.\n"
			.. "Effect stacks: 4th use = -30s, 5th = -60s, 6th = -90s, etc.",
		5, 120, 5,
		cfg.psychoAccelPerExtraUse,
		defaults.psychoAccelPerExtraUse,
		function(value)
			cfg.psychoAccelPerExtraUse = value
			applyAll()
		end)

	------------------------------------------------------------
	-- PERK GATES
	------------------------------------------------------------
	nativeSettings.addSubcategory(catPG, "Perk Gates")

	nativeSettings.addSwitch(
		catPG,
		"Require EdgeRunner Perk",
		"Require the EdgeRunner perk for full runtime access. (Default: OFF)\n"
			.. "When OFF: full runtime from the start, like David in the anime.\n"
			.. "When ON: without the perk, only 33% of runtime is available.",
		cfg.requireEdgeRunnerPerk,
		defaults.requireEdgeRunnerPerk,
		function(value)
			cfg.requireEdgeRunnerPerk = value
			applyAll()
		end)
end

registerForEvent("onInit", function()
	loadConfig()
	initUI()
	setTweaks()
	applyGameplayCfg()
end)
