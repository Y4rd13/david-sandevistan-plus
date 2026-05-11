# David Sandevistan Plus

Custom Cyberpunk 2077 Sandevistan mod with lore-accurate defaults and every gameplay parameter configurable via an in-game Settings menu.

## Features

- **Lore-accurate defaults** — Safety ON/OFF is automatic based on psycho stage (stage 5+ = limiters fail)
- Custom icon and localization (MILITECH "DAVID MARTINEZ" SANDEVISTAN PLUS)
- In-game settings via Mod Settings tab: **David Sandevistan Plus** (7 categories, 44 tunables)
- Daily activation counter — Doc warned David not to use it more than 3 times a day
- No health brake by default — David never had an auto-stop
- Progressive dilation — stage 0 starts at 90%, power increases with psychosis (up to 99.35% at stage 6)
- Config persists across sessions via `config.json`
- **Lore-accurate gameplay systems** — neural strain, runtime as body endurance, immunoblocker items, hallucinations, auto-attack, blackout, graduated recovery, non-linear drain, micro-episodes (see below)

### Custom HUD

A minimal HUD overlay showing real-time Sandy status:
- **Runtime bar** — color-coded with time dilation percentage (represents body endurance, not battery)
- **Activation counter** — daily activations vs safe limit
- **Psycho bar** — visible when cyberpsychosis is active, showing current stage
- **Strain bar** — Neural Load level, visible when strain > 0
- **Contextual status** — COMEDOWN timer, RECOVERING (safe area), STABILIZED (DF immunosuppressant)
- **Auto-hides** when phone, inventory, or menus are open (UISystem integration)

### Biomonitor (Animated Medtech Panel)

An animated biomonitor panel (Animated Widgets Framework) showing all treatment and status data in one unified view. Toggleable via CET keybind, auto-triggers on stage change, neural load threshold, and milestone advance.

- **Status section**: Tolerance, Efficacy, Neural Load, Cyberpsychosis stage, Treatment RX progress
- **Protocol section**: Prescribed doses + tier, Visits (with countdown to next), Rest hours, Milestone progress
- **Substance detection**: Separate cyan notification panel when immunoblocker is consumed — shows detected substance and dynamic feedback ("Insufficient for Stage V" / "Treatment dose registered — 3 remaining")
- **Auto-fade**: Substance detection panel auto-closes ~5s after consumption. The main biomonitor stays open until the player closes it (no timed fade)
- **Position configurable** via the in-game Mod Settings UI

### Progressive Cyberpsychosis

A 5-level system inspired by David Martinez's descent in Edgerunners:

| Level | Name | Persistent VFX | Gameplay |
|-------|------|---------------|----------|
| 0 | Normal | None | Full functionality — heavy overuse triggers first episode |
| 1 | Unstable | None | Subtle tremor (0.001), micro-episodes every 5-10 min |
| 2 | Glitching | Subtle glitch | Persistent `hacking_glitch_low`, heartbeat, tremor, random nosebleeds |
| 3 | Losing It | Medium distortion | Persistent glitch + drugged VFX, stronger tremor |
| 4 | On The Edge | Heavy distortion | 3-layer VFX, 15% movement penalty, manic laughter, **auto-attack** (involuntary, stage 3+), hallucinations |
| 5 | Cyberpsycho | Full psychosis | 5 simultaneous VFX, 15% movement penalty, Safety OFF automatic, Sandy stays active during episodes |
| 6 | Last Breath | All VFX removed → ramp | **Permanent death** — Second Heart revival triggers final stand |

**Safety is automatic:** Stages 0-4 have Safety ON (limiters active). At stage 5, Safety OFF engages automatically — the limiters fail and V can't stop, like David in Episode 10. Sandy stays active during psycho episodes at stage 5. Death is near-inevitable.

#### Psychosis Combat Effects

During psychosis episodes (stage 3+) and Last Breath, V's cyberware delivers combat advantages and malfunctions offensively:

| Effect | Context | What Happens |
|--------|---------|-------------|
| **PsychosisCombatBuff** | Episodes + Last Breath decay | +50% movement speed, +100% armor, x10 health regen -- David was STRONGER during psychosis |
| **Cycled SFX** | Episodes + Last Breath decay | `ui_gmpl_perk_edgerunner` (Edgerunner perk sound) fires during psychosis episodes and Last Breath decay |
| **Weapon auto-draw** | Episodes (FrightenNPCs) | `DrawItemRequest` forces weapon draw from wheel slot -- V reaches for a weapon involuntarily |
| **Ticking Time Bomb** | Last Breath decay | 20m AoE EMP wave stuns enemies (Stun + EMP + Electrocuted status effects) |
| **Blackwall Kill** | Last Breath decay | 25m AoE Blackwall corruption (`HauntedBlackwallForceKill` + `BlackWallHack` -- real Phantom Liberty effects) |
| **Blackwall Civilian Corruption** | Last Breath decay | V's cyberware malfunctions and corrupts nearby civilians: 30% chance at Chorus 1, 40% at Chorus 2, 60% at Final Chorus |

