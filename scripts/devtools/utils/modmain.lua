----
-- Different modmain mod utilities.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @module Utils.Modmain
-- @see Utils
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
----
local Modmain = {}

-- base (to store original functions after overrides)
local BaseGetModInfo

--- Hide the modinfo changelog.
--
-- Overrides the global `KnownModIndex.GetModInfo` to hide the changelog if it's included in the
-- description.
--
-- @tparam string modname
-- @tparam boolean enable
-- @treturn boolean
function Modmain.HideChangelog(modname, enable)
    if modname and enable and not BaseGetModInfo then
        BaseGetModInfo = _G.KnownModIndex.GetModInfo
        _G.KnownModIndex.GetModInfo = function(get_mod_info, mod_name)
            if
                mod_name == modname
                and get_mod_info.savedata
                and get_mod_info.savedata.known_mods
                and get_mod_info.savedata.known_mods[modname]
            then
                local TrimString = _G.TrimString
                local modinfo = get_mod_info.savedata.known_mods[modname].modinfo
                if modinfo and type(modinfo.description) == "string" then
                    local changelog = modinfo.description:find("v" .. modinfo.version, 0, true)
                    if type(changelog) == "number" then
                        modinfo.description = TrimString(modinfo.description:sub(1, changelog - 1))
                    end
                end
            end
            return BaseGetModInfo(get_mod_info, mod_name)
        end
        return true
    elseif BaseGetModInfo then
        _G.KnownModIndex.GetModInfo = BaseGetModInfo
        BaseGetModInfo = nil
    end
    return false
end

return Modmain
