----
-- Data tool.
--
-- A tool to handle saving/loading for both general and server specific data. All stale server
-- specific data is removed automatically during the load.
--
-- Once the data has changed the `dirty` field becomes `true` and the data can be either saved or
-- reset to its original state. After saving or resetting the `dirty` becomes `false`.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.8.0
----
require("class")

local Utils = require("devtools/utils")

-- general
local _DEFAULT_PERSIST_DATA = { general = {}, servers = {} }
local _ENCODE_SAVES = ENCODE_SAVES
local _SERVER_EXPIRE_TIME = USER_HISTORY_EXPIRY_TIME

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @usage local data = Data(modname)
local Data = Class(function(self, modname)
    Utils.Debug.AddMethods(self)

    -- general
    self.dirty = true
    self.modname = modname
    self.name = "Data"
    self.server_id = nil

    -- persist_data
    self.original_persist_data = _DEFAULT_PERSIST_DATA
    self.persist_data = _DEFAULT_PERSIST_DATA

    -- loading
    self:Load(function(status)
        if status == false then
            self:Save()
        end
    end)

    -- other
    self:DebugInit(self.name)
end)

--- Helpers
-- @section helpers

local function DebugString(self, ...)
    self:DebugString("[data]", ...)
end

local function DebugStringGet(self, ...)
    DebugString(self, "[get]", ...)
end

local function DebugStringSet(self, ...)
    DebugString(self, "[set]", ...)
end

local function DebugStringStart(self, ...)
    self:DebugStringStart("[data]", ...)
end

local function DebugStringStop(self, ...)
    self:DebugStringStop("[data]", ...)
end

local function DebugError(self, ...)
    DebugString(self, "[error]", ...)
end

local function DebugErrorGet(self, ...)
    DebugStringGet(self, "[error]", ...)
end

local function DebugErrorStop(self, ...)
    DebugStringStop(self, "[error]", ...)
end

--- General
-- @section general

--- Gets the modname.
-- @treturn string
function Data:GetModname()
    return self.modname
end

--- Gets the name.
-- @treturn string
function Data:GetName()
    return self.name
end

--- Gets the persist data.
-- @treturn table
function Data:GetPersistData()
    return self.persist_data
end

--- Sets the dirty.
-- @tparam boolean dirty
function Data:SetDirty(dirty)
    self.dirty = dirty
end

--- Gets the dirty.
-- @treturn boolean
function Data:IsDirty()
    return self.dirty
end

--- Gets the save name.
-- @treturn string
function Data:GetSaveName()
    return BRANCH ~= "dev" and self.modname or (self.modname .. "_" .. BRANCH)
end

--- Resets to the original state.
function Data:Reset()
    DebugString(self, "[reset]", "Success")
    self.persist_data = self.original_persist_data
    self.dirty = true
end

--- Saving
-- @section saving

--- Saves.
-- @tparam[opt] function cb Callback
-- @tparam[opt] string name Debug name
function Data:Save(cb, name)
    if self.dirty then
        DebugString(self, "[save]", name ~= nil and string.format("Saved (%s)", name) or "Saved")

        SavePersistentString(self:GetSaveName(), json.encode(self.persist_data), _ENCODE_SAVES, cb)
        self.dirty = false

        if cb then
            cb(true)
        end
    end
end

--- Loading
-- @section loading

--- Loads.
--
-- Gets the data string from a save file and calls the `OnLoad` where the loading is actually
-- handled.
--
-- @tparam[opt] function cb Callback
function Data:Load(cb)
    DebugStringStart(self, "[load]", string.format("Loading %s...", self:GetSaveName()))
    TheSim:GetPersistentString(self:GetSaveName(), function(_, str)
        self:OnLoad(str, cb)
    end, false)
end

