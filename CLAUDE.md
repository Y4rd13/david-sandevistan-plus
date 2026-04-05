# David Sandevistan Plus — Project Rules

## CRITICAL: Game Mod Safety Rules

**NEVER delete, rename, move, or overwrite ANY of the following files in the Cyberpunk 2077 game directory without EXPLICIT user approval:**

### Protected files (NEVER touch without asking):
- **Mod config files**: Any `config.json`, `settings.json`, or similar inside mod folders
- **CET state files**: `persistent.json`, `config.json`, `bindings.json`, `layout.ini` in `cyber_engine_tweaks/`
- **CET core files**: `cyber_engine_tweaks.asi`, `version.dll`, `global.ini`
- **Log files**: Any `.log` file — these contain diagnostic history the user may need
- **Database files**: Any `db.sqlite3` in mod folders
- **Save games**: Anything under save directories
- **RED4ext files**: `RED4ext.dll`, `winmm.dll`, any plugin `.dll` files
- **Address library**: Any `.bin` files in `plugins/address_library/`
- **Archive files**: Any `.archive` files in `archive/pc/mod/`
- **Script caches**: `final.redscripts`, `final.redscripts.modded`
- **Mod folders**: Never rename mod folders (e.g., adding `.DISABLED` suffix)

### Before ANY destructive action:
1. **ASK the user first** — describe exactly what you want to do and why
2. **Wait for explicit approval** before executing
3. **Never batch-delete** multiple files without listing each one
4. Prefer **read-only investigation** (reading logs, checking file states) over modifying files
5. If troubleshooting requires disabling something, **ask the user to do it manually**

### Safe actions (can do without asking):
- Reading any file
- Checking file timestamps, sizes, hashes
- Running diagnostic commands (PowerShell queries, process checks, etc.)
- Searching the web for solutions
- Editing source code files in the **project repo** (`/mnt/g/Documentos/Projects/david-sandevistan/`)

## Project Overview

Custom Cyberpunk 2077 Sandevistan mod with lore-accurate defaults and full configurability.
Two components: **DavidSandevistanPlus** (game logic) + **MartinezPLUS** (Native Settings tuner UI).

## Key Paths
- **Project repo**: `/mnt/g/Documentos/Projects/david-sandevistan/`
- **Game mods**: `/mnt/g/SteamLibrary/steamapps/common/Cyberpunk 2077/bin/x64/plugins/cyber_engine_tweaks/mods/`
- **RED4ext plugins**: `/mnt/g/SteamLibrary/steamapps/common/Cyberpunk 2077/red4ext/plugins/`
- **CET directory**: `/mnt/g/SteamLibrary/steamapps/common/Cyberpunk 2077/bin/x64/plugins/cyber_engine_tweaks/`

## Modding Stack
- **CET** v1.37.1 — Cyber Engine Tweaks (ASI loader via `version.dll`)
- **RED4ext** v1.29.1 — Native plugin loader (via `winmm.dll`)
- **nativeSettings** — CET mod for settings UI ("MODS" tab)
- **nativeSettings_side_menu_add_on** — Side panel in MODS tab (requires Codeware + ArchiveXL)
- **Codeware**, **ArchiveXL**, **TweakXL** — Core modding frameworks (RED4ext plugins)

## Vendor NPC System (Community + Quest Scene)

Vendor NPCs use 3 layers — ALL must stay in sync:
1. **Streaming sector** (World Builder) — Community + AISpot + Static Marker, `AlwaysLoaded`
2. **Character record** (TweakXL YAML) — full `gamedataCharacter_Record` with `vendorID`
3. **Quest scene + questphase** — creates Talk button via `scnChoiceNode`
4. **Journal** (optional) — POI mappin on map, activated by questphase `questJournalEntry_NodeType`

### NodeRef Sync Rule (CRITICAL)
When World Builder NodeRefs change, update ALL files that reference them:
- Scenes: `communityParams.reference` + `vendorPanel objectRef.reference`
- Journal: `staticNodeRef` + `dynamicEntityRef.reference`
- NodeRefs MUST use `$/mod/` prefix format (flat names silently fail)

### Workflow
1. Edit in **repo** first, then copy to game directory
2. After World Builder re-export: verify ALL NodeRefs match across scenes/journal
3. Convert JSON → CR2W via WolvenKit CLI: `mcp__wolvenkit__convert_from_json`
4. Pack via WolvenKit UI (CLI `build` includes garbage files)
5. Copy `.archive` + `.xl` to game directory

### Key Files
- Scenes: `wolven/.../davidsandevistanplus/quest/scenes/*.scene`
- Questphases: `wolven/.../davidsandevistanplus/quest/*.questphase`
- Journal: `wolven/.../davidsandevistanplus/journal/dsp_vendors.journal`
- Character records: `r6/tweaks/DavidSandevistanPlus/immunoblocker_vendors.yaml`
- Sectors: `wolven/.../dsp_npcs/sectors/*.streamingsector`
- Archive XL: `archive/pc/mod/david-sandevistan-plus.archive.xl`
