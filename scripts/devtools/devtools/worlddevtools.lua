----
-- World tools.
--
-- Extends `devtools.DevTools` and includes different world functionality. Acts as a layer to
-- `TheWorld` so most of the methods are just for convenience. However, it also holds upvalues
-- retrieved in the **modmain** for the rain/snow prediction and some map-related features that
-- don't require direct access to `ThePlayer`.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.world
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod devtools.WorldDevTools
-- @see DevTools
-- @see devtools.DevTools
-- @see devtools.world.SaveDataDevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
require "class"
require "consolecommands"

local DevTools = require "devtools/devtools/devtools"
local SaveDataDevTools = require "devtools/devtools/world/savedatadevtools"
local SDK = require "devtools/sdk/sdk/sdk"

-- threads
local _PRECIPITATION_THREAD_ID = "mod_dev_tools_precipitation_thread"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam EntityScript inst
-- @tparam DevTools devtools
-- @usage local worlddevtools = WorldDevTools(TheWorld, devtools)
local WorldDevTools = Class(DevTools, function(self, inst, devtools)
    DevTools._ctor(self, "WorldDevTools", devtools)

    -- general
    self.inst = inst
    self.ismastersim = inst.ismastersim
    self.savedata = SaveDataDevTools(self, self.devtools)

    -- map
    self.is_map_clearing = false
    self.is_map_fog_of_war = true

    -- weather
    self.precipitation_ends = nil
    self.precipitation_starts = nil
    self.precipitation_thread = nil

    if inst then
        self:StartPrecipitationThread()
        if devtools then
            devtools.ismastersim = inst.ismastersim
        end
    end

    -- self
    self:DoInit()
end)

--- General
-- @section general

--- Checks if a master simulated world.
-- @treturn boolean
function WorldDevTools:IsMasterSim()
    return self.ismastersim
end

--- Gets `TheWorld`.
-- @treturn table
function WorldDevTools:GetWorld()
    return self.inst
end

--- Gets `TheWorld.net`.
-- @treturn table
function WorldDevTools:GetWorldNet()
    return self.inst and self.inst.net
end

--- Gets `TheWorld` meta.
-- @tparam[opt] string name Meta name
-- @treturn[1] table Meta table, when no name passed
-- @treturn[2] string Meta value, when the name is passed
function WorldDevTools:GetMeta(name)
    local meta = self.inst and self.inst.meta
    if meta and name ~= nil then
        return meta and meta[name]
    end
    return meta
end

--- Gets meta seed.
-- @treturn string
function WorldDevTools:GetSeed()
    return self:GetMeta("seed")
end

--- Selection
-- @section selection

--- Gets debug entity.
--
-- This is a convenience method returning:
--
--    GetDebugEntity()
--
-- @treturn table
function WorldDevTools:GetSelectedEntity() -- luacheck: only
    return GetDebugEntity()
end

--- Selects `TheWorld`.
--
-- This is a convenience method returning:
--
--    SetDebugEntity(TheWorld)
--
-- @treturn boolean Always true
function WorldDevTools:Select()
    SetDebugEntity(self.inst)
    self.devtools.labels:RemoveSelected()
    self:DebugString("Selected TheWorld")
    return true
end

--- Selects `TheWorld.net`.
--
-- This is a convenience method returning:
--
--    SetDebugEntity(TheWorld.net)
--
-- @treturn boolean Always true
function WorldDevTools:SelectNet()
    SetDebugEntity(self.inst.net)
    self.devtools.labels:RemoveSelected()
    self:DebugString("Selected TheWorld.net")
    return true
end

--- Selects an entity under the mouse.
--
-- This is a convenience method returning:
--
--    SetDebugEntity(TheInput:GetWorldEntityUnderMouse())
--
-- @treturn boolean
function WorldDevTools:SelectEntityUnderMouse()
    local entity = TheInput:GetWorldEntityUnderMouse()
    if entity then
        SetDebugEntity(entity)
        self.devtools.labels:AddSelected(entity)
        self:DebugString("Selected", entity:GetDisplayName())

        local screen = self.devtools.screen
        if screen then
            screen:ResetDataSidebarIndex()
        end

        return true
    end

    SetDebugEntity(nil)
    self.devtools.labels:RemoveSelected()
    self:DebugString("Unselected")

    local screen = self.devtools.screen
    if screen then
        screen:ResetDataSidebarIndex()
    end

    return false
