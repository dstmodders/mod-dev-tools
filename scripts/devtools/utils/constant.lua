----
-- Different constant mod utilities.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @module Utils.Constant
-- @see Utils
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.8.0
----
local Constant = {}

--- Returns a skin index.
-- @see GetStringSkinName
-- @see GetStringName
-- @tparam string prefab
-- @tparam number skin
-- @treturn string
function Constant.GetSkinIndex(prefab, skin)
    return PREFAB_SKINS_IDS[prefab] and PREFAB_SKINS_IDS[prefab][skin]
end

--- Returns a string skin name.
-- @see GetSkinIndex
-- @see GetStringName
-- @tparam number skin
-- @treturn string
function Constant.GetStringSkinName(skin)
    return STRINGS.SKIN_NAMES[skin]
end

--- Returns a string name.
-- @see GetSkinIndex
-- @see GetStringSkinName
-- @tparam string name
-- @treturn string
function Constant.GetStringName(name)
    return STRINGS.NAMES[string.upper(name)]
end

return Constant
