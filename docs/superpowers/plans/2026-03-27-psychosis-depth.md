# Psychosis Depth Improvements — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 6 mechanic improvements that deepen the cyberpsychosis experience — from strain recovery to medication tolerance.

**Architecture:** Each mechanic is self-contained and hooks into existing systems via well-defined integration points. No new files — all changes go into existing modules (strain.lua, init.lua, psychosis.lua, immunoblocker_logic.lua). Each task is implemented, tested in-game, and committed before the next starts.

**Tech Stack:** CET Lua 5.3, Cyberpunk 2077 game APIs, quest fact persistence, CET MCP bridge for verification.

**Spec:** `docs/superpowers/specs/2026-03-27-psychosis-depth-improvements.md`

---

### Task 1: Natural Strain Decay (Stages 0-2)

**Files:**
- Modify: `bin/x64/.../DavidSandevistanPlus/strain.lua:22-64`

- [ ] **Step 1: Add natural decay rates table**

In `strain.lua`, after line 24 (`local passiveStrainPerSec = { [4]=0.04, [5]=0.08 }`), add:

```lua
-- Natural strain decay at low stages (body can still recover on its own)
-- Stage 3+ = no natural decay (needs external help)
local naturalDecayPerSec = { [0]=-0.03, [1]=-0.02, [2]=-0.01 }
```

- [ ] **Step 2: Extend UpdatePassiveStrain to handle decay at stages 0-2**

Replace the `UpdatePassiveStrain` function (lines 52-64) with:

```lua
dsp.UpdatePassiveStrain = (function(self)
	if not self.cfg.enableCyberpsychosis then return end
	if self.lastBreath then return end
	local stage = self.CyberPsychoWarnings

	-- Stages 4-5: strain INCREASES passively (chrome consuming you)
	local passive = passiveStrainPerSec[stage]
	if passive then
		local eff = self:GetImmunoblockerEffectiveness()
		local reduction = immunoReduction[eff] or 0
		local effective = passive * (1 - reduction) * (self.cfg.strainBuildupMultiplier or 1.0)
		-- Treatment milestone reduction
		local milestoneReduction = self.treatmentMilestoneStrainMult or 1.0
		effective = effective * milestoneReduction
		self.neuralStrain = self.neuralStrain + effective
		local guaranteed = self:GetStrainGuaranteed()
		local cap = guaranteed or 150
		if self.neuralStrain > cap then self.neuralStrain = cap end
		return
	end

	-- Stages 0-2: strain DECAYS naturally (body recovers on its own)
	local decay = naturalDecayPerSec[stage]
	if not decay then return end  -- stage 3: no natural decay
	if self.isRunning then return end  -- no decay while Sandy active
	local rate = math.abs(decay) * (self.cfg.strainRecoveryMultiplier or 1.0)
	-- Immunoblocker active: decay rate ×2
	local eff = self:GetImmunoblockerEffectiveness()
	if eff == 'full' or eff == 'partial' then rate = rate * 2.0 end
	-- Treatment milestone reduction (applied as faster decay)
	local milestoneReduction = self.treatmentMilestoneStrainMult or 1.0
	if milestoneReduction < 1.0 then
		rate = rate * (1.0 + (1.0 - milestoneReduction))  -- e.g. 0.7 mult → 1.3x faster decay
	end
	self.neuralStrain = math.max(self.neuralStrain - rate, 0)
 end)
```

- [ ] **Step 3: Copy to game directory**

```bash
cp "bin/x64/.../DavidSandevistanPlus/strain.lua" \
   "/mnt/g/SteamLibrary/.../DavidSandevistanPlus/strain.lua"
```

- [ ] **Step 4: Verify in-game via CET MCP**

1. Set psycho stage to 0 via debug keybind
2. Add strain via MCP: `dsp.neuralStrain = 30`
3. Wait 30s, check: `print(dsp.neuralStrain)` — should be ~29.1 (decayed at 0.03/sec)
4. Set stage to 4: verify strain INCREASES (passive +0.04/sec)
5. Set stage to 3: verify strain does NOT decay naturally

- [ ] **Step 5: Commit**

```bash
git add strain.lua
git commit -m "feat: natural strain decay at stages 0-2

Body recovers on its own at low psychosis stages:
- Stage 0: -0.03/sec (~17min to clear 30 strain)
- Stage 1: -0.02/sec (~25min)
- Stage 2: -0.01/sec (~50min)
- Stage 3+: no natural decay
- Blocked during Sandy active, doubled by immunoblocker"
```

---

### Task 2: Sandy Penalty During Active Treatment

**Files:**
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua:243-246` (state vars)
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua:717-730` (Sandy activation)
- Modify: `bin/x64/.../DavidSandevistanPlus/psychosis.lua:577-591` (treatment reset)

