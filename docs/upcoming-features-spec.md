# Upcoming Features — Technical Spec

Three new features for progressive cyberpsychosis immersion.

---

## Feature 1: Cyberpsychosis Auto-Attack (Stage 4-5)

V involuntarily attacks nearby NPCs during high psychosis — loss of control.

### Trigger
- Stage 4-5, random chance during strain episodes or micro-episodes
- Chance increases with stage: 15% at stage 4, 35% at stage 5
- Only fires if V has a weapon equipped (any type) or cyberware arms
- Cooldown: minimum 30s between auto-attacks

### Detection Flow
```
1. Detect V's equipped weapon type:
   - Ranged (pistol, SMG, rifle, shotgun) → QuestForceShoot
   - Melee (katana, knife, bat, hammer) → QuestForceShoot (melee uses same input)
   - Fists / Gorilla Arms → QuestForceShoot
   - No weapon → skip (no attack)

2. Detect NPC in front of V:
   - Game.GetTargetingSystem():GetLookAtObject(player, false, false)
   - Must be NPC (target:IsNPC())
   - Must be within 15m range

3. Trigger auto-attack:
   - Set QuestForceShoot = true on PlayerStateMachine blackboard
   - Hold for 0.3-0.5s (brief burst, not sustained fire)
   - Reset QuestForceShoot = false

4. Visual feedback:
   - Red outline on target NPC for 2-3s (OutlineRequestEvent, EOutlineType.RED)
   - Camera shake spike (tremor 0.008 for 1s)
   - VFX flash: afterimage_glitch (0.5s)
   - Message: "What did I just..." / "I can't control it..." / "They were going to..."
```

### API Reference
```lua
-- Detect weapon type
local weapon = Game.GetPlayer():GetActiveWeapon()
-- or: Game.GetTransactionSystem():GetItemInSlot(player, TweakDBID.new("AttachmentSlots.WeaponRight"))

-- Force shoot
local bb = Game.GetPlayer():GetPlayerStateMachineBlackboard()
bb:SetBool(Game.GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, true)
-- later:
bb:SetBool(Game.GetAllBlackboardDefs().PlayerStateMachine.QuestForceShoot, false)

-- Red outline on NPC
local evt = OutlineRequestEvent.new()
local data = OutlineData.new()
data.outlineType = EOutlineType.RED
data.outlineOpacity = 1.0
evt.outlineRequest = OutlineRequest.CreateRequest(CName.new('cyberpsychosis'), data)
npc:QueueEvent(evt)

-- Make NPC hostile to V (so they fight back)
local npcAtt = npc:GetAttitudeAgent()
npcAtt:SetAttitudeTowards(Game.GetPlayer():GetAttitudeAgent(), EAIAttitude.AIA_Hostile)
```

### NPC Consequences
- After auto-attack, the target NPC becomes hostile toward V (fights back)
- Nearby civilians flee (already handled by StimBroadcaster gunshot)
- NCPD heat increases (already handled by NCPDIsWatching)
- Strain increases from the kill if NPC dies (+8 for civilian)

### Messages Pool (stage-aware)
```
Stage 4:
  "What did I just do..."
  "I didn't mean to... my hand moved on its own"
  "No... that wasn't me"

Stage 5:
  "THEY WERE LOOKING AT ME"
  "Had to... had to do it"
  "More... need more"
```

---

## Feature 2: Hallucinations (Stage 3-5)

V sees and hears things that aren't real.

### Tier 1: VFX + Audio Hallucinations (already partially implemented)
- Flash VFX: `hacking_glitch_low`, `burnout_glitch`, `braindance_sound_vision_mode` (0.3-1.5s)
- Audio: combat sounds, voices, heartbeat via `SoundPlayEvent`
- Existing: micro-episode system already does visual glitches

### Tier 2: Phantom NPCs (TO IMPLEMENT)

Spawn ghost NPCs near V that appear briefly and vanish.

#### Trigger
- Stage 3: every 3-5 min, 1 ghost NPC
- Stage 4: every 1-3 min, 1-2 ghost NPCs
- Stage 5: every 30-60s, 1-3 ghost NPCs
- Suppressed by immunoblocker (full/partial)

#### Spawn Flow
```
1. Select random NPC record to spawn:
   - Civilian records (generic crowd NPCs)
   - At stage 5: cyberpsycho-type NPCs or gang members
   - Optional: Lucy, David, or Jackie ghost at stage 5 (lore easter egg)

2. Calculate spawn position:
   - 5-15m from V, in V's forward cone (±60°)
   - Must be on navmesh (or accept slight floating)

3. Spawn + VFX:
   - exEntitySpawner.SpawnRecord(record, worldTransform)
   - Wait 1-2 frames for entity to initialize
   - Apply CyberpsychoNPCStatusEffect (optical blur/ghost VFX)
   - Apply red outline (EOutlineType.RED) to make them look threatening

4. Despawn timer:
   - Stage 3: despawn after 3-5s
   - Stage 4: despawn after 5-8s (longer, more unsettling)
   - Stage 5: despawn after 2-4s (flash — barely there)

5. Despawn:
   - exEntitySpawner.Despawn(entity)
   - Brief afterimage_glitch VFX on V when ghost vanishes (0.3s)
```

