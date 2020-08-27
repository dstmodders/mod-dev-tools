----
-- Base data.
--
-- Includes base data functionality and must be extended by other data classes. Shouldn't be used
-- on its own.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.Data
-- @see data.RecipeData
-- @see data.SelectedData
-- @see data.WorldData
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @usage local data = Data()
local Data = Class(function(self)
    Utils.AddDebugMethods(self)
end)

--- Value
-- @section value

--- Changes number into a clock string.
-- @tparam number seconds Seconds
-- @tparam boolean is_hour_disabled Should hours be disabled?
-- @treturn string
function Data:ToValueClock(seconds, is_hour_disabled) -- luacheck: only
    seconds = tonumber(seconds)
    if seconds <= 0 then
        return is_hour_disabled and "00:00" or "00:00:00";
    end
    local h = string.format("%02.f", math.floor(seconds / 3600));
    local m = string.format("%02.f", math.floor(seconds / 60 - (h * 60)));
    local s = string.format("%02.f", math.floor(seconds - h * 3600 - m * 60));
    return is_hour_disabled and m .. ":" .. s or h .. ":" .. m .. ":" .. s
end

--- Changes number into a float string.
-- @tparam number num
-- @treturn string
function Data:ToValueFloat(num) -- luacheck: only
    return string.format("%0.2f", num or 0)
end

--- Changes number into a percentage string.
-- @tparam number num
-- @treturn string
function Data:ToValuePercent(num) -- luacheck: only
    return string.format("%0.2f", num or 0) .. "%"
end

--- Changes number into a scale string.
-- @tparam number num
-- @treturn string
function Data:ToValueScale(num) -- luacheck: only
    return string.format("%0.2f°", num or 0)
end

--- Changes table into string.
-- @tparam table t
-- @treturn string
function Data:ToValueSplit(t)
    if type(t) == "table" and #t > 0 then
        local value, value_clean

        value = ""
        for _, v in pairs(t) do
            value_clean = v

            -- and math.floor(value_clean) ~= value_clean
            if type(value_clean) == "number" then
                value_clean = self:ToValueFloat(v)
            end

            value = value .. value_clean
            if next(t, _) ~= nil then
                value = value .. " | "
            end
        end

        return value
    end
end

--- Line
-- @section line

--- Pushes line into table.
-- @tparam table t
-- @tparam string name
-- @tparam table|string value
function Data:PushLine(t, name, value)
    if type(t) ~= "table"
        or type(name) ~= "string"
        or string.len(name) == 0
        or value == nil
    then
        return
    end

    if type(value) == "table" and #value > 0 then
        value = self:ToValueSplit(value)
    end

    table.insert(t, string.format("%s: %s", name, value))
end

--- Other
-- @section other

--- Inserts title strings into table.
-- @tparam table t
-- @tparam string title
function Data:TableInsertTitle(t, title) -- luacheck: only
    table.insert(t, "***** ")
    table.insert(t, string.upper(title))
    table.insert(t, " *****\n\n")
end

--- Inserts data strings into table.
-- @tparam table t
-- @tparam table lines_stack
function Data:TableInsertData(t, lines_stack) -- luacheck: only
    for _, v in pairs(lines_stack) do
        table.insert(t, tostring(v))
        table.insert(t, "\n")
    end
end

return Data