- [ ] **Step 1: Add state variable**

In `init.lua`, after line 246 (`,prescribedDoses = 0`), add:

```lua
,sandyUsesDuringTreatment = 0
,sandyTreatmentWarned = false
```

- [ ] **Step 2: Add treatment penalty in Sandy activation**

In `init.lua`, after line 723 (`self:AddStrain(self.cfg.strainPerActivation)`), insert:

```lua
			-- Treatment penalty: using Sandy fights the medication
			if self.treatmentActive then
				self:AddStrain(self.cfg.strainPerActivation * 0.5, true)  -- +50% raw strain
				self.sandyUsesDuringTreatment = (self.sandyUsesDuringTreatment or 0) + 1
				-- First use warning
				if not self.sandyTreatmentWarned then
					self.sandyTreatmentWarned = true
					self:ViktorSMS("V, my readings just spiked. You're using the Sandy while on treatment? That's working against everything we're doing here. Keep it up and I'll need to adjust your prescription.")
				end
				-- Every 3 uses: add 1 dose to prescription
				if self.sandyUsesDuringTreatment % 3 == 0 then
					self.prescribedDoses = (self.prescribedDoses or 0) + 1
					self:ViktorSMS("You're still running the Sandy. I've adjusted your prescription — you'll need " .. tostring(self.prescribedDoses - (self.completedDoses or 0)) .. " more doses now. Your call, kid.")
				end
			end
```

- [ ] **Step 3: Reset counter on treatment complete**

In `psychosis.lua`, in `CheckTreatmentComplete()`, after line 591 (`self.prescribedDoses = 0`), add:

```lua
			self.sandyUsesDuringTreatment = 0
			self.sandyTreatmentWarned = false
```

Also reset in the treatment activation block (line 578-580), after `self.prescribedDoses = rx.doses`:

```lua
					self.sandyUsesDuringTreatment = 0
					self.sandyTreatmentWarned = false
```

- [ ] **Step 4: Copy both files to game directory**

- [ ] **Step 5: Verify in-game**

1. Set psycho stage 2, visit ripperdoc to activate treatment
2. Activate Sandy → verify: Viktor SMS warning appears, strain is 50% higher than normal
3. Activate Sandy 3 more times → verify: prescription dose count increases by 1
4. Check `dsp.prescribedDoses` increased vs original prescription

- [ ] **Step 6: Commit**

```bash
git commit -m "feat: Sandy penalty during active treatment

Using Sandy while on treatment works against medication:
- +50% strain per activation (raw, bypasses stage multiplier)
- Viktor warning SMS on first use per treatment
- Every 3 Sandy uses: prescription extended by 1 dose
- Counter resets on treatment completion"
```

---

### Task 3: Micro-Episode Chaining

**Files:**
- Modify: `bin/x64/.../DavidSandevistanPlus/psychosis.lua:253-684` (micro-episode system)
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua:290-296` (state vars)

- [ ] **Step 1: Add chain definitions table and state vars**

In `psychosis.lua`, after `microEpisodeIntervals` (line 270), add:

```lua
-- Micro-episode chain definitions: { [trigger_type] = { target, chance } }
local microEpisodeChains = {
	visual_glitch = { target = "tremor_burst", chance = 0.25 },
	tremor_burst  = { target = "nosebleed",    chance = 0.20 },
	nosebleed     = { target = "manic_laugh",  chance = 0.15 },
	sandy_flash   = { target = "visual_glitch",chance = 0.30 },
	medium_glitch = { target = "manic_laugh",  chance = 0.20 },
}

-- Stage multiplier for chain chance
local chainStageMultiplier = { [1]=1.0, [2]=1.0, [3]=1.5, [4]=2.0, [5]=2.5 }
```

In `init.lua`, after line 296 (near other state vars for micro-episodes), add:

```lua
,microEpisodeChainCount = 0
,microEpisodeChainTimer = nil
,pendingChainType = nil
```

- [ ] **Step 2: Add chain logic after FireMicroEpisode effect application**

In `psychosis.lua`, replace the dev_mode print block at the end of `FireMicroEpisode` (lines 681-683) with:

```lua
		-- Chain logic: check if this episode can trigger a follow-up
		local chainDef = microEpisodeChains[selected.type]
		if chainDef and (self.microEpisodeChainCount or 0) < 3 then
			local eff = self:GetImmunoblockerEffectiveness()
			if eff ~= 'full' then  -- full blocks chains
				local stageMult = chainStageMultiplier[self.CyberPsychoWarnings] or 1.0
				local chainChance = chainDef.chance * stageMult
				if eff == 'partial' then chainChance = chainChance * 0.5 end
				if math.random() < chainChance then
					self.microEpisodeChainCount = (self.microEpisodeChainCount or 0) + 1
					self.pendingChainType = chainDef.target
					self.microEpisodeChainTimer = 1.5 + math.random() * 1.5  -- 1.5-3s delay
					self.tremor.intensity = math.min(self.tremor.intensity + 0.001, 0.02)
				end
			end
		end

		if self.dev_mode then
			print('[DSP] Micro-episode: '..selected.type..' dur='..string.format("%.1f",dur)..'s psycho='..tostring(self.CyberPsychoWarnings)..' chain='..(self.microEpisodeChainCount or 0))
		end
