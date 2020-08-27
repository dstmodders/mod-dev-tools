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
-- @release 0.1.0-alpha
----
local Console = {}

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

return Console
