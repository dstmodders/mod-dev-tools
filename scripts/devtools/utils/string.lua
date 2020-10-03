----
-- Different string mod utilities.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module Utils.String
-- @see Utils
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0-alpha
----
local String = {}

--- Converts a number into a clock string.
-- @tparam number seconds Seconds
-- @tparam boolean is_hour_disabled Should hours be disabled?
-- @treturn string
function String.ValueClock(seconds, is_hour_disabled)
    seconds = tonumber(seconds)
    if seconds <= 0 then
        return is_hour_disabled and "00:00" or "00:00:00";
    end
    local h = string.format("%02.f", math.floor(seconds / 3600));
    local m = string.format("%02.f", math.floor(seconds / 60 - (h * 60)));
    local s = string.format("%02.f", math.floor(seconds - h * 3600 - m * 60));
    return is_hour_disabled and m .. ":" .. s or h .. ":" .. m .. ":" .. s
end

--- Converts a number into a float string.
-- @tparam number num
-- @treturn string
function String.ValueFloat(num)
    return string.format("%0.2f", num or 0)
end

--- Converts a number into a percentage string.
-- @tparam number num
-- @treturn string
function String.ValuePercent(num)
    return string.format("%0.2f", num or 0) .. "%"
end

--- Converts a number into a scale string.
-- @tparam number num
-- @treturn string
function String.ValueScale(num)
    return string.format("%0.2f°", num or 0)
end

--- Converts a table values into a string.
--
-- Converts a table:
--
--    { "one", "two", "three" }
--
-- To string:
--
--    one | two | three"
--
-- @tparam table t
-- @treturn string
function String.TableSplit(t)
    if type(t) == "table" and #t > 0 then
        local value, value_clean

        value = ""
        for _, v in pairs(t) do
            value_clean = v

            -- and math.floor(value_clean) ~= value_clean
            if type(value_clean) == "number" then
                value_clean = String.ValueFloat(v)
            end

            value = value .. value_clean
            if next(t, _) ~= nil then
                value = value .. " | "
            end
        end

        return value
    end
end

return String