```

- [ ] **Step 3: Add chain timer processing in the displayTick micro-episode block**

In `init.lua`, find where `FireMicroEpisode` is called (around line 1500), and BEFORE the `self:FireMicroEpisode()` call, add chain timer processing:

```lua
				-- Process pending micro-episode chain
				if self.microEpisodeChainTimer then
					self.microEpisodeChainTimer = self.microEpisodeChainTimer - 1
					if self.microEpisodeChainTimer <= 0 then
						local chainType = self.pendingChainType
						self.microEpisodeChainTimer = nil
						self.pendingChainType = nil
						if chainType then
							self:FireMicroEpisodeByType(chainType)
						end
					end
				end
```

- [ ] **Step 4: Add FireMicroEpisodeByType helper**

In `psychosis.lua`, after `FireMicroEpisode` (after line 684), add:

```lua
	-- Fire a specific micro-episode type (used by chain system)
	dsp.FireMicroEpisodeByType = (function(self, targetType)
		if self.CachedInMenu or self.CachedBrainDance or (not self.VIsInControl) then
			self.microEpisodeChainCount = 0
			return
		end
		-- Find the episode definition
		local selected = nil
		for _, ep in ipairs(microEpisodePool) do
			if ep.type == targetType and self.CyberPsychoWarnings >= ep.minLevel then
				selected = ep
				break
			end
		end
		if not selected then
			self.microEpisodeChainCount = 0
			return
		end
		self.lastMicroEpisodeType = selected.type

		-- Apply effect (same logic as FireMicroEpisode)
		local dur = selected.duration[1] + math.random() * (selected.duration[2] - selected.duration[1])
		if selected.type == "visual_glitch" then
			self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Light)
		elseif selected.type == "tremor_burst" then
			self.tremor.intensity = math.max(self.tremor.intensity, 0.012)
		elseif selected.type == "nosebleed" then
			self:StatusEffect_CheckAndApply(self.martinez.NosebleedEffect)
		elseif selected.type == "manic_laugh" then
			self:StatusEffect_CheckAndApply(self.martinez.PsychoLaughEffect)
			local laughAttackChance = { [3]=0.30, [4]=0.50, [5]=0.70 }
			self:TryAutoAttack(laughAttackChance[self.CyberPsychoWarnings] or 0.30, true)
		elseif selected.type == "sandy_flash" then
			if not self.isRunning and self:IsWearingSandevistan() then
				self.bbs:StartSandevistan()
				self.microEpisodeSandyFlash = dur
			end
		elseif selected.type == "medium_glitch" then
			self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Medium)
		end
		if selected.type == "visual_glitch" or selected.type == "medium_glitch" then
			self.microEpisodeCleanup = { timer = dur, type = selected.type }
		end

		-- Continue chain
		local chainDef = microEpisodeChains[selected.type]
		if chainDef and (self.microEpisodeChainCount or 0) < 3 then
			local eff = self:GetImmunoblockerEffectiveness()
			if eff ~= 'full' then
				local stageMult = chainStageMultiplier[self.CyberPsychoWarnings] or 1.0
				local chainChance = chainDef.chance * stageMult
				if eff == 'partial' then chainChance = chainChance * 0.5 end
				if math.random() < chainChance then
					self.microEpisodeChainCount = (self.microEpisodeChainCount or 0) + 1
					self.pendingChainType = chainDef.target
					self.microEpisodeChainTimer = 1.5 + math.random() * 1.5
					self.tremor.intensity = math.min(self.tremor.intensity + 0.001, 0.02)
				end
			end
		end

		if (self.microEpisodeChainCount or 0) >= 3 or not self.pendingChainType then
			-- Chain ended: apply cooldown and reset
			if (self.microEpisodeChainCount or 0) >= 3 then
				self:ResetMicroEpisodeTimer()  -- resets with normal interval
				-- Double the interval for post-chain cooldown
				if self.microEpisodeTimer then
					self.microEpisodeTimer = self.microEpisodeTimer * 2
				end
			end
			self.microEpisodeChainCount = 0
			self.pendingChainType = nil
		end

		if self.dev_mode then
			print('[DSP] Chain micro-episode: '..selected.type..' chain='..(self.microEpisodeChainCount or 0))
		end
	 end)
