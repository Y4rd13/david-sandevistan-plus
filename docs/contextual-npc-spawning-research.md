# Contextual NPC Spawning — API Research

> Research date: 2026-03-26
> Goal: Find methods for spawning NPCs at contextually appropriate positions (cover, walls, doors, crowd, navmesh) using CET Lua in Cyberpunk 2077.

---

## 1. Raycast System (SpatialQueriesSystem) — CONFIRMED WORKING

The primary tool for spatial awareness. Used by AutoLoot, RedHotTools, AMM, leanAnywhere, sitAnywhere, entSpawner, and DSP itself.

### Core API

```lua
local sqs = Game.GetSpatialQueriesSystem()
local success, result = sqs:SyncRaycastByCollisionGroup(from, to, collisionGroup, staticOnly, dynamicOnly)
-- from: Vector4 (start)
-- to: Vector4 (end)
-- collisionGroup: string name (see list below)
-- staticOnly: bool
-- dynamicOnly: bool
-- Returns: success (bool), result (traceResult with .position (Vector3), .normal, .material)
-- result.position is Vector3, use Vector4.Vector3To4(result.position) to convert
```

### All Known Collision Groups

From RedHotTools `collision-groups.lua` + TargetingHelper + mod usage:

| Group | Type | Used By | Notes |
|-------|------|---------|-------|
| `Dynamic` | dynamic | RHT, TargetingHelper | Movable objects |
| `Static` | static | DSP, AMM, AutoLoot, RHT | Buildings, roads, crates, walls |
| `Vehicle` | dynamic | RHT, TargetingHelper | Vehicles |
| `Terrain` | static | RHT, TargetingHelper, AutoLoot | Ground terrain |
| `Water` | static | RHT, TargetingHelper | Water surfaces |
| `PlayerBlocker` | static | leanAnywhere, sitAnywhere, entSpawner, RHT, TargetingHelper, AutoLoot | Trees, billboards, barriers |
| `Destructible` | dynamic | RHT | Destructible objects |
| `Collider` | static | RHT | Generic colliders |
| `Particle` | static | RHT | Particle colliders |
| `Debris` | dynamic | RHT | Debris objects |
| `VehicleBlocker` | static | RHT | Vehicle blockers |
| `DestructibleCluster` | static | RHT | Destructible clusters |
| `Visibility` | static | RHT | Visibility blockers |
| `Interaction` | dynamic | RHT | Interaction volumes |
| `Shooting` | dynamic | RHT | Bullet collision |
| `NetworkDevice` | static | RHT | Hackable devices |
| `NPCTraceObstacle` | static | RHT | NPC pathfinding obstacles |
| `FoliageDestructible` | dynamic | RHT | Breakable foliage |
| `Cloth` | — | RHT (commented) | Cloth physics |
| `Player` | — | RHT (commented) | Player collision |
| `AI` | — | RHT (commented) | AI collision |
| `Ragdoll` | — | RHT (commented) | Ragdoll physics |
| `NPCBlocker` | — | RHT (commented) | NPC navigation blockers |
| `NPCCollision` | — | RHT (commented) | NPC body collision |
| `PhotoModeCamera` | — | RHT (commented) | Photo mode camera |

### Alternative Raycast APIs

**Physics interface** (from LocomotionEventsTransition observer):
```lua
-- Used by leanAnywhere, sitAnywhere, entSpawner
Observe("LocomotionEventsTransition", "OnUpdate", function(_, _, _, interface)
    -- interface is gamestateMachineGameScriptInterface
    local result = interface:RaycastWithASingleGroup(from, to, "PlayerBlocker")
    if result:IsValid() then
        local hitPos = Vector4.Vector3To4(result.position)
        local hitNormal = Vector4.Vector3To4(result.normal)
    end

    -- Alternative with different collision logic:
    local result2 = interface:Raycast(from, to, "Bullet logic")
end)
```

**RedHotTools multi-raycast** (via WorldInspector):
```lua
local inspectionSystem = Game.GetWorldInspector()
local filter = physicsQueryFilter.AddGroup(CName.new("Static"))
local traces = inspectionSystem:SyncRaycastMultiple(camera.position, camera.forward, camera.distance, filter)
```