#### Audio Component
```
- When ghost spawns: play 3D sound from ghost's position
  - Whisper/voice: "ono_v_effort_short" or combat grunt
  - Or footsteps: ambient crowd sounds
- Queue SoundPlayEvent to the spawned entity (3D spatialized)
```

#### Messages on hallucination
```
Stage 3:
  "Did someone just...?"
  "Thought I saw..."
  "Shadows moving... just my eyes"

Stage 4:
  "They're watching me..."
  "Who's there?!"
  "Can't trust what I see anymore"

Stage 5:
  "THEY'RE EVERYWHERE"
  "Lucy...? No... not real"
  "GET OUT OF MY HEAD"
```

---

## Feature 3: Blackout / Wake Up (Overuse Exhaustion)

V collapses from overuse and wakes up at a safe location hours later.

### Trigger
- **Stages 0-3**: Exhaustion at 3× safe activations → blackout
- **Stage 4+**: Exhaustion at 3× safe activations → blackout (same mechanic, different consequences)
- **Stage 5 (Safety OFF)**: NO blackout — stays as colapso inminente → death path (KillV). David doesn't pass out at stage 5, he pushes through until death.

### Current Behavior (to replace for stages 0-4)
```lua
-- ExhaustionCheck (loreEffects.lua:123)
-- Currently: EndSandevistan + Stun + drain 30s runtime
-- Replace with: blackout sequence
```

### Blackout Sequence
```
1. PRE-BLACKOUT (immediate):
   - dsp:End() — stop Sandy
   - dsp:RemoveAllPsychoVFX()
   - dsp:StopHeartbeat()
   - Play "burnout_glitch" VFX (0.5s)
   - Message: "Body gives out... everything goes dark"

2. SCREEN BLACK (0.5s delay):
   - Apply BaseStatusEffect.CyberwareInstallationAnimationBlackout
   - Game.GetPlayer() frozen (NoCombat restriction)

3. TELEPORT (1.0s delay):
   - Clear wanted level (Prevention Heat_0)
   - Select wakeup location:
     - 60% chance: V's apartment (H10 Megabuilding exterior)
     - 30% chance: Viktor's clinic
     - 10% chance: random alley (woke up on the street)
   - Teleport V to selected location
   - Advance time 4-8 hours (random)

4. WAKE UP (2.0s after teleport):
   - Call dsp:Rested(hoursSkipped) — applies sleep recovery
   - FastForwardPlayerState() — clears temp status effects
   - Remove blackout effect
   - Apply "eyes_opening" VFX (slow eye open)
   - Brief groggy VFX: "status_drugged_medium" (2s)
   - Set health to 50-70% (didn't rest properly)
   - Camera reset

5. POST-WAKE MESSAGE:
   - Viktor: "Woke up at Viktor's... how did I get here?"
   - Apartment: "Home... don't remember coming back"
   - Street: "Woke up in an alley... head's splitting"
```

### Wakeup Locations
```lua
local blackoutLocations = {
    { name = "apartment", pos = Vector4.new(-1204.0, 1842.0, 115.0, 1.0), rot = EulerAngles.new(0, 0, 180), chance = 0.6 },
    { name = "viktor",   pos = Vector4.new(-1554.434, 1239.794, 11.520, 1.0), rot = EulerAngles.new(0, 0, 0), chance = 0.3 },
    { name = "alley",    pos = Vector4.new(-1286.9, -1686.1, 44.2, 1.0), rot = EulerAngles.new(0, 0, 90), chance = 0.1 },
}
```

### Stage 5 Exception
At stage 5 with Safety OFF, exhaustion does NOT trigger blackout. Instead:
- Current behavior stays: strain episode → KillV → death path
- David doesn't collapse and wake up — he fights until the end

---

## Implementation Priority

1. **Feature 3: Blackout** — replaces current Stun mechanic, cleanest to implement
2. **Feature 2: Hallucinations Tier 2** — phantom NPCs, builds on existing micro-episode system
3. **Feature 1: Auto-Attack** — most complex, needs careful testing for balance

## Files to Modify

| File | Feature 1 | Feature 2 | Feature 3 |
|------|-----------|-----------|-----------|
| `init.lua` | Blackboard access | — | Timer delays |
| `psychosis.lua` | Auto-attack trigger | Phantom NPC spawn | — |
| `loreEffects.lua` | — | — | ExhaustionCheck → blackout |
| `strain.lua` | — | — | — |
| `martinez.lua` | — | Ghost NPC status effect | — |
