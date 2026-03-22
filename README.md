# David Sandevistan Plus

Custom Cyberpunk 2077 Sandevistan mod with lore-accurate defaults and every gameplay parameter configurable via an in-game Settings menu.

## Features

- **Lore-accurate defaults** — Safety ON/OFF is automatic based on psycho stage (stage 5+ = limiters fail)
- Custom icon and localization (MILITECH "DAVID MARTINEZ" SANDEVISTAN PLUS)
- In-game settings via Native Settings UI tab: "Martinez Sandy+"
- Daily activation counter — Doc warned David not to use it more than 3 times a day
- No health brake by default — David never had an auto-stop
- Progressive dilation — stage 0 starts at 90%, power increases with psychosis (up to 99.35% at stage 6)
- Config persists across sessions via `config.json`
- **Lore-accurate gameplay systems** — neural strain, runtime as body endurance, immunoblocker items, hallucinations, auto-attack, blackout, graduated recovery, non-linear drain, micro-episodes (see below)

### Custom HUD

A visual HUD overlay showing real-time Sandy status:
- **Runtime bar** — color-coded green/yellow/red with time dilation percentage (represents body endurance, not battery)
- **Status line** — activation count, contextual status (stage info, overuse count)
- **Psycho bar** — visible when cyberpsychosis is active, with level and RX progress
- **Strain bar** — Neural Strain level with BrainMelt icon, blue/yellow/red color coding, visible at all stages when strain > 0

### Progressive Cyberpsychosis

A 5-level system inspired by David Martinez's descent in Edgerunners:

| Level | Name | Persistent VFX | Gameplay |
|-------|------|---------------|----------|
| 0 | Normal | None | Full functionality — heavy overuse triggers first episode |
| 1 | Unstable | None | Subtle tremor (0.001), micro-episodes every 5-10 min |
| 2 | Glitching | Subtle glitch | Persistent `hacking_glitch_low`, heartbeat, tremor, random nosebleeds |
| 3 | Losing It | Medium distortion | Persistent glitch + drugged VFX, stronger tremor |
| 4 | On The Edge | Heavy distortion | 3-layer VFX, 15% movement penalty, manic laughter, **auto-attack** (involuntary), hallucinations |
| 5 | Cyberpsycho | Full psychosis | 5 simultaneous VFX, 15% movement penalty, Safety OFF automatic, Sandy stays active during episodes |
| 6 | Last Breath | All VFX removed → ramp | **Permanent death** — Second Heart revival triggers final stand |

**Safety is automatic:** Stages 0-4 have Safety ON (limiters active). At stage 5, Safety OFF engages automatically — the limiters fail and V can't stop, like David in Episode 10. Sandy stays active during psycho episodes at stage 5. Death is near-inevitable.

#### Psychosis Combat Effects (Level 5+)

At high psychosis levels and during Last Breath, V's cyberware malfunctions offensively:

| Effect | Range | What Happens | Visual |
|--------|-------|-------------|--------|
| **Ticking Time Bomb** | 20m AoE | EMP wave radiates outward from V, stunning enemies | Electrical arcs on V (epicenter) + staggered stun wave expanding by distance |
| **Blackwall Kill** | 25m AoE | Blackwall corruption spreads to nearby enemies | `HauntedBlackwallForceKill` + `BlackWallHack` — real Phantom Liberty Blackwall effects |

### Last Breath (Stage VI — Requires Second Heart)

When V dies at psycho level 5 and Second Heart revives them, Stage VI begins — David's final stand, inspired by Episode 10 of Edgerunners. All effects are synchronized to "I Really Want to Stay at Your House" (Rosa Walton, ~4:05).

**Phase 1 — Peace (20s):**
- All psychosis VFX stripped — the world is clear
- Song starts at 3s, Sandy activates at 5s with dilation ramp 90% → 99.35%
- Peak dilation (99.35%) held for 10s — David's moment of perfect clarity
- `CYBERPSYCHOSIS VI — UNCLASSIFIED — LAST BREATH`