### Practical Patterns for NPC Spawning

**Ground-snapping** (already used in DSP phantoms):
```lua
local from = Vector4.new(spawnX, spawnY, vPos.z + 5.0, 1.0)
local to = Vector4.new(spawnX, spawnY, vPos.z - 10.0, 1.0)
local hit = Game.GetSpatialQueriesSystem():SyncRaycastByCollisionGroup(from, to, "Static", false, false)
if hit.result then
    spawnZ = hit.position.z
end
```

**Wall detection** (cast outward, find wall hit):
```lua
local sqs = Game.GetSpatialQueriesSystem()
local vPos = V:GetWorldPosition()
local dir = Vector4.new(math.cos(angle), math.sin(angle), 0, 0)
local from = Vector4.new(vPos.x, vPos.y, vPos.z + 1.0, 1.0)
local to = Vector4.new(vPos.x + dir.x * 30, vPos.y + dir.y * 30, vPos.z + 1.0, 1.0)
local success, result = sqs:SyncRaycastByCollisionGroup(from, to, "Static", false, false)
if success then
    local wallPos = Vector4.Vector3To4(result.position)
    local wallNormal = Vector4.Vector3To4(result.normal)
    -- Spawn just behind wall: offset by normal
    local spawnPos = Vector4.new(wallPos.x + wallNormal.x * 1.5, wallPos.y + wallNormal.y * 1.5, wallPos.z, 1.0)
end
```

**Outdoors check** (DSP already uses this):
```lua
local upTarget = Vector4.new(pos.x, pos.y, pos.z + 50.0, 1.0)
local hit = Game.GetSpatialQueriesSystem():SyncRaycastByCollisionGroup(pos, upTarget, "Static", false, false)
local isOutdoors = not hit.result
```

---

## 2. Navmesh System (AINavigationSystem) — CONFIRMED WORKING

### Core API

```lua
local navSys = Game.GetAINavigationSystem()

-- Check if a point is on navmesh (walkable)
-- entity: gameEntity (e.g., the NPC or player)
-- point: Vector4 (the position to test)
-- tolerance: Vector4 (search box around the point, e.g., Vector4.new(0.3, 0.3, 0.3, 1))
-- Returns: bool
local isOnNavmesh = navSys:IsPointOnNavmesh(entity, point, tolerance)
```

**Usage example** (from AutoLoot):
```lua
local aINavigationSystem = Game.GetAINavigationSystem()
-- ...
if aINavigationSystem:IsPointOnNavmesh(gameObj, hitPoint, Vector4.new(0.3, 0.3, 0.3, 1)) then
    -- Point is walkable
end
```

### Known Limitations
- Only `IsPointOnNavmesh` is confirmed callable from CET Lua
- `FindPointInSphereOnNavmesh` may exist in RTTI but is NOT confirmed callable from CET
- The entity parameter appears to be used for navmesh context (which navmesh layer to query)
- Tolerance Vector4 acts as a search box — larger = more lenient matching
- Must be called with a valid entity (player or spawned NPC)

### Practical Pattern: Validate Spawn Positions

```lua
local navSys = Game.GetAINavigationSystem()
local V = Game.GetPlayer()
local tolerance = Vector4.new(1.0, 1.0, 1.0, 1.0)

-- Test if a computed spawn position is walkable
local testPos = Vector4.new(spawnX, spawnY, spawnZ, 1.0)
if navSys:IsPointOnNavmesh(V, testPos, tolerance) then
    -- Position is valid for NPC spawning
end
```

---

## 3. Targeting System — Finding Nearby Entities (NPCs, Devices, Doors)

### Core API