### Last Breath (Stage VI — Requires Second Heart)

When V dies at psycho level 5 and Second Heart revives them, Stage VI begins — David's final stand, inspired by Episode 10 of Edgerunners. All effects are synchronized to "I Really Want to Stay at Your House" (Rosa Walton, ~4:05).

**Phase 1 — Peace (20s):**
- All psychosis VFX stripped — the world is clear
- Song starts at 3s, Sandy activates at 5s with dilation ramp 90% → 99.35%
- Peak dilation (99.35%) held for 10s — David's moment of perfect clarity
- `CYBERPSYCHOSIS VI — UNCLASSIFIED — LAST BREATH`

**Phase 2 — Decay (~225s, song-synced):**
- Combat buffs active throughout decay (+50% speed, +100% armor, x10 health regen)
- Cycled SFX: `ui_gmpl_perk_edgerunner` fires at decay start
- Effects synchronized to the song's emotional arc:
  - **Chorus 1** (1:15) → Ticking Time Bomb + Blackwall Kill + 30% Blackwall civilian corruption
  - **Chorus 2** (2:46) → full intensity + 40% civilian corruption
  - **Verse 2** (1:53) → calm, all combat effects pause
  - **Bridge** (3:08) → moment of clarity, ALL effects stripped
  - **Final Chorus** (3:40) → peak burst, maximum intensity + 60% civilian corruption
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

Eight interconnected systems that make gameplay feel like David's experience in Edgerunners. All toggleable — disable any system without side effects. For formulas, cross-system interactions, and implementation details, see **[docs/lore-systems.md](docs/lore-systems.md)**.

#### Neural Strain (Episode Trigger)

An accumulation pool + dice roll system. Strain builds from Sandy use, kills, Safety OFF, and low runtime — episodes strike unpredictably once strain crosses the threshold for the current psycho level.

| Strain Source | Amount | Note |
|---------------|--------|------|
| Sandy activation | +5 base | +3 per overuse beyond safe limit |
| Sandy active | +2/min | Continuous accumulation |
| Safety OFF | +0.10/s | Automatic at stage 5 |
| Kill (Sandy active) | +2 to +6 | Faction-based (configurable): civilian=6, NCPD=5, corpo=3, gang=2 |
| Low runtime (<10%) | +0.5/s | Body exhausted, Sandy stresses it more |
| Zero runtime (0%) | +1.0/s | Death wish — body screams |

| Drain Source | Amount | Note |
|--------------|--------|------|
| Safe area | -0.05/s | Only when Sandy inactive |
| Sleep | -40 (scaled) | Scaled by hours rested and activity multiplier (x1.0 to x2.5) |
| Ripperdoc | -25 | Professional treatment |
| Activities | -2 to -8 (immediate) | Lover -5, sleepWithLover -8, shower -5, social -3, pet -2, apartment -2 |
| Immunoblocker | -0.08/0.18/0.35/s | Per tier (Common/Uncommon/Rare). Reduces accumulation 80% (full) or 50% (partial) |
| DF Immunosuppressant | -0.08/s | Weaker, doesn't block accumulation |

Strain sources are split into two categories with different scaling:

- **Tolerance-based strain** (Sandy activation, overuse bonus, active time): scaled by a stage multiplier that reflects the body's growing tolerance to cyberware. Stage 0-1: x0.5, Stage 2: x0.75, Stage 3-5: x1.0.
- **Psychological/physical strain** (kills, low/zero runtime, Safety OFF): bypasses the stage multiplier (`raw=true`). The psychological trauma of killing and the physical stress of pushing the body at zero runtime hit equally hard at all stages.

When strain exceeds the threshold, a dice roll fires **every 15 seconds**: `chance = progress × 0.20`, where `progress = (strain - threshold) / (guaranteed - threshold)`, clamped to 1.0. So the chance ramps from 0 to a peak of 20% per roll as strain climbs from threshold to guaranteed. At guaranteed (or above), an episode is forced.

