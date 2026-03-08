# Martinez Sandy+ (MartinezPLUS)

Tuner companion mod for [David's Apogee](https://www.nexusmods.com/cyberpunk2077/mods/9547) (Martinez Sandevistan) in Cyberpunk 2077.

Adds a **Native Settings UI** tab to configure the Martinez Sandevistan parameters in real time from the game's Settings menu.

## Requirements

- [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107)
- [Native Settings UI](https://www.nexusmods.com/cyberpunk2077/mods/3518)
- [David's Apogee - Martinez Sandevistan](https://www.nexusmods.com/cyberpunk2077/mods/9547)

## Installation

Extract the zip into your Cyberpunk 2077 installation directory:

```
Cyberpunk 2077/
└── bin/x64/plugins/cyber_engine_tweaks/mods/MartinezPLUS/
    └── init.lua
```

Or install via Vortex / Mod Organizer 2.

## Settings

Open the game menu: **Settings > Mods > Martinez Sandy+**

### Time Dilation
- **Time Dilation Speed** — Base time scale from `0.15` (85% slowdown, default) down to `0.001` (99.9%).
  Recommended limit: **0.0065** (99.35%). Values below may cause visual glitches.
  Safety Off and Overclock from David's Apogee still stack on top of this value.

### Duration & Cooldown
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Sandevistan Duration | 1–600 sec | 300 | How long the Sandy stays active |
| Recharge Duration | 0.5–30 | 2.0 | Recharge time |
| Cooldown Base | 0.1–10 | 1.0 | Cooldown multiplier |
| Activation Cost | 0–1 | 0.1 | Stamina cost to activate (0 = free) |
| Kill Recharge Value | 0–50 | 0.0 | Recharge gained per kill |

### Combat Stats (while Sandy active)
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Critical Chance | 0–100 | 20 | Bonus crit chance |
| Critical Damage | 0–500 | 20 | Bonus crit damage |
| Headshot Damage Multiplier | 1.0–5.0 | 1.2 | Headshot damage multiplier |

### On-Kill Effects (while Sandy active)
| Setting | Range | Default | Description |
|---------|-------|---------|-------------|
| Heal on Kill | 0–50% | 5 | Health restored per kill |
| Stamina on Kill | 0–100 | 22 | Stamina restored per kill |

## How It Works

This mod modifies TweakDB flat values for the Martinez Sandevistan (`Items.MartinezSandevistanPlusPlus`) at runtime. All David's Apogee dynamic systems (Safety Limiters, Overclock, Cyberpsychosis) continue to work normally on top of your configured values.

Settings are saved to `config.json` and persist across sessions.

## Credits

- **beckylou** — Creator of [David's Apogee](https://www.nexusmods.com/cyberpunk2077/mods/9547)
- **XxJepxX** — Creator of [Tier 5 Plus](https://www.nexusmods.com/cyberpunk2077/mods/9547) (inspiration for the Native Settings approach)
- **Native Settings UI** by [keanuWheeze](https://www.nexusmods.com/cyberpunk2077/mods/3518)

## License

[MIT](LICENSE)