```lua
local ts = Game.GetTargetingSystem()

-- Find all entities in radius
local searchQuery = Game['TSQ_ALL;']()  -- or TSQ_ALL.new()
searchQuery.maxDistance = 20.0  -- meters
searchQuery.ignoreInstigator = true
searchQuery.testedSet = TargetingSet.Visible  -- or gameTargetingSet.None

local success, parts = ts:GetTargetParts(player, searchQuery)
if success then
    for _, part in ipairs(parts) do
        local entity = part:GetComponent(part):GetEntity()
        -- entity could be NPCPuppet, vehicleBaseObject, Device, etc.
    end
end

-- Find single closest entity to crosshair
local target = ts:GetObjectClosestToCrosshair(player, searchQuery)

-- Get crosshair ray (for raycasting)
local from, forward = ts:GetCrosshairData(player)

-- Get current look-at target (what scanner sees)
local target = ts:GetLookAtObject(player, false, false)
```

### Search Query Variants

```lua
-- NPCs only
local tsq = Game['TSQ_NPC;']()
-- or
local tsq = TSQ_NPC()

-- All entities
local tsq = Game['TSQ_ALL;']()
-- or
local tsq = TSQ_ALL.new()

-- Custom query with filters
local searchQuery = TargetSearchQuery.new()
searchQuery.filterObjectByDistance = true
searchQuery.testedSet = gameTargetingSet.None
searchQuery.maxDistance = 15
searchQuery.includeSecondaryTargets = true
searchQuery.ignoreInstigator = true
```

### Practical Pattern: Find Crowd NPC Positions

```lua
local function findNearbyNPCPositions(radius)
    local V = Game.GetPlayer()
    local ts = Game.GetTargetingSystem()
    local searchQuery = Game['TSQ_ALL;']()
    searchQuery.maxDistance = radius
    searchQuery.ignoreInstigator = true

    local success, parts = ts:GetTargetParts(V, searchQuery)
    local positions = {}

    if success then
        for _, part in ipairs(parts) do
            pcall(function()
                local entity = part:GetComponent(part):GetEntity()
                if entity and entity:IsA('NPCPuppet') and entity:IsCrowd() then
                    table.insert(positions, entity:GetWorldPosition())
                end
            end)
        end
    end
    return positions
end
```

### Practical Pattern: Find Devices (Including Doors)

```lua
local function findNearbyDevices(radius)
    local V = Game.GetPlayer()
    local ts = Game.GetTargetingSystem()
    local tsq = Game['TSQ_ALL;']()
    tsq.maxDistance = radius

    local success, parts = ts:GetTargetParts(V, tsq)
    local devices = {}

    if success then
        for _, part in ipairs(parts) do
            pcall(function()
                local entity = part:GetComponent(part):GetEntity()
                if entity and entity:IsA('gameDevice') then
                    table.insert(devices, {
                        entity = entity,
                        position = entity:GetWorldPosition(),
                        className = NameToString(entity:GetClassName())
                    })
                end
            end)
        end
    end
    return devices
end
```

---

## 4. AI Movement Commands — Making NPCs Move to Positions

From WolvenKit/cet-examples `AIControl.lua` and AMM `util.lua`:

### Move To Position

```lua
function MoveTo(npc, targetPosition, movementType)
    local worldPosition = WorldPosition.new()
    worldPosition:SetVector4(targetPosition)

    local positionSpec = AIPositionSpec.new()
    positionSpec:SetWorldPosition(worldPosition)

    local moveCmd = AIMoveToCommand.new()
    moveCmd.movementTarget = positionSpec
    moveCmd.movementType = movementType or moveMovementType.Sprint
    moveCmd.desiredDistanceFromTarget = 1.0
    moveCmd.finishWhenDestinationReached = true
    moveCmd.ignoreNavigation = false  -- false = use navmesh pathfinding
    moveCmd.useStart = true
    moveCmd.useStop = false

    npc:GetAIControllerComponent():SendCommand(moveCmd)
    return moveCmd
end
```

### Teleport To Position

```lua
function TeleportTo(npc, targetPosition)
    local teleportCmd = AITeleportCommand.new()
    teleportCmd.position = targetPosition
    teleportCmd.rotation = npc:GetWorldYaw()
    teleportCmd.doNavTest = false  -- skip nav test for teleport

    npc:GetAIControllerComponent():SendCommand(teleportCmd)
    return teleportCmd
end
```