| Level | Threshold | Guaranteed | Episode Cooldown | Experience |
|-------|-----------|------------|-----------------|------------|
| 0 | 100 | — | — | Only dice rolls fire — no guaranteed ceiling |
| 1 | 85 | — | 48h | Manageable with care |
| 2 | 70 | 120 | 36h | Casual overuse is dangerous |
| 3 | 55 | 100 | 24h | Almost any aggressive session triggers |
| 4 | 40 | 100 | 12h | Constant danger, passive strain +0.025/s |
| 5 | 30 | 70 (forced) | 6h | Near-inevitable, passive strain +0.05/s |

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

| Stage | Frequency | Phantom lifetime | Intensity |
|-------|-----------|-----------------|-----------|
| 3 | Every 3-5 min | 4-6s (all behaviours) | Subtle — *"Thought I saw..."* |
| 4 | Every 1-3 min | 8-14s (4-6s for lover phantoms) | Unsettling — *"They're watching me..."* |
| 5 | Every 30-60s | 10-20s (4-6s for lover phantoms) | Constant — *"THEY'RE EVERYWHERE"* |

> Phantom lifetime grows with stage — they linger longer as the brain loses grip. The exception is `lover_stare` behaviour (Lucy phantoms), which always stays brief. Phantoms also despawn early if V walks past a proximity threshold.

Suppressed by immunoblocker (full/partial effectiveness).

#### Auto-Attack (Stage 3-5)

V involuntarily attacks nearby NPCs — loss of motor control. Uses `AIWeapon.Fire()` to fire V's weapon at a detected NPC, the same method used by Wannabe Edgerunner. Does not require aiming. If weapon is in hand, fires immediately with `ono_v_laughs_hard`. If no weapon is drawn, `DrawItemRequest` forces a draw from the weapon wheel slot, then fires after a 2s delay.

Four trigger points, each with stage-scaled chances (stage 2 already has small chances for the three non-laugh triggers):

| Trigger | Stage 2 | Stage 3 | Stage 4 | Stage 5 | Context |
|---------|---------|---------|---------|---------|---------|
| Manic laugh (micro-episode) | — | 30% | 50% | 70% | Laugh → hand fires on its own |
| Stage change (BleedingEffect) | 15% | 40% | 60% | 80% | Psycho level escalation → violent outburst |
| Low runtime (<10%, per second) | 5% | 10% | 20% | 35% | Body exhausted, Sandy stresses the nervous system |
| Nosebleed (on activation) | 3% | 5% | 15% | 25% | Physical deterioration → involuntary trigger pull |

30s cooldown between attacks. NPC within 15m, red outline 2s, target becomes hostile. Post-attack VFX (PsychoWarningEffect_Medium) + camera shake + contextual messages (*"What did I just do..."* / *"THEY WERE LOOKING AT ME"*).

#### Blackout (Overuse Exhaustion)

At 3x safe daily activations, V collapses and wakes up hours later at a safe location. Stage-based chance determines whether the blackout fires: 90% at stage 0, 70% at stage 1, 40% at stage 2, 15% at stage 3. V must be within 200m of a known safe location; otherwise a stun-only fallback triggers. Daily cooldown (one blackout per day). Stage 4-5: no blackout -- psychosis/death path takes over.

| Step | What happens |
|------|-------------|
| 1 | Sandy deactivates, screen darkens (*"Body gives out... everything goes dark"*) |
| 2 | Teleport to nearest safe location within 200m |
| 3 | Time advances 4-8 hours |
| 4 | Wake up with location-specific recovery |

Recovery depends on location type:

| Location | Type | Strain Drain | Runtime Restore | Health | Psycho Recovery |
|----------|------|-------------|-----------------|--------|-----------------|
| V's apartment | Apartment | -15 | +25% max | 40-60% | Can reduce psycho level (like sleep) |
| Viktor's clinic | Ripper | -25 | +50% max | 60-70% | Treatment dose only |
| Kabuki ripper | Ripper | -25 | +50% max | 60-70% | Treatment dose only |

#### Treatment Protocol (Graduated Recovery)

Recovery is a process with three pillars: **medication**, **ripperdoc visits**, and **rest**. Viktor prescribes a full protocol — the biomonitor tracks progress. Treatment milestones (33%/66%) provide increasing protection against stage escalation.

| Stage | Doses (Base) | Min Tier | Visits | Rest | Treatment Days |
|-------|-------------|----------|--------|------|---------------|
| 1 | 3 | Common | 1 | 8h | ~1 day |
| 2 | 5 | Common | 1 | 8h | ~2 days |
| 3 | 5 | Uncommon | 2 | 12h | ~2 days |
| 4 | 7 | Military Grade | 3 | 16h | ~3 days |
| 5 | 10 | Military Grade | 5 | 24h | ~5 days |

