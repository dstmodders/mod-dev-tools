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
-- @release 0.6.0-alpha
----
require "class"

local Data = require "devtools/data/data"
local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam screens.DevToolsScreen screen
-- @tparam devtools.WorldDevTools worlddevtools
-- @usage local worlddata = WorldData(screen, worlddevtools)
local WorldData = Class(Data, function(self, screen, worlddevtools)
    Data._ctor(self, screen)

    -- general
    self.savedatadevtools = worlddevtools and worlddevtools.savedata
    self.worlddevtools = worlddevtools

    -- self
    self:Update()
end)

--- General
-- @section general

--- Updates lines stack.
function WorldData:Update()
    Data.Update(self)

    self:PushTitleLine("World " .. (not self.worlddevtools:IsCave() and "(Forest)" or "(Cave)"))
    self:PushEmptyLine()
    self:PushWorldData()

    if self.savedatadevtools then
        self:PushEmptyLine()
        self:PushTitleLine("Save Data")
        self:PushEmptyLine()
        self:PushSaveData()
    end
end

--- World
-- @section world

--- Pushes world moisture line.
function WorldData:PushWorldMoistureLine()
    local worlddevtools = self.worlddevtools
    local moisture = worlddevtools:GetStateMoisture()
    local moisture_ceil = worlddevtools:GetStateMoistureCeil()
    local moisture_rate = worlddevtools:GetMoistureRate()
    local moisture_floor = worlddevtools:GetMoistureFloor()

    if moisture ~= nil and moisture_ceil ~= nil and moisture_rate ~= nil then
        local moisture_string = Utils.String.ValueFloat(moisture)

        if moisture_rate and moisture_rate > 0 then
            moisture_string = string.format(
                "%0.2f (%s%0.2f)",
                moisture,
                worlddevtools:IsPrecipitation() and "-" or "+",
                math.abs(moisture_rate)
            )
        end

        local value = moisture_floor
            and Utils.String.TableSplit({ moisture_floor, moisture_string, moisture_ceil })
            or Utils.String.TableSplit({ moisture_string, moisture_ceil })

        self:PushLine("Moisture", value)
    end
end

--- Pushes world phase line.
function WorldData:PushWorldPhaseLine()
    local worlddevtools = self.worlddevtools
    local phase = worlddevtools:GetPhase()
    if phase ~= nil then
        local next_phase = worlddevtools:GetNextPhase(phase)
        if next_phase then
            local seconds = worlddevtools:GetTimeUntilPhase(next_phase)
            if seconds ~= nil then
                self:PushLine("Phase", { phase, Utils.String.ValueClock(seconds, true) })
            else
                self:PushLine("Phase", phase)
            end
        end
    end
end

--- Pushes world precipitation line.
function WorldData:PushWorldPrecipitationLines()
    local worlddevtools = self.worlddevtools

    local precipitation_rate = worlddevtools:GetStatePrecipitationRate()
    if precipitation_rate and precipitation_rate > 0 then
        local peakprecipitationrate = worlddevtools:GetPeakPrecipitationRate()
        self:PushLine("Precipitation Rate", peakprecipitationrate ~= nil
            and { precipitation_rate, peakprecipitationrate }
            or Utils.String.ValueFloat(precipitation_rate))
    end

    local is_snowing = worlddevtools:GetStateIsSnowing()
    local precipitation_starts = worlddevtools:GetPrecipitationStarts()
    local precipitation_ends = worlddevtools:GetPrecipitationEnds()

    if precipitation_starts and precipitation_ends then
        local label = is_snowing and "Snow" or "Rain"
        if not worlddevtools:IsPrecipitation() then
            self:PushLine(
                label .. " Starts",
                "~" .. Utils.String.ValueClock(precipitation_starts)
            )
        else
            self:PushLine(label .. " Ends", "~" .. Utils.String.ValueClock(precipitation_ends))
        end
    end

    if is_snowing then
        self:PushLine(
            "Snow Level",
            Utils.String.ValuePercent(worlddevtools:GetStateSnowLevel() * 100)
        )
    end
end

--- Pushes world temperature line.
function WorldData:PushWorldTemperatureLine()
    local temperature = self.worlddevtools:GetStateTemperature()
    if temperature ~= nil then
        self:PushLine("Temperature", Utils.String.ValueScale(temperature))
    end
end

--- Pushes world wetness line.
function WorldData:PushWorldWetnessLine()
    local worlddevtools = self.worlddevtools
    local wetness = worlddevtools:GetStateWetness()
    local wetness_rate = worlddevtools:GetWetnessRate()

    if wetness and wetness > 0 then
        local value = Utils.String.ValuePercent(wetness)
        if wetness_rate and wetness_rate > 0 then
            value = string.format("%s (+%0.2f)", value, math.abs(wetness_rate))
        elseif wetness_rate and wetness_rate < 0 then
            value = string.format("%s (-%0.2f)", value, math.abs(wetness_rate))
        end
        self:PushLine("Wetness", value)
    end
end

--- Pushes world data.
function WorldData:PushWorldData()
    Utils.AssertRequiredField("WorldData.worlddevtools", self.worlddevtools)

    self:PushLine("Seed", self.worlddevtools:GetSeed())
    self:PushLine("Season", self.worlddevtools:GetStateSeason())
    self:PushWorldPhaseLine()
    self:PushWorldTemperatureLine()
    self:PushWorldMoistureLine()
    self:PushWorldPrecipitationLines()
    self:PushWorldWetnessLine()

    -- Commented out intentionally. Maybe will be uncommented later.
    --local savedatadevtools = self.savedatadevtools
    --if savedatadevtools and not self.worlddevtools:IsCave() then
    --    self:PushLine("Walrus Camps", savedatadevtools:GetNrOfWalrusCamps())
    --end
