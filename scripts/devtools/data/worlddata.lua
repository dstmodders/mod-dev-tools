----
-- World data.
--
-- Includes world data in data sidebar which aim is to display some world and save data info.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.WorldData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
local Data = require "devtools/data/data"
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevToolsScreen screen
-- @tparam WorldTools worldtools
-- @usage local worlddata = WorldData(screen, worldtools)
local WorldData = Class(Data, function(self, screen, worldtools)
    Data._ctor(self, screen)

    -- general
    self.worldsavedatatools = worldtools and worldtools.savedata
    self.worldtools = worldtools

    -- other
    self:Update()
end)

--- General
-- @section general

--- Updates lines stack.
function WorldData:Update()
    Data.Update(self)

    self:PushTitleLine("World " .. (not SDK.World.IsCave() and "(Forest)" or "(Cave)"))
    self:PushEmptyLine()
    self:PushWorldData()

    if self.worldsavedatatools then
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
    local moisture = SDK.World.GetState("moisture")
    local moisture_ceil = SDK.World.GetState("moistureceil")
    local moisture_rate = SDK.World.GetMoistureRate()
    local moisture_floor = SDK.World.GetMoistureFloor()

    if moisture ~= nil and moisture_ceil ~= nil and moisture_rate ~= nil then
        local moisture_string = SDK.Utils.Value.ToFloatString(moisture)

        if moisture_rate and moisture_rate > 0 then
            moisture_string = string.format(
                "%0.2f (%s%0.2f)",
                moisture,
                SDK.World.IsPrecipitation() and "-" or "+",
                math.abs(moisture_rate)
            )
        end

        local value = moisture_floor and table.concat({
            SDK.Utils.Value.ToFloatString(moisture_floor),
            moisture_string,
            SDK.Utils.Value.ToFloatString(moisture_ceil),
        }, " | ") or table.concat({
            moisture_string,
            SDK.Utils.Value.ToFloatString(moisture_ceil),
        }, " | ")

        self:PushLine("Moisture", value)
    end
end

--- Pushes world phase line.
function WorldData:PushWorldPhaseLine()
    local phase = SDK.World.GetPhase()
    if phase ~= nil then
        local next_phase = SDK.World.GetPhaseNext(phase)
        if next_phase then
            local seconds = SDK.World.GetTimeUntilPhase(next_phase)
            if seconds ~= nil then
                self:PushLine("Phase", { phase, SDK.Utils.Value.ToClockString(seconds, true) })
            else
                self:PushLine("Phase", phase)
            end
        end
    end
end

--- Pushes world precipitation line.
function WorldData:PushWorldPrecipitationLines()
    local worldtools = self.worldtools

    local precipitation_rate = SDK.World.GetState("precipitationrate")
    if precipitation_rate and precipitation_rate > 0 then
        local peakprecipitationrate = SDK.World.GetPeakPrecipitationRate()
        self:PushLine("Precipitation Rate", peakprecipitationrate ~= nil and {
            SDK.Utils.Value.ToFloatString(precipitation_rate),
            SDK.Utils.Value.ToFloatString(peakprecipitationrate)
        } or SDK.Utils.Value.ToFloatString(precipitation_rate))
    end

    local is_snowing = SDK.World.GetState("issnowing")
    local precipitation_starts = worldtools:GetPrecipitationStarts()
    local precipitation_ends = worldtools:GetPrecipitationEnds()

    if precipitation_starts and precipitation_ends then
        local label = is_snowing and "Snow" or "Rain"
        if not SDK.World.IsPrecipitation() then
            self:PushLine(
                label .. " Starts",
                "~" .. SDK.Utils.Value.ToClockString(precipitation_starts)
            )
        else
            self:PushLine(
                label .. " Ends",
                "~" .. SDK.Utils.Value.ToClockString(precipitation_ends)
            )
        end
    end

    if is_snowing then
        self:PushLine(
            "Snow Level",
            SDK.Utils.Value.ToPercentString(SDK.World.GetState("snowlevel") * 100)
        )
    end
end

--- Pushes world temperature line.
function WorldData:PushWorldTemperatureLine()
    local temperature = SDK.World.GetState("temperature")
    if temperature ~= nil then
        self:PushLine("Temperature", SDK.Utils.Value.ToDegreeString(temperature))
    end