**Doses scale with tolerance**: tolerance stage 1 = x1.3, stage 2 = x1.6, stage 3 = x2.0 required doses.

**Ripperdoc visits**: hover over the Sandevistan in any ripperdoc menu → "Stabilize Sandevistan" button. 24h game-time cooldown between visits. Cost scales with stage (2,000–20,000 eddies).

**Treatment protection**: active treatment milestones dynamically extend episode cooldowns — 33% milestone = x1.66, 66% = x2.33. Following the protocol prevents stage escalation. Not following it = normal degradation speed.

**Rest**: sleep hours count toward the protocol. The biomonitor shows "Rest: 8/16h".

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
| **Random nosebleed** | Psycho lvl 2+ independent of Sandy (intervals: 5–10min at lvl 2, 3–6min at lvl 3, 90s–3min at lvl 4, 45–90s at lvl 5) | David bled unprompted in Ep 3, 5, 9 — getting worse without using the Sandy |
| **Blackout collapse** | Sandy activation at 3× safe daily limit → teleport to safe location + time skip | David passes out after 8 uses in Ep 2 |
| **Hallucinations** | Phantom NPCs appear and vanish at psycho lvl 3-5 | David seeing things in Eps 8-10 |
| **Auto-attack** | Involuntary weapon fire (`AIWeapon.Fire()`) at nearby NPCs at psycho lvl 3-5, from 4 trigger points | David losing control in Ep 10 |
| **Micro-episodes** | Random at psycho lvl 1–5 (frequency scales with level) | David's involuntary twitches, glitches, and nosebleeds throughout Eps 5–10 |
| **Pre-psychosis VFX** | Before each psycho episode (`PrePsychosisEffect`: ~8s of blackout distortion + Blackwall scream at stage 4+, with the scream firing 4s after VFX start) | David's vision distorting before losing control |
| **Terminal clarity** | 4s before death at psycho lvl 5 (KillV → RemoveAllVFX → "..." → KillV_Execute) | David snaps out of psychosis right before death in Ep 10 |
| **V's laugh** | Random during Last Breath decay phase | David laughing through the pain in Ep 10 |
| **"I Really Want to Stay at Your House"** | Plays during Last Breath peace phase | The song from the anime's final scenes |
| **Delusional messages** | Every 4–8s during Last Breath decay | David's fragmented thoughts about Lucy and the Moon |

### Martinez Rush (Kill-Triggered Combat Burst)

An Edgerunner-inspired burst that can proc on kill while Sandy is active — V briefly slips into the same combat high David hit during his best runs. Higher psychosis = higher chance, higher risk.

| Mechanic | Detail |
|----------|--------|
| Trigger | Every kill during Sandy rolls against a per-stage chance (2% / 4% / 7% / 12% / 18% / 25%) |
| Cooldown | 45s real-time between procs (configurable) |
| Duration | 12s base, +25% if Safety OFF — so up to 15s |
| Requires Edgerunner perk | Default **on**. Rush only procs if V has the vanilla Edgerunner perk unlocked in the Reflexes tree. Disable the toggle to get Rush regardless of perks. |
| Stat bonuses (configurable) | +67% fire rate, +40% melee speed, +82% reload speed, +25% movement, +20 crit chance, +35 crit damage, +45% armor, 6.0× combat regen |
| Cost | Runtime drain ×1.5 for the entire window, plus a 3s stamina crash that lands **the moment Sandy deactivates** (never wasted in time dilation) |
| Audio cue | Kerenzikov entry SFX + a 35% chance per kill to hear V laugh (`ono_v_laughs_hard/soft/long`, 3.5s cooldown between laughs) |
| Visual cue | ~0.56s pre-cue flash (`dsp_martinez_rush_init` — custom effect shipped with the mod archive) then a red Blackwall frame overlay around the screen edges for the duration |

Every bonus above plus the chance multiplier, duration, cooldown, drain multiplier and perk gate are exposed as their own entries under the **Martinez Rush** category in the in-game Mod Settings UI. Rush does **not** add neural strain — it intentionally stays out of the cyberpsychosis progression budget so the stage cadence stays intact.

### Activity Tracking + Sleep Multiplier

Human connections reduce Neural Strain and improve sleep recovery. David stayed human through Lucy and his crew -- these interactions ground V the same way.

Six activities are tracked per day. Each gives an immediate strain drain and contextual message. Some also restore runtime. On sleep, the total activity count determines a sleep multiplier that scales strain drain: 1.0 base + 0.25 per activity, up to x2.5 with all six.