```

- [ ] **Step 5: Reset chain state in ResetMicroEpisodeTimer**

In `psychosis.lua`, at the top of `ResetMicroEpisodeTimer` (line 607), add:

```lua
		self.microEpisodeChainCount = 0
		self.microEpisodeChainTimer = nil
		self.pendingChainType = nil
```

- [ ] **Step 6: Copy to game, verify in-game**

1. Set psycho stage 4 (high chain chance)
2. Wait for micro-episode → watch CET log for chain messages
3. Verify chains cap at 3 episodes
4. Verify tremor intensity increases during chain
5. Verify post-chain cooldown (next episode takes longer)

- [ ] **Step 7: Commit**

```bash
git commit -m "feat: micro-episode chaining system

Micro-episodes can cascade: glitch→tremor→nosebleed→laugh.
- 5 chain paths with defined probabilities
- Max 3 episodes per chain, 1.5-3s delay between links
- Chain chance scales with stage (×1.0 at 1-2, ×2.5 at 5)
- Cumulative tremor +0.001 per chain link
- Immunoblocker full blocks chains, partial halves chance
- Post-chain cooldown: ×2 interval after 3-chain"
```

---

### Task 4: Phantom Visual Escalation

**Files:**
- Modify: `bin/x64/.../DavidSandevistanPlus/psychosis.lua:792-1260` (phantom system)

- [ ] **Step 1: Update spawn distances and durations by stage**

In `psychosis.lua`, update the phantom spawn logic (around line 1170-1235). Change the spawn distance calculation to be stage-dependent:

```lua
		-- Stage-dependent spawn distance
		local spawnDistRange = {
			[3] = { 15, 25 },  -- peripheral shadows
			[4] = { 8, 15 },   -- hostile presences
			[5] = { 3, 8 },    -- total terror
		}
		local distRange = spawnDistRange[self.CyberPsychoWarnings] or { 8, 15 }
		local dist = distRange[1] + math.random() * (distRange[2] - distRange[1])
```

Update despawn durations to match spec:
```lua
		-- Stage-dependent durations (shorter = more fleeting)
		local phantomDurations = {
			[3] = { frozen={4,6}, approach={4,6}, attack={4,6}, lover_stare={4,6} },
			[4] = { frozen={8,12}, approach={8,14}, attack={8,14}, lover_stare={4,6} },
			[5] = { frozen={10,16}, approach={10,20}, attack={10,20}, lover_stare={4,6} },
		}
```

- [ ] **Step 2: Add proximity despawn check in UpdateHallucinations**

In the phantom lifecycle loop inside `UpdateHallucinations`, add proximity check:

```lua
				-- Proximity despawn: phantom vanishes when V gets close
				local proxDist = phantom.isLover and 3.0 or 2.0
				if phantom.behavior ~= 'attack' then
					pcall(function()
						local ent = Game.FindEntityByID(phantom.entityID)
						if ent and IsDefined(ent) then
							local pPos = ent:GetWorldPosition()
							local dx = vPos.x - pPos.x
							local dy = vPos.y - pPos.y
							local distSq = dx*dx + dy*dy
							if distSq < proxDist * proxDist then
								-- Instant glitch despawn
								Game.GetStatusEffectSystem():ApplyStatusEffect(ent:GetEntityID(),
									TweakDBID.new('BaseStatusEffect.HauntedBlackwallForceKill'))
								pcall(function() Game.GetDynamicEntitySystem():DeleteEntity(phantom.entityID) end)
								table.remove(self.phantomNPCs, i)
							end
						end
					end)
				end
```

- [ ] **Step 3: Add false alarm mechanic**

In the phantom spawn trigger (where `nextHallucinationTime` fires), before actual spawn:

```lua
			-- 20% chance of false alarm: sound/glitch plays but no NPC
			if math.random() < 0.20 then
				pcall(function()
					self:StatusEffect_CheckAndApply(self.martinez.PsychoWarningEffect_Light)
					local V = Game.GetPlayer()
					if V and IsDefined(V) then
						local evt = SoundPlayEvent.new()
						evt.soundName = "quickhack_shortcircuit"
						V:QueueEvent(evt)
					end
				end)
				-- Reset timer and skip actual spawn
				local range = hallucinationIntervals[self.CyberPsychoWarnings] or {180, 300}
				self.nextHallucinationTime = now + range[1] + math.random() * (range[2] - range[1])
				-- Apply jitter (×0.5 to ×2.0)
				local jitter = 0.5 + math.random() * 1.5
				self.nextHallucinationTime = self.nextHallucinationTime * jitter
				return
			end
```

- [ ] **Step 4: Add interval jitter to all phantom spawns**

After setting `self.nextHallucinationTime` in the spawn logic, apply jitter:

```lua
			-- Anti-habituation: jitter ×0.5 to ×2.0
			local jitter = 0.5 + math.random() * 1.5
			self.nextHallucinationTime = self.nextHallucinationTime * jitter
