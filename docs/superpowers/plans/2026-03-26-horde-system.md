# Horde System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add paranoia-driven horde waves of hostile gang NPCs at psychosis stage 4-5, creating survival pressure that intensifies as V kills phantoms.

**Architecture:** New `UpdateHorde` function in `psychosis.lua` runs alongside `UpdateHallucinations` from `onUpdate`. Horde state lives on the `dsp` table. When a horde is active, normal phantoms are paused. Gang members sprint toward V; killed ones trigger replacements. Immunoblocker cancels the horde. All spawns/despawns use Blackwall VFX.

**Tech Stack:** CET Lua 5.3, Cyberpunk 2077 RED4 API, exEntitySpawner, HauntedBlackwallForceKill

---

## File Map

| File | Changes |
|------|---------|
| `psychosis.lua` | New horde state, `UpdateHorde`, `StartHorde`, `EndHorde`, `SpawnHordeNPC`, `ProcessHordeKills` — all in the `psychosis.attach(dsp)` scope |
| `init.lua` | Add `dsp:UpdateHorde(dt)` call in `onUpdate`, add `DebugForceHorde` keybind |

---

### Task 1: Horde state and configuration

**Files:**
- Modify: `psychosis.lua` (after `attackRecords` table, ~line 707)

- [ ] **Step 1: Add horde config tables at module level**

```lua
-- Horde system config (module-local)
local hordeConfig = {
	-- Check interval: how often we roll for a horde event (seconds)
	checkInterval = { [4] = 300, [5] = 120 },  -- stage 4: every 5min, stage 5: every 2min
	-- Duration of a horde wave (seconds)
	duration = { [4] = {60, 90}, [5] = {90, 120} },
	-- Base probability per check (0-1), multiplied by strain ratio
	baseChance = { [4] = 0.3, [5] = 0.5 },
	-- Spawn interval: time between automatic NPC spawns during horde (seconds)
	spawnInterval = { [4] = {3, 5}, [5] = {2, 4} },
	-- Reinforcements per kill: {min, max} additional NPCs spawned when V kills one
	reinforcePerKill = { [4] = {1, 2}, [5] = {1, 3} },
	-- Reinforcement spawn delay after kill (seconds)
	reinforceDelay = { [4] = {1.5, 3.0}, [5] = {0.8, 2.0} },
	-- Reinforcement spawn distance (further away than normal phantoms)
	reinforceDist = { [4] = {12, 20}, [5] = {14, 25} },
	-- Max simultaneous horde NPCs
	maxNPCs = { [4] = 20, [5] = 30 },
	-- Cooldown between hordes (seconds)
	cooldown = { [4] = 600, [5] = 300 },  -- stage 4: 10min, stage 5: 5min
}
```

- [ ] **Step 2: Add horde state fields on dsp table**

After `dsp.phantomNPCs = {}` (~line 748), add:

```lua
	-- Horde state
	dsp.hordeActive = false
	dsp.hordeNPCs = {}           -- { entityID, spawnTime, behaviorApplied }
	dsp.hordeEndTime = 0         -- os.clock() when horde ends
	dsp.hordeNextSpawn = 0       -- os.clock() for next auto-spawn
	dsp.hordeNextCheck = 0       -- os.clock() for next horde roll
	dsp.hordeCooldownUntil = 0   -- os.clock() when cooldown expires
	dsp.hordeGangRecord = nil    -- single gang type for current horde
	dsp.hordePendingReinforce = {} -- { {spawnTime, count}, ... } delayed reinforcements
	dsp.hordeKills = 0           -- kills during current horde
```