end

--- Save Data
-- @section save-data

--- Pushes `deerclopsspawner` line.
function WorldData:PushDeerclopsSpawnerLine()
    local value

    local data = self.savedatadevtools:GetMapPersistData()
    if not data or type(data.deerclopsspawner) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local spawner = data.deerclopsspawner
        if spawner and spawner.warning == true then
            value = "warning"
        elseif spawner then
            value = spawner.activehassler ~= nil and "yes" or "no"
        end
    end

    self:PushLine("Deerclops", value)
end

--- Pushes `beargerspawner` line.
function WorldData:PushBeargerSpawnerLine()
    local value

    local data = self.savedatadevtools:GetMapPersistData()
    if not data or type(data.beargerspawner) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local spawner = data.beargerspawner
        if spawner and spawner.warning == true then
            value = "warning"
        elseif spawner and type(spawner.activehasslers) == "table" then
            if #spawner.activehasslers == 0 and type(spawner.lastKillDay) == "number" then
                value = Utils.String.TableSplit({ "killed", "day " .. spawner.lastKillDay })
            elseif #spawner.activehasslers > 0 then
                value = "yes"
            else
                value = "no"
            end
        end
    end

    self:PushLine("Bearger", value or "error")
end

--- Pushes `malbatrossspawner` line.
function WorldData:PushMalbatrossSpawnerLine()
    local value

    local data = self.savedatadevtools:GetMapPersistData()
    if not data or type(data.malbatrossspawner) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local spawner = data.malbatrossspawner
        if spawner and spawner.activeguid ~= nil then
            value = "yes"
        elseif spawner then
            local timetospawn = spawner._time_until_spawn
            if type(timetospawn) == "number" then
                if spawner._firstspawn == true or timetospawn <= 0 then
                    value = "waiting"
                elseif timetospawn > 0 then
                    value = Utils.String.ValueClock(timetospawn - GetTime())
                else
                    value = "no"
                end
            end
        end
    end

    self:PushLine("Malbatross", value or "error")
end

--- Pushes `deerherdspawner` line.
function WorldData:PushDeersSpawnerLine()
    local value

    local data = self.savedatadevtools:GetMapPersistData()
    if not data or type(data.deerherdspawner) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local spawner = data.deerherdspawner
        if spawner and type(spawner._timetospawn) == "number" then
            value = spawner._timetospawn <= 0
                and "waiting"
                or Utils.String.ValueClock(spawner._timetospawn - GetTime())
        elseif spawner and type(spawner._activedeer) == "table" then
            value = #spawner._activedeer
        end
    end

    self:PushLine("Deers", value or "error")
end

--- Pushes `klaussackspawner` line.
function WorldData:PushKlausSackSpawnerLine()
    local value

    local data = self.savedatadevtools:GetMapPersistData()
    if not data or type(data.klaussackspawner) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local spawner = data.klaussackspawner
        if spawner and type(spawner.timetorespawn) == "number" then
            value = spawner.timetorespawn > 0
                and Utils.String.ValueClock(spawner.timetorespawn - GetTime())
                or "no"
        elseif spawner and spawner.timetorespawn == false then
            value = "yes"
        end
    end

    self:PushLine("Klaus Sack", value or "error")
end

--- Pushes `hounded` line.
function WorldData:PushHoundedLine()
    local value

    local data = self.savedatadevtools:GetMapPersistData()
    if not data or type(data.hounded) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local hounded = data.hounded
        if hounded and type(hounded.timetoattack) == "number" then
            value = hounded.timetoattack > 0
                and Utils.String.ValueClock(hounded.timetoattack - GetTime())
                or "no"
        end
    end

    self:PushLine(
        (self.worlddevtools:IsCave() and "Worms" or "Hounds") .. " Attack",
        value or "error"
    )
end

--- Pushes `chessunlocks` line.
function WorldData:PushChessUnlocksLine()
    local value

    local data = self.savedatadevtools:GetMapPersistData()
    if not data or type(data.chessunlocks) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local chessunlocks = data.chessunlocks
        if chessunlocks and type(chessunlocks.unlocks) == "table" then
            value = #chessunlocks.unlocks > 0
                and table.concat(chessunlocks.unlocks, ", ")
                or "no"
        end
    end

    self:PushLine("Chess Unlocks", value or "error")
end

--- Pushes save data.
function WorldData:PushSaveData()
    Utils.AssertRequiredField("WorldData.savedatadevtools", self.savedatadevtools)
    Utils.AssertRequiredField("WorldData.worlddevtools", self.worlddevtools)

    self:PushLine("Seed", self.savedatadevtools:GetSeed())
    self:PushLine("Save Version", self.savedatadevtools:GetVersion())

    -- Commented out intentionally. Maybe will be uncommented later.
    --if self.savedatadevtools:GetMapPersistData() then
    --    if not self.worlddevtools:IsCave() then
    --        self:PushDeerclopsSpawnerLine()
    --        self:PushBeargerSpawnerLine()
    --        self:PushMalbatrossSpawnerLine()
    --        self:PushDeersSpawnerLine()
    --        self:PushKlausSackSpawnerLine()
    --    end
    --    self:PushHoundedLine()
    --    self:PushChessUnlocksLine()
    --end
end

return WorldData