```

- [ ] **Step 5: Add intensity amplifiers**

In the phantom spawn decision block, add amplifiers:

```lua
			-- Intensity amplifiers
			-- Sandy used recently: next phantom comes faster
			if self.sandyEndTime and (now - self.sandyEndTime) < 30 then
				self.nextHallucinationTime = self.nextHallucinationTime * 0.5
			end
```

Add kill-during-Sandy phantom trigger in the kill strain logic (init.lua, where `strainPerKillGang` etc. are applied):

```lua
			-- Kill during Sandy: 40% chance of immediate phantom
			if self.isRunning and self.CyberPsychoWarnings >= 3 and math.random() < 0.40 then
				self.nextHallucinationTime = os.clock() + 0.5  -- almost immediate
			end
```

- [ ] **Step 6: Add stage 5 group spawn**

In the phantom spawn logic, after creating the first phantom at stage 5:

```lua
			-- Stage 5: 30% chance of group spawn (2 phantoms)
			if self.CyberPsychoWarnings >= 5 and math.random() < 0.30 then
				-- Spawn second phantom 1-2m offset from first
				-- (reuse same spawn logic with slight offset)
				-- ... second spawn call with offset position
			end
```

- [ ] **Step 7: Copy to game, verify in-game**

1. Stage 3: verify phantoms spawn far (15-25m), last 4-6s, frozen only
2. Stage 4: verify closer spawns, approach/attack behavior mix
3. Stage 5: verify very close spawns, group spawns visible
4. Walk toward a frozen phantom: verify it despawns at <2m
5. Walk toward a lover phantom: verify despawn at <3m
6. Wait for false alarm: verify sound plays without NPC
7. Check CET log for phantom proximity despawn messages

- [ ] **Step 8: Commit**

```bash
git commit -m "feat: phantom visual escalation by stage

Stage 3: peripheral shadows (15-25m, 4-6s, frozen only)
Stage 4: hostile presences (8-15m, 8-14s, approach/attack)
Stage 5: total terror (3-8m, 10-20s, 30% group spawn)
- Proximity despawn: frozen/approach at 2m, lover at 3m
- 20% false alarm chance (sound+glitch, no NPC)
- Interval jitter ×0.5-2.0 (anti-habituation)
- Sandy kill → 40% immediate phantom trigger
- Post-Sandy 30s: phantom delay halved"
```

---

### Task 5: Medication Tolerance

**Files:**
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua:233-246` (state vars)
- Modify: `bin/x64/.../DavidSandevistanPlus/immunoblocker_logic.lua:26-35` (effectiveness)
- Modify: `bin/x64/.../DavidSandevistanPlus/psychosis.lua:537-575` (prescription + dose tracking)
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua:565-612` (VisitedRipper tolerance reset)

- [ ] **Step 1: Add tolerance state variables**

In `init.lua`, after `prescribedDoses` (line 246), add:

```lua
,toleranceAmount = 0.0
,toleranceStage = 0
,lastImmunoblockerGameTime = 0  -- game-time of last immunoblocker use (for decay)
```

- [ ] **Step 2: Add tolerance config tables**

In `immunoblocker_logic.lua`, at the top of `immunoblocker_logic.attach(dsp)` (after line 4), add:

```lua
	-- Tolerance buildup: { chance, amount } per tier
	local toleranceBuildup = {
		[1] = { chance = 0.70, amount = 1.0 },  -- Common
		[2] = { chance = 0.50, amount = 1.0 },  -- Uncommon
		[3] = { chance = 0.30, amount = 0.5 },  -- Rare
	}
	local toleranceThresholds = { 4.0, 8.0, 12.0 }  -- stage 0→1, 1→2, 2→3
	local toleranceDoseMultiplier = { [0]=1.0, [1]=1.3, [2]=1.6, [3]=2.0 }
```

- [ ] **Step 3: Add tolerance buildup on immunoblocker consumption**

In `immunoblocker_logic.lua`, add a function after `GetImmunoblockerEffectiveness`:

```lua
	-- Called when immunoblocker is consumed: probabilistic tolerance buildup
	dsp.AddToleranceOnConsumption = (function(self, tier)
		local info = toleranceBuildup[tier]
		if not info then return end
		if math.random() > info.chance then return end  -- probability check
		self.toleranceAmount = (self.toleranceAmount or 0) + info.amount
		-- Record game-time of last use (for decay tracking)
		pcall(function()
			self.lastImmunoblockerGameTime = Game.GetTimeSystem():GetGameTimeStamp()
		end)
		-- Check stage advance
		local stage = self.toleranceStage or 0
		if stage < 3 then
			local threshold = toleranceThresholds[stage + 1]
			if threshold and self.toleranceAmount >= threshold then
				self.toleranceStage = stage + 1
				self.toleranceAmount = 0  -- reset for next stage
				self:ViktorSMS("V, your system's building resistance to the blockers. Effectiveness is dropping. I can flush it at the clinic.")
				print('[DSP] Tolerance stage advanced to ' .. tostring(self.toleranceStage))
			end
		end
	 end)
