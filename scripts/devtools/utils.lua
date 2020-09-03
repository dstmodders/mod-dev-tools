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
-- @see Utils.String
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
local Utils = {}

local String = require "devtools/utils/string"

Utils.String = String

-- base (to store original functions after overrides)
local BaseGetModInfo

--- Helpers
-- @section helpers

local function DebugString(...)
    return _G.ModDevToolsDebug and _G.ModDevToolsDebug:DebugString(...)
end

local function PrintDumpValues(table, title, name, prepend)
    prepend = prepend ~= nil and prepend .. " " or ""

    print(prepend .. (name
        and string.format('Dumping "%s" %s...', name, title)
        or string.format('Dumping %s...', title)))

    if #table > 0 then
        table = Utils.TableSortAlphabetically(table)
        for _, v in pairs(table) do
            print(prepend .. v)
        end
    else
        print(prepend .. "No " .. title)
    end
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

--- Dump
-- @section dump

--- Dumps all entity components.
-- @usage DumpComponents(ThePlayer, "ThePlayer")
-- @see DumpEventListeners
-- @see DumpFields
-- @see DumpFunctions
-- @see DumpReplicas
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
function Utils.DumpComponents(entity, name, prepend)
    PrintDumpValues(Utils.GetComponents(entity), "Components", name, prepend)
end

--- Dumps all entity event listeners.
-- @usage DumpEventListeners(ThePlayer, "ThePlayer")
-- @see DumpComponents
-- @see DumpFields
-- @see DumpFunctions
-- @see DumpReplicas
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
function Utils.DumpEventListeners(entity, name, prepend)
    PrintDumpValues(Utils.GetEventListeners(entity), "Event Listeners", name, prepend)
end

--- Dumps all entity fields.
-- @usage DumpFields(ThePlayer, "ThePlayer")
-- @see DumpComponents
-- @see DumpEventListeners
-- @see DumpFunctions
-- @see DumpReplicas
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
function Utils.DumpFields(entity, name, prepend)
    PrintDumpValues(Utils.GetFields(entity), "Fields", name, prepend)
end

--- Dumps all entity functions.
-- @usage DumpFunctions(ThePlayer, "ThePlayer")
-- @see DumpComponents
-- @see DumpEventListeners
-- @see DumpFields
-- @see DumpReplicas
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
function Utils.DumpFunctions(entity, name, prepend)
    PrintDumpValues(Utils.GetFunctions(entity), "Functions", name, prepend)
end

--- Dumps all entity replicas.
-- @usage DumpReplicas(ThePlayer, "ThePlayer")
-- @see DumpComponents
-- @see DumpEventListeners
-- @see DumpFields
-- @see DumpFunctions
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
function Utils.DumpReplicas(entity, name, prepend)
    PrintDumpValues(Utils.GetReplicas(entity), "Replicas", name, prepend)
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
                if not Utils.TableHasValue(result, tag) then
                    table.insert(result, tag)
                end
            end
        end

        if #result > 0 then
            return Utils.TableSortAlphabetically(result)
        end
    end
end

--- Returns a table on all entity components.
-- @usage dumptable(GetComponents(ThePlayer))
-- @see GetEventListeners
-- @see GetFields
-- @see GetFunctions
-- @see GetReplicas
-- @tparam EntityScript entity
-- @treturn table
function Utils.GetComponents(entity)
    local result = {}
    if type(entity) == "table" or type(entity) == "userdata" then
        if type(entity.components) == "table" then
            for k, _ in pairs(entity.components) do
                table.insert(result, k)
            end
        end
    end
    return result
end

--- Returns a table on all entity event listeners.
-- @usage dumptable(GetEventListeners(ThePlayer))
-- @see GetComponents
-- @see GetFields
-- @see GetFunctions
-- @see GetReplicas
-- @tparam EntityScript entity
-- @treturn table
function Utils.GetEventListeners(entity)
    local result = {}
    if type(entity) == "table" or type(entity) == "userdata" then
        if type(entity.event_listeners) == "table" then
            for k, _ in pairs(entity.event_listeners) do
                table.insert(result, k)
            end
        end
    end
    return result
end

--- Returns a table on all entity fields.
-- @usage dumptable(GetFields(ThePlayer))
-- @see GetComponents
-- @see GetEventListeners
-- @see GetFunctions
-- @see GetReplicas
-- @tparam EntityScript entity
-- @treturn table
function Utils.GetFields(entity)
    local result = {}
    if type(entity) == "table" then
        for k, v in pairs(entity) do
            if type(v) ~= "function" then
                table.insert(result, k)
            end
        end
    end
    return result