--- Handles loading.
--
-- Decodes the JSON string into both `original_persist_data` (so we could reset the data state if
-- needed) and `persist_data` (the actual data) fields.
--
-- @tparam string str Data string
-- @tparam[opt] function cb Callback
function Data:OnLoad(str, cb)
    if str == nil or string.len(str) == 0 then
        DebugErrorStop(self, "[load]", "Failure", "(empty string)")
        if cb then
            cb(false)
        end
    else
        DebugStringStop(self, "[load]", "Success", "(length: " .. #str .. ")")

        local persist_data =
            TrackedAssert("TheSim:GetPersistentString " .. self.name, json.decode, str)

        if not persist_data then
            self.dirty = true
            persist_data = _DEFAULT_PERSIST_DATA
        else
            self.dirty = false
        end

        self.original_persist_data = persist_data
        self.persist_data = persist_data

        self:CleanServers() -- sets the dirty to true as well
        self:Save()

        if cb then
            cb(true)
        end
    end
end

--- Data (General)
-- @section data-general

--- Sets the general data field.
--
-- The `Save` should be called separately.
--
-- @tparam string key Field name
-- @tparam any value Field value
-- @treturn boolean
function Data:GeneralSet(key, value)
    if self.persist_data and not self.persist_data.general then
        self.persist_data.general = {}
    end
    DebugString(self, "[set]", key .. ":", value)
    self.persist_data.general[key] = value
    self.dirty = true
    return true
end

--- Gets the general data field.
--
-- Can optionally set the retrieved field value to the destination class field as well.
--
-- @tparam string key Field name
-- @tparam[opt] table dest Destination class
-- @tparam[opt] string field Destination class field name
-- @treturn any
function Data:GeneralGet(key, dest, field)
    if self.persist_data and not self.persist_data.general then
        self.persist_data.general = {}
    end

    local value = self.persist_data.general[key]
    if dest then
        field = field ~= nil and field or key
        dest[field] = value
    end

    return value
end

--- Data (Server)
-- @section data-server

local function RefreshLastSeen(server)
    if server and server.lastseen then
        server.lastseen = os.time()
    end
end

--- Gets the server ID.
--
-- Gets a unique server identifier: `TheWorld.net.components.shardstate:GetMasterSessionId()`.
--
-- @treturn string
function Data:GetServerID() -- luacheck: only
    return Utils.Chain.Get(TheWorld, "net", "components", "shardstate", "GetMasterSessionId", true)
end

--- Gets the server.
-- @treturn table
function Data:GetServer()
    self.server_id = self:GetServerID()
    if self.server_id then
        if self.persist_data and self.persist_data.servers then
            local server = self.persist_data.servers[self.server_id]
            if not server then
                server = { lastseen = os.time(), data = {} }
            end

            RefreshLastSeen(server)
            self.persist_data.servers[self.server_id] = server
            self.dirty = true

            return server
        end
    else
        DebugError(self, "No server data")
    end
end

--- Gets the server last seen.
--
-- Just a convenience method of the `GetServer().lastseen`.
--
-- @treturn number
function Data:GetServerLastSeen()
    local server = self:GetServer()
    return server and server.lastseen
end

--- Gets the server data.
--
-- Just a convenience method of the `GetServer().data`.
--
-- @treturn table
function Data:GetServerData()
    local server = self:GetServer()
    return server and server.data
end

--- Refreshes the server last seen.
--
-- The `Save` should be called separately.
--
-- @treturn boolean
function Data:ServerRefreshLastSeen()
    local server = self:GetServer()
    if server and server.lastseen then
        RefreshLastSeen(server)
        self.dirty = true
        return true
    end
    return false
end

--- Sets the server data field.
--
-- The `Save` should be called separately.
--
-- @tparam string key Field name
-- @tparam any value Field value
-- @treturn boolean
function Data:ServerSet(key, value)
    local data = self:GetServerData()
    if data then
        DebugStringSet(self, "[" .. self.server_id .. "]", key .. ":", value)
        self.persist_data.servers[self.server_id].data[key] = value
        self.dirty = true
        return true
    end
    return false
end

--- Gets the server data field.
--
-- Can optionally set the retrieved field value to the destination class field as well.
--
-- @tparam string key Field name
-- @tparam[opt] table dest Destination class
-- @tparam[opt] string field Destination class field name
-- @treturn any
function Data:ServerGet(key, dest, field)
    local server = self:GetServer()
    if server and server.data then
        local data = server.data
        local value = data[key]
        if value then
            DebugStringGet(self, "[" .. self.server_id .. "]", key)
            if dest then
                field = field ~= nil and field or key
                dest[field] = value
            end
            return value
        end
        DebugErrorGet(self, "[" .. self.server_id .. "]", key)
    end
end

--- Cleans stale servers.
--
-- Cleans all servers that haven't been seen for the `USER_HISTORY_EXPIRY_TIME` (30 days).
function Data:CleanServers()
    local servers = Utils.Chain.Get(self, "persist_data", "servers")
    if type(servers) == "table" then
        local i = 0
        local time = os.time()
        for id, server in pairs(servers) do
            i = i + 1
            if server and server.lastseen then
                if os.difftime(time, server.lastseen) > _SERVER_EXPIRE_TIME then
                    DebugString(self, "[remove]", "[" .. id .. "]")
                    self.persist_data.servers[id] = nil
                    self.dirty = true
                end
            end
        end
    end
end

return Data