```

- [ ] **Step 4: Modify GetImmunoblockerEffectiveness to account for tolerance**

Replace `GetImmunoblockerEffectiveness` (lines 26-35):

```lua
	dsp.GetImmunoblockerEffectiveness = (function(self)
		local tier = self:GetImmunoblockerTier()
		if tier == 0 then return 'none' end
		-- Tolerance reduces effective tier
		local effectiveTier = math.max(tier - (self.toleranceStage or 0), 0)
		if effectiveTier == 0 then return 'ineffective' end
		local psycho = self.CyberPsychoWarnings
		local maxEffective = { 1, 2, 5 }   -- Common, Uncommon, Rare
		local partialLevel = { 2, 3, -1 }  -- Common partial at 2, Uncommon at 3, Rare never
		if psycho <= maxEffective[effectiveTier] then return 'full' end
		if psycho == partialLevel[effectiveTier] then return 'partial' end
		return 'ineffective'
	 end)
```

- [ ] **Step 5: Hook tolerance buildup into CheckTreatmentDose**

In `psychosis.lua`, inside `CheckTreatmentDose` (around line 565), after `self.completedDoses = ...`, add:

```lua
		-- Tolerance buildup on consumption
		self:AddToleranceOnConsumption(consumedTier)
```

- [ ] **Step 6: Make GetPrescription dynamic with tolerance compensation**

Replace `GetPrescription` (lines 537-541):

```lua
	dsp.GetPrescription = (function(self, level)
		local entry = prescriptionTable[level]
		if not entry then return { doses = 0, visits = 0, minTier = 0 } end
		-- Tolerance compensation: more doses needed when tolerance is high
		local tolMult = toleranceDoseMultiplier[self.toleranceStage or 0] or 1.0
		local adjustedDoses = math.ceil(entry.doses * tolMult)
		return { doses = adjustedDoses, visits = entry.visits, minTier = entry.minTier }
	 end)
```

Note: this requires moving `toleranceDoseMultiplier` to `psychosis.lua` or making it accessible. Simplest: define it in psychosis.lua near prescriptionTable:

```lua
local toleranceDoseMultiplier = { [0]=1.0, [1]=1.3, [2]=1.6, [3]=2.0 }
```

- [ ] **Step 7: Add tolerance decay and ripperdoc reset**

In `immunoblocker_logic.lua`, add tolerance decay function:

```lua
	-- Called once per second from displayTick: decays tolerance if no immunoblocker used recently
	dsp.UpdateToleranceDecay = (function(self)
		if (self.toleranceAmount or 0) <= 0 and (self.toleranceStage or 0) <= 0 then return end
		local ok, now = pcall(function() return Game.GetTimeSystem():GetGameTimeStamp() end)
		if not ok then return end
		local lastUse = self.lastImmunoblockerGameTime or 0
		if lastUse == 0 then return end
		-- Only decay if 24h game-time since last use
		local hoursSinceUse = (now - lastUse) / 3600
		if hoursSinceUse < 24 then return end
		-- Decay: 1.0 per game-day (called once/sec, so divide by 86400)
		local decayPerSec = 1.0 / 86400
		self.toleranceAmount = math.max((self.toleranceAmount or 0) - decayPerSec, 0)
		-- Check stage decrease
		if self.toleranceAmount <= 0 and (self.toleranceStage or 0) > 0 then
			self.toleranceStage = self.toleranceStage - 1
			-- Set amount to just below the threshold of the new stage
			local prevThreshold = toleranceThresholds[self.toleranceStage] or 0
			self.toleranceAmount = math.max(prevThreshold - 0.1, 0)
			print('[DSP] Tolerance stage decreased to ' .. tostring(self.toleranceStage))
		end
	 end)
```

In `init.lua` `VisitedRipper`, after the strain drain (line 634), add:

```lua
			-- Ripperdoc flushes tolerance
			if (self.toleranceAmount or 0) > 0 or (self.toleranceStage or 0) > 0 then
				self.toleranceAmount = math.max((self.toleranceAmount or 0) - 4.0, 0)
				if self.toleranceAmount <= 0 and (self.toleranceStage or 0) > 0 then
					self.toleranceStage = self.toleranceStage - 1
					local prevThreshold = toleranceThresholds[self.toleranceStage] or 0
					self.toleranceAmount = math.max(prevThreshold - 0.1, 0)
				end
			end
