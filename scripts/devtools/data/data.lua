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
-- @release 0.4.0
----
require "class"

local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @usage local data = Data(screen)
local Data = Class(function(self, screen)
    Utils.Debug.AddMethods(self)

    -- general
    self.screen = screen
    self.stack = {}
end)

--- General
-- @section general

--- Clears stack.
function Data:Clear()
    self.stack = {}
end

--- Updates stack.
function Data:Update()
    self:Clear()
end

--- Line
-- @section line

--- Pushes title line into stack.
function Data:PushEmptyLine()
    table.insert(self.stack, "")
end

--- Pushes title line into stack.
-- @tparam string title
function Data:PushTitleLine(title)
    if type(title) == "string" then
        table.insert(self.stack, string.format("***** %s *****", string.upper(title)))
    end
end

--- Pushes line into stack.
-- @tparam string name
-- @tparam table|string value
function Data:PushLine(name, value) -- luacheck: only
    if type(name) ~= "string" or string.len(name) == 0 or value == nil then
        return
    end

    if type(value) == "table" and #value > 0 then
        value = Utils.String.TableSplit(value)
    end

    table.insert(self.stack, string.format("%s: %s", name, value))
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function Data:__tostring()
    if #self.stack == 0 then
        return
    end

    local t = {}

    for _, line in pairs(self.stack) do
        table.insert(t, tostring(line))
        table.insert(t, "\n")
    end

    return table.concat(t)
end

return Data
