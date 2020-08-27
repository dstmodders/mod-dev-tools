----
-- World data.
--
-- Includes world data functionality which aim is to display some world and save data info.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.WorldData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Data = require "devtools/data/data"
local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam devtools.WorldDevTools worlddevtools
-- @usage local worlddata = WorldData(worlddevtools)
local WorldData = Class(Data, function(self, worlddevtools)
    Data._ctor(self)

    -- general
    self.save_data_lines_stack = {}
    self.savedatadevtools = worlddevtools.savedata
    self.world_lines_stack = {}
    self.worlddevtools = worlddevtools

    -- update
    self:Update()
end)

--- General
-- @section general

--- Clears lines stack.
function WorldData:Clear()
    self.world_lines_stack = {}
    self.save_data_lines_stack = {}
end

--- Updates lines stack.
function WorldData:Update()
    self:Clear()
    self:PushWorldData()
    if self.savedatadevtools then
        self:PushSaveData()
    end
end

--- World
-- @section world

local function PushWorldLine(self, name, value)
    self:PushLine(self.world_lines_stack, name, value)
end

local function PushWorldMoistureLine(self)
    local worlddevtools = self.worlddevtools
    local moisture = worlddevtools:GetStateMoisture()
    local moisture_ceil = worlddevtools:GetStateMoistureCeil()
    local moisture_rate = worlddevtools:GetMoistureRate()
    local moisture_floor = worlddevtools:GetMoistureFloor()

    if moisture ~= nil and moisture_ceil ~= nil and moisture_rate ~= nil then
        local moisture_string = self:ToValueFloat(moisture)

        if moisture_rate and moisture_rate > 0 then
            moisture_string = string.format(
                "%0.2f (%s%0.2f)",
                moisture,
                worlddevtools:IsPrecipitation() and "-" or "+",
                math.abs(moisture_rate)
            )
        end

        local value = moisture_floor
            and self:ToValueSplit({ moisture_floor, moisture_string, moisture_ceil })
            or self:ToValueSplit({ moisture_string, moisture_ceil })

        PushWorldLine(self, "Moisture", value)
    end
end

local function PushWorldPhaseLine(self)
    local worlddevtools = self.worlddevtools
    local phase = worlddevtools:GetPhase()
    if phase ~= nil then
        local next_phase = worlddevtools:GetNextPhase(phase)
        if next_phase then
            local seconds = worlddevtools:GetTimeUntilPhase(next_phase)
            if seconds ~= nil then
                PushWorldLine(self, "Phase", { phase, self:ToValueClock(seconds, true) })
            else
                PushWorldLine(self, "Phase", phase)
            end
        end
    end
end

local function PushWorldPrecipitationLines(self)
    local worlddevtools = self.worlddevtools

    local precipitation_rate = worlddevtools:GetStatePrecipitationRate()
    if precipitation_rate and precipitation_rate > 0 then
        local peakprecipitationrate = worlddevtools:GetPeakPrecipitationRate()
        PushWorldLine(self, "Precipitation Rate", peakprecipitationrate ~= nil
            and { precipitation_rate, peakprecipitationrate }
            or self:ToValueFloat(precipitation_rate))
    end

    local is_snowing = worlddevtools:GetStateIsSnowing()
    local precipitation_starts = worlddevtools:GetPrecipitationStarts()
    local precipitation_ends = worlddevtools:GetPrecipitationEnds()

    if precipitation_starts and precipitation_ends then
        local label = is_snowing and "Snow" or "Rain"
        if not worlddevtools:IsPrecipitation() then
            PushWorldLine(self, label .. " Starts", "~" .. self:ToValueClock(precipitation_starts))
        else
            PushWorldLine(self, label .. " Ends", "~" .. self:ToValueClock(precipitation_ends))
        end
    end

    if is_snowing then
        PushWorldLine(
            self,
            "Snow Level",
            self:ToValuePercent(worlddevtools:GetStateSnowLevel() * 100)
        )
    end
