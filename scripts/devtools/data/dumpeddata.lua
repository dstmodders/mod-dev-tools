----
-- Dumped data.
--
-- Includes dumped data functionality which show show different dump lines in the "Dump" submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.DumpedData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0-alpha
----
require "class"

local Data = require "devtools/data/data"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam screens.DevToolsScreen screen
-- @usage local dumpeddata = DumpedData(screen)
local DumpedData = Class(Data, function(self, screen)
    Data._ctor(self, screen)

    -- general
    self.name = nil
    self.values = {}

    -- self
    self:Update()
end)

--- General
-- @section general

--- Updates lines stack.
function DumpedData:Update()
    Data.Update(self)

    local dumped = self.screen:GetDumped()
    self.name = dumped.name
    self.values = dumped.values

    if type(self.name) == "string" then
        self:PushTitleLine(self.values == 0
            and string.format("Dumped %s", self.name, #self.values)
            or string.format("Dumped %s [%d]", self.name, #self.values))
    else
        self:PushTitleLine(self.values == 0
            and "Dumped"
            or string.format("Dumped [%d]", #self.values))
    end

    self:PushEmptyLine()
    self:PushDumpedData(dumped)
end

--- Pushes ingredients data.
function DumpedData:PushDumpedData()
    if type(self.values) == "table" and #self.values > 0 then
        for _, value in pairs(self.values) do
            self:PushLine(nil, value)
        end
    else
        self:PushLine(nil, "[NO DATA]")
    end
end

return DumpedData
