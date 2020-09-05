----
-- Different console commands.
--
-- Includes different console commands to be used inside the in-game console.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module Console
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0
----
local Console = {}

local Utils = require "devtools/utils"

local _EMOTE_THREAD

--- Helpers
-- @section helpers

local function Error(description, ...)
    print("Error: " .. string.format(description, ...))
end

local function IsInvalidParameterType(variable, expected, name, number)
    local got = type(variable)
    if got ~= expected then
        if number then
            Error(
                'invalid #%d parameter "%s" type (got %s, expected %s)',
                number,
                name,
                got,
                expected
            )
        else
            Error('invalid parameter "%s" type (got %s, expected %s)', name, got, expected)
        end
        return true
    end
    return false
end

local function IsRequiredParameterMissing(name, value, number)
    if not value then
        if number then
            Error('required #%d parameter "%s" not provided', number, name)
        else
            Error('required parameter "%s" not provided', name)
        end
        return true
    end
    return false
end

local function DecodeFileSuccess(path)
    print(string.format("Decoded successfully: %s", path))
end

local function DecodeFileLoad(path, is_loaded, str)
    local result

    if is_loaded then
        local success, data = RunInSandboxSafe(str)
        if success then
            result = data
            TheSim:SetPersistentString(path .. "_decoded", str, false, function()
                DecodeFileSuccess(path)
            end)
        else
            Error("dumping file %s has failed", path)
        end
    else
        Error("file %s not found", path)
    end

    return result
end

--- General
-- @section general

--- Decodes an existing data file.
--
-- It creates the decoded version in the same directory with the "_decoded" suffix and returns the
-- decoded data as a string.
--
-- @see d_decodesavedata
-- @tparam string path Path to the file inside the `client_save` directory
-- @treturn string Decoded data
-- @usage dumptable(d_decodefile("server_temp/server_save"))
function d_decodefile(path)
    if IsRequiredParameterMissing("path", path) then
        return
    end

    TheSim:GetPersistentString(path, function(is_loaded, str)
        return DecodeFileLoad(path, is_loaded, str)
    end)
end

--- Decodes a savedata file.
--
-- It decodes the appropriate savedata file:
--
--   * `client_save/client_temp/server_save`
--   * `client_save/server_temp/server_save`
--
-- @see d_decodefile
-- @treturn string Decoded data
-- @usage dumptable(d_decodesavedata())
function d_decodesavedata()
    if not InGamePlay() then
        Error("should be called only in the gameplay")
        return false
    end

    local path = TheWorld.ismastersim and "server_temp/server_save" or "client_temp/server_save"

    return d_decodefile(path)
end

--- Does an in-game PlayerController action.
-- @tparam table action An action to do
-- @usage d_doaction(BufferedAction(ThePlayer, c_findnext("flint"), ACTIONS.PICKUP))
function d_doaction(action)
    if IsRequiredParameterMissing("action", action) then
        return
    end

    if ThePlayer.components and not ThePlayer.components.playercontroller then
        Error("PlayerController is not available")
        return
    end

    ThePlayer.components.playercontroller:DoAction(action)
end