```

Note: `toleranceThresholds` needs to be accessible in init.lua. Either duplicate the table or reference via a dsp getter. Simplest: add `dsp.GetToleranceThreshold(stage)` helper in immunoblocker_logic.lua, then call it from init.lua.

- [ ] **Step 8: Add tolerance persistence via quest facts**

In `SaveGame` and `LoadGamePart3`, add tolerance save/load:

```lua
-- Save:
self.qs:SetFactStr('dsp_tolerance_amount', math.floor((self.toleranceAmount or 0) * 100))
self.qs:SetFactStr('dsp_tolerance_stage', self.toleranceStage or 0)
self.qs:SetFactStr('dsp_tolerance_last_use', math.floor((self.lastImmunoblockerGameTime or 0)))

-- Load:
self.toleranceAmount = (self.qs:GetFactStr('dsp_tolerance_amount') or 0) / 100
self.toleranceStage = self.qs:GetFactStr('dsp_tolerance_stage') or 0
self.lastImmunoblockerGameTime = self.qs:GetFactStr('dsp_tolerance_last_use') or 0
```

- [ ] **Step 9: Add UpdateToleranceDecay call to displayTick**

In `init.lua`, in the displayTick Phase 2 block (where `UpdatePassiveStrain` is called), add:

```lua
				self:UpdateToleranceDecay()
```

- [ ] **Step 10: Copy all modified files to game, verify**

1. Consume 5 Common immunoblockers → check `dsp.toleranceAmount` increases
2. Verify tolerance stage advances at threshold 4.0
3. Check `dsp:GetImmunoblockerEffectiveness()` shows reduced tier
4. Visit ripperdoc → verify tolerance drops by 4.0
5. Check prescription doses increase with tolerance (GetPrescription)
6. Save/load → verify tolerance persists

- [ ] **Step 11: Commit**

```bash
git commit -m "feat: medication tolerance system (Dark Future-inspired)

Two-layer tolerance: continuous amount + discrete stages (0-3).
- Buildup: 70%/50%/30% chance per Common/Uncommon/Rare dose
- Each stage reduces immunoblocker effective tier by 1
- Natural decay: -1.0/day after 24h without consumption
- Ripperdoc flushes -4.0 per visit
- Prescription dynamically adjusts: ×1.0/1.3/1.6/2.0 doses
- Persisted via quest facts across save/load"
```

---

### Task 6: Treatment Intermediate Milestones

**Files:**
- Modify: `bin/x64/.../DavidSandevistanPlus/psychosis.lua:549-605` (treatment check)
- Modify: `bin/x64/.../DavidSandevistanPlus/init.lua:243-246` (state vars)

- [ ] **Step 1: Add milestone state variable**

In `init.lua`, after `sandyTreatmentWarned` (added in Task 2), add:

```lua
,treatmentMilestone = 0             -- 0=none, 1=33%, 2=66%, 3=complete
,treatmentMilestoneStrainMult = 1.0 -- passive strain rate multiplier from milestones
,treatmentMilestoneEpisodeMult = 1.0 -- micro-episode interval multiplier from milestones
,treatmentMilestonePhantomMult = 1.0 -- phantom interval multiplier from milestones
```

- [ ] **Step 2: Add milestone calculation function**

In `psychosis.lua`, after `CheckTreatmentDose` (around line 575), add:

```lua
	-- Calculate treatment progress and apply milestone benefits
	dsp.UpdateTreatmentMilestone = (function(self)
		if not self.treatmentActive then
			self.treatmentMilestone = 0
			self.treatmentMilestoneStrainMult = 1.0
			self.treatmentMilestoneEpisodeMult = 1.0
			self.treatmentMilestonePhantomMult = 1.0
			return
		end
		local rx = self:GetPrescription(self.CyberPsychoWarnings)
		if rx.doses == 0 then return end
		local doseProgress = (self.completedDoses or 0) / rx.doses
		local visitProgress = rx.visits > 0 and ((self.completedVisits or 0) / rx.visits) or 1.0
		local progress = (doseProgress + visitProgress) / 2.0

		local prevMilestone = self.treatmentMilestone or 0

		if progress >= 0.66 then
			self.treatmentMilestone = 2
			self.treatmentMilestoneStrainMult = 0.4   -- -60% passive strain
			self.treatmentMilestoneEpisodeMult = 1.6  -- ×1.6 slower micro-episodes
			self.treatmentMilestonePhantomMult = 1.5  -- ×1.5 slower phantoms
		elseif progress >= 0.33 then
			self.treatmentMilestone = 1
			self.treatmentMilestoneStrainMult = 0.7   -- -30% passive strain
			self.treatmentMilestoneEpisodeMult = 1.3  -- ×1.3 slower micro-episodes
			self.treatmentMilestonePhantomMult = 1.0  -- no phantom change yet
		else
			self.treatmentMilestone = 0
			self.treatmentMilestoneStrainMult = 1.0
			self.treatmentMilestoneEpisodeMult = 1.0
			self.treatmentMilestonePhantomMult = 1.0
		end

		-- Viktor SMS on milestone advance
		if self.treatmentMilestone > prevMilestone then
			if self.treatmentMilestone == 1 then
				self:ViktorSMS("Good, V. Your readings are stabilizing. Keep taking the meds. Don't skip doses.")
			elseif self.treatmentMilestone == 2 then
				self:ViktorSMS("Real improvement here, kid. Neural pathways are re-routing. Almost there.")
			end
		end
	 end)