**Phase 2 — Decay (~225s, song-synced):**
- Effects synchronized to the song's emotional arc:
  - **Chorus drops** (1:15, 2:46) → Ticking Time Bomb + Blackwall Kill fire
  - **Verse 2** (1:53) → calm, all combat effects pause
  - **Bridge** (3:08) → moment of clarity, ALL effects stripped
  - **Final Chorus** (3:40) → peak burst, maximum intensity
  - **Outro** (3:58) → effects fade
- Time dilation degrades 99.35% → 90% (exp 2.5 curve)
- Camera tremor, V's laugh, delusional messages — all song-phase aware
- Sandy cannot be deactivated — V is locked in

**Death:**
- Runtime hits 0: `THE MOON... I CAN SEE IT`
- 3s of terminal clarity → `DAVID MARTINEZ — FLATLINED` — permanent death

> Last Breath is a one-way trip. There is no recovery from Stage VI.
>
> For the full song-synced timeline, effect graphs, and implementation details, see **[docs/last-breath.md](docs/last-breath.md)**.

### Lore-Accurate Gameplay Systems

Six interconnected systems that make gameplay feel like David's experience in Edgerunners. All toggleable — disable any system without side effects. For formulas, cross-system interactions, and implementation details, see **[docs/lore-systems.md](docs/lore-systems.md)**.

#### Neural Strain (Episode Trigger)

An accumulation pool + dice roll system. Strain builds from Sandy use, kills, Safety OFF, and low runtime — episodes strike unpredictably once strain crosses the threshold for the current psycho level.

| Strain Source | Amount | Note |
|---------------|--------|------|
| Sandy activation | +5 base | +3 per overuse beyond safe limit |
| Sandy active | +2/min | Continuous accumulation |
| Safety OFF | +0.15/s | Automatic at stage 5 |
| Kill (Sandy active) | +2 to +8 | Faction-based (configurable): civilian=8, NCPD=5, corpo=3, gang=2 |
| Low runtime (<10%) | +0.5/s | Body exhausted, Sandy stresses it more |
| Zero runtime (0%) | +1.0/s | Death wish — body screams |

| Drain Source | Amount | Note |
|--------------|--------|------|
| Safe area | -0.05/s | Only when Sandy inactive |
| Sleep | -40 (scaled) | Scaled by hours rested |
| Ripperdoc | -25 | Professional treatment |
| Immunoblocker | -0.08/0.18/0.35/s | Per tier (Common/Uncommon/Rare). Reduces accumulation 80% (full) or 50% (partial) |
| DF Immunosuppressant | -0.08/s | Weaker, doesn't block accumulation |

When strain exceeds the threshold, a dice roll fires each second: `chance = (strain - threshold) / 200`. At the guaranteed cap, an episode is forced.

| Level | Threshold | Guaranteed | Experience |
|-------|-----------|------------|------------|
| 0 | 60 | 100 | Hard to trigger — highest thresholds, but overuse escalates to stage 1 |
| 1 | 50 | 90 | Manageable with care |
| 2 | 40 | 80 | Casual overuse is dangerous |
| 3 | 30 | 70 | Almost any aggressive session triggers |
| 4 | 20 | 60 | Constant danger |
| 5 | 10 | 50 | Near-inevitable |

#### Immunoblocker (Consumable Item)

Doc's prescribed medication — *"Nine times your customary dosage."* Reduces strain accumulation and drains existing strain while active. Effectiveness depends on tier vs psycho level: full (80% reduction + full drain), partial (50% reduction + full drain), or ineffective (0% reduction + 25% drain). Also suppresses micro-episodes and counts as a prescription treatment dose. Each tier has a custom inventory icon.

