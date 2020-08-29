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
-- @classmod devtools.WorldDevTools
-- @see DevTools
-- @see devtools.DevTools
-- @see devtools.world.SaveDataDevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"
require "consolecommands"

local DevTools = require "devtools/devtools/devtools"
local SaveDataDevTools = require "devtools/devtools/world/savedatadevtools"
local Utils = require "devtools/utils"

-- threads
local _PRECIPITATION_THREAD_ID = "mod_dev_tools_precipitation_thread"

local WorldDevTools = Class(DevTools, function(self, inst, devtools)
    DevTools._ctor(self, "WorldDevTools", devtools)

    -- general
    self.inst = inst
    self.ismastersim = inst.ismastersim
    self.savedata = SaveDataDevTools(self, self.devtools)

    -- map
    self.is_map_clearing = false
    self.is_map_fog_of_war = true

    -- precipitation
    self.precipitation_ends = nil
    self.precipitation_starts = nil
    self.precipitation_thread = nil

    -- upvalues
    self.weathermoisturefloor = nil
    self.weathermoisturerate = nil
    self.weatherpeakprecipitationrate = nil
    self.weatherwetrate = nil

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

--- Checks if it's a cave world.
-- @treturn boolean
function WorldDevTools:IsCave()
    return self.inst and self.inst:HasTag("cave")
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

--- Gets weather component.
--
-- Returns the component based on the current world type: cave or forest.
--
-- @treturn[1] Weather
-- @treturn[2] CaveWeather
function WorldDevTools:GetWeatherComponent()
    if not self.inst or not self.inst.net or not self.inst.net.components then
        return
    end

    local component
    if self:IsCave() then
        component = self.inst.net.components.caveweather or nil
        return component ~= nil and component or nil
    else
        component = self.inst.net.components.weather or nil
        return component ~= nil and component or nil
    end
end

--- Gets the time until the phase.
--
-- This is a convenience method returning:
--
--    TheWorld.net.components.clock:GetTimeUntilPhase(phase)
--
-- @tparam string phase
-- @treturn number
function WorldDevTools:GetTimeUntilPhase(phase)
    return self.inst
        and self.inst.net
        and self.inst.net.components
        and self.inst.net.components.clock
        and self.inst.net.components.clock:GetTimeUntilPhase(phase)
end

--- Gets the phase.
-- @tparam string phase Phase
-- @treturn number
function WorldDevTools:GetPhase()
    return self:IsCave() and self:GetStateCavePhase() or self:GetStatePhase()
end

--- Gets the next phase.
--
-- Returns the value based on the following logic:
--
--   - day => dusk
--   - dusk => night
--   - night => day
--
-- @tparam string phase Current phase
-- @treturn string Next phase
function WorldDevTools:GetNextPhase(phase) -- luacheck: only
    return Utils.TableNextValue({ "day", "dusk", "night" }, phase)
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
        self:DebugString("Selected", entity:GetDisplayName())
        return true
    end
    return false
end

--- State
-- @section state

--- Gets `TheWorld` state.
-- @tparam[opt] string name State name
-- @treturn[1] table State table, when no name passed
-- @treturn[2] string State value, when the name is passed
function WorldDevTools:GetState(name)
    local state = self.inst and self.inst.state
    if state and name ~= nil then
        return state and state[name]
    end
    return state
end

--- Gets `cavephase` state.
-- @treturn string
function WorldDevTools:GetStateCavePhase()
    return self:GetState("cavephase")
end

--- Gets `issnowing` state.
-- @treturn boolean
function WorldDevTools:GetStateIsSnowing()
    return self:GetState("issnowing")
end

--- Gets `moisture` state.
-- @treturn number
function WorldDevTools:GetStateMoisture()
    return self:GetState("moisture")
end

--- Gets `moistureceil` state.
-- @treturn number
function WorldDevTools:GetStateMoistureCeil()
    return self:GetState("moistureceil")
end

--- Gets `phase` state.
-- @treturn string
function WorldDevTools:GetStatePhase()
    return self:GetState("phase")
end

--- Gets `precipitationrate` state.
-- @treturn number
function WorldDevTools:GetStatePrecipitationRate()
    return self:GetState("precipitationrate")
end

--- Gets `remainingdaysinseason` state.
-- @treturn number
function WorldDevTools:GetStateRemainingDaysInSeason()
    return self:GetState("remainingdaysinseason")
end

--- Gets `season` state.
-- @treturn string
function WorldDevTools:GetStateSeason()
    return self:GetState("season")
end

--- Gets `snowlevel` state.
-- @treturn number
function WorldDevTools:GetStateSnowLevel()
    return self:GetState("snowlevel")
end

--- Gets `temperature` state.
-- @treturn number
function WorldDevTools:GetStateTemperature()
    return self:GetState("temperature")
end

--- Gets `wetness` state.
-- @treturn number
function WorldDevTools:GetStateWetness()
    return self:GetState("wetness")
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

--- Precipitation
-- @section precipitation

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

--- Gets precipitation state.
-- @treturn boolean
function WorldDevTools:IsPrecipitation()
    return self.inst
        and self.inst.state
        and self.inst.state.precipitation ~= "none"
        or self.inst.state.moisture >= self.inst.state.moistureceil
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

    self.precipitation_thread = Utils.ThreadStart(_PRECIPITATION_THREAD_ID, function()
        moisture = self:GetStateMoisture()
        moisture_ceil = self:GetStateMoistureCeil()
        moisture_floor = self:GetMoistureFloor() or 0

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
        return self.inst and self.inst.net and self:GetWeatherComponent()
    end)
end

--- Stops the precipitation thread.
--
-- Stops the thread started earlier by the `StartPrecipitationThread`.
function WorldDevTools:ClearPrecipitationThread()
    Utils.ThreadClear(self.precipitation_thread)
end

--- Upvalues
-- @section upvalues

--- Sets `weathermoisturefloor` upvalue.
--
-- This setter is called in the **modmain** where the value is retrieved using the `DebugUpvalue`.
--
-- @tparam number value
function WorldDevTools:SetMoistureFloor(value)
    self.weathermoisturefloor = value
end

--- Sets `weathermoisturerate` upvalue.
--
-- This setter is called in the **modmain** where the value is retrieved using the `DebugUpvalue`.
--
-- @tparam number value
function WorldDevTools:SetMoistureRate(value)
    self.weathermoisturerate = value
end

--- Sets `weatherpeakprecipitationrate`.
--
-- This setter is called in the **modmain** where the value is retrieved using the `DebugUpvalue`.
--
-- @tparam number value
function WorldDevTools:SetPeakPrecipitationRate(value)
    self.weatherpeakprecipitationrate = value
end

--- Sets `weatherwetrate` upvalue.
--
-- This setter is called in the **modmain** where the value is retrieved using the `DebugUpvalue`.
--
-- @tparam number value
function WorldDevTools:SetWetnessRate(value)
    self.weatherwetrate = value
end

--- Gets `weathermoisturefloor` upvalue.
--
-- Returns the value set earlier by `SetMoistureFloor`.
--
-- @treturn number
function WorldDevTools:GetMoistureFloor()
    return self.weathermoisturefloor
end

--- Gets `weathermoisturerate` upvalue.
--
-- Returns the value set earlier by `SetMoistureRate`.
--
-- @treturn number
function WorldDevTools:GetMoistureRate()
    return self.weathermoisturerate
end

--- Gets `weatherpeakprecipitationrate`.
--
-- Returns the value set earlier by `SetPeakPrecipitationRate`.
--
-- @treturn number
function WorldDevTools:GetPeakPrecipitationRate()
    return self.weatherpeakprecipitationrate
end

--- Gets `weatherwetrate` upvalue.
--
-- Returns the value set earlier by `SetWetnessRate`.
--
-- @treturn number
function WorldDevTools:GetWetnessRate()
    return self.weatherwetrate
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
        "IsCave",
        "GetMeta",
        "GetSeed",
        "GetWeatherComponent",
        "GetTimeUntilPhase",
        "GetPhase",
        "GetNextPhase",

        -- selection
        "GetSelectedEntity",
        "SelectEntityUnderMouse",

        -- state
        "GetState",
        "GetStateCavePhase",
        "GetStateIsSnowing",
        "GetStateMoisture",
        "GetStateMoistureCeil",
        "GetStatePhase",
        "GetStatePrecipitationRate",
        "GetStateRemainingDaysInSeason",
        "GetStateSeason",
        "GetStateSnowLevel",
        "GetStateTemperature",
        "GetStateWetness",

        -- map
        "IsMapClearing",
        "IsMapFogOfWar",
        "ToggleMapClearing",
        "ToggleMapFogOfWar",

        -- precipitation
        "GetPrecipitationStarts",
        "GetPrecipitationEnds",
        "IsPrecipitation",
        "StartPrecipitationThread",
        "ClearPrecipitationThread",

        -- upvalues
        "SetMoistureFloor",
        "SetMoistureRate",
        "SetPeakPrecipitationRate",
        "SetWetnessRate",
        "GetMoistureFloor",
        "GetMoistureRate",
        "GetPeakPrecipitationRate",
        "GetWetnessRate",
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
