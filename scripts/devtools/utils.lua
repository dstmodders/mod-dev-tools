----
-- Different mod utilities.
--
-- Includes different utilities used throughout the whole mod.
--
-- In order to become an utility the solution should either:
--
-- 1. Be a non-mod specific and isolated which can be reused in my other mods.
-- 2. Be a mod specific and isolated which can be used between classes/modules.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module Utils
-- @see Utils.Dump
-- @see Utils.String
-- @see Utils.Table
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
local Utils = {}

Utils.Dump = require "devtools/utils/dump"
Utils.String = require "devtools/utils/string"
Utils.Table = require "devtools/utils/table"

-- base (to store original functions after overrides)
local BaseGetModInfo

--- Helpers
-- @section helpers

local function DebugString(...)
    return _G.ModDevToolsDebug and _G.ModDevToolsDebug:DebugString(...)
end

--- Debugging
-- @section debugging

--- Adds debug methods to the destination class.
--
-- Checks the global environment if the `Debug` is available and adds the corresponding
-- methods from there. Otherwise, adds all the corresponding functions as empty ones.
--
-- @tparam table dest Destination class
function Utils.AddDebugMethods(dest)
    local methods = {
        "DebugActivateEventListener",
        "DebugDeactivateEventListener",
        "DebugError",
        "DebugErrorNotAdmin",
        "DebugErrorNotInCave",
        "DebugErrorNotInForest",
        "DebugInit",
        "DebugSelectedPlayerString",
        "DebugSendRPCToServer",
        "DebugString",
        "DebugStringStart",
        "DebugStringStop",
        "DebugTerm",
    }

    if _G.ModDevToolsDebug then
        for _, v in pairs(methods) do
            dest[v] = function(_, ...)
                if _G.ModDevToolsDebug and _G.ModDevToolsDebug[v] then
                    return _G.ModDevToolsDebug[v](_G.ModDevToolsDebug, ...)
                end
            end
        end
    else
        for _, v in pairs(methods) do
            dest[v] = function()
            end
        end
    end
end

--- General
-- @section general

--- Adds methods from one class to another.
-- @tparam table src Source class to get methods from
-- @tparam table dest Destination class to add methods to
-- @tparam table methods Methods to add
function Utils.AddMethodsToAnotherClass(src, dest, methods)
    for k, v in pairs(methods) do
        -- we also add tables as they can behave as functions in some cases
        if type(src[v]) == "function" or type(src[v]) == "table" then
            k = type(k) == "number" and v or k
            rawset(dest, k, function(_, ...)
                return src[v](src, ...)
            end)
        end
    end
end

--- Adds methods from one class to another.
-- @tparam table src Source class from where we remove methods
-- @tparam table methods Methods to remove
function Utils.RemoveMethodsFromAnotherClass(src, methods)
    for _, v in pairs(methods) do
        -- we also add tables as they can behave as functions in some cases
        if type(src[v]) == "function" or type(src[v]) == "table" then
            src[v] = nil
        end
    end
end

--- Assets if the required field is not missing.
-- @tparam string name
-- @tparam any field
function Utils.AssertRequiredField(name, field)
    assert(field ~= nil, string.format("Required %s is missing", name))
end

--- Executes the console command remotely.
-- @tparam string cmd Command to execute
-- @tparam[opt] table data Data that will be unpacked and used alongside with string
-- @treturn table
function Utils.ConsoleRemote(cmd, data)
    local fn_str = string.format(cmd, unpack(data or {}))
    local x, _, z = TheSim:ProjectScreenPos(TheSim:GetPosition())
    TheNet:SendRemoteExecute(fn_str, x, z)
end

--- Chain
-- @section chain