### Hold Position

```lua
local holdCmd = AIHoldPositionCommand.new()
holdCmd.duration = 10.0
holdCmd.ignoreInCombat = false
npc:GetAIControllerComponent():SendCommand(holdCmd)
```

### Rotate To Face Position

```lua
local positionSpec = AIPositionSpec.new()
-- ... set world position ...
local rotateCmd = AIRotateToCommand.new()
rotateCmd.target = positionSpec
rotateCmd.angleTolerance = 5.0
rotateCmd.speed = 1.0
npc:GetAIControllerComponent():SendCommand(rotateCmd)
```

---

## 5. Spawn Systems Comparison

### DynamicEntitySystem (AMM/DSP Horde pattern — for NPCs with AI)

```lua
local spec = DynamicEntitySpec.new()
spec.recordID = TweakDBID.new("Character.cpz_maelstrom_grunt1_melee1_machete_mb")
spec.persistState = false
spec.persistSpawn = false
spec.alwaysSpawned = true
spec.spawnInView = false
spec.position = Vector4.new(x, y, z, 1.0)
spec.orientation = EulerAngles.ToQuat(EulerAngles.new(0, 0, yaw))
spec.tags = { "AMM_NPC" }

local entityID = Game.GetDynamicEntitySystem():CreateEntity(spec)
-- Poll with Game.FindEntityByID(entityID) until entity appears
-- Then apply AI behavior
```

### exEntitySpawner (DSP Phantom pattern — simpler but no AI attack)

```lua
local transform = V:GetWorldTransform()
local pos = WorldPosition.new()
WorldPosition.SetVector4(pos, Vector4.new(x, y, z, 1.0))
WorldTransform.SetWorldPosition(transform, pos)
WorldTransform.SetOrientation(transform, EulerAngles.ToQuat(EulerAngles.new(0, 0, yaw)))
local entityID = exEntitySpawner.SpawnRecord(recordPath, transform)
-- NOTE: hostile NPCs spawned this way have a known bug — they aim but don't fire
```

### StaticEntitySystem (entSpawner — for props/static objects)

```lua
local spec = StaticEntitySpec.new()
spec.templatePath = "base\\path\\to\\entity.ent"
spec.position = position
spec.orientation = rotation:ToQuat()
spec.attached = true
spec.appearanceName = "default"
local entityID = Game.GetStaticEntitySystem():SpawnEntity(spec)
```

---

## 6. AMM Positioning Approach

AMM has **NO spatial awareness**. It uses a simple "distance + angle from player" approach:

```lua
-- From AMM Modules/util.lua
function Util:GetDirection(angle)
    return Vector4.RotateAxis(Game.GetPlayer():GetWorldForward(), Vector4.new(0, 0, 1, 0), angle / 180.0 * Pi())
end

function Util:GetPosition(distance, angle)
    local pos = Game.GetPlayer():GetWorldPosition()
    local heading = Util:GetDirection(angle)
    return Vector4.new(pos.x + (heading.x * distance), pos.y + (heading.y * distance), pos.z + heading.z, pos.w + heading.w)
end

-- NPC spawns: 1m forward, facing -180 (toward player)
spawn.entitySpec.position = Util:GetPosition(1, 0)
spawn.entitySpec.orientation = Util:GetOrientation(-180)

-- Vehicle spawns: 5.5m forward
spawn.entitySpec.position = Util:GetPosition(5.5, 0.0)
```

**Key takeaway:** AMM does not check for walls, navmesh, or obstructions. Spawned entities can clip into walls.

---

## 7. entSpawner Positioning Approach

entSpawner also has **NO automatic spatial awareness for placement**. It uses:

1. **Manual position** from saved coordinates in preset files
2. **Camera raycast** for interactive placement (user points at surface, clicks to place)
3. **LocomotionEventsTransition** observer for physics interface access