end

--- Pushes world wetness line.
function WorldData:PushWorldWetnessLine()
    local wetness = SDK.World.GetState("wetness")
    local wetness_rate = SDK.World.GetWetnessRate()

    if wetness and wetness > 0 then
        local value = SDK.Utils.Value.ToPercentString(wetness)
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
    SDK.Utils.AssertRequiredField("WorldData.worldtools", self.worldtools)

    self:PushLine("Seed", SDK.World.GetSeed())
    self:PushLine("Season", SDK.World.GetState("season"))
    self:PushWorldPhaseLine()
    self:PushWorldTemperatureLine()
    self:PushWorldMoistureLine()
    self:PushWorldPrecipitationLines()
    self:PushWorldWetnessLine()

    -- Commented out intentionally. Maybe will be uncommented later.
    --local worldsavedatatools = self.worldsavedatatools
    --if worldsavedatatools and not SDK.World.IsCave() then
    --    self:PushLine("Walrus Camps", worldsavedatatools:GetNrOfWalrusCamps())
    --end
end

--- Save Data
-- @section save-data

--- Pushes `deerclopsspawner` line.
function WorldData:PushDeerclopsSpawnerLine()
    local value

    local data = self.worldsavedatatools:GetMapPersistData()
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

    local data = self.worldsavedatatools:GetMapPersistData()
    if not data or type(data.beargerspawner) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local spawner = data.beargerspawner
        if spawner and spawner.warning == true then
            value = "warning"
        elseif spawner and type(spawner.activehasslers) == "table" then
            if #spawner.activehasslers == 0 and type(spawner.lastKillDay) == "number" then
                value = table.concat({ "killed", "day " .. spawner.lastKillDay }, " | ")
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

    local data = self.worldsavedatatools:GetMapPersistData()
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
                    value = SDK.Utils.Value.ToClockString(timetospawn - GetTime())
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

    local data = self.worldsavedatatools:GetMapPersistData()
    if not data or type(data.deerherdspawner) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local spawner = data.deerherdspawner
        if spawner and type(spawner._timetospawn) == "number" then
            value = spawner._timetospawn <= 0
                and "waiting"
                or SDK.Utils.Value.ToClockString(spawner._timetospawn - GetTime())
        elseif spawner and type(spawner._activedeer) == "table" then
            value = #spawner._activedeer
        end
    end

    self:PushLine("Deers", value or "error")
end

--- Pushes `klaussackspawner` line.
function WorldData:PushKlausSackSpawnerLine()
    local value

    local data = self.worldsavedatatools:GetMapPersistData()
    if not data or type(data.klaussackspawner) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local spawner = data.klaussackspawner
        if spawner and type(spawner.timetorespawn) == "number" then
            value = spawner.timetorespawn > 0
                and SDK.Utils.Value.ToClockString(spawner.timetorespawn - GetTime())
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

    local data = self.worldsavedatatools:GetMapPersistData()
    if not data or type(data.hounded) ~= "table" then
        value = "unavailable"
    end

    if not value then
        local hounded = data.hounded
        if hounded and type(hounded.timetoattack) == "number" then
            value = hounded.timetoattack > 0
                and SDK.Utils.Value.ToClockString(hounded.timetoattack - GetTime())
                or "no"
        end
    end

    self:PushLine(
        (SDK.World.IsCave() and "Worms" or "Hounds") .. " Attack",
        value or "error"
    )
end

--- Pushes `chessunlocks` line.
function WorldData:PushChessUnlocksLine()
    local value

    local data = self.worldsavedatatools:GetMapPersistData()
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
    SDK.Utils.AssertRequiredField("WorldData.worldsavedatatools", self.worldsavedatatools)
    SDK.Utils.AssertRequiredField("WorldData.worldtools", self.worldtools)

    self:PushLine("Seed", self.worldsavedatatools:GetSeed())
    self:PushLine("Save Version", self.worldsavedatatools:GetVersion())

    -- Commented out intentionally. Maybe will be uncommented later.
    --if self.worldsavedatatools:GetMapPersistData() then
    --    if not SDK.World.IsCave() then
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