| Activity | Immediate Strain Drain | Runtime Restore | Detection |
|----------|----------------------|-----------------|-----------|
| Lover (romantic partner) | -5 | +10% max | Redscript LocKey match (requires active romance quest fact) |
| Sleep with Lover | -8 | +15% max | Redscript LocKey match |
| Shower | -5 | +5% max | Redscript LocKey match + CET status effect fallback |
| Social (dance, drink, rollercoaster) | -3 | -- | Redscript LocKey match |
| Pet (Nibbles, cats, iguana) | -2 | -- | Redscript LocKey match + CET status effect fallback |
| Apartment amenity (coffee, guitar, incense) | -2 | -- | 30s in safe area (not club, not running Sandy) |

Activities reset on sleep. The sleep multiplier formula: `1.0 + (activityCount * 0.25)`.

Detection uses two phases: **Phase 2** (primary) is redscript `DSPActivityTracker.reds`, which wraps `dialogWidgetGameController` to intercept dialog LocKeys and match them to activities via `DSPActivityChecker.Check()`. **Phase 1** (fallback) is CET status effect observers that detect shower and pet interactions via status effect names.

## Requirements

All listed mods must be installed for David Sandevistan Plus to function.

**Loaders and frameworks:**
- [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107) — CET, the Lua runtime that drives the core logic
- [RED4ext](https://www.nexusmods.com/cyberpunk2077/mods/2380) — native plugin loader (dependency of Codeware / ArchiveXL / TweakXL / Audioware)
- [redscript](https://www.nexusmods.com/cyberpunk2077/mods/1511) — compiles every `.reds` file in `r6/scripts/`

**Modding frameworks:**
- [ArchiveXL](https://www.nexusmods.com/cyberpunk2077/mods/4198) — required by the custom `.archive.xl` (sectors, quest phases, journal)
- [TweakXL](https://www.nexusmods.com/cyberpunk2077/mods/4197) — loads `r6/tweaks/DavidSandevistanPlus/*.yaml` (immunoblocker items, vendors, status effects, auto-injector cyberware)
- [Codeware](https://www.nexusmods.com/cyberpunk2077/mods/7780) — HUD auto-scaling via `VirtualResolutionWatcher`, ScriptableSystem helpers
- [Audioware](https://www.nexusmods.com/cyberpunk2077/mods/12001) — Last Breath song + 136 V male voice lines + Blackwall scream (independent of Wwise, supports `affectedByTimeDilation = false`)
- [Mod Settings](https://www.nexusmods.com/cyberpunk2077/mods/4885) — the in-game UI tab that exposes every tunable declared via `@runtimeProperty` in `DSPSettings.reds`. **Not the same as "Native Settings UI" (mod 3518)** — `DSPSettings.reds` uses the newer Mod Settings module by Jackhumbert.

## Installation

Extract into your Cyberpunk 2077 installation directory, preserving the folder structure:

```
Cyberpunk 2077/
├── archive/pc/mod/
│   ├── david-sandevistan-plus.archive
│   └── david-sandevistan-plus.archive.xl
│
├── bin/x64/plugins/cyber_engine_tweaks/mods/
│   └── DavidSandevistanPlus/
│       ├── init.lua                  ← entry point + main loop
│       ├── martinez.lua              ← TweakDB status effect factory
│       ├── strain.lua                ← neural strain system
│       ├── psychosis.lua             ← stage progression + hallucinations
│       ├── death.lua                 ← Last Breath / Stage VI
│       ├── immunoblocker_logic.lua   ← tolerance + auto-injector
│       ├── loreEffects.lua           ← tremor, nosebleed, blackout
│       ├── gameListeners.lua         ← game event registration
│       ├── entEffects.lua            ← entity-level effects
│       ├── ncpd.lua                  ← NCPD / MaxTac escalation
│       ├── hud.lua                   ← CET→redscript HUD bridge
│       ├── sms.lua                   ← Viktor SMS + vendor proximity
│       ├── voice.lua                 ← Audioware voice line bridge
│       ├── gui.lua                   ← CET ImGui debug window
│       └── localization/
│           └── en-us.lua
│
├── r6/scripts/DavidSandevistanPlus/  ← 11 redscript files
│   ├── DSPSettings.reds              ← Mod Settings UI (44 tunables)
│   ├── DSPHUDSystem.reds             ← HUD rendering
│   ├── DSPAudioBridge.reds           ← Audioware bridge (song, voice, SFX)
│   ├── DSPBiomonitorSystem.reds      ← animated biomonitor panel
│   ├── DSPPlayerEvents.reds          ← @wrapMethod hooks (attach / detach / immuno)
│   ├── DSPKillTracker.reds           ← kill faction → strain
│   ├── DSPActivityTracker.reds       ← dialog LocKey → activity type
│   ├── DSPRipperdocHook.reds         ← "Stabilize Sandevistan" button
│   ├── DSPConsumeOverride.reds       ← bypass vanilla HealthBooster pipeline
│   ├── DSPViktorBridge.reds          ← PhoneExtension SMS bridge
│   └── DSPViktorPhone.reds           ← Viktor phone contact
│
├── r6/scripts/AnimatedWidgets/       ← Animated Widgets Library (r457 & gh057, bundled)
│   ├── AnimatedGlobals.reds
│   ├── AnimatedWidgetsLib.reds
│   ├── AnimatedMonitor.reds
│   └── AnimatedBiomonitor.reds
│
├── r6/tweaks/DavidSandevistanPlus/   ← TweakXL YAML (REQUIRED — items + vendors)
│   ├── immunoblocker_effects.yaml    ← 3 tiers + auto-injector cyberware
│   └── immunoblocker_vendors.yaml    ← Arroyo dealer + Kabuki kid
│
└── r6/audioware/DavidSandevistanPlus/
    ├── audios.yaml                   ← 138 entries (2 SFX + 136 voice lines)
    ├── last_breath_song.ogg
    ├── sfx/
    │   └── blackwall_scream.ogg
    └── voice/v_male/
        └── *.ogg                     ← 136 V male voice lines
```

> **Critical:** missing `r6/tweaks/` means no vendors and no working immunoblocker items. Missing `r6/scripts/DavidSandevistanPlus/DSPSettings.reds` means the Mod Settings UI fails to compile and the whole mod silently breaks. Missing `voice/v_male/*.ogg` leaves V mute in every contextual scene.

> **Audioware note:** The Last Breath song plays at normal speed even during Sandy's 99.35% time dilation because `DSPAudioBridge.reds` passes `affectedByTimeDilation = false` to the Audioware `Play()` call. Audioware uses its own audio engine (Kira) independent of Wwise.

## Settings

Open the game menu: **Settings > Mods > David Sandevistan Plus**.

44 tunables across 7 categories. Defaults are lore-accurate — most users won't need to change anything. Changes take effect immediately (no game restart) unless noted.

### 1. Time Dilation (2 settings)

| Setting | Default | Notes |
|---|---|---|
| Require EdgeRunner Perk | on | When **on**, the perk gates the full Sandy: without it, runtime caps at 33% of max and base dilation drops 99.35% → 95% for stages 1-5. Stage 0 already caps at 90% from the stage curve. When **off**, full 99.35% dilation and full runtime tank are available from level 1. |
| Enable Session Fatigue | on | Each activation past `Safe Activations per Day` reduces time dilation by 2% (cap -10% total). Resets on sleep. Disabled while Safety OFF (that state already caps at 95%). |

> Time dilation peak values (99.35% with perk, 95% without, 90% stage 0 cap) are **hardcoded** — not exposed as tunables. The per-stage curve is shown under "Progressive Dilation Degradation" below.

### 2. Runtime & Drain (8 settings)

| Setting | Range | Default |
|---|---|---|
| Runtime Tank (seconds) | 1–600 | 300 |
| Recharge Duration | 0.5–30 | 2.0 |
| Cooldown Base | 0.1–10 | 0.5 |
| Activation Cost | 0.0–1.0 | 0.0 |
| Kill Recharge Value | 0–50 | 2.0 |
| Full Recharge Hours | 1–48 | 16 |
| Max Recharge per Sleep | 1–24 | 10 |
| Drain Accel Start (sec) | 10–180 | 60 |

After `Drain Accel Start` seconds of continuous use, drain accelerates as `1 + (minutesOver ^ 1.5)` — doubles ~1 min past the threshold, ~4× after 2 min, ~6× after 3 min. Lower threshold = more pressure to act fast.

### 3. Combat Stats (5 settings)

Bonuses applied while Sandy is active.

| Setting | Range | Default |
|---|---|---|
| Critical Chance | 0–100 | 30 |
| Critical Damage | 0–500 | 35 |
| Headshot Damage Multiplier | 1.0–5.0 | 1.5 |
| Heal on Kill (%) | 0.0–50.0 | 3.0 |
| Stamina on Kill | 0–100 | 22 |

### 4. Cyberpsychosis (6 settings, advanced-gated)

| Setting | Range | Default | Notes |
|---|---|---|---|
| Advanced Settings | on/off | off | Toggle to reveal the 5 settings below in the UI |
| Safe Activations per Day | 1–20 | 3 | Doc's "three times a day" warning. Scaled per stage: 0=×1, 1=×1.7, 2=×2.3, 3=×3, 4=×4, 5=unlimited. Each activation past the limit adds +3 base strain. |
| Strain Buildup Speed | 0.25–3.0 | 1.0 | Multiplier on activation, overuse, active-time and passive strain. Kill strain (faction-based) bypasses this and stays at +2/+3/+5/+6 (gang/corpo/ncpd/civilian). |
| Strain Recovery Speed | 0.25–3.0 | 1.0 | Multiplier on sleep, ripper, safe area, immunoblocker, and natural decay |
| Episode Cooldown Multiplier | 0.25–3.0 | 1.0 | Scales the 48/36/24/12/6h game-time minimums between stage escalations. Active treatment milestones extend further. |
| Micro-Episode Frequency | 0.25–3.0 | 1.0 | 0.5 = half as often, 2.0 = twice |

### 5. Recovery (3 settings, advanced-gated)

| Setting | Range | Default | Notes |
|---|---|---|---|
| Advanced Settings | on/off | off | Toggle to reveal the 2 settings below |
| Sleep Recovery (%) | 0.25–1.0 | 0.75 | % of remaining degraded max runtime recovered per sleep. Multiplicative — diminishing returns across sessions. Full restore requires a ripperdoc visit. |
| Tolerance Decay Hours | 6–72 | 24 | Game-time hours of immunoblocker abstinence before tolerance starts decaying (fixed -1.0 per game-day once decay begins). Ripperdoc visits flush -4.0 instantly. |

### 6. Economy & Interface (7 settings)

| Setting | Range | Default | Notes |
|---|---|---|---|
| Immunoblocker Price: Common | 500–20,000 | 6,000€$ | 3 min duration |
| Immunoblocker Price: Uncommon | 1,000–50,000 | 24,000€$ | 6 min duration |
| Immunoblocker Price: Rare | 5,000–200,000 | 100,000€$ | 10 min duration |
| Enable Debug Logs | on/off | off | Detailed CET console output for troubleshooting |
| Biomonitor Position X | 0–3000 | 80 | On a 3840×2160 canvas. Auto-scales to your resolution. |
| Biomonitor Position Y | 0–2000 | 600 | (same canvas) |
| Sandevistan Color Grading | Vanilla / GreenI / GreenII / GreenIII / Neon / Clean | Neon | Requires game restart to apply |

### 7. Martinez Rush (13 settings)

Kill-triggered combat burst during Sandy. Every value below is individually tunable; setting a stat to 0 disables just that bonus. The feature itself is always live (it intentionally has no global toggle — set the chance to 0.25× and the bonuses to 0 if you don't want it).

| Setting | Range | Default | Notes |
|---|---|---|---|
| Require Edgerunner Perk | on/off | on | On: Rush only procs if V has the vanilla Edgerunner perk in Reflexes. Off: Rush works regardless. |
| Rush Chance Multiplier | 0.25–3.0 | 1.0 | Base chance per kill scales by stage: 2% / 4% / 7% / 12% / 18% / 25%. Multiplied by this value. |
| Rush Duration (sec) | 6–30 | 12 | Safety OFF extends by +25% (so 12s → 15s) |
| Rush Cooldown (sec) | 15–180 | 45 | Real-time minimum between procs |
| Rush Runtime Drain Multiplier | 1.0–3.0 | 1.5 | Drain rate during the Rush window — the primary cost |
| Rush Fire Rate Bonus (%) | 0–150 | 67 | +67% rate of fire on ranged weapons |
| Rush Reload Speed Bonus (%) | 0–150 | 82 | Reloads take 45% of normal time |
| Rush Melee Attack Speed Bonus (%) | 0–150 | 40 | +40% swing rate for blades and blunt |
| Rush Movement Speed Bonus (%) | 0–100 | 25 | +25% run/sprint speed |
| Rush Crit Chance Bonus | 0–100 | 20 | Flat +20 crit chance points |
| Rush Crit Damage Bonus | 0–200 | 35 | Flat +35 crit damage points |
| Rush Armor Bonus (%) | 0–200 | 45 | +45% damage reduction |
| Rush Combat Regen Multiplier | 1.0–20.0 | 6.0 | 6× normal in-combat health regen |

Rush does **not** add neural strain — it intentionally stays out of the cyberpsychosis progression budget so stage cadence stays intact. The cost is the runtime drain plus a 3-second stamina crash that lands the moment Sandy deactivates.

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

> **Safety ON/OFF** is automatic and hidden from the player — stages 0-4 have Safety ON, stage 5+ Safety OFF engages automatically.
>
> **Comedown** has been removed. Penalties are runtime-based — V's body deteriorates during Sandy use, not after. No reactivation block (lore-accurate: David never had a cooldown).

## How It Works

**DavidSandevistanPlus** exposes all gameplay values through the native Mod Settings framework: tunables are declared on `DSPSettings.reds` (`@runtimeProperty`), the redscript scriptable system writes a `dsp_settings_changed` quest fact on save, and the CET side pulls the updated values into the runtime `cfg` table via `syncSettingsFromRedscript()`. TweakDB stat flats are rewritten on the fly through `TweakDB:SetFlat` + `TweakDB:Update` so most tuning takes effect without a game restart.

### Daily Activation Counter

Inspired by Doc's warning to David: "don't use it more than 3 times a day." Each activation beyond the safe limit adds bonus Neural Strain. The effect stacks — the more you overuse it, the faster psychosis progresses. Counter resets when V sleeps.

### Cyberpsychosis Flow

```
Activate Sandy → strain accumulates (+5 base, +3 per overuse)
  ├─ Sandy active: +2/min strain
  ├─ Safety OFF (stage 5): +0.10/s strain
  ├─ Kills during Sandy: +2 to +6 strain (faction-based, configurable)
  ├─ Low runtime (<10%): +0.5/s strain (body exhausted)
  └─ Zero runtime (0%): +1.0/s strain (death wish)

Strain exceeds threshold → dice roll every 15 seconds:
  ├─ chance = progress × 0.20  (progress = (strain - threshold) / (guaranteed - threshold))
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
  ├─ Stages 0-3: BLACKOUT → stage-based chance (90/70/40/15%), 200m range check
  │   ├─ Near safe location: teleport + time skip 4-8h + location-specific recovery
  │   └─ Too far: stun only (no teleport)
  ├─ Stage 4-5: no blackout — psychosis/death path
  └─ Daily cooldown: one blackout per day

Strain scaling by stage (tolerance-based strain only):
  ├─ Stage 0-1: ×0.5 (body resists at low stages)
  ├─ Stage 2: ×0.75
  └─ Stage 3-5: ×1.0 (full impact)
  Note: kill strain, runtime strain, Safety OFF strain bypass multiplier (raw=true)

Psychosis features by stage:
  ├─ Stage 3+: Hallucinations (phantom NPCs spawn and vanish)
  ├─ Stage 3+: Auto-attack (AIWeapon.Fire() — 4 trigger points, stage-scaled chances)
  ├─ Stage 3+: Combat buffs during episodes (+50% speed, +100% armor, ×10 health regen)
  ├─ Stage 3+: Cycled SFX (ui_gmpl_perk_edgerunner during episodes)
  └─ Stage 5: Safety OFF automatic, Sandy stays on during episodes

Death at level 5 + Second Heart:
  └─ Last Breath (Stage VI)
      ├─ Peace (20s): VFX cleared, max dilation 99.35%, song plays
      ├─ Decay (~225s): VFX ramp, dilation drops, Blackwall kills
      └─ Runtime = 0 → permanent death (DAVID MARTINEZ — FLATLINED)

Recovery (levels 1–5) — Treatment Protocol (3 pillars):
  ├─ Immunoblocker doses: reduces strain + counts toward prescription
  │   └─ Substance detection biomonitor shows feedback on consumption
  ├─ Ripperdoc visits: "Stabilize Sandevistan" button in ripper menu
  │   ├─ 24h game-time cooldown between visits
  │   ├─ Cost: 2k-20k eddies (scales with stage)
  │   └─ Viktor SMS: "Come back tomorrow" when visits remain
  ├─ Rest: sleep hours count toward protocol (8-24h by stage)
  ├─ Treatment milestones protect against escalation:
  │   ├─ 33% progress → episode cooldown ×1.66
  │   └─ 66% progress → episode cooldown ×2.33
  ├─ Activities: 6 tracked (lover, sleepWithLover, shower, social, pet, apartment)
  │   ├─ Immediate strain drain (-2 to -8) + runtime restore
  │   └─ Sleep multiplier: 1.0 + (activities × 0.25), max ×2.5 with all 6
  ├─ Tolerance: repeated immunoblocker use builds resistance (×1.3/×1.6/×2.0 doses)
  │   └─ Decays after 24h without use, flushed at ripperdoc
  └─ Biomonitor tracks all progress: doses, visits, rest, milestone %
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
