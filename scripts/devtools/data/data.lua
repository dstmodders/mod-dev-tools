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
    Utils.Debug.AddMethods(self)
end)

--- Line
-- @section line

--- Pushes line into table.
-- @tparam table t
-- @tparam string name
-- @tparam table|string value
function Data:PushLine(t, name, value) -- luacheck: only
    if type(t) ~= "table"
        or type(name) ~= "string"
        or string.len(name) == 0
        or value == nil
    then
        return
    end

    if type(value) == "table" and #value > 0 then
        value = Utils.String.TableSplit(value)
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