- [ ] **Step 3: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/psychosis.lua
git commit -m "feat(horde): add horde config tables and state fields"
```

---

### Task 2: Horde spawn helper

**Files:**
- Modify: `psychosis.lua` (after `applyGlitchDespawn` function, ~line 912)

- [ ] **Step 1: Add SpawnHordeNPC function**

This spawns a single gang NPC facing V, sprinting toward V with hostile AI. Uses the shared `attackRecords` or horde-specific `hordeGangRecord`.

```lua
	-- Spawn a single horde NPC facing and sprinting toward V
	local function spawnHordeNPC(self, minDist, maxDist)
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return nil end
		local max = hordeConfig.maxNPCs[self.CyberPsychoWarnings] or 20
		if #self.hordeNPCs >= max then return nil end

		local vPos = V:GetWorldPosition()
		local dist = minDist + math.random() * (maxDist - minDist)
		local angle = math.random() * 2 * math.pi
		local spawnX = vPos.x + math.cos(angle) * dist
		local spawnY = vPos.y + math.sin(angle) * dist
		local spawnZ = vPos.z

		local record = self.hordeGangRecord or attackRecords[math.random(#attackRecords)]

		local ok, entityID = pcall(function()
			local transform = V:GetWorldTransform()
			local pos = WorldPosition.new()
			WorldPosition.SetVector4(pos, Vector4.new(spawnX, spawnY, spawnZ, 1.0))
			WorldTransform.SetWorldPosition(transform, pos)
			local dx = vPos.x - spawnX
			local dy = vPos.y - spawnY
			local yaw = math.deg(math.atan(dx, dy)) + 180
			WorldTransform.SetOrientation(transform, EulerAngles.ToQuat(EulerAngles.new(0, 0, yaw)))
			return exEntitySpawner.SpawnRecord(record, transform)
		end)

		if ok and entityID then
			local now = os.clock()
			table.insert(self.hordeNPCs, {
				entityID = entityID,
				spawnTime = now,
				behaviorApplied = false,
			})
			return entityID
		end
		return nil
	end
```

- [ ] **Step 2: Add applyHordeBehavior function**

Called 1.0s after spawn to make NPC hostile and sprint toward V:

```lua
	-- Apply hostile sprint-to-V behavior on horde NPC
	local function applyHordeBehavior(self, hordeNPC)
		local ent = Game.FindEntityByID(hordeNPC.entityID)
		if not ent or not IsDefined(ent) then return end
		local V = Game.GetPlayer()
		if not V or not IsDefined(V) then return end
		local npc = ent

		-- Make hostile
		pcall(function()
			npc:GetAttitudeAgent():SetAttitudeGroup(CName.new("Hostile"))
			npc:GetAttitudeAgent():SetAttitudeTowards(V:GetAttitudeAgent(), EAIAttitude.AIA_Hostile)
		end)
		pcall(function()
			local sensePreset = TweakDBInterface.GetReactionPresetRecord(TweakDBID.new("ReactionPresets.Ganger_Aggressive"))
			npc.reactionComponent:SetReactionPreset(sensePreset)
			npc.reactionComponent:TriggerCombat(V)
		end)
		-- Fallback: sprint toward V
		pcall(function()
			local vPos = V:GetWorldPosition()
			local dest = NewObject('WorldPosition')
			WorldPosition.SetVector4(dest, vPos)
			local posSpec = NewObject('AIPositionSpec')
			posSpec:SetWorldPosition(posSpec, dest)
			local cmd = NewObject('handle:AIMoveToCommand')
			cmd.movementTarget = posSpec
			cmd.rotateEntityTowardsFacingTarget = true
			cmd.ignoreNavigation = true
			cmd.desiredDistanceFromTarget = 0.5
			cmd.movementType = CName.new("Sprint")
			cmd.finishWhenDestinationReached = true
			npc:GetAIControllerComponent():SendCommand(cmd)
		end)
		-- SFX
		pcall(function()
			local evt = SoundPlayEvent.new()
			evt.soundName = "quickhack_cyberpsychosis_mech"
			npc:QueueEvent(evt)
		end)
	end
```

- [ ] **Step 3: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/psychosis.lua
git commit -m "feat(horde): spawn and behavior helpers for horde NPCs"
```

---

### Task 3: StartHorde and EndHorde

**Files:**
- Modify: `psychosis.lua` (after the spawn helpers)

- [ ] **Step 1: Add StartHorde function on dsp**

```lua
	dsp.StartHorde = (function(self)
		if self.hordeActive then return end
		local stage = self.CyberPsychoWarnings
		local now = os.clock()

		self.hordeActive = true
		self.hordeNPCs = {}
		self.hordePendingReinforce = {}
		self.hordeKills = 0

		-- Pick a single gang type for this horde
		self.hordeGangRecord = attackRecords[math.random(#attackRecords)]

		-- Duration
		local durRange = hordeConfig.duration[stage] or {60, 90}
		self.hordeEndTime = now + durRange[1] + math.random() * (durRange[2] - durRange[1])

		-- First spawn timer
		self.hordeNextSpawn = now + 1.0  -- first NPC in 1s

		-- Blackwall VFX on V
		pcall(function()
			self:StatusEffect_CheckAndApply('BaseStatusEffect.HauntedBlackwallForceKill')
		end)

		-- Warning message
		self.bbs:SendWarning("THEY'RE COMING", 3.0, "halluc_s5_01")

		-- Blackwall scream
		pcall(function() self.hud:PlayVoiceLine("dsp_blackwall_scream") end)

		print('[DSP] Horde started: '..self.hordeGangRecord..' duration='..(math.floor(self.hordeEndTime - now))..'s stage='..tostring(stage))
	 end)
```

- [ ] **Step 2: Add EndHorde function on dsp**

```lua
	dsp.EndHorde = (function(self)
		if not self.hordeActive then return end
		local now = os.clock()

		-- Blackwall VFX + despawn all surviving horde NPCs
		for _, h in ipairs(self.hordeNPCs) do
			pcall(function()
				local ent = Game.FindEntityByID(h.entityID)
				if ent and IsDefined(ent) then
					Game.GetStatusEffectSystem():ApplyStatusEffect(ent:GetEntityID(),
						TweakDBID.new('BaseStatusEffect.HauntedBlackwallForceKill'))
				end
			end)
		end

		-- Delayed despawn (let Blackwall VFX play for 2s)
		self.hordeDespawnTime = now + 2.0

		-- Set cooldown
		local stage = self.CyberPsychoWarnings
		local cd = hordeConfig.cooldown[stage] or 300
		self.hordeCooldownUntil = now + cd

		self.hordeActive = false
		self.hordePendingReinforce = {}

		-- Brief Blackwall VFX on V
		pcall(function()
			self:StatusEffect_CheckAndApply('BaseStatusEffect.HauntedBlackwallForceKill')
		end)

		print('[DSP] Horde ended: kills='..tostring(self.hordeKills)..' remaining='..tostring(#self.hordeNPCs))
	 end)
```

- [ ] **Step 3: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/psychosis.lua
git commit -m "feat(horde): StartHorde and EndHorde with Blackwall VFX"
```

---

### Task 4: UpdateHorde main loop

**Files:**
- Modify: `psychosis.lua` (after EndHorde)

- [ ] **Step 1: Add UpdateHorde function on dsp**

```lua
	dsp.UpdateHorde = (function(self, dt)
		if not self.cfg.enableCyberpsychosis then return end
		if self.CyberPsychoWarnings < 4 then return end
		if self.CachedInMenu or self.CachedBrainDance then return end
		if not self.VIsInControl then return end
		if self.lastBreath then return end

		local now = os.clock()
		local stage = self.CyberPsychoWarnings

		-- Process pending despawns from EndHorde (Blackwall VFX played, now remove)
		if self.hordeDespawnTime and now >= self.hordeDespawnTime then
			for _, h in ipairs(self.hordeNPCs) do
				pcall(function()
					local ent = Game.FindEntityByID(h.entityID)
					if ent and IsDefined(ent) then
						exEntitySpawner.Despawn(ent)
					end
				end)
			end
			self.hordeNPCs = {}
			self.hordeDespawnTime = nil
		end

		-- If horde is active
		if self.hordeActive then
			-- Cancel if immunoblocker taken
			local eff = self:GetImmunoblockerEffectiveness()
			if eff == 'full' or eff == 'partial' then
				self:EndHorde()
				return
			end

			-- Check if time expired
			if now >= self.hordeEndTime then
				self:EndHorde()
				return
			end

			-- Process horde NPC lifecycle
			local i = #self.hordeNPCs
			while i >= 1 do
				local h = self.hordeNPCs[i]
				-- Apply behavior 1.0s after spawn
				if not h.behaviorApplied and now >= h.spawnTime + 1.0 then
					h.behaviorApplied = true
					pcall(function() applyHordeBehavior(self, h) end)
				end
				-- Check if dead (entity no longer exists or no longer alive)
				local isDead = false
				pcall(function()
					local ent = Game.FindEntityByID(h.entityID)
					if not ent or not IsDefined(ent) then
						isDead = true
					elseif ent:IsDeadNoStatPool() or ent:IsDead() then
						isDead = true
						-- Blackwall VFX on corpse
						Game.GetStatusEffectSystem():ApplyStatusEffect(ent:GetEntityID(),
							TweakDBID.new('BaseStatusEffect.HauntedBlackwallForceKill'))
					end
				end)
				if isDead then
					self.hordeKills = self.hordeKills + 1
					table.remove(self.hordeNPCs, i)
					-- Queue reinforcements
					local reinforceRange = hordeConfig.reinforcePerKill[stage] or {1, 2}
					local count = reinforceRange[1] + math.random(0, reinforceRange[2] - reinforceRange[1])
					local delayRange = hordeConfig.reinforceDelay[stage] or {1.0, 2.0}
					for r = 1, count do
						local delay = delayRange[1] + math.random() * (delayRange[2] - delayRange[1])
						table.insert(self.hordePendingReinforce, { time = now + delay + (r - 1) * 0.5 })
					end
				end
				i = i - 1
			end

			-- Process pending reinforcements
			local ri = #self.hordePendingReinforce
			while ri >= 1 do
				if now >= self.hordePendingReinforce[ri].time then
					local distRange = hordeConfig.reinforceDist[stage] or {12, 20}
					spawnHordeNPC(self, distRange[1], distRange[2])
					table.remove(self.hordePendingReinforce, ri)
				end
				ri = ri - 1
			end

			-- Auto-spawn on interval
			if now >= self.hordeNextSpawn then
				local spawnRange = hordeConfig.spawnInterval[stage] or {3, 5}
				self.hordeNextSpawn = now + spawnRange[1] + math.random() * (spawnRange[2] - spawnRange[1])
				spawnHordeNPC(self, 8, 16)
			end

			return  -- skip normal phantom scheduling while horde is active
		end

		-- Not active: roll for horde event
		local eff = self:GetImmunoblockerEffectiveness()
		if eff == 'full' or eff == 'partial' then return end

		if now < self.hordeNextCheck then return end
		local interval = hordeConfig.checkInterval[stage] or 300
		self.hordeNextCheck = now + interval

		-- Cooldown
		if now < self.hordeCooldownUntil then return end

		-- Probability: base chance * strain ratio
		local base = hordeConfig.baseChance[stage] or 0.3
		local threshold = self:GetStrainThreshold()
		local strainRatio = math.min((self.neuralStrain or 0) / threshold, 1.5)
		local chance = base * strainRatio

		if math.random() < chance then
			self:StartHorde()
		end
	 end)
```

- [ ] **Step 2: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/psychosis.lua
git commit -m "feat(horde): UpdateHorde main loop with spawn, kill detection, reinforcements"
```

---

### Task 5: Integration into onUpdate and hallucinations pause

**Files:**
- Modify: `init.lua:2603` (onUpdate callback)
- Modify: `psychosis.lua:914` (UpdateHallucinations)

- [ ] **Step 1: Add UpdateHorde call in onUpdate**

At `init.lua:2603`, after `dsp:UpdateHallucinations(dt)`, add:

```lua
    dsp:UpdateHorde(dt)
```

- [ ] **Step 2: Pause normal phantoms during horde**

At `psychosis.lua:914`, in `UpdateHallucinations`, after the immunoblocker check add:

```lua
		-- Pause normal phantoms while horde is active
		if self.hordeActive then return end
```

This goes after `if eff == 'full' or eff == 'partial' then return end` (line 921).

- [ ] **Step 3: Add DespawnAllHordeNPCs to DespawnAllPhantoms**

In `DespawnAllPhantoms` (~line 1084), add horde cleanup:

```lua
		-- Also cleanup horde NPCs
		for _, h in ipairs(self.hordeNPCs) do
			pcall(function()
				local ent = Game.FindEntityByID(h.entityID)
				if ent and IsDefined(ent) then
					exEntitySpawner.Despawn(ent)
				end
			end)
		end
		self.hordeNPCs = {}
		self.hordeActive = false
		self.hordePendingReinforce = {}
```

- [ ] **Step 4: Add debug keybind**

At `init.lua`, after `DebugForcePhantom` keybind, add:

```lua
registerInput("DebugForceHorde", 'DEBUG: Force Horde Event Now', function(isKeyDown)
	if not isKeyDown then return end
	if dsp.hordeActive then
		dsp:EndHorde()
		print("[DSP DEBUG] Horde ended manually")
	else
		dsp:StartHorde()
		print("[DSP DEBUG] Horde started at stage "..tostring(dsp.CyberPsychoWarnings))
	end
end)
```

- [ ] **Step 5: Commit**

```bash
git add bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/psychosis.lua bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus/init.lua
git commit -m "feat(horde): integrate into onUpdate, pause phantoms during horde, debug keybind"
```

---

### Task 6: Copy to game and verify

- [ ] **Step 1: Copy all modified files to game directory**

```bash
cp bin/x64/.../DavidSandevistanPlus/psychosis.lua /mnt/g/SteamLibrary/.../DavidSandevistanPlus/psychosis.lua
cp bin/x64/.../DavidSandevistanPlus/init.lua /mnt/g/SteamLibrary/.../DavidSandevistanPlus/init.lua
```

- [ ] **Step 2: Test with debug keybinds**

1. Set stage to 4 with `DebugPsychoUp`
2. Press `DebugForceHorde` — should see Blackwall VFX on V, gang NPCs spawning and sprinting at V
3. Kill NPCs — should see Blackwall VFX on corpses, reinforcements arrive from further away
4. Wait for timer — all survivors should simultaneously get Blackwall VFX and despawn
5. Press `DebugForceHorde` again to toggle off early — all despawn with Blackwall VFX

- [ ] **Step 3: Test stage 5**

1. Set stage to 5
2. Press `DebugForceHorde` — should have more NPCs, faster spawns, longer duration
3. Take immunoblocker during horde — should cancel immediately with Blackwall VFX on all

- [ ] **Step 4: Test normal phantom pause**

1. While horde active, press `DebugForcePhantom` — should NOT spawn a normal phantom
2. After horde ends, press `DebugForcePhantom` — should spawn normally
