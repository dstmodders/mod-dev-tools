----
-- Selected entity tags data.
--
-- Includes selected entity tags in data sidebar.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.SelectedTagsData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0-alpha
----
require "class"

local Data = require "devtools/data/data"
local Utils = require "devtools/utils"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam screens.DevToolsScreen screen
-- @tparam DevTools devtools
-- @tparam devtools.WorldDevTools worlddevtools
-- @tparam EntityScript player
-- @usage local selectedtagsdata = SelectedTagsData(self, screen, devtools, worlddevtools, player)
local SelectedTagsData = Class(Data, function(self, screen, devtools, worlddevtools, player)
    Data._ctor(self, screen)

    -- general
    self.devtools = devtools
    self.entity = worlddevtools:GetSelectedEntity()
    self.player = player
    self.worlddevtools = worlddevtools

    -- self
    self:Update()
end)

--- General
-- @section general

--- Updates lines stack.
function SelectedTagsData:Update()
    Data.Update(self)

    self:PushTitleLine("Selected Entity Tags")
    self:PushEmptyLine()
    self:PushTagsData()
end

--- Pushes tags data.
function SelectedTagsData:PushTagsData()
    local entity = self.entity
    if not entity then
        entity = self.player
    end

    if not entity then
        self:PushLine("", "[NO SELECTED ENTITY]")
        return
    end

    local tags
    tags = Utils.Entity.GetTags(entity)
    if type(tags) == "table" then
        for _, tag in pairs(tags) do
            self:PushLine("", tag)
        end
    end
end

return SelectedTagsData