```

- [ ] **Step 3: Call UpdateTreatmentMilestone after each dose and visit**

In `CheckTreatmentDose`, after `self.completedDoses = ...` (line 566), add:

```lua
		self:UpdateTreatmentMilestone()
```

In `VisitedRipper` (init.lua), after incrementing `completedVisits`, add:

```lua
				self:UpdateTreatmentMilestone()
```

- [ ] **Step 4: Apply milestone multipliers to micro-episode intervals**

In `ResetMicroEpisodeTimer` (psychosis.lua, line 607-618), after calculating the random interval, multiply by milestone:

```lua
		local milestoneEpMult = self.treatmentMilestoneEpisodeMult or 1.0
		self.microEpisodeTimer = math.floor(self.microEpisodeTimer * milestoneEpMult)
```

- [ ] **Step 5: Apply milestone multiplier to phantom intervals**

In the hallucination timer reset (where `nextHallucinationTime` is set), multiply by milestone:

```lua
		local milestonePMult = self.treatmentMilestonePhantomMult or 1.0
		self.nextHallucinationTime = self.nextHallucinationTime * milestonePMult
```

- [ ] **Step 6: Apply milestone strain multiplier (already done in Task 1)**

The `treatmentMilestoneStrainMult` is already used in the `UpdatePassiveStrain` rewrite from Task 1. Verify it's there.

- [ ] **Step 7: Reset milestones on treatment complete**

In `CheckTreatmentComplete`, after resetting treatment state (line 591), add:

```lua
			self.treatmentMilestone = 0
			self.treatmentMilestoneStrainMult = 1.0
			self.treatmentMilestoneEpisodeMult = 1.0
			self.treatmentMilestonePhantomMult = 1.0
```

- [ ] **Step 8: Persist milestone across save/load**

```lua
-- Save:
self.qs:SetFactStr('dsp_treatment_milestone', self.treatmentMilestone or 0)

-- Load:
self.treatmentMilestone = self.qs:GetFactStr('dsp_treatment_milestone') or 0
if self.treatmentMilestone >= 2 then
	self.treatmentMilestoneStrainMult = 0.4
	self.treatmentMilestoneEpisodeMult = 1.6
	self.treatmentMilestonePhantomMult = 1.5
elseif self.treatmentMilestone >= 1 then
	self.treatmentMilestoneStrainMult = 0.7
	self.treatmentMilestoneEpisodeMult = 1.3
	self.treatmentMilestonePhantomMult = 1.0
end
```

- [ ] **Step 9: Copy to game, verify**

1. Start treatment at stage 3 (5 doses, 2 visits)
2. Take 2 doses → verify milestone 1 SMS + strain mult = 0.7
3. Take 2 more doses + 1 visit → verify milestone 2 SMS + phantom interval ×1.5
4. Complete treatment → verify stage reduces, milestones reset
5. Save/load mid-treatment → verify milestone persists

- [ ] **Step 10: Commit**

```bash
git commit -m "feat: treatment intermediate milestones

Progressive relief during Viktor's treatment protocol:
- 33% complete: -30% passive strain, ×1.3 micro-episode interval
- 66% complete: -60% strain, ×1.6 episodes, ×1.5 phantom interval
- 100%: stage reduction (existing behavior)
- Viktor SMS at each milestone
- Progress = (doses/prescribed + visits/required) / 2
- Persisted via quest facts across save/load"
```

---

## Summary

| Task | Mechanic | Primary Files | Depends On |
|------|----------|---------------|-----------|
| 1 | Natural Strain Decay | strain.lua | — |
| 2 | Sandy Treatment Penalty | init.lua, psychosis.lua | — |
| 3 | Micro-Episode Chaining | psychosis.lua, init.lua | — |
| 4 | Phantom Visual Escalation | psychosis.lua, init.lua | — |
| 5 | Medication Tolerance | immunoblocker_logic.lua, psychosis.lua, init.lua | Before Task 6 |
| 6 | Treatment Milestones | psychosis.lua, init.lua | After Task 5 |

Each task follows: implement → copy to game → verify in-game → commit → next task.