end

local function PushWorldTemperatureLine(self)
    local temperature = self.worlddevtools:GetStateTemperature()
    if temperature ~= nil then
        PushWorldLine(self, "Temperature", self:ToValueScale(temperature))
    end
end

local function PushWorldWetnessLine(self)
    local worlddevtools = self.worlddevtools
    local wetness = worlddevtools:GetStateWetness()
    local wetness_rate = worlddevtools:GetWetnessRate()

    if wetness and wetness > 0 then
        local value = self:ToValuePercent(wetness)
        if wetness_rate and wetness_rate > 0 then
            value = string.format("%s (+%0.2f)", value, math.abs(wetness_rate))
        elseif wetness_rate and wetness_rate < 0 then
            value = string.format("%s (-%0.2f)", value, math.abs(wetness_rate))
        end
        PushWorldLine(self, "Wetness", value)
    end
end

--- Pushes world data.
function WorldData:PushWorldData()
    Utils.AssertRequiredField("WorldData.worlddevtools", self.worlddevtools)

    local worlddevtools = self.worlddevtools

    PushWorldLine(self, "Seed", worlddevtools:GetSeed())
    PushWorldLine(self, "Season", worlddevtools:GetStateSeason())
    PushWorldPhaseLine(self)
    PushWorldTemperatureLine(self)
    PushWorldMoistureLine(self)
    PushWorldPrecipitationLines(self)
    PushWorldWetnessLine(self)

    -- Commented out intentionally. Will be uncommented later.
    --local savedatadevtools = self.savedatadevtools
    --if savedatadevtools and not worlddevtools:IsCave() then
    --    PushWorldLine(self, "Walrus Camps", savedatadevtools:GetNrOfWalrusCamps())
    --end
end

--- Save data
-- @section save-data

local function PushSaveDataLine(self, name, value)
    self:PushLine(self.save_data_lines_stack, name, value)
end

--local function GetDeerclopsSpawnerValue(persistdata)
--    if not persistdata or type(persistdata.deerclopsspawner) ~= "table" then
--        return "unavailable"
--    end
--
--    local spawner = persistdata.deerclopsspawner
--
--    if spawner.warning == true then
--        return "warning"
--    end
--
--    return spawner.activehassler ~= nil and "yes" or "no"
--end
--
--local function GetBeargerSpawnerValue(self, persistdata)
--    if not persistdata or type(persistdata.beargerspawner) ~= "table" then
--        return "unavailable"
--    end
--
--    local spawner = persistdata.beargerspawner
--
--    if spawner.warning == true then
--        return "warning"
--    end
--
--    if type(spawner.activehasslers) == "table" then
--        if #spawner.activehasslers == 0 and type(spawner.lastKillDay) == "number" then
--            return self:ToValueSplit({ "killed", "day " .. spawner.lastKillDay })
--        elseif #spawner.activehasslers > 0 then
--            return "yes"
--        end
--
--        return "no"
--    end
--
--    return "error"
--end
--
--local function GetMalbatrossSpawnerValue(self, persistdata)
--    if not persistdata or type(persistdata.malbatrossspawner) ~= "table" then
--        return "unavailable"
--    end
--
--    local spawner = persistdata.malbatrossspawner
--
--    if spawner.activeguid ~= nil then
--        return "yes"
--    end
--
--    local timetospawn = spawner._time_until_spawn
--    if type(timetospawn) == "number" then
--        if spawner._firstspawn == true or timetospawn <= 0 then
--            return "waiting"
--        elseif timetospawn > 0 then
--            return self:ToValueClock(timetospawn - GetTime())
--        end
--
--        return "no"
--    end
--
--    return "error"
--end
--
--local function GetDeersSpawnerValue(self, persistdata)
--    if not persistdata or type(persistdata.deerherdspawner) ~= "table" then
--        return "unavailable"
--    end
--
--    local spawner = persistdata.deerherdspawner
--    local timetospawn = spawner._timetospawn
--
--    if type(timetospawn) == "number" then
--        return timetospawn <= 0
--            and "waiting"
--            or self:ToValueClock(timetospawn - GetTime())
--    end
--
--    if type(spawner._activedeer) == "table" then
--        return #spawner._activedeer
--    end
--
--    return "error"
--end
--
--local function GetKlausSackSpawnerValue(self, persistdata)
--    if not persistdata or type(persistdata.klaussackspawner) ~= "table" then
--        return "unavailable"
--    end
--
--    local timetorespawn = persistdata.klaussackspawner.timetorespawn
--    if type(timetorespawn) == "number" then
--        return timetorespawn > 0
--            and self:ToValueClock(timetorespawn - GetTime())
--            or "no"
--    elseif timetorespawn == false then
--        return "yes"
--    end
--
--    return "error"
--end
--
--local function GetHoundedValue(self, persistdata)
--    if not persistdata or type(persistdata.hounded) ~= "table" then
--        return "unavailable"
--    end
--
--    local timetoattack = persistdata.hounded.timetoattack
--    if type(timetoattack) == "number" then
--        return timetoattack > 0
--            and self:ToValueClock(timetoattack - GetTime())
--            or "no"
--    end
--
--    return "error"
--end
--
--local function GetChessUnlocksValue(persistdata)
--    if not persistdata or type(persistdata.chessunlocks) ~= "table" then
--        return "unavailable"
--    end
--
--    local unlocks = persistdata.chessunlocks.unlocks
--    if type(unlocks) == "table" then
--        return #unlocks > 0
--            and table.concat(unlocks, ", ")
--            or "no"
--    end
--
--    return "error"
--end