--- Gets chained field.
--
-- Simplifies the last chained field retrieval like:
--
--    return TheWorld
--        and TheWorld.net
--        and TheWorld.net.components
--        and TheWorld.net.components.shardstate
--        and TheWorld.net.components.shardstate.GetMasterSessionId
--        and TheWorld.net.components.shardstate:GetMasterSessionId
--
-- Or it's value:
--
--    return TheWorld
--        and TheWorld.net
--        and TheWorld.net.components
--        and TheWorld.net.components.shardstate
--        and TheWorld.net.components.shardstate.GetMasterSessionId
--        and TheWorld.net.components.shardstate:GetMasterSessionId()
--
-- It also supports net variables and tables acting as functions.
--
-- @usage Utils.ChainGet(TheWorld, "net", "components", "shardstate", "GetMasterSessionId") -- (function) 0x564445367790
-- @usage Utils.ChainGet(TheWorld, "net", "components", "shardstate", "GetMasterSessionId", true) -- (string) D000000000000000
-- @tparam table src
-- @tparam string|boolean ...
-- @treturn function|userdata|table
function Utils.ChainGet(src, ...)
    if src and (type(src) == "table" or type(src) == "userdata") then
        local args = { ... }
        local execute = false

        if args[#args] == true then
            table.remove(args, #args)
            execute = true
        end

        local previous = src
        for i = 1, #args do
            if src[args[i]] then
                previous = src
                src = src[args[i]]
            else
                return
            end
        end

        if execute and previous then
            if type(src) == "function" then
                return src(previous)
            elseif type(src) == "userdata" or type(src) == "table" then
                if type(src.value) == "function" then
                    -- netvar
                    return src:value()
                elseif getmetatable(src.value) and getmetatable(src.value).__call then
                    -- netvar (for testing)
                    return src.value(src)
                elseif getmetatable(src) and getmetatable(src).__call then
                    -- table acting as a function
                    return src(previous)
                end
            end
            return
        end

        return src
    end
end

--- Validates chained fields.
--
-- Simplifies the chained fields checking like below:
--
--    return TheWorld
--        and TheWorld.net
--        and TheWorld.net.components
--        and TheWorld.net.components.shardstate
--        and TheWorld.net.components.shardstate.GetMasterSessionId
--        and true
--        or false
--
-- @usage Utils.ChainValidate(TheWorld, "net", "components", "shardstate", "GetMasterSessionId") -- (boolean) true
-- @tparam table src
-- @tparam string|boolean ...
-- @treturn boolean
function Utils.ChainValidate(src, ...)
    return Utils.ChainGet(src, ...) and true or false
end

--- Constants
-- @section constants

--- Returns a skin index.
-- @see GetStringSkinName
-- @see GetStringName
-- @tparam string prefab
-- @tparam number skin
-- @treturn string
function Utils.GetSkinIndex(prefab, skin)
    return PREFAB_SKINS_IDS[prefab] and PREFAB_SKINS_IDS[prefab][skin]
end

--- Returns a string skin name.
-- @see GetSkinIndex
-- @see GetStringName
-- @tparam number skin
-- @treturn string
function Utils.GetStringSkinName(skin)
    return STRINGS.SKIN_NAMES[skin]
end

--- Returns a string name.
-- @see GetSkinIndex
-- @see GetStringSkinName
-- @tparam string name
-- @treturn string
function Utils.GetStringName(name)
    return STRINGS.NAMES[string.upper(name)]
end

--- Entity
-- @section entity

--- Returns an entity animation state bank.
-- @see GetAnimStateBuild
-- @see GetAnimStateAnim
-- @tparam EntityScript entity
-- @treturn string
function Utils.GetAnimStateBank(entity)
    -- @todo: Find a better way of getting the entity AnimState bank instead of using RegEx...
    if entity.AnimState then
        local debug = entity:GetDebugString()
        local bank = string.match(debug, "AnimState:.*bank:%s+(%S+)")
        if bank and string.len(bank) > 0 then
            return bank
        end
    end
end

--- Returns an entity animation state build.
-- @see GetAnimStateBank
-- @see GetAnimStateAnim
-- @tparam EntityScript entity
-- @treturn string
function Utils.GetAnimStateBuild(entity)
    if entity.AnimState then
        return entity.AnimState:GetBuild()
    end
end

--- Returns an entity animation state animation.
-- @see GetAnimStateBank
-- @see GetAnimStateBuild
-- @tparam EntityScript entity
-- @treturn string
function Utils.GetAnimStateAnim(entity)
    -- TODO: Find a better way of getting the entity AnimState anim instead of using RegEx...
    if entity.AnimState then
        local debug = entity:GetDebugString()
        local anim = string.match(debug, "AnimState:.*anim:%s+(%S+)")
        if anim and string.len(anim) > 0 then
            return anim
        end
    end
end

--- Returns an entity state graph name.
-- @see GetStateGraphState
-- @tparam EntityScript entity
-- @treturn string
function Utils.GetStateGraphName(entity)
    -- TODO: Find a better way of getting the entity StateGraph name instead of using RegEx...
    if entity.sg then
        local debug = tostring(entity.sg)
        local name = string.match(debug, 'sg="(%S+)",')
        if name and string.len(name) > 0 then
            return name
        end
    end
end

--- Returns an entity state graph state.
-- @see GetStateGraphName
-- @tparam EntityScript entity
-- @treturn string
function Utils.GetStateGraphState(entity)
    -- TODO: Find a better way of getting the entity StateGraph state instead of using RegEx...
    if entity.sg then
        local debug = tostring(entity.sg)
        local state = string.match(debug, 'state="(%S+)",')
        if state and string.len(state) > 0 then
            return state
        end
    end
end

--- Returns an entity tags.
-- @tparam EntityScript entity
-- @tparam boolean is_all
-- @treturn table
function Utils.GetTags(entity, is_all)
    -- TODO: Find a better way of getting the entity tag instead of using RegEx...
    is_all = is_all == true

    local debug = entity:GetDebugString()
    local tags = string.match(debug, "Tags: (.-)\n")

    if tags and string.len(tags) > 0 then
        local result = {}

        if is_all then
            for tag in tags:gmatch("%S+") do
                table.insert(result, tag)
            end
        else
            for tag in tags:gmatch("%S+") do
                if not Utils.Table.HasValue(result, tag) then
                    table.insert(result, tag)
                end
            end
        end

        if #result > 0 then
            return Utils.Table.SortAlphabetically(result)
        end
    end
end

--- Modmain
-- @section modmain

--- Hide the modinfo changelog.
--
-- Overrides the global `KnownModIndex.GetModInfo` to hide the changelog if it's included in the
-- description.
--
-- @tparam string modname
-- @tparam boolean enable
-- @treturn boolean
function Utils.HideChangelog(modname, enable)
    if modname and enable and not BaseGetModInfo then
        BaseGetModInfo =  _G.KnownModIndex.GetModInfo
        _G.KnownModIndex.GetModInfo = function(_self, _modname)
            if _modname == modname
                and _self.savedata
                and _self.savedata.known_mods
                and _self.savedata.known_mods[modname]
            then
                local TrimString = _G.TrimString
                local modinfo = _self.savedata.known_mods[modname].modinfo
                if modinfo and type(modinfo.description) == "string" then
                    local changelog = modinfo.description:find("v" .. modinfo.version, 0, true)
                    if type(changelog) == "number" then
                        modinfo.description = TrimString(modinfo.description:sub(1, changelog - 1))
                    end
                end
            end
            return BaseGetModInfo(_self, _modname)
        end
        return true
    elseif BaseGetModInfo then
        _G.KnownModIndex.GetModInfo = BaseGetModInfo
        BaseGetModInfo = nil
    end
    return false
end

--- RPC
-- @section rpc

local _SendRPCToServer

--- Checks if `SendRPCToServer()` is enabled.
-- @treturn boolean
function Utils.IsSendRPCToServerEnabled()
    return _SendRPCToServer == nil
end

--- Disables `SendRPCToServer()`.
--
-- Only affects the `SendRPCToServer()` wrapper function Utils.and leaves the `TheNet:SendRPCToServer()`
-- as is.
function Utils.DisableSendRPCToServer()
    if not _SendRPCToServer then
        _SendRPCToServer = SendRPCToServer
        SendRPCToServer = function() end
        DebugString("SendRPCToServer: disabled")
    else
        DebugString("SendRPCToServer: already disabled")
    end
end

--- Enables `SendRPCToServer()`.
function Utils.EnableSendRPCToServer()
    if _SendRPCToServer then
        SendRPCToServer = _SendRPCToServer
        _SendRPCToServer = nil
        DebugString("SendRPCToServer: enabled")
    else
        DebugString("SendRPCToServer: already enabled")
    end
end

--- Thread
-- @section thread

--- Starts a new thread.
--
-- Just a convenience wrapper for the `StartThread`.
--
-- @tparam string id Thread ID
-- @tparam function fn Thread function
-- @tparam[opt] function whl While function
-- @tparam[opt] function init Initialization function
-- @tparam[opt] function term Termination function
-- @treturn table
function Utils.ThreadStart(id, fn, whl, init, term)
    whl = whl ~= nil and whl or function()
        return true
    end

    return StartThread(function()
        DebugString("Thread started")
        if init then
            init()
        end
        while whl() do
            fn()
        end
        if term then
            term()
        end
        Utils.ThreadClear()
    end, id)
end

--- Clears a thread.
-- @tparam table thread Thread
function Utils.ThreadClear(thread)
    local task = scheduler:GetCurrentTask()
    if thread or task then
        if thread and not task then
            DebugString("[" .. thread.id .. "]", "Thread cleared")
        else
            DebugString("Thread cleared")
        end
        thread = thread ~= nil and thread or task
        KillThreadsWithID(thread.id)
        thread:SetList(nil)
    end
end

return Utils