end

--- Returns a table on all entity functions.
-- @usage dumptable(GetFunctions(ThePlayer))
-- @see GetComponents
-- @see GetEventListeners
-- @see GetFields
-- @see GetReplicas
-- @tparam EntityScript entity
-- @treturn table
function Utils.GetFunctions(entity)
    local result = {}
    local metatable = getmetatable(entity)

    if metatable and metatable["__index"] then
        for k, _ in pairs(metatable["__index"]) do
            table.insert(result, k)
        end
    end

    if type(entity) == "table" and #result == 0 then
        for k, v in pairs(entity) do
            if type(v) == "function" then
                table.insert(result, k)
            end
        end
    end

    return result
end

--- Returns a table on all entity replicas.
-- @usage dumptable(GetReplicas(ThePlayer))
-- @see GetComponents
-- @see GetEventListeners
-- @see GetFields
-- @see GetFunctions
-- @tparam EntityScript entity
-- @treturn table
function Utils.GetReplicas(entity)
    local result = {}
    if entity.replica and type(entity.replica._) == "table" then
        for k, _ in pairs(entity.replica._) do
            table.insert(result, k)
        end
    end
    return result
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

--- Table
-- @section table

--- Compares two tables if they are the same.
-- @tparam table a Table A
-- @tparam table b Table B
-- @treturn boolean
function Utils.TableCompare(a, b)
    -- basic validation
    if a == b then
        return true
    end

    -- null check
    if a == nil or b == nil then
        return false
    end

    -- validate type
    if type(a) ~= "table" then
        return false
    end

    -- compare meta tables
    local meta_table_a = getmetatable(a)
    local meta_table_b = getmetatable(b)
    if not Utils.TableCompare(meta_table_a, meta_table_b) then
        return false
    end

    -- compare nested tables
    for index, va in pairs(a) do
        local vb = b[index]
        if not Utils.TableCompare(va, vb) then
            return false
        end
    end

    for index, vb in pairs(b) do
        local va = a[index]
        if not Utils.TableCompare(va, vb) then
            return false
        end
    end

    return true
end

--- Counts the number of elements inside the table.
-- @tparam table t Table
-- @treturn number
function Utils.TableCount(t)
    if type(t) ~= "table" then
        return false
    end

    local result = 0
    for _ in pairs(t) do
        result = result + 1
    end

    return result
end

--- Checks if a table has the provided value.
-- @tparam table t Table
-- @tparam string value
-- @treturn boolean
function Utils.TableHasValue(t, value)
    if type(t) ~= "table" then
        return false
    end

    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end

    return false
end

--- Gets the table key based on the value.
-- @tparam table t Table
-- @param value Value to look for
-- @treturn number
function Utils.TableKeyByValue(t, value)
    if type(t) ~= "table" then
        return false
    end

    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
end

--- Merges two tables.
-- @todo Add nested tables merging support for ipaired tables
-- @tparam table a Table A
-- @tparam table b Table B
-- @tparam[opt] boolean is_merge_nested Should nested tables be merged
-- @treturn table
function Utils.TableMerge(a, b, is_merge_nested)
    -- guessing if the table is an ipaired one
    local is_ipaired = true
    for k, _ in pairs(b) do
        if type(k) ~= "number" then
            is_ipaired = false
        end
    end

    if is_ipaired then
        for i = 1, #b do
            a[#a + 1] = b[i]
        end
    else
        for k, v in pairs(b) do
            if is_merge_nested then
                if type(v) == "table" then
                    if type(a[k] or false) == "table" then
                        Utils.TableMerge(a[k] or {}, b[k] or {})
                    else
                        a[k] = v
                    end
                end
            else
                a[k] = v
            end
        end
    end
    return a
end

--- Gets the next table value.
--
-- When the next value doesn't exist it returns the first one.
--
-- **NB!** Currently supports only "ipaired" tables.
--
-- @tparam table t Table
-- @tparam string value Value
-- @treturn string
function Utils.TableNextValue(t, value)
    if type(t) ~= "table" then
        return false
    end

    for k, v in pairs(t) do
        if v == value then
            return k < #t and t[k + 1] or t[1]
        end
    end
end

--- Sorts the table elements alphabetically.
-- @tparam table t Table
-- @treturn number
function Utils.TableSortAlphabetically(t)
    if type(t) ~= "table" then
        return false
    end

    table.sort(t, function(a, b)
        return a:lower() < b:lower()
    end)

    return t
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
