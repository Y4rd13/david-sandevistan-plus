-- MartinezPLUS - Tuner for David Sandevistan Plus
-- Requires: nativeSettings, DavidSandevistanPlus

local RecordName = "Items.MartinezSandevistanPlusPlus"
local apogeeConfigFile = "../DavidSandevistanPlus/config.json"

local defaults = {
	-- TweakDB values
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
	strainPerActivation = 5,
	strainPerOveruseBonus = 3,
	strainPerMinuteActive = 2,
	strainPerSecSafetyOff = 0.15,
	strainPerKillBase = 3,
	strainPerComedown5s = 1,
	strainDrainSafeArea = 0.05,
	strainDrainSleep = 40,
	strainDrainRipper = 25,
	strainDrainImmunoblocker = 0.1,
	strainDrainDFImmuno = 0.08,
	strainBuildupMultiplier = 1.0,
	strainRecoveryMultiplier = 1.0,
	safetyOffTimeDilation = 975,
	enableComedown = true,
	comedownBaseDuration = 5.0,
	comedownMaxDuration = 20.0,
	comedownRuntimeThreshold = 60,
	comedownBlockSandy = true,
	comedownPsychoMultiplier = 1.5,
	comedownTremorAtPsycho = true,
	enablePrescription = true,
	maxPsychoRecoveryPerSleep = 1,
	ripperRecoveryLevels = 1,
	enableNonLinearDrain = true,
	drainExponent = 1.5,
	drainAccelStartSec = 60,
	enableSessionFatigue = true,
	sessionFatiguePenalty = 0.02,
	maxSessionFatiguePenalty = 0.10,
	enableRuntimeDegradation = true,
	sleepRecoveryPercent = 0.75,
	ripperFullRestore = true,
	enableMicroEpisodes = true,
	microEpisodeFrequency = 1.0,
	requireEdgeRunnerPerk = true,
	timeDilationNoPerk = 0.05,
	timeDilationWithPerk = 0.0065,
	tickLength = 1.25,
}

local cfg = {}
for k, v in pairs(defaults) do cfg[k] = v end

local nativeSettings = nil