--- Starts an emote spamming.
--
-- When the second emote is passed (the fourth parameter) the pause time is split between both
-- emotes. To stop/interrupt you can use the corresponding `d_emotestop`.
--
-- Since the server and client interaction doesn't correspond to emotes sent in less than .5 second
-- you can't spam emotes quicker than that to trigger the sound effect. However, since the "toast"
-- and "pose" emotes use the same sound effect but the "toast" one is a little bit delayed you can
-- use that for your advantage to cause triggering the same sound effect at the same time. This
-- causality was found by [@Viktor](http://steamcommunity.com/profiles/76561198053787151) as he does
-- enjoy playing with emotes.
--
-- **NB!** This feature is bundled in this mod as a testing tool to automate the emote user command
-- call. The common use-case testing scenario: how the tested functionality behaves during user
-- commands interruptions.
--
-- @see d_emotepose
-- @see d_emotestop
-- @tparam string emote Emote to spam
-- @tparam[opt] number num Number of times to spam an emote (default: 1)
-- @tparam[opt] number pause Time to wait between spamming (default: 0.5)
-- @tparam[opt] string sec Second emote to spam
-- @usage d_emote("yawn") -- spam the "yawn" emote
-- @usage d_emote("yawn", 10) -- spam 10 "yawn" emotes every .5 second
-- @usage d_emote("yawn", 10, 1) -- spam 10 "yawn" emotes every 1 second
-- @usage d_emote("toast", 10, 1.1, "pose") -- spam both "toast" and "pose" emotes 10 times
function d_emote(emote, num, pause, sec)
    if IsRequiredParameterMissing("emote", emote, 1)
        or IsInvalidParameterType(emote, "string", "emote", 1)
    then
        return
    end

    if num ~= nil and IsInvalidParameterType(num, "number", "number", 2) then
        return
    end

    if pause ~= nil and IsInvalidParameterType(pause, "number", "pause", 3) then
        return
    end

    if sec ~= nil and IsInvalidParameterType(sec, "string", "second", 4) then
        return
    end

    num = num ~= nil and num or 1
    pause = pause ~= nil and pause or .5

    _EMOTE_THREAD = StartThread(function()
        for _ = 1, num do
            TheNet:SendSlashCmdToServer(emote, true)
            Sleep(sec and pause / 2 or pause)
            if sec then
                TheNet:SendSlashCmdToServer(sec, true)
                Sleep(pause / 2)
            end
        end
        d_emotestop()
    end, "emote_thread")
end

--- Starts a "double" pose emote spamming.
--
-- This is a convenience function of the:
--
--    d_emote("toast", number, 1.1, "pose")
--
-- @see d_emote
-- @see d_emotestop
-- @tparam[opt] number number Number of times to spam an emote (default: 1)
function d_emotepose(number)
    if number ~= nil and IsInvalidParameterType(number, "number", "number") then
        return
    end

    number = number ~= nil and number or 1
    d_emote("toast", number, 1.1, "pose")
end

--- Stops the d_emote spamming.
-- @see d_emote
function d_emotestop()
    if _EMOTE_THREAD then
        KillThreadsWithID(_EMOTE_THREAD.id)
        _EMOTE_THREAD:SetList(nil)
        _EMOTE_THREAD = nil
    end
end

--- Searches for an item in the inventory by name.
-- @see d_findinventoryitems
-- @tparam string prefab Prefab name
-- @treturn table Prefab
-- @usage dumptable(d_findinventoryitem("rope"))
function d_findinventoryitem(prefab)
    if IsRequiredParameterMissing("prefab", prefab) then
        return
    end

    return d_findinventoryitems(prefab)[1]
end

--- Searches for items in the inventory by a prefab name.
-- @see d_findinventoryitem
-- @tparam string prefab Prefab name
-- @treturn table Prefab
-- @usage dumptable(d_findinventoryitems("rope")[1])
function d_findinventoryitems(prefab)
    if IsRequiredParameterMissing("prefab", prefab) then
        return
    end

    local result = {}
    local inventory = ThePlayer.replica.inventory

    local items = inventory:GetItems()
    for _, v in pairs(items) do
        if v.prefab == prefab then
            table.insert(result, v)
        end
    end

    return result
end

--- Says the plain string in the chat.
--
-- By default, the message is sent in the "whisper" mode. This can be changed by setting the global
-- parameter to "true".
--
-- @tparam string message Message to say
-- @tparam[opt] boolean is_global Send the message in a non-whisper mode
-- @usage d_say("hi") -- Whispers in chat: hi
-- @usage d_say("hi", true) -- Says in chat: hi
function d_say(message, is_global)
    if IsRequiredParameterMissing("message", message, 1) then
        return
    end

    if is_global ~= nil and IsInvalidParameterType(is_global, "boolean", "global", 2) then
        return
    end

    is_global = is_global ~= nil and is_global or false
    TheNet:Say(message, not is_global)
end

--- Says something "<your username> is saying hi" in the chat.
--
-- By default, the message is sent in the "whisper" mode. This can be changed by setting the global
-- parameter to "true".
--
-- @tparam string message Message to say
-- @tparam[opt] boolean is_global Send the message in a non-whisper mode
-- @usage d_says("is saying hi") -- Whispers in chat: <your username> is saying hi
-- @usage d_says("is saying hi", true) -- Says in chat: <your username> is saying hi
function d_says(message, is_global)
    if IsRequiredParameterMissing("message", message, 1) then
        return
    end

    if is_global ~= nil and IsInvalidParameterType(is_global, "boolean", "global", 2) then
        return
    end

    is_global = is_global ~= nil and is_global or false
    TheNet:Say(message, not is_global, true)
end

--- Returns an entity tags.
-- @tparam EntityScript entity
-- @tparam boolean is_all
-- @treturn table
function d_gettags(...)
    return Utils.GetTags(...)
end

--- AnimState
-- @section animstate

--- Returns an entity animation state animation.
-- @tparam EntityScript entity
-- @treturn string
function d_getanim(...)
    return Utils.Entity.GetAnimStateAnim(...)
end

--- Returns an entity animation state bank.
-- @tparam EntityScript entity
-- @treturn string
-- @usage d_getanimbank(ThePlayer)
function d_getanimbank(...)
    return Utils.Entity.GetAnimStateBank(...)
end

--- Returns an entity animation state build.
-- @tparam EntityScript entity
-- @treturn string
function d_getanimbuild(...)
    return Utils.Entity.GetAnimStateBank(...)
end

--- Dump
-- @section dump

--- Dumps all entity components.
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
-- @usage d_dumpcomponents(ThePlayer)
function d_dumpcomponents(...)
    return Utils.Dump.Components(...)
end

--- Dumps all entity event listeners.
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
-- @usage d_dumpeventlisteners(ThePlayer)
function d_dumpeventlisteners(...)
    return Utils.Dump.EventListeners(...)
end

--- Dumps all entity fields.
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
-- @usage d_dumpfields(ThePlayer)
function d_dumpfields(...)
    return Utils.Dump.Fields(...)
end

--- Dumps all entity functions.
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
-- @usage d_dumpfunctions(ThePlayer)
function d_dumpfunctions(...)
    return Utils.Dump.Functions(...)
end

--- Dumps all entity replicas.
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
-- @usage d_dumpreplicas(ThePlayer)
function d_dumpreplicas(...)
    return Utils.Dump.Replicas(...)
end

--- Returns a table on all entity components.
-- @tparam EntityScript entity
-- @treturn table
-- @usage dumptable(d_getcomponents(ThePlayer))
function d_getcomponents(...)
    return Utils.Dump.GetComponents(...)
end

--- Returns a table on all entity event listeners.
-- @tparam EntityScript entity
-- @treturn table
-- @usage dumptable(d_geteventlisteners(ThePlayer))
function d_geteventlisteners(...)
    return Utils.Dump.GetEventListeners(...)
end

--- Returns a table on all entity fields.
-- @tparam EntityScript entity
-- @treturn table
-- @usage dumptable(d_getfields(ThePlayer))
function d_getfields(...)
    return Utils.Dump.GetFields(...)
end

--- Returns a table on all entity functions.
-- @tparam EntityScript entity
-- @treturn table
-- @usage dumptable(d_getfunctions(ThePlayer))
function d_getfunctions(...)
    return Utils.Dump.GetFunctions(...)
end

--- Returns a table on all entity replicas.
-- @tparam EntityScript entity
-- @treturn table
-- @usage dumptable(d_getreplicas(ThePlayer))
function d_getreplicas(...)
    return Utils.Dump.GetReplicas(...)
end

--- StateGraph
-- @section stategraph

--- Returns an entity state graph name.
-- @tparam EntityScript entity
-- @treturn string
function d_getsg(...)
    return Utils.Entity.GetStateGraphName(...)
end

--- Returns an entity state graph state.
-- @tparam EntityScript entity
-- @treturn string
function d_getsgstate(...)
    return Utils.Entity.GetStateGraphState(...)
end

--- Table
-- @section table

--- Compares two tables if they are the same.
-- @tparam table a Table A
-- @tparam table b Table B
-- @treturn boolean
function d_tablecompare(...)
    return Utils.Table.Compare(...)
end

--- Counts the number of elements inside the table.
-- @tparam table t Table
-- @treturn number
function d_tablecount(...)
    return Utils.Table.Count(...)
end

--- Checks if a table has the provided value.
-- @tparam table t Table
-- @tparam string value
-- @treturn boolean
function d_tablehasvalue(...)
    return Utils.Table.HasValue(...)
end

--- Gets the table key based on the value.
-- @tparam table t Table
-- @param value Value to look for
-- @treturn number
function d_tablekeybyvalue(...)
    return Utils.Table.KeyByValue(...)
end

--- Merges two tables.
-- @todo Add nested tables merging support for ipaired tables
-- @tparam table a Table A
-- @tparam table b Table B
-- @tparam[opt] boolean is_merge_nested Should nested tables be merged
-- @treturn table
function d_tablemerge(...)
    return Utils.Table.Merge(...)
end

--- Klei
-- @section klei

local function SortByTypeAndValue(a, b)
    local a_type, b_type = type(a), type(b)
    return a_type < b_type or (
        a_type ~= "table"
            and b_type ~= "table"
            and a_type == b_type
            and a < b
    )
end

--- Dumps table.
--
-- The same as the original `dumptable` from the `debugtools` module. The only difference is in the
-- local `SortByTypeAndValue` which avoids comparing tables to avoid non-sandbox crashes.
--
-- @tparam table obj
-- @tparam number indent
-- @tparam number recurse_levels
-- @tparam table visit_table
-- @tparam boolean is_terse
function dumptable(obj, indent, recurse_levels, visit_table, is_terse)
    local is_top_level = visit_table == nil
    if visit_table == nil then
        visit_table = {}
    end

    indent = indent or 1
    local i_recurse_levels = recurse_levels or 5
    if obj then
        local dent = string.rep("\t", indent)

        if type(obj) == type("") then
            print(obj)
            return
        end

        if type(obj) == "table" then
            if visit_table[obj] ~= nil then
                print(dent .. "(Already visited", obj, "-- skipping.)")
                return
            else
                visit_table[obj] = true
            end
        end

        local keys = {}

        for k, _ in pairs(obj) do
            table.insert(keys, k)
        end

        table.sort(keys, SortByTypeAndValue)

        if not is_terse and is_top_level and #keys == 0 then
            print(dent .. "(empty)")
        end

        for _, k in ipairs(keys) do
            local v = obj[k]
            if type(v) == "table" and i_recurse_levels > 0 then
                if v.entity and v.entity:GetGUID() then
                    print(dent .. "K: ", k, " V: ", v, "(Entity -- skipping.)")
                else
                    print(dent .. "K: ", k, " V: ", v)
                    dumptable(v, indent + 1, i_recurse_levels - 1, visit_table)
                end
            else
                print(dent .. "K: ", k, " V: ", v)
            end
        end
    elseif not is_terse then
        print("nil")
    end
end

if _G.MOD_DEV_TOOLS_TEST then
    Console._DecodeFileLoad = DecodeFileLoad
    Console._DecodeFileSuccess = DecodeFileSuccess
    Console._Error = Error
    Console._IsInvalidParameterType = IsInvalidParameterType
    Console._IsRequiredParameterMissing = IsRequiredParameterMissing
end

return Console
