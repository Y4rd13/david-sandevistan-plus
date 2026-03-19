# VendorsXL Animation Loop Fix — Technical Analysis

## Problem

VendorsXL vendors with complex workspot animations (e.g., `child__sit_ground_gun__play__01.workspot`) only play the first idle cycle and stop. Simple workspots (standing idle with tablet) appear unaffected because their single-cycle animation looks the same as a loop.

## Root Cause

`worldAISpotNode.isWorkspotInfinite` defaults to `false`. VendorsXL never sets it to `true`.

### How VendorsXL creates AISpots (VendorsXL.reds:118-126)

```redscript
let node = sector.GetNode(i*2+1) as worldAISpotNode;
if (IsDefined(node)){
    let new_spot = new AIActionSpot();
    new_spot.resource *= this.vendorxl_workspots[i];
    new_spot.useClippingSpace = false;
    node.spot = new_spot;
}
```

VendorsXL replaces `node.spot` with a new `AIActionSpot` containing only the workspot path. It never touches the outer `worldAISpotNode` properties — `isWorkspotInfinite` stays at its default `false`.

### Working reference: NCEE

NCEE's `npc_kdd.streamingsector` has `isWorkspotInfinite: 1` on its `worldAISpotNode`. The same workspot (`child__sit_ground_gun__play__01`) plays the full animation loop: sitting idle → holding stomach → grabbing gun → pretending to shoot → returning to idle → repeat.

## Animation Loop Architecture

Two independent layers control workspot looping:

### Layer 1: Sector node (`worldAISpotNode`)

| Field | Default | Effect |
|-------|---------|--------|
| `isWorkspotInfinite` | `false` | `false`: engine plays animation tree once, fires `WorkspotFinishedEvent`, releases NPC. `true`: engine keeps NPC in workspot, cycling through all sequences indefinitely. |
| `isWorkspotStatic` | `false` | Locks NPC position |

### Layer 2: Workspot file (`workSequence`)

| Field | Effect |
|-------|--------|
| `loopInfinitely` | Whether this specific sequence replays its child clips |
| `previousLoopInfinitely` | Whether the previous sequence loops (transition logic) |

Both layers must cooperate. `isWorkspotInfinite` on the node is the outer gate — even if the workspot file has `loopInfinitely` on its sequences, the engine releases the NPC from the spot when the top-level sequence finishes if `isWorkspotInfinite = false`.

## AIActionSpot vs worldAISpotNode

VendorsXL only modifies `AIActionSpot` (the inner spot). The outer `worldAISpotNode` has additional engine-level properties that VendorsXL does not configure:

| worldAISpotNode property | VendorsXL sets? | NCEE value |
|--------------------------|----------------|------------|
| `isWorkspotInfinite` | No (stays false) | `true` (1) |
| `isWorkspotStatic` | No | `false` (0) |
| `disableBumps` | No | `false` (0) |
| `lookAtTarget` | No | `null` (0) |
| `useCrowdWhitelist` | No | `true` (1) |
| `useCrowdBlacklist` | No | `true` (1) |

### AIActionSpot fields (8 total)

| Field | Default | Purpose |
|-------|---------|---------|
| `resource` | — | Workspot file path |
| `ActorBodytypeE3` | default enum | Actor body type for rig socket matching |
| `masterNodeRef` | null | Reference to master AI spot |
| `enabledWhenMasterOccupied` | false | Activates only when master is occupied |
| `snapToGround` | false | Snap NPC to terrain |
| `useClippingSpace` | false | Enable facing direction cone |
| `clippingSpaceOrientation` | 180.0 | Facing cone direction (degrees) |
| `clippingSpaceRange` | 120.0 | Facing cone width (degrees) |

The clipping space fields control NPC facing direction, NOT animation playback. They are not relevant to the loop issue.

## The Fix

One line added to VendorsXL's `vendorsxl_sector` callback, after `node.spot = new_spot;`:

```redscript
node.isWorkspotInfinite = true;
```

This is safe and retrocompatible:
- Simple workspots (standing idle) are unaffected — their single-cycle animation already looks like a loop
- Complex workspots (sitting, interacting with props) will play the full animation cycle
- No existing vendor behavior changes — the NPC still responds to player proximity, still allows vendor interaction

## Proposed Enhancement: Configurable Animation Mode

Using an unused field on the Character record as a flag, VendorsXL could support per-vendor animation modes:

| Mode | Behavior |
|------|----------|
| Default (0) | `isWorkspotInfinite = true` — full animation loop (proposed new default) |
| Static (1) | `isWorkspotInfinite = false` — play once and freeze (current behavior) |

## WorkspotGameSystem API Reference

Methods available for runtime workspot control:

| Method | Purpose |
|--------|---------|
| `SendPlaySignal(actor)` | Resume playback (exists in API, never used in game) |
| `ResetPlaybackToStart(actor)` | Soft reset animation to beginning |
| `HardResetPlaybackToStart(actor)` | Hard reset (used on death/panic) |
| `SendForwardSignal(actor)` | Advance to next animation in sequence |
| `SendJumpToAnimEnt(actor, animName, instant)` | Jump to specific animation |
| `IsActorInWorkspot(actor)` | Check if actor is in a workspot |
| `GetExtendedInfo(actor)` | Get state: isActive, entering, exiting, inReaction |
| `StopNpcInWorkspot(actor)` | Remove NPC from workspot (destructive) |
| `SendReactionSignal(actor, reactionName)` | Trigger in-workspot reaction (e.g., 'Fear') |

## LookAt System (Separate from Animation)

The "vendor looks at player" behavior is an **animation overlay** — eyes/head/chest track the player independently of the workspot body animation. It does NOT interrupt the workspot loop:

- `LookAtAddEvent` → queued on NPC with `SetEntityTarget(player)`
- `LookAtRemoveEvent` → removes the look-at when player moves away
- `TerminateReactionLookatEvent` → stops reaction-driven look-at
- Controlled by `reactionPreset` rules (stimuli → `gamedataOutput.LookAt`)
- VendorsXL adds its own proximity-based look-at (closed source)

## Files Referenced

| File | Purpose |
|------|---------|
| `VendorsXL.reds` | VendorsXL redscript — AISpot creation at lines 118-126 |
| `VendorsXL.archive` | Pre-made sector with 100 template node pairs |
| `##########_VendorsXL.yaml` | Base Character/Vendor records |
| `npc_kdd.streamingsector.json` | NCEE reference — working `isWorkspotInfinite: 1` |
| `worldAISpotNode.cs` (WolvenKit) | Node class definition with `isWorkspotInfinite` |
| `AIActionSpot.cs` (WolvenKit) | Inner spot class — 8 fields |
| `workWorkspotTree.cs` (WolvenKit) | Workspot file structure — `loopInfinitely` on sequences |
| `aiSpot.lua` (World Builder) | Shows how World Builder monitors and re-initiates loops |