-- Gameplay keys that DavidsApogee reads from config.json
local gameplayKeys = {
	"enableHealthDrain", "damageMin", "damageMax",
	"enableHealthBrake", "healthBrakeDefault", "requiredHealthMin",
	"safetyOffDrainMultiplier", "enableSafetyOffKill", "safetyOffKillThreshold",
	"fullRechargeHours", "maxRechargePerSleep", "enableCyberpsychosis",
	"dailySafeActivations",
	"strainPerActivation", "strainPerOveruseBonus", "strainPerMinuteActive",
	"strainPerSecSafetyOff", "strainPerKillBase", "strainPerComedown5s",
	"strainDrainSafeArea", "strainDrainSleep", "strainDrainRipper",
	"strainDrainImmunoblocker", "strainDrainDFImmuno",
	"strainBuildupMultiplier", "strainRecoveryMultiplier",
	"safetyOffTimeDilation",
	"enableComedown", "comedownBaseDuration", "comedownMaxDuration", "comedownRuntimeThreshold",
	"comedownBlockSandy", "comedownPsychoMultiplier", "comedownTremorAtPsycho",
	"enablePrescription", "maxPsychoRecoveryPerSleep", "ripperRecoveryLevels",
	"enableNonLinearDrain", "drainExponent", "drainAccelStartSec",
	"enableSessionFatigue", "sessionFatiguePenalty", "maxSessionFatiguePenalty",
	"enableRuntimeDegradation", "sleepRecoveryPercent", "ripperFullRestore",
	"enableMicroEpisodes", "microEpisodeFrequency",
	"requireEdgeRunnerPerk",
	"timeDilationNoPerk", "timeDilationWithPerk",
	"tickLength",
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
	cfg.timeDilationNoPerk = tonumber(cfg.timeDilationNoPerk) or defaults.timeDilationNoPerk
	cfg.timeDilationWithPerk = tonumber(cfg.timeDilationWithPerk) or defaults.timeDilationWithPerk
end

local function saveConfig()
	local toSave = {}
	for k, v in pairs(cfg) do toSave[k] = v end
	toSave.timeDilationNoPerk = string.format("%.8f", cfg.timeDilationNoPerk)
	toSave.timeDilationWithPerk = string.format("%.8f", cfg.timeDilationWithPerk)
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
	setFlatAndUpdate(RecordName .. "_Stat_Modifier_04.value", 0.15)
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
	-- Update item tooltip to show correct time dilation percentage
	local dilationPct = math.floor((1 - cfg.timeDilationNoPerk) * 1000 + 0.5) / 10
	setFlatAndUpdate(RecordName .. "_Equip1_Various_UI.floatValues",
		{dilationPct, cfg.critChance * 1.0, cfg.critDamage * 1.0, cfg.headshotDamageMultiplier * 1.0, cfg.healOnKill * 1.0, cfg.staminaOnKill * 1.0, cfg.sandyDuration * 1.0})
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
	local catNS = tab .. "/NeuralStrain"
	local catCD = tab .. "/Comedown"
	local catRX = tab .. "/Prescription"
	local catNLD = tab .. "/NonLinearDrain"
	local catME = tab .. "/MicroEpisodes"

	if not nativeSettings.pathExists(tab) then
		nativeSettings.addTab(tab, "Martinez Sandy+")
	end

	for _, path in ipairs({catTD, catDC, catCS, catOK, catHD, catHB, catSO, catRC, catCP, catNS, catCD, catRX, catNLD, catME}) do
		if nativeSettings.pathExists(path) then
			nativeSettings.removeSubcategory(path)
		end
	end

	------------------------------------------------------------
	-- TIME DILATION
	------------------------------------------------------------
	nativeSettings.addSubcategory(catTD, "Time Dilation")

	local dilationData = {
		{ label = "85%",      value = 0.15   },
		{ label = "90%",      value = 0.10   },
		{ label = "92.5%",    value = 0.075  },
		{ label = "95%",      value = 0.05   },
		{ label = "97.5%",    value = 0.025  },
		{ label = "99%",      value = 0.01   },
		{ label = "99.25%",   value = 0.0075 },
		{ label = "99.35%",   value = 0.0065 },
		{ label = "99.5%",    value = 0.005  },
	}

	local dilationLabels = {}
	local dilationValues = {}
	for i, opt in ipairs(dilationData) do
		dilationLabels[i] = opt.label
		dilationValues[i] = opt.value
	end

	local function findDilationIndex(val)
		local best = 1
		local bestDiff = math.abs(dilationValues[1] - val)
		for i, v in ipairs(dilationValues) do
			local diff = math.abs(v - val)
			if diff < bestDiff then
				best = i
				bestDiff = diff
			end
		end
		return best
	end

	nativeSettings.addSelectorString(
		catTD,
		"Time Dilation (No Perk)",
		"Time dilation without EdgeRunner perk. (Default: 95%)\n"
			.. "Higher % = slower time = more power.\n"
			.. "Values above 99.35% may cause visual glitches.",
		dilationLabels,
		findDilationIndex(cfg.timeDilationNoPerk),
		findDilationIndex(defaults.timeDilationNoPerk),
		function(value)
			cfg.timeDilationNoPerk = dilationValues[value]
			applyAll()
		end)

	nativeSettings.addSelectorString(
		catTD,
		"Time Dilation (With Perk)",
		"Time dilation with EdgeRunner perk. (Default: 99.35%)\n"
			.. "Higher % = slower time = more power.\n"
			.. "Values above 99.35% may cause visual glitches.",
		dilationLabels,
		findDilationIndex(cfg.timeDilationWithPerk),
		findDilationIndex(defaults.timeDilationWithPerk),
		function(value)
			cfg.timeDilationWithPerk = dilationValues[value]
			applyAll()
		end)

	nativeSettings.addSwitch(
		catTD,
		"Require EdgeRunner Perk",
		"Require the EdgeRunner perk for enhanced time dilation. (Default: ON)\n"
			.. "When ON: Without the perk, V gets the 'No Perk' dilation value.\n"
			.. "When OFF: V always gets the 'With Perk' value from day one.",
		cfg.requireEdgeRunnerPerk,
		defaults.requireEdgeRunnerPerk,
		function(value)
			cfg.requireEdgeRunnerPerk = value
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
			.. "Normal: 1s/tick | Safety Off: 5s/tick (configurable via Drain Multiplier).\n"
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
			.. "Lore: David activated with no visible cost — the toll was cumulative (cyberpsychosis).",
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

	local timeDilationOptions = {
		{ label = "92.5%", value = 925 },
		{ label = "95%",   value = 950 },
		{ label = "97.5% (Default)", value = 975 },
		{ label = "99%",   value = 990 },
		{ label = "99.5%", value = 1000 },
	}
	local tdLabels = {}
	local tdValues = {}
	local tdDefault = 3
	for i, opt in ipairs(timeDilationOptions) do
		tdLabels[i] = opt.label
		tdValues[i] = opt.value
		if opt.value == cfg.safetyOffTimeDilation then tdDefault = i end
	end
	local tdDefaultIdx = 3
	for i, opt in ipairs(timeDilationOptions) do
		if opt.value == defaults.safetyOffTimeDilation then tdDefaultIdx = i break end
	end

	nativeSettings.addSelectorString(
		catSO,
		"Safety Off Time Dilation",
		"Time dilation when Safety Limiters are OFF. (Default: 97.5%)\n"
			.. "Higher = slower time = more power. David ran without limiters for the speed boost.\n"
			.. "This replaces the default perk-based time dilation while Safety is OFF.",
		tdLabels,
		tdDefault,
		tdDefaultIdx,
		function(value)
			cfg.safetyOffTimeDilation = tdValues[value]
			applyAll()
		end)

	------------------------------------------------------------
	-- RECHARGE & RECOVERY
	------------------------------------------------------------
	nativeSettings.addSubcategory(catRC, "Recharge & Recovery")

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

	nativeSettings.addSwitch(
		catRC,
		"Enable Runtime Degradation",
		"Each Sandy session permanently costs max runtime (1%/60s). (Default: ON)\n"
			.. "Sleep recovers a percentage. Ripperdoc can restore 100%.\n"
			.. "Capped at 50% max runtime loss.",
		cfg.enableRuntimeDegradation,
		defaults.enableRuntimeDegradation,
		function(value)
			cfg.enableRuntimeDegradation = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catRC,
		"Sleep Recovery (%)",
		"Percentage of degraded max runtime recovered per sleep. (Default: 0.75 = 75%)",
		0.25, 1.0, 0.05, "%.2f",
		cfg.sleepRecoveryPercent,
		defaults.sleepRecoveryPercent,
		function(value)
			cfg.sleepRecoveryPercent = value
			applyAll()
		end)

	nativeSettings.addSwitch(
		catRC,
		"Ripper Full Restore",
		"Ripperdoc visit restores 100% max runtime. (Default: ON)",
		cfg.ripperFullRestore,
		defaults.ripperFullRestore,
		function(value)
			cfg.ripperFullRestore = value
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

	nativeSettings.addSwitch(
		catCP,
		"Enable Session Fatigue",
		"Each overuse activation makes time dilation less effective. (Default: ON)\n"
			.. "Resets on sleep. Stacks with psycho dilation curves.\n"
			.. "Lore: David's body adapted poorly — each use in a session was less potent.",
		cfg.enableSessionFatigue,
		defaults.enableSessionFatigue,
		function(value)
			cfg.enableSessionFatigue = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catCP,
		"Fatigue Penalty per Overuse",
		"Time dilation loss per overuse activation. (Default: 0.02 = 2%)\n"
			.. "Example: 5 overuses = 10% less effective dilation.",
		0.01, 0.10, 0.01, "%.2f",
		cfg.sessionFatiguePenalty,
		defaults.sessionFatiguePenalty,
		function(value)
			cfg.sessionFatiguePenalty = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catCP,
		"Max Fatigue Penalty",
		"Cap for total session fatigue penalty. (Default: 0.10 = 10%)",
		0.05, 0.30, 0.01, "%.2f",
		cfg.maxSessionFatiguePenalty,
		defaults.maxSessionFatiguePenalty,
		function(value)
			cfg.maxSessionFatiguePenalty = value
			applyAll()
		end)

	------------------------------------------------------------
	-- NEURAL STRAIN
	------------------------------------------------------------
	nativeSettings.addSubcategory(catNS, "Neural Strain")

	nativeSettings.addRangeFloat(
		catNS,
		"Strain Buildup Speed",
		"Global multiplier for ALL neural strain accumulation. (Default: 1.0)\n"
			.. "Scales ALL sources: activations, overuse, safety off, kills, comedown.\n"
			.. "0.5 = half as fast, 2.0 = twice as fast.\n"
			.. "Lower = more Sandy uses before psycho episodes trigger.",
		0.25, 3.0, 0.25, "%.2f",
		cfg.strainBuildupMultiplier,
		defaults.strainBuildupMultiplier,
		function(value)
			cfg.strainBuildupMultiplier = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catNS,
		"Strain Recovery Speed",
		"Global multiplier for ALL neural strain recovery. (Default: 1.0)\n"
			.. "Scales ALL drains: sleep, ripperdoc, immunoblocker, safe areas.\n"
			.. "0.5 = half recovery speed, 2.0 = twice as fast.\n"
			.. "Higher = faster recovery from strain buildup.",
		0.25, 3.0, 0.25, "%.2f",
		cfg.strainRecoveryMultiplier,
		defaults.strainRecoveryMultiplier,
		function(value)
			cfg.strainRecoveryMultiplier = value
			applyAll()
		end)

	------------------------------------------------------------
	-- COMEDOWN
	------------------------------------------------------------
	nativeSettings.addSubcategory(catCD, "Comedown (Deactivation Debuff)")

	nativeSettings.addSwitch(
		catCD,
		"Enable Comedown",
		"Apply a debuff after deactivating the Sandevistan. (Default: ON)\n"
			.. "Lore: David showed visible strain after deactivating — disorientation, heavy breathing.\n"
			.. "Duration scales with how long the Sandy was active.",
		cfg.enableComedown,
		defaults.enableComedown,
		function(value)
			cfg.enableComedown = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catCD,
		"Base Duration (sec)",
		"Minimum comedown duration after a short Sandy use. (Default: 3.0)",
		1.0, 10.0, 0.5, "%.1f",
		cfg.comedownBaseDuration,
		defaults.comedownBaseDuration,
		function(value)
			cfg.comedownBaseDuration = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catCD,
		"Max Duration (sec)",
		"Maximum comedown duration after prolonged Sandy use. (Default: 8.0)",
		3.0, 20.0, 0.5, "%.1f",
		cfg.comedownMaxDuration,
		defaults.comedownMaxDuration,
		function(value)
			cfg.comedownMaxDuration = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catCD,
		"Scaling Threshold (sec)",
		"Seconds of Sandy runtime used before comedown reaches max duration. (Default: 60)\n"
			.. "Below this: comedown scales linearly from base to max.\n"
			.. "Above this: always max duration.",
		10, 300, 5,
		cfg.comedownRuntimeThreshold,
		defaults.comedownRuntimeThreshold,
		function(value)
			cfg.comedownRuntimeThreshold = value
			applyAll()
		end)

	nativeSettings.addSwitch(
		catCD,
		"Block Sandy During Comedown",
		"Prevent Sandy reactivation during comedown. (Default: ON)\n"
			.. "Lore: David couldn't just pop it again instantly — his body needed to recover.",
		cfg.comedownBlockSandy,
		defaults.comedownBlockSandy,
		function(value)
			cfg.comedownBlockSandy = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catCD,
		"Psycho Duration Multiplier",
		"Comedown duration multiplier at psycho level 3+. (Default: 1.5)\n"
			.. "Higher psycho = longer comedown. 1.5 = 50% longer at psycho 3+.",
		1.0, 3.0, 0.1, "%.1f",
		cfg.comedownPsychoMultiplier,
		defaults.comedownPsychoMultiplier,
		function(value)
			cfg.comedownPsychoMultiplier = value
			applyAll()
		end)

	nativeSettings.addSwitch(
		catCD,
		"Tremor During Comedown (Psycho 3+)",
		"Camera shake during comedown at psycho level 3+. (Default: ON)",
		cfg.comedownTremorAtPsycho,
		defaults.comedownTremorAtPsycho,
		function(value)
			cfg.comedownTremorAtPsycho = value
			applyAll()
		end)

	------------------------------------------------------------
	-- DOC PRESCRIPTION (Graduated Recovery)
	------------------------------------------------------------
	nativeSettings.addSubcategory(catRX, "Doc Prescription (Graduated Recovery)")

	nativeSettings.addSwitch(
		catRX,
		"Enable Prescription System",
		"Recovery is a process, not instant. Sleep = -1 level max. (Default: ON)\n"
			.. "Lore: Doc prescribed treatments over time — David couldn't just sleep it off.\n"
			.. "When OFF: original instant-cure behavior.",
		cfg.enablePrescription,
		defaults.enablePrescription,
		function(value)
			cfg.enablePrescription = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catRX,
		"Max Recovery per Sleep",
		"Maximum psycho levels recovered per sleep session. (Default: 1)\n"
			.. "Higher values = faster sleep recovery.",
		1, 5, 1,
		cfg.maxPsychoRecoveryPerSleep,
		defaults.maxPsychoRecoveryPerSleep,
		function(value)
			cfg.maxPsychoRecoveryPerSleep = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catRX,
		"Ripper Recovery Levels",
		"Psycho levels recovered per ripperdoc visit. (Default: 1)",
		1, 3, 1,
		cfg.ripperRecoveryLevels,
		defaults.ripperRecoveryLevels,
		function(value)
			cfg.ripperRecoveryLevels = value
			applyAll()
		end)

	------------------------------------------------------------
	-- NON-LINEAR DRAIN
	------------------------------------------------------------
	nativeSettings.addSubcategory(catNLD, "Non-Linear Runtime Drain")

	nativeSettings.addSwitch(
		catNLD,
		"Enable Non-Linear Drain",
		"Runtime drain accelerates the longer Sandy is active. (Default: ON)\n"
			.. "First 60s = normal. Then drain increases exponentially.\n"
			.. "Lore: David's body deteriorated faster the longer he pushed.",
		cfg.enableNonLinearDrain,
		defaults.enableNonLinearDrain,
		function(value)
			cfg.enableNonLinearDrain = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catNLD,
		"Drain Exponent",
		"Acceleration curve exponent. (Default: 1.5)\n"
			.. "Higher = more aggressive drain at sustained use.",
		1.0, 3.0, 0.1, "%.1f",
		cfg.drainExponent,
		defaults.drainExponent,
		function(value)
			cfg.drainExponent = value
			applyAll()
		end)

	nativeSettings.addRangeInt(
		catNLD,
		"Drain Acceleration Start (sec)",
		"Seconds of active Sandy before drain acceleration kicks in. (Default: 60)",
		10, 180, 5,
		cfg.drainAccelStartSec,
		defaults.drainAccelStartSec,
		function(value)
			cfg.drainAccelStartSec = value
			applyAll()
		end)

	------------------------------------------------------------
	-- MICRO-EPISODES
	------------------------------------------------------------
	nativeSettings.addSubcategory(catME, "Micro-Episodes (Random Symptoms)")

	nativeSettings.addSwitch(
		catME,
		"Enable Micro-Episodes",
		"Random involuntary symptoms between psycho episodes. (Default: ON)\n"
			.. "Visual glitches, tremors, nosebleeds, involuntary Sandy flashes.\n"
			.. "Frequency scales with psycho level. Suppressed during comedown.",
		cfg.enableMicroEpisodes,
		defaults.enableMicroEpisodes,
		function(value)
			cfg.enableMicroEpisodes = value
			applyAll()
		end)

	nativeSettings.addRangeFloat(
		catME,
		"Frequency Multiplier",
		"Multiplier for micro-episode frequency. (Default: 1.0)\n"
			.. "0.5 = half as frequent, 2.0 = twice as frequent.",
		0.25, 3.0, 0.25, "%.2f",
		cfg.microEpisodeFrequency,
		defaults.microEpisodeFrequency,
		function(value)
			cfg.microEpisodeFrequency = value
			applyAll()
		end)

end

registerForEvent("onInit", function()
	loadConfig()
	initUI()
	setTweaks()
	applyGameplayCfg()
end)