The interactive placement raycast:
```lua
Observe("LocomotionEventsTransition", "OnUpdate", function(_, _, _, interface)
    editor.interface = interface
end)

-- Later, for picking:
local raycast = editor.interface:RaycastWithASingleGroup(origin, target, "PlayerBlocker")
if raycast:IsValid() then
    local hitPos = Vector4.Vector3To4(raycast.position)
    local hitNormal = Vector4.Vector3To4(raycast.normal)
end
```

---

## 8. What Does NOT Exist (Confirmed Absent)

Based on exhaustive search of all installed mods, online resources, and community examples:

| API | Status | Notes |
|-----|--------|-------|
| `Game.GetCoverManager()` | NOT FOUND | No mod uses it, likely not exposed to scripting |
| `FindCoverPoints()` | NOT FOUND | Cover system is internal to AI behavior trees |
| `Game.GetNavigationSystem()` | NOT FOUND | Not a valid game system name |
| `FindPointInSphereOnNavmesh()` | UNCONFIRMED | May exist in RTTI but zero CET usage found |
| `FindNavmeshPointInRadius()` | NOT FOUND | Not a real API |
| `GetNearestPointOnNavmesh()` | NOT FOUND | Not a real API |
| Door-type entity query | NOT DIRECT | Doors are `gameDevice` subclasses; find via TargetingSystem + IsA check |
| `GetEntitiesInArea()` | NOT FOUND | Use TargetingSystem:GetTargetParts instead |
| `Game.GetPopulationSystem()` | NOT FOUND | Crowd system is not scriptable |

---

## 9. Recommended Contextual Spawning Strategy

Given the available APIs, here is a practical multi-layered approach:

### Layer 1: Radial raycast wall detection (find "behind cover" positions)

Cast 8-16 rays outward from player at chest height. Where they hit walls, the spawn position is offset behind the wall by the hit normal.

```lua
local function findWallSpawnPositions(V, count, minDist, maxDist)
    local sqs = Game.GetSpatialQueriesSystem()
    local vPos = V:GetWorldPosition()
    local positions = {}
    local rayCount = 16

    for i = 0, rayCount - 1 do
        local angle = (i / rayCount) * 2 * math.pi
        local dir = Vector4.new(math.cos(angle), math.sin(angle), 0, 0)
        local from = Vector4.new(vPos.x, vPos.y, vPos.z + 1.0, 1.0)
        local to = Vector4.new(vPos.x + dir.x * maxDist, vPos.y + dir.y * maxDist, vPos.z + 1.0, 1.0)

        local success, result = sqs:SyncRaycastByCollisionGroup(from, to, "Static", false, false)
        if success then
            local hitPos = Vector4.Vector3To4(result.position)
            local dist = Vector4.Distance(vPos, hitPos)
            if dist >= minDist then
                local normal = Vector4.Vector3To4(result.normal)
                -- Spawn 1-2m behind the wall (on the other side)
                local spawnPos = Vector4.new(
                    hitPos.x + normal.x * 1.5,
                    hitPos.y + normal.y * 1.5,
                    hitPos.z,
                    1.0
                )
                table.insert(positions, { pos = spawnPos, dist = dist, type = "wall" })
            end
        end
    end
    return positions
end
```

### Layer 2: Navmesh validation

After computing candidate positions (from wall detection, random scatter, or crowd positions), validate each one:

```lua
local function isWalkable(pos)
    local navSys = Game.GetAINavigationSystem()
    local V = Game.GetPlayer()
    return navSys:IsPointOnNavmesh(V, pos, Vector4.new(1.0, 1.0, 1.0, 1.0))
end
```

### Layer 3: Ground snapping

For any position that passes navmesh check, snap to actual ground:

```lua
local function snapToGround(pos)
    local sqs = Game.GetSpatialQueriesSystem()
    local from = Vector4.new(pos.x, pos.y, pos.z + 5.0, 1.0)
    local to = Vector4.new(pos.x, pos.y, pos.z - 10.0, 1.0)
    local success, result = sqs:SyncRaycastByCollisionGroup(from, to, "Static", false, false)
    if success then
        return Vector4.new(result.position.x, result.position.y, result.position.z, 1.0)
    end
    return pos  -- fallback: original position
end
```