| Tier | Name | Quality | Duration | Price | Drain | Availability |
|------|------|---------|----------|-------|-------|-------------|
| Common | Immunoblocker | Rare (blue) | 180s (3 min) | 6,000€$ | 0.08/s | Always present |
| Uncommon | Immunoblocker — High Dosage | Epic (purple) | 360s (6 min) | 24,000€$ | 0.18/s | Commonly present |
| Rare | Military-Grade Immunoblocker | Legendary (gold) | 600s (10 min) | 100,000€$ | 0.35/s | Uncommonly present |

Sold exclusively through street vendors (VendorsXL): Arroyo punk dealer (all 3 tiers) and Kabuki street kid (Common + Uncommon only). Prices and kill strain per faction are configurable via in-game Settings UI.

#### Runtime as Body Endurance

Runtime represents how much V's body can take — not a battery charge. V can always reactivate the Sandy (no cooldown — David never had one in Edgerunners). The cost is progressive physical deterioration:

| Runtime % | Stamina | Speed | Armor | Tremor | Strain/s | Nosebleed |
|-----------|---------|-------|-------|--------|----------|-----------|
| 60–100% | ×1.5 boost | Normal | Normal | Stage-based only | — | — |
| 30–60% | Normal | Normal | Normal | Stage-based only | — | — |
| 10–30% | Normal | Normal | Normal | +0.003 | +0.15/s | On activation |
| 0–10% | ×0.5 | ×0.6 | ×0.5 | +0.006 | +0.5/s | On activation |
| 0% | ×0.5 | ×0.6 | ×0.5 | +0.006 | +1.0/s | On activation |

MaxRuntime degrades with psychosis — the body endures less at higher stages:

| Stage | MaxRuntime | With 300s base |
|-------|-----------|---------------|
| 0 | 100% | 300s |
| 1 | 90% | 270s |
| 2 | 80% | 240s |
| 3 | 65% | 195s |
| 4 | 50% | 150s |
| 5 | 35% | 105s |

Stage 4-5 also applies a permanent ×0.85 stamina regen debuff even outside Sandy.

#### Hallucinations (Stage 3-5)

V sees things that aren't real. Phantom NPCs spawn 5-15m from V, appear briefly with ghost VFX, then vanish.

| Stage | Frequency | Despawn time | Intensity |
|-------|-----------|-------------|-----------|
| 3 | Every 3-5 min | 3-5s | Subtle — *"Thought I saw..."* |
| 4 | Every 1-3 min | 5-8s | Unsettling — *"They're watching me..."* |
| 5 | Every 30-60s | 2-4s | Constant — *"THEY'RE EVERYWHERE"* |

Suppressed by immunoblocker (full/partial effectiveness).

#### Auto-Attack (Stage 4-5)

V involuntarily attacks nearby NPCs during Sandy — loss of control. The Sandy detects an NPC in front of V and fires/attacks automatically.

| Stage | Chance per second | Cooldown | Effect |
|-------|------------------|----------|--------|
| 4 | 15% | 30s | Weapon fires at NPC, red outline 2s, NPC becomes hostile |
| 5 | 35% | 30s | Same but more frequent — *"THEY WERE LOOKING AT ME"* |

Only triggers during Sandy active, with weapon equipped, NPC within 15m.

#### Blackout (Overuse Exhaustion)

At 3× safe daily activations, V collapses and wakes up hours later at a random safe location. Replaces the old stun mechanic with a full blackout sequence.

| Step | What happens |
|------|-------------|
| 1 | Sandy deactivates, screen darkens (*"Body gives out... everything goes dark"*) |
| 2 | Teleport to: apartment (60%), Viktor's clinic (30%), random alley (10%) |
| 3 | Time advances 4-8 hours, sleep recovery applied |
| 4 | Wake up with 50-70% health, groggy VFX, location-specific message |

