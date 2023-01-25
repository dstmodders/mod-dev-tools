----
-- Save data tools.
--
-- Extends `devtools.DevTools` and includes different savedata functionality. It is used mainly for
-- showing some additional data about the world.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.world.savedata
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod devtools.world.SaveDataDevTools
-- @see DevTools
-- @see devtools.DevTools
-- @see devtools.WorldDevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
----
require "class"
require "consolecommands"

local DevTools = require "devtools/devtools/devtools"

-- general
local _SAVEDATA

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam devtools.WorldDevTools worlddevtools
-- @tparam DevTools devtools
-- @usage local savedatadevtools = SaveDataDevTools(worlddevtools, devtools)
local SaveDataDevTools = Class(DevTools, function(self, worlddevtools, devtools)
    DevTools._ctor(self, "SaveDataDevTools", devtools)

    -- general
    self.inst = worlddevtools.inst
    self.ismastersim = worlddevtools.ismastersim
    self.worlddevtools = worlddevtools

    -- walrus camps
    self.nr_of_walrus_camps = 0

    if self.inst then
        self:Load()
        if self.inst.topology then
            if self.inst.topology.ids then
                self:GuessNrOfWalrusCamps()
            end
        end
    end

    -- self
    self:DoInit()
end)

--- Helpers
-- @section helpers

local function DebugErrorStop(self, ...)
    self:DebugStringStop("[savedata]", "[error]", ...)
end

local function DebugString(self, ...)
    self:DebugString("[savedata]", ...)
end

local function DebugStringStart(self, ...)
    self:DebugStringStart("[savedata]", ...)
end

local function DebugStringStop(self, ...)
    self:DebugStringStop("[savedata]", ...)
end

local function ValidateLoadField(self, field, name)
    if field then
        DebugString(self, "[validation]", name .. ": OK")
        return true
    end
    DebugString(self, "[validation]", name .. ": MISSING")
    return false
end

local function ValidateLoadFile(self, savedata)
    DebugString(self, "[validation]", "Validating savedata...")
    local map = savedata.map
    if ValidateLoadField(self, map, "map") then
        local persistdata = map.persistdata
        if ValidateLoadField(self, persistdata, "map.persistdata") then
            local name

            name = "map.persistdata.chessunlocks"
            local chessunlocks = persistdata.chessunlocks
            if ValidateLoadField(self, chessunlocks, name) then
                ValidateLoadField(self, chessunlocks.unlocks, name .. ".unlocks")
            end

            name = "map.persistdata.hounded"
            local hounded = persistdata.hounded
            if ValidateLoadField(self, hounded, name) then
                ValidateLoadField(self, hounded.timetoattack, name .. ".timetoattack")
            end

            if not self.worlddevtools:IsCave() then
                name = "map.persistdata.beargerspawner"
                local beargerspawner = persistdata.beargerspawner
                if ValidateLoadField(self, beargerspawner, name) then
                    ValidateLoadField(
                        self,
                        beargerspawner.activehasslers,
                        name .. ".activehasslers"
                    )

                    ValidateLoadField(
                        self,
                        beargerspawner.lastKillDay,
                        name .. ".lastKillDay"
                    )

                    ValidateLoadField(self, beargerspawner.warning, name .. ".warning")
                end

                name = "map.persistdata.deerclopsspawner"
                local deerclopsspawner = persistdata.deerclopsspawner
                if ValidateLoadField(self, deerclopsspawner, name) then
                    ValidateLoadField(
                        self,
                        deerclopsspawner.activehasslers,
                        name .. ".activehasslers"
                    )

                    ValidateLoadField(
                        self,
                        deerclopsspawner.warning,
                        name .. ".warning"
                    )
                end

                name = "map.persistdata.deerherdspawner"
                local deerherdspawner = persistdata.deerherdspawner
                if ValidateLoadField(self, deerherdspawner, name) then
                    ValidateLoadField(self, deerherdspawner._activedeer, name .. "._activedeer")
                    ValidateLoadField(self, deerherdspawner._timetospawn, name .. "._timetospawn")
                end

                name = "map.persistdata.klaussackspawner"
                local klaussackspawner = persistdata.klaussackspawner
                if ValidateLoadField(self, klaussackspawner, name) then
                    ValidateLoadField(
                        self,
                        klaussackspawner.timetorespawn,
                        name .. ".timetorespawn"
                    )
                end

                name = "map.persistdata.malbatrossspawner"
                local malbatrossspawner = persistdata.malbatrossspawner
                if ValidateLoadField(self, malbatrossspawner, name) then
                    ValidateLoadField(
                        self,
                        malbatrossspawner._firstspawn,
                        name .. "._firstspawn"
                    )

                    ValidateLoadField(
                        self,
                        malbatrossspawner._time_until_spawn,
                        name .. "._time_until_spawn"
                    )

                    ValidateLoadField(self, malbatrossspawner.activeguid, name .. ".activeguid")
                end
            end
        end
    end
