----
-- World state data.
--
-- Includes world state data in data sidebar.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.WorldStateData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
local Data = require "devtools/data/data"
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevToolsScreen screen
-- @tparam EntityScript world
-- @usage local worldstatedata = WorldStateData(screen, TheWorld)
local WorldStateData = Class(Data, function(self, screen, world)
    Data._ctor(self, screen)

    -- general
    self.state = world and world.state
    self.state_keys = {}
    self.world = world

    if self.state then
        self.state_keys = SDK.Utils.Table.Keys(self.state)
        self.state_keys = SDK.Utils.Table.SortAlphabetically(self.state_keys)
    end

    -- self
    self:Update()
end)

--- General
-- @section general

--- Updates lines stack.
function WorldStateData:Update()
    Data.Update(self)

    self:PushTitleLine("World State")
    self:PushEmptyLine()
    self:PushWorldStateData()
end

--- Pushes ingredients data.
function WorldStateData:PushWorldStateData()
    if #self.state_keys > 0 then
        local state
        for _, v in pairs(self.state_keys) do
            state = self.state[v]
            if type(state) == "number" and SDK.Utils.IsInteger(state) then
                self:PushLine(v, tostring(state))
            elseif type(state) == "number" and not SDK.Utils.IsInteger(state) then
                self:PushLine(v, SDK.Utils.String.ValueFloat(state))
            else
                self:PushLine(v, tostring(state))
            end
        end
    end
end

return WorldStateData