Stage 5 Safety OFF: no blackout — V fights through to death (David doesn't pass out at stage 5).

#### Doc Prescription (Graduated Recovery)

Recovery is a process, not a button. Sleep cures -1 level max. Ripperdoc visits provide treatment doses. Higher psycho levels require more treatments — level 5 can't go below 4 without a ripper visit.

| Psycho Level | Required Treatments | Min Ripper Visits | Sleep Alone? |
|---|---|---|---|
| 1 | 1 | 0 | Yes (1 sleep) |
| 2 | 2 | 0 | Yes (2 sleeps) |
| 3 | 3 | 1 | No |
| 4 | 5 | 2 | No |
| 5 | 7 | 3 | No — can't go below 4 without ripper |

HUD shows `RX 2/5` next to psycho level when a prescription is active. Dark Future immunosuppressant counts as a partial treatment dose (60s accumulation = 0.5 dose).

#### Non-Linear Runtime Drain

The Sandy isn't a battery — it's a body. Drain accelerates the longer V stays in dilation. Session fatigue makes each activation less effective. Max runtime degrades with sustained use.

| System | Effect | Default |
|--------|--------|---------|
| **Accelerating drain** | After 60s continuous use, drain rate increases exponentially (exp 1.5) | First 60s normal, 120s = 2× drain, 180s = 3.8× |
| **Session fatigue** | Each activation past safe limit reduces dilation effectiveness | -2% per overuse, cap -10% |
| **Runtime degradation** | Each session costs 1% max runtime per 60s of use | Cap 50% loss, sleep recovers 75%, ripper restores 100% |

#### Micro-Episodes

Random involuntary symptoms between major psycho episodes. Unpredictable and cumulative — David's deterioration wasn't on a timer.

| Type | Min Level | Effect |
|------|-----------|--------|
| Visual glitch | 1 | Brief `hacking_glitch_low` (0.5–1.5s) |
| Tremor burst | 2 | Camera shake spike (1–3s) |
| Nosebleed | 2 | `burnout_glitch` VFX (3s) |
| Manic laugh | 3 | `perk_edgerunner_player` VFX (3s) |
| Sandy flash | 3 | Involuntary Sandy activation (1–2s), auto-stops |
| Medium glitch | 4 | Glitch + drugged VFX (1.5–3s) |

Frequency: every 5–10min at level 1, every 5–15s at level 5. Suppressed during Last Breath, menu/braindance, and while immunoblocker or DF immunosuppressant is active.

### On-Screen Notifications

Contextual notifications use V's inner monologue and Doc's voice — no HUD-style readouts. Messages vary randomly and scale with psycho level:

| Event | Example | Tone |
|-------|---------|------|
| Game load | `Spine hums to life... no safety net. Just the way David liked it` | Atmospheric |
| Game load (psycho) | `Head won't stop buzzing... Doc was right about the limits` | Foreboding |
| Activation | `Sandy's humming... let's go` / `Everything stops... skull's on fire` (lvl 3) | Escalating |
| Overuse (lvl 0) | `"Three times a day, David. I mean it." ...sorry, Doc` | Doc's voice |
| Overuse (lvl 3) | `Doc would lose it if he saw me now...` | David losing grip |
| Overuse (lvl 4) | `NOBODY SETS MY LIMITS` | Full psycho |
| Low runtime | `Running on fumes... should stop soon` | Warning |
| Deactivation | `World snaps back... everything aches` | Physical |
| Psycho level up | `CYBERPSYCHOSIS III — LOSING GRIP ON REALITY` | System warning |
| Hallucination | `They're watching me...` / `THEY'RE EVERYWHERE` | Paranoia |
| Auto-attack | `What did I just do...` / `THEY WERE LOOKING AT ME` | Loss of control |
| Blackout | `Body gives out... everything goes dark` | Collapse |
| Blackout wakeup | `Woke up at Viktor's... how did I get here?` | Disorientation |
| Sleep recovery | `Slept it off a little... but the buzzing's still there` | Partial relief |
| Sleep cured | `Head's clear... feels like me again` | Relief |
| Sleep recharge | `Sandy feels charged... spine's humming again` | Fresh start |
| Ripper treatment | `"Getting better, but we're not done. 3 more sessions."` | Doc's voice |
| Ripper cured | `"You're clean, kid. Don't make me do this again."` | Doc's voice |
| Exhaustion | `Body gives out... pushed too far today` | Collapse |
| Death | `DAVID... IT'S TIME TO STOP` | Finality |
| Last Breath | `CYBERPSYCHOSIS VI — UNCLASSIFIED — LAST BREATH` | System warning |
| Last Breath death | `DAVID MARTINEZ — FLATLINED` | Permanent |

### Sensory Effects (Edgerunners-Accurate)

Lore-accurate physical effects inspired by David Martinez's deterioration across Episodes 2–10:

| Effect | Trigger | Lore Reference |
|--------|---------|----------------|
| **Camera shake** | Psycho lvl 1–5 (progressive intensity 0.001→0.008) | David's hands shake from Ep 5 onward, worsening through Ep 8–10 |
| **Manic laughter** | Random at psycho lvl 4–5 (`perk_edgerunner_player` VFX) | David laughing uncontrollably in Ep 10 |
| **FOV pulse** | Every Sandy activation (+12° for 0.4s) | Perception shift on Sandevistan activation |
| **Heartbeat** | Psycho lvl 2+ idle, or Sandy active with low health | Tension audio during David's deterioration |
| **Nosebleed** | Sandy activation after exceeding safe daily limit | David bleeds from the nose in Ep 2, 3, 5, 9 |
| **Random nosebleed** | Psycho lvl 2+ independent of Sandy (intervals: 4–8min at lvl 2, 30–60s at lvl 5) | David bled unprompted in Ep 3, 5, 9 — getting worse without using the Sandy |
| **Blackout collapse** | Sandy activation at 3× safe daily limit → teleport to safe location + time skip | David passes out after 8 uses in Ep 2 |
| **Hallucinations** | Phantom NPCs appear and vanish at psycho lvl 3-5 | David seeing things in Eps 8-10 |
| **Auto-attack** | Involuntary weapon fire at nearby NPCs at psycho lvl 4-5 | David losing control in Ep 10 |
| **Micro-episodes** | Random at psycho lvl 1–5 (frequency scales with level) | David's involuntary twitches, glitches, and nosebleeds throughout Eps 5–10 |
| **Terminal clarity** | 2.5s before death at psycho lvl 5 | David snaps out of psychosis right before death in Ep 10 |
| **V's laugh** | Random during Last Breath decay phase | David laughing through the pain in Ep 10 |
| **"I Really Want to Stay at Your House"** | Plays during Last Breath peace phase | The song from the anime's final scenes |
| **Delusional messages** | Every 4–8s during Last Breath decay | David's fragmented thoughts about Lucy and the Moon |

## Requirements

- [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107)
- [Native Settings UI](https://www.nexusmods.com/cyberpunk2077/mods/3518)
- [ArchiveXL](https://www.nexusmods.com/cyberpunk2077/mods/4198)
- [Codeware](https://www.nexusmods.com/cyberpunk2077/mods/7780) (HUD auto-scaling via VirtualResolutionWatcher)
- [Audioware](https://www.nexusmods.com/cyberpunk2077/mods/12001) (Last Breath song playback, independent of Wwise)

## Installation

Extract into your Cyberpunk 2077 installation directory:

```
Cyberpunk 2077/
├── archive/pc/mod/
│   ├── david-sandevistan-plus.archive
│   └── david-sandevistan-plus.archive.xl
├── bin/x64/plugins/cyber_engine_tweaks/mods/
│   ├── DavidSandevistanPlus/
│   │   ├── init.lua
│   │   ├── martinez.lua
│   │   ├── loreEffects.lua
│   │   ├── strain.lua
│   │   ├── psychosis.lua
│   │   ├── death.lua
│   │   ├── immunoblocker.lua
│   │   ├── immunoblocker_logic.lua
│   │   ├── gameListeners.lua
│   │   ├── entEffects.lua
│   │   ├── ncpd.lua
│   │   ├── hud.lua
│   │   └── gui.lua
│   └── MartinezPLUS/
│       └── init.lua
├── r6/audioware/DavidSandevistanPlus/
│   ├── audios.yaml
│   └── last_breath_song.ogg
└── r6/scripts/DavidSandevistanPlus/
    ├── DSPHUDSystem.reds
    └── DSPKillTracker.reds
```

> **Note:** The Last Breath song is played via [Audioware](https://www.nexusmods.com/cyberpunk2077/mods/12001), which uses its own audio engine (Kira) independent of Wwise. The song plays at normal speed even during Sandy's 99.35% time dilation thanks to `affectedByTimeDilation = false`.

## Settings

Open the game menu: **Settings > Mods > Martinez Sandy+**

### Time Dilation
| Setting | Options | Default | Description |
|---------|---------|---------|-------------|
| Time Dilation (No Perk) | 85%–99.5% | 95% | Time dilation without EdgeRunner perk |
| Time Dilation (With Perk) | 85%–99.5% | 99.35% | Time dilation with EdgeRunner perk |
| Require EdgeRunner Perk | on/off | on | Require perk for enhanced dilation (off = full access from day 1) |

#### Progressive Dilation Degradation

Time dilation degrades as runtime depletes — higher psychosis stages degrade faster. The curve follows `rtRatio^exp` where higher exponents mean the peak fades quicker:

| Stage | Dilation Range | Curve | Behavior |
|-------|---------------|-------|----------|
| 0 Normal | 90% (capped) | — | Capped at 90% regardless of perk — Sandy works, not at full potential |
| 1 Unstable | 92.5% → 90% | exp 1.5 | Nearly linear |
| 2 Glitching | 93.5% → 90% | exp 1.8 | Slight acceleration |
| 3 Losing It | 95% → 90% | exp 2.0 | Quadratic drop |
| 4 On The Edge | 96.5% → 87% | exp 2.3 | Peak fades fast |
| 5 Cyberpsycho | 97.5% → 85% | exp 2.8 | Brief flash of peak |
| 6 Last Breath | 99.35% → 90% | Multi-phase | See [last-breath.md](docs/last-breath.md) |

For curve visualizations and formulas, see **[docs/dilation-curves.md](docs/dilation-curves.md)**. For Stage 6 song-synced timeline, see **[docs/last-breath.md](docs/last-breath.md)**.

### Duration & Cooldown
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Runtime Tank (sec) | 1–600 | 300 | Total runtime reservoir (drains at different rates) |
| Recharge Duration | 0.5–30 | 2.0 | Base recharge time after deactivation |
| Cooldown Base | 0.1–10 | 0.5 | Cooldown multiplier between activations |
| Activation Cost | 0–1 | 0.0 | Stamina cost to activate (0 = free) |
| Kill Recharge Value | 0–50 | 2.0 | Runtime recharged per kill during Sandy |

### Combat Stats (while Sandy active)
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Critical Chance | 0–100 | 30 | Bonus crit chance |
| Critical Damage | 0–500 | 35 | Bonus crit damage |
| Headshot Damage Multiplier | 1.0–5.0 | 1.5 | Headshot damage multiplier |

### On-Kill Effects (while Sandy active)
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Heal on Kill | 0–50% | 3 | Health restored per kill |
| Stamina on Kill | 0–100 | 22 | Stamina restored per kill |

### Health Drain
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Enable Health Drain | on/off | on | Toggle health cost while Sandy is active |
| Minimum Damage per Tick (%) | 0–10% | 1.0 | Health drain at full runtime |
| Maximum Damage per Tick (%) | 0–50% | 15.0 | Health drain at zero runtime |

### Health Brake (Emergency Stop)
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Enable Health Brake | on/off | off | Auto-stop Sandy on low health |
| Health Brake Threshold | 15–80% | 50 | Health % to trigger brake |
| Minimum Required Health | 5–50% | 15 | Absolute minimum health threshold |

> **Safety ON/OFF** is automatic — stages 0-4 have Safety ON, stage 5+ has Safety OFF. Not configurable.

### Recharge & Recovery
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Full Recharge Hours | 1–48 | 16 | In-game hours for full recharge |
| Max Recharge Per Sleep | 1–24 | 10 | Max recharge hours per sleep |
| Enable Runtime Degradation | on/off | on | Each session costs max runtime (1%/60s, cap 50%) |
| Sleep Recovery (%) | 0.25–1.0 | 0.75 | % of degraded runtime recovered by sleep |
| Ripper Full Restore | on/off | on | Ripperdoc fully restores max runtime |

### Cyberpsychosis
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Enable Cyberpsychosis | on/off | on | Toggle the cyberpsychosis system |
| Safe Activations per Day | 1–20 | 3 | Activations before strain acceleration |
| Enable Session Fatigue | on/off | on | Repeated activations reduce dilation effectiveness |
| Fatigue Penalty per Overuse | 0.01–0.10 | 0.02 | Dilation loss per excess activation (2% default) |
| Max Fatigue Penalty | 0.05–0.30 | 0.10 | Maximum dilation penalty cap (10% default) |

### Neural Strain
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Strain Buildup Speed | 0.25–3.0 | 1.0 | Global multiplier for all strain accumulation |
| Strain Recovery Speed | 0.25–3.0 | 1.0 | Global multiplier for all strain drain |

> Individual strain values (per-activation, per-kill, drain rates, etc.) are preconfigured with lore-accurate defaults. Advanced users can tune them via `config.json`.

> **Comedown** has been removed. Penalties are now runtime-based — V's body deteriorates progressively during Sandy use, not after. No reactivation block (lore-accurate: David never had a cooldown).

### Doc Prescription (Graduated Recovery)
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Enable Prescription | on/off | on | Require multiple treatments to cure psychosis |
| Max Recovery Per Sleep | 1–5 | 1 | Maximum psycho levels recovered per sleep |
| Ripper Recovery Levels | 1–3 | 1 | Psycho levels recovered per ripperdoc visit |

### Non-Linear Runtime Drain
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Enable Non-Linear Drain | on/off | on | Drain accelerates with sustained use |
| Drain Exponent | 1.0–3.0 | 1.5 | Acceleration curve steepness |
| Drain Acceleration Start | 10–180 sec | 60 | Seconds before acceleration kicks in |

### Micro-Episodes (Random Symptoms)
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Enable Micro-Episodes | on/off | on | Random involuntary symptoms at psycho 1+ |
| Frequency Multiplier | 0.25–3.0 | 1.0 | Scale episode frequency (0.5 = half, 2.0 = double) |

## How It Works

**DavidSandevistanPlus** has all gameplay values exposed in a configurable `cfg` table. **MartinezPLUS** provides the Native Settings UI and writes to `DavidSandevistanPlus/config.json`. Changes to TweakDB values apply instantly; gameplay parameters update both at runtime and persist to disk.

### Daily Activation Counter

Inspired by Doc's warning to David: "don't use it more than 3 times a day." Each activation beyond the safe limit adds bonus Neural Strain. The effect stacks — the more you overuse it, the faster psychosis progresses. Counter resets when V sleeps.

### Cyberpsychosis Flow

```
Activate Sandy → strain accumulates (+5 base, +3 per overuse)
  ├─ Sandy active: +2/min strain
  ├─ Safety OFF (stage 5): +0.15/s strain
  ├─ Kills during Sandy: +2 to +8 strain (faction-based, configurable)
  ├─ Low runtime (<10%): +0.5/s strain (body exhausted)
  └─ Zero runtime (0%): +1.0/s strain (death wish)

Strain exceeds threshold → dice roll each second:
  ├─ chance = (strain - threshold) / 200
  ├─ Stages 0-4: EPISODE → Sandy shuts down + Safety ON + psychoLevel++
  ├─ Stage 5 Safety OFF: EPISODE → Sandy stays active + FrightenNPCs
  └─ Strain hits guaranteed cap → forced episode (can't avoid)

Runtime-based penalties (during Sandy active):
  ├─ >30%: stamina ×1.5 (body energized)
  ├─ 10-30%: tremor + nosebleed + strain +0.15/s
  ├─ <10%: stamina ×0.5, speed ×0.6, armor ×0.5, strain +0.5/s
  └─ 0%: strain +1.0/s (pushing past all limits)

MaxRuntime scales by stage: 100% → 90% → 80% → 65% → 50% → 35%

Overuse exhaustion (3× safe activations):
  ├─ Stages 0-4: BLACKOUT → teleport to safe location + time skip 4-8h
  └─ Stage 5: no blackout — death path (David fights to the end)

Psychosis features by stage:
  ├─ Stage 3+: Hallucinations (phantom NPCs spawn and vanish)
  ├─ Stage 4+: Auto-attack (involuntary weapon fire at nearby NPCs)
  └─ Stage 5: Safety OFF automatic, Sandy stays on during episodes

Death at level 5 + Second Heart:
  └─ Last Breath (Stage VI)
      ├─ Peace (20s): VFX cleared, max dilation 99.35%, song plays
      ├─ Decay (~225s): VFX ramp, dilation drops, Blackwall kills
      └─ Runtime = 0 → permanent death (DAVID MARTINEZ — FLATLINED)

Recovery (levels 1–5) — Graduated:
  ├─ Sleep: -1 psycho level max + drains strain + partial treatment dose
  ├─ Visit Viktor: -1 level + drains strain + treatment dose + runtime recharge
  ├─ Immunoblocker: reduces strain accumulation + drains strain + counts as dose
  ├─ Level 3+: requires ripper visit(s) — can't fully cure with sleep alone
  ├─ Level 5: needs 7 treatments (3 ripper + 4 sleep) to fully clear
  └─ HUD shows prescription progress: "RX completed/total"
```

## Compatibility

### Dark Future

Fully compatible with [Dark Future](https://www.nexusmods.com/cyberpunk2077/mods/12950). The two mods use different scripting systems (CET/Lua vs Redscript), separate TweakDB records, and independent Quest Fact namespaces — no conflicts.

Both mods have their own cyberpsychosis systems that coexist:
- **Dark Future** — Humanity Loss from cumulative cyberware installation
- **David Sandevistan Plus** — Cyberpsychosis from overusing the Sandevistan specifically

With both active, V faces double pressure — which is lore-accurate: David's psychosis came from both excessive chrome AND pushing the Sandevistan past its limits.

#### Dark Future Consumable Integration

David Sandevistan Plus automatically detects Dark Future's consumable status effects and reacts to them:

| Dark Future Consumable | Effect on our Cyberpsychosis System |
|---|---|
| **Immunosuppressant** | Drains Neural Strain at -0.08/s (weaker than our Immunoblocker, doesn't block accumulation). Counts as partial treatment dose (60s = 0.5 dose). Suppresses micro-episodes. |
| **Endotrisine** | Halves strain accumulation from Sandevistan use and Safety Off. |

No configuration needed — if Dark Future is installed and V takes these consumables, the effects apply automatically. If Dark Future is not installed, these checks are safely skipped.

Our **Immunoblocker** is stronger than DF's Immunosuppressant: it reduces strain accumulation by 80% (full) or 50% (partial) and drains at 0.08–0.35/s depending on tier. Available exclusively from street vendors (Arroyo + Kabuki). Both can be active simultaneously without conflict.

## Credits

- **keanuWheeze** — [Native Settings UI](https://www.nexusmods.com/cyberpunk2077/mods/3518)

## License

[MIT](LICENSE)