### Layer 4: Crowd position hijacking

Find crowd NPC positions and spawn hostile NPCs there (emerging from the crowd):

```lua
local function findCrowdPositions(radius)
    local V = Game.GetPlayer()
    local ts = Game.GetTargetingSystem()
    local tsq = Game['TSQ_ALL;']()
    tsq.maxDistance = radius
    tsq.ignoreInstigator = true

    local success, parts = ts:GetTargetParts(V, tsq)
    local positions = {}

    if success then
        for _, part in ipairs(parts) do
            pcall(function()
                local entity = part:GetComponent(part):GetEntity()
                if entity and entity:IsA('NPCPuppet') and not entity:IsDead() then
                    -- Prefer crowd NPCs for less jarring "emergence from crowd"
                    local isCrowd = entity.isCrowd or false
                    table.insert(positions, {
                        pos = entity:GetWorldPosition(),
                        type = isCrowd and "crowd" or "npc",
                        entityID = entity:GetEntityID()
                    })
                end
            end)
        end
    end
    return positions
end
```

### Layer 5: Line-of-sight check (spawn out of view)

Verify spawn position is NOT in player's direct line of sight:

```lua
local function isOutOfSight(V, spawnPos)
    local sqs = Game.GetSpatialQueriesSystem()
    local eyePos = Vector4.new(
        V:GetWorldPosition().x,
        V:GetWorldPosition().y,
        V:GetWorldPosition().z + 1.7,
        1.0
    )
    local success, _ = sqs:SyncRaycastByCollisionGroup(eyePos, spawnPos, "Static", false, false)
    return success  -- if raycast hits something, the point is occluded
end
```

---

## 10. Sources

### Installed mods analyzed:
- `AppearanceMenuMod/Modules/spawn.lua` — DynamicEntitySystem spawning, no spatial awareness
- `AppearanceMenuMod/Modules/util.lua` — GetPosition/GetDirection helpers, SyncRaycastByCollisionGroup for NPC move-to
- `entSpawner/modules/classes/spawn/spawnable.lua` — StaticEntitySystem spawning
- `entSpawner/modules/utils/editor/editor.lua` — LocomotionEventsTransition raycast interface
- `AutoLoot/modules/logic.lua` — IsPointOnNavmesh usage, multi-group raycast helper
- `RedHotTools/modules/world/main.lua` — SpatialQueriesSystem, WorldInspector multi-raycast
- `RedHotTools/modules/world/data/collision-groups.lua` — COMPLETE collision group list
- `NightCityVoices/modules/npc_scanner.lua` — TSQ_ALL + GetTargetParts for NPC finding
- `CETBridge/handlers.lua` — GetTargetParts for nearby entity enumeration
- `react_to_horn/init.lua` — GetTargetParts with TargetingSet.Visible
- `Say_Something_Damn_It/init.lua` — TargetSearchQuery.new() with custom filters
- `leanAnywhere/modules/logic.lua` — RaycastWithASingleGroup via LocomotionEventsTransition
- `DavidSandevistanPlus/psychosis.lua` — Current phantom/horde spawn logic

### Online resources:
- [WolvenKit/cet-examples TargetingHelper.lua](https://github.com/WolvenKit/cet-examples/blob/main/ai-components/TargetingHelper.lua) — Collision group list, GetCrosshairData, multi-group raycast
- [WolvenKit/cet-examples AIControl.lua](https://github.com/WolvenKit/cet-examples/blob/main/ai-components/AIControl.lua) — AIMoveToCommand, AITeleportCommand, AIFollowerRole, AIHoldPositionCommand
- [NativeDB](https://nativedb.red4ext.com/) — RTTI database (requires JS, not scrapeable)
- [RED4ext.NativeDB](https://github.com/wopss/RED4ext.NativeDB) — Source for NativeDB
- [Collision reference](https://wiki.redmodding.org/cyberpunk-2077-modding/for-mod-creators-theory/files-and-what-they-do/file-formats/entity-.ent-files/collision) — Collision system docs
