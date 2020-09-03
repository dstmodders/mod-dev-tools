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
-- @see Utils.Debug
-- @see Utils.Dump
-- @see Utils.Entity
-- @see Utils.Methods
-- @see Utils.RPC
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
Utils.Debug = require "devtools/utils/debug"
Utils.Dump = require "devtools/utils/dump"
Utils.Entity = require "devtools/utils/entity"
Utils.Methods = require "devtools/utils/methods"
Utils.RPC = require "devtools/utils/rpc"
Utils.String = require "devtools/utils/string"
Utils.Table = require "devtools/utils/table"
Utils.Thread = require "devtools/utils/thread"

-- base (to store original functions after overrides)
local BaseGetModInfo

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

return Utils