--- Pushes save data.
function WorldData:PushSaveData()
    Utils.AssertRequiredField("WorldData.savedatadevtools", self.savedatadevtools)
    Utils.AssertRequiredField("WorldData.worlddevtools", self.worlddevtools)

    PushSaveDataLine(self, "Seed", self.savedatadevtools:GetSeed())
    PushSaveDataLine(self, "Save Version", self.savedatadevtools:GetVersion())

    -- Commented out intentionally. Will be uncommented later.
    --local worlddevtools = self.worlddevtools
    --local persistdata = self.savedatadevtools:GetMapPersistData()
    --if persistdata then
    --    if not worlddevtools:IsCave() then
    --        PushSaveDataLine(self, "Deerclops", GetDeerclopsSpawnerValue(persistdata))
    --        PushSaveDataLine(self, "Bearger", GetBeargerSpawnerValue(self, persistdata))
    --        PushSaveDataLine(self, "Malbatross", GetMalbatrossSpawnerValue(self, persistdata))
    --        PushSaveDataLine(self, "Deers", GetDeersSpawnerValue(self, persistdata))
    --        PushSaveDataLine(self, "Klaus Sack", GetKlausSackSpawnerValue(self, persistdata))
    --        PushSaveDataLine(self, "Hounds Attack", GetHoundedValue(self, persistdata))
    --    else
    --        PushSaveDataLine(self, "Worms Attack", GetHoundedValue(self, persistdata))
    --    end
    --    PushSaveDataLine(self, "Chess Unlocks", GetChessUnlocksValue(persistdata))
    --end
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function WorldData:__tostring()
    if #self.world_lines_stack == 0 then
        return
    end

    local t = {}

    self:TableInsertTitle(
        t,
        "World " .. (not self.worlddevtools:IsCave() and "(Forest)" or "(Cave)")
    )

    self:TableInsertData(t, self.world_lines_stack)
    table.insert(t, "\n")

    if #self.save_data_lines_stack > 0 then
        self:TableInsertTitle(t, "Save Data")
        self:TableInsertData(t, self.save_data_lines_stack)
    end

    return table.concat(t)
end

return WorldData
