# David Sandevistan Plus

Custom Cyberpunk 2077 Sandevistan mod — a fully standalone fork of [David's Apogee](https://www.nexusmods.com/cyberpunk2077/mods/9547) with lore-accurate defaults and every gameplay parameter configurable via an in-game Settings menu.

## Features

- **Lore-accurate defaults** — Safety OFF from the start, like David in Edgerunners
- Custom icon and localization (MILITECH "DAVID MARTINEZ" SANDEVISTAN PLUS)
- 21 gameplay parameters + 11 TweakDB parameters, all tunable from Settings
- Native Settings UI tab with 12 subcategories
- Daily activation counter — Doc warned David not to use it more than 3 times a day
- No EdgeRunner perk gate — full runtime from day 1, like David in the anime
- No health brake by default — David never had an auto-stop
- Config persists across sessions via `config.json`

### Custom HUD

A visual HUD overlay replaces the original text-only display:
- **Runtime bar** — color-coded green/yellow/red with time dilation percentage
- **Status line** — activation count, contextual status (Safety Off, Comedown, Recovering)
- **Psycho bar** — only visible when cyberpsychosis is active, with level and timer

### Progressive Cyberpsychosis

A 5-level system inspired by David Martinez's descent in Edgerunners:

| Level | Name | Persistent VFX | Gameplay |
|-------|------|---------------|----------|
| 0 | Normal | None | Full functionality |
| 1 | Unstable | None | 12s MartinezFury episodes on overload |
| 2 | Glitching | None | 12s MartinezFury episodes, faster timer |
| 3 | Losing It | Subtle glitch | Persistent `hacking_glitch_low` VFX |
| 4 | On The Edge | Medium distortion | Persistent glitch + drugged VFX |
| 5 | Cyberpsycho | Full psychosis | 4 simultaneous VFX, immunities, last stand |

**Safety OFF at Level 5 (David's Last Stand):** V experiences full psychosis VFX (glitch, braindance, drugged, blackwall) but the Sandevistan still works — pushing through like David did. Death only comes when the PsychoOutburst timer runs out.

**Safety ON at Level 5:** Sandy is blocked, Kiroshi optics disabled, V must sleep or recover in a safe area.

### On-Screen Notifications

18 contextual notifications keep the player informed using in-world language:

| Event | Example | Type |
|-------|---------|------|
| Game load | `SANDEVISTAN ONLINE — 180/300s — SAFETY OFF` | Info |
| Activation | `SANDEVISTAN — TIME DILATION 97.5% \| PSYCHOSIS III` | Info |
| Overuse | `OVERUSE — 4 ACTIVATIONS TODAY (SAFE: 3) — REST RECOMMENDED` | Warning |
| Low runtime | `LOW RUNTIME: 12s — DEACTIVATE OR RISK EPISODE` | Warning |
| Cooldown | `SYSTEM COOLDOWN — 5s` | Info |
| Psycho level up | `CYBERPSYCHOSIS III — LOSING GRIP ON REALITY` | Warning |
| Psycho recovery | `RECOVERING — PSYCHOSIS LEVEL II` | Info |
| Death | `SYSTEM FAILURE — NEURAL COLLAPSE` | Warning |
| Sleep | `RECHARGED +120s — RUNTIME: 180/300s` | Info |

### Sensory Effects (Edgerunners-Accurate)

Lore-accurate physical effects inspired by David Martinez's deterioration across Episodes 2–10:

| Effect | Trigger | Lore Reference |
|--------|---------|----------------|
| **Camera shake** | Psycho lvl 3–5 (progressive intensity) | David's hands shake visibly from Ep 8 onward |
| **Manic laughter** | Random at psycho lvl 4–5 (`perk_edgerunner_player` VFX) | David laughing uncontrollably in Ep 10 |
| **FOV pulse** | Every Sandy activation (+12° for 0.4s) | Perception shift on Sandevistan activation |
| **Heartbeat** | Psycho lvl 3+ idle, or Sandy active with low health | Tension audio during David's deterioration |
| **Nosebleed** | Sandy activation after exceeding safe daily limit | David bleeds from the nose in Ep 2, 3, 5, 9 |
| **Exhaustion collapse** | Sandy activation at 3× safe daily limit | David passes out after 8 uses in Ep 2 |
| **Terminal clarity** | 2.5s before death at psycho lvl 5 | David snaps out of psychosis right before death in Ep 10 |

## Requirements

- [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107)
- [Native Settings UI](https://www.nexusmods.com/cyberpunk2077/mods/3518)
- [ArchiveXL](https://www.nexusmods.com/cyberpunk2077/mods/4198)

## Installation

Extract into your Cyberpunk 2077 installation directory:

```
Cyberpunk 2077/
├── archive/pc/mod/
│   ├── david-sandevistan-plus.archive
│   └── david-sandevistan-plus.archive.xl
└── bin/x64/plugins/cyber_engine_tweaks/mods/
    ├── DavidSandevistanPlus/
    │   ├── init.lua
    │   ├── martinez.lua
    │   ├── hud.lua
    │   └── gui.lua
    └── MartinezPLUS/
        └── init.lua
```

## Settings

Open the game menu: **Settings > Mods > Martinez Sandy+**

### Time Dilation
- **Time Dilation Speed** — Base time scale from `0.10` (90% slowdown, default — lore-accurate ~10x speed factor) down to `0.001` (99.9%).
  Recommended limit: **0.0065** (99.35%). Values below may cause visual glitches.
  Safety Off and Overclock still stack on top of this value.

### Duration & Cooldown
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Sandevistan Duration | 1–600 sec | 300 | How long the Sandy stays active |
| Recharge Duration | 0.5–30 | 2.0 | Recharge time |
| Cooldown Base | 0.1–10 | 0.5 | Cooldown multiplier |
| Activation Cost | 0–1 | 0.0 | Stamina cost to activate (0 = free) |
| Kill Recharge Value | 0–50 | 2.0 | Recharge gained per kill |

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
| Damage Min | 0.1–5.0% | 1.0 | Minimum health drain per tick |
| Damage Max | 1.0–25.0% | 15.0 | Maximum health drain per tick |
| Tick Length | 0.25–5.0 sec | 1.25 | Game loop tick interval |

### Health Brake
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Enable Health Brake | on/off | off | Auto-stop Sandy on low health |
| Brake Threshold | 10–90% | 50 | Health % to trigger brake |
| Minimum Health | 1–50% | 15 | Absolute minimum health threshold |

### Safety Off
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Extra Damage | 1–20 | 5 | Extra damage per tick with safety off |
| Drain Multiplier | 1–10 | 4 | Extra runtime drain with safety off |
| Enable Safety Off Kill | on/off | on | Can V die from safety off |
| Kill Threshold | 1–10% | 2 | Health % that triggers death |
| Safety Off Time Dilation | 92.5%–99.5% | 97.5% | Time dilation boost when limiters are off |

### Recharge
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Full Recharge Hours | 1–48 | 16 | In-game hours for full recharge |
| Max Recharge Per Sleep | 1–24 | 10 | Max recharge hours per sleep |

### Cyberpsychosis
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Enable Cyberpsychosis | on/off | on | Toggle the cyberpsychosis system |
| Safe Activations per Day | 1–20 | 3 | Activations before psycho acceleration (Doc's warning) |
| Psycho Acceleration per Extra Use | 5–120 | 30 | Seconds subtracted from psycho timer per extra use |

### Comedown (Deactivation Debuff)
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Enable Comedown | on/off | on | Apply debuff after deactivating Sandy |
| Base Duration | 1–10 sec | 3.0 | Minimum comedown after short use |
| Max Duration | 3–20 sec | 8.0 | Maximum comedown after prolonged use |
| Scaling Threshold | 10–300 sec | 60 | Runtime used before comedown reaches max |

### Perk Gates
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Require EdgeRunner Perk | on/off | off | Require EdgeRunner perk for full runtime (off = full access from day 1) |

## How It Works

**DavidSandevistanPlus** is a fork of David's Apogee v2.25.3 with all hardcoded gameplay values extracted into a configurable `cfg` table. **MartinezPLUS** provides the Native Settings UI and writes to `DavidSandevistanPlus/config.json`. Changes to TweakDB values apply instantly; gameplay parameters update both at runtime and persist to disk.

### Daily Activation Counter

Inspired by Doc's warning to David: "don't use it more than 3 times a day." Each activation beyond the safe limit accelerates the cyberpsychosis timer. The effect stacks — the more you overuse it, the faster psychosis progresses. Counter resets when V sleeps.

### Cyberpsychosis Flow

```
Activate Sandy → health drains → runtime depletes
  └─ Health critical + RT=0 → BleedingEffect()
      └─ CyberPsychoWarnings++ (1→5)
      └─ FrightenNPCs() → MartinezFury (12s Sandy disabled, NPCs flee)
      └─ PsychoOutburst timer starts (5-60 min random)

PsychoOutburst timer ticks down:
  ├─ Safety OFF: -10s/tick (accelerated)
  ├─ Sandy active: -2s/tick
  ├─ Idle: -1s/tick
  ├─ Safe area / Club: +5s/tick (recovery)
  └─ Timer reaches 0 → forced episode OR death at level 5

Recovery:
  ├─ Safe areas / clubs: gradual recovery (+5s/tick on timer)
  ├─ Sleep ≥ 8hrs: full psychosis cure
  ├─ Sleep < 8hrs at level 5: reduced to level 1
  └─ Visit Viktor: equivalent to 8hr rest (5min cooldown)
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
| **Immunosuppressant** | Pauses PsychoOutburst timer progression (recovers like a safe area). Blocks daily activation penalty from overuse. |
| **Endotrisine** | Doubles psycho recovery rate in safe areas. Halves psycho acceleration from Sandevistan use and Safety Off. |

No configuration needed — if Dark Future is installed and V takes these consumables, the effects apply automatically. If Dark Future is not installed, these checks are safely skipped.

## Credits

- **beckylou** — Creator of [David's Apogee](https://www.nexusmods.com/cyberpunk2077/mods/9547), the base this mod is forked from
- **XxJepxX** — Creator of Tier 5 Plus (inspiration for the Native Settings approach)
- **keanuWheeze** — [Native Settings UI](https://www.nexusmods.com/cyberpunk2077/mods/3518)

## License

[MIT](LICENSE)