end

--- Map
-- @section map

--- Checks if the map clearing state.
-- @treturn boolean
function WorldDevTools:IsMapClearing()
    return self.is_map_clearing
end

--- Checks if the map for of war state.
-- @treturn boolean
function WorldDevTools:IsMapFogOfWar()
    return self.is_map_fog_of_war
end

--- Toggles map clearing.
-- @treturn boolean
function WorldDevTools:ToggleMapClearing()
    if not self.ismastersim then
        return false
    end

    self.is_map_clearing = not self.is_map_clearing
    self.inst.minimap.MiniMap:ContinuouslyClearRevealedAreas(self.is_map_clearing)
    self:DebugString(
        "Continuous revealed areas clearing is",
        (self.is_map_clearing and "enabled" or "disabled")
    )

    return self.is_map_clearing
end

--- Toggles fog of war.
-- @treturn boolean
function WorldDevTools:ToggleMapFogOfWar()
    if not self.ismastersim then
        return false
    end

    self.is_map_fog_of_war = not self.is_map_fog_of_war
    self.inst.minimap.MiniMap:EnableFogOfWar(self.is_map_fog_of_war)
    self:DebugString("Fog of War is", (self.is_map_fog_of_war and "enabled" or "disabled"))

    return self.is_map_fog_of_war
end

--- Weather
-- @section weather

--- Gets precipitation start time.
-- @treturn number
function WorldDevTools:GetPrecipitationStarts()
    return self.precipitation_starts
end

--- Gets precipitation end time.
-- @treturn number
function WorldDevTools:GetPrecipitationEnds()
    return self.precipitation_ends
end

--- Starts the precipitation thread.
--
-- Starts the thread that sets both `precipitation_starts` and `precipitation_ends` fields used for
-- predicting when the rain/show starts/ends.
--
-- The in-game prediction accuracy is ~15 minutes at very best.
function WorldDevTools:StartPrecipitationThread()
    local moisture, moisture_ceil, moisture_floor
    local current_ceil, previous_ceil, diff_ceil
    local current_floor, previous_floor, diff_floor
    local frames

    self.precipitation_thread = SDK.Thread.Start(_PRECIPITATION_THREAD_ID, function()
        moisture = SDK.World.GetState("moisture")
        moisture_ceil = SDK.World.GetState("moistureceil")
        moisture_floor = SDK.World.GetMoistureFloor() or 0

        current_ceil = math.abs(moisture_ceil - moisture)
        current_floor = math.abs(moisture_floor - moisture)

        if not previous_ceil then
            previous_ceil = current_ceil
        end

        if not previous_floor then
            previous_floor = current_floor
        end

        diff_ceil = math.abs(current_ceil - previous_ceil)
        diff_floor = math.abs(current_floor - previous_floor)
        previous_ceil = current_ceil
        previous_floor = current_floor

        frames = current_ceil * (FRAMES / FRAMES) / diff_ceil
        self.precipitation_starts = frames

        frames = current_floor * (FRAMES / FRAMES) / diff_floor
        self.precipitation_ends = frames

        Sleep(FRAMES / FRAMES)
    end, function()
        return self.inst and self.inst.net and SDK.World.GetWeatherComponent()
    end)
end

--- Stops the precipitation thread.
--
-- Stops the thread started earlier by the `StartPrecipitationThread`.
function WorldDevTools:ClearPrecipitationThread()
    SDK.Thread.Clear(self.precipitation_thread)
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function WorldDevTools:DoInit()
    DevTools.DoInit(self, self.devtools, "world", {
        SelectWorld = "Select",
        SelectWorldNet = "SelectNet",

        -- general
        "IsMasterSim",
        "GetWorld",
        "GetWorldNet",
        "GetMeta",
        "GetSeed",

        -- selection
        "GetSelectedEntity",
        "SelectEntityUnderMouse",

        -- map
        "IsMapClearing",
        "IsMapFogOfWar",
        "ToggleMapClearing",
        "ToggleMapFogOfWar",

        -- weather
        "GetPrecipitationStarts",
        "GetPrecipitationEnds",
        "StartPrecipitationThread",
        "ClearPrecipitationThread",
    })
end

--- Terminates.
function WorldDevTools:DoTerm()
    if self.savedata then
        self.savedata.DoTerm(self.savedata)
    end
    DevTools.DoTerm(self)
end

return WorldDevTools
