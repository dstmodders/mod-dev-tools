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
-- @see Utils.Chain
-- @see Utils.Dump
-- @see Utils.Entity
-- @see Utils.Methods
-- @see Utils.String
-- @see Utils.Table
-- @see Utils.Thread
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
local Utils = {}

Utils.Chain = require "devtools/utils/chain"
Utils.Dump = require "devtools/utils/dump"
Utils.Entity = require "devtools/utils/entity"
Utils.Methods = require "devtools/utils/methods"
Utils.String = require "devtools/utils/string"
Utils.Table = require "devtools/utils/table"
Utils.Thread = require "devtools/utils/thread"

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

return Utils