end

--- General
-- @section general

--- Gets the save data path.
--
-- Returns one of the following paths based on the server type:
--
--   - `server_temp/server_save` (local game)
--   - `client_temp/server_save` (dedicated server)
--
-- @treturn string
function SaveDataDevTools:GetPath()
    return self.ismastersim and "server_temp/server_save" or "client_temp/server_save"
end

--- Gets the save data.
--
-- Returns the save data loaded using the `Load`.
--
-- @treturn table
function SaveDataDevTools:GetSaveData() -- luacheck: only
    return _SAVEDATA
end

--- Gets the map persistdata.
-- @treturn table
function SaveDataDevTools:GetMapPersistData() -- luacheck: only
    return _SAVEDATA and _SAVEDATA.map and _SAVEDATA.map.persistdata
end

--- Gets the meta.
-- @tparam[opt] string name Meta name
-- @treturn[1] table Meta table, when no name passed
-- @treturn[2] string Meta value, when the name is passed
function SaveDataDevTools:GetMeta(name) -- luacheck: only
    local meta = _SAVEDATA and _SAVEDATA.meta
    if meta and name ~= nil then
        return meta and meta[name]
    end
    return meta
end

--- Gets the meta seed.
-- @treturn string
function SaveDataDevTools:GetSeed()
    return self:GetMeta("seed")
end

--- Gets the meta version.
-- @treturn string
function SaveDataDevTools:GetVersion()
    return self:GetMeta("saveversion")
end

--- Loads the save data.
--
-- Returns the data which is stored on the client side.
--
-- @tparam string path
-- @treturn boolean
function SaveDataDevTools:Load(path)
    path = path ~= nil and path or self:GetPath()

    DebugStringStart(self, "Path:", path)

    local success, savedata

    TheSim:GetPersistentString(path, function(loadsuccess, str)
        if loadsuccess then
            DebugString(self, "Loaded successfully")
            success, savedata = RunInSandboxSafe(str)
            if success then
                DebugStringStop(self, "Data extracted successfully")
                DebugString(self, "Seed:", savedata.meta.seed)
                DebugString(self, "Version:", savedata.meta.saveversion)
                ValidateLoadFile(self, savedata)
                _SAVEDATA = savedata
                return savedata
            else
                DebugErrorStop(self, "Data extraction has failed")
                return false
            end
        else
            DebugErrorStop(self, "Load has failed")
            return false
        end
    end)

    return savedata
end

--- Walrus Camps
-- @section walrus-camps

--- Guesses the number of Walrus Camps.
--
-- Uses the topology IDs data to predict how many Walrus Camps in the current world.
--
-- @treturn number
function SaveDataDevTools:GuessNrOfWalrusCamps()
    self.nr_of_walrus_camps = 0
    DebugStringStart(self, "Guessing the number of Walrus Camps...")
    for _, id in pairs(self.inst.topology.ids) do
        if string.match(id, "WalrusHut_Grassy")
            or string.match(id, "WalrusHut_Plains")
            or string.match(id, "WalrusHut_Rocky")
        then
            self.nr_of_walrus_camps = self.nr_of_walrus_camps + 1
        end
    end
    DebugStringStop(self, string.format("Found %d Walrus Camps", self.nr_of_walrus_camps))
    return self.nr_of_walrus_camps
end

--- Gets the number of Walrus Camps.
--
-- Returns the number of Walrus Camps guessed earlier by the `GuessNrOfWalrusCamps`.
--
-- @treturn number
function SaveDataDevTools:GetNrOfWalrusCamps()
    return self.nr_of_walrus_camps
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function SaveDataDevTools:DoInit()
    DevTools.DoInit(self, self.devtools, "world", {
        -- general
        GetSaveDataPath = "GetPath",
        GetSaveData = "GetSaveData",
        GetSaveDataMapPersistData = "GetMapPersistData",
        GetSaveDataMeta = "GetMeta",
        GetSaveDataSeed = "GetSeed",
        GetSaveDataVersion = "GetVersion",
        LoadSaveData = "Load",

        -- walrus camps
        "GuessNrOfWalrusCamps",
        "GetNrOfWalrusCamps",
    })
end

return SaveDataDevTools
