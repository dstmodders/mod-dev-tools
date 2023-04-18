----
-- Selected entity tags data.
--
-- Includes selected entity tags in data sidebar.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod data.SelectedTagsData
-- @see data.Data
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local Data = require("devtools/data/data")
local SDK = require("devtools/sdk/sdk/sdk")

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevToolsScreen screen
-- @tparam DevTools devtools
-- @tparam WorldTools worldtools
-- @tparam EntityScript player
-- @usage local selectedtagsdata = SelectedTagsData(self, screen, devtools, worldtools, player)
local SelectedTagsData = Class(Data, function(self, screen, devtools, worldtools, player)
    Data._ctor(self, screen)

    -- general
    self.devtools = devtools
    self.entity = worldtools:GetSelectedEntity()
    self.player = player
    self.worldtools = worldtools

    -- other
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
    tags = SDK.Entity.GetTags(entity)
    if type(tags) == "table" then
        for _, tag in pairs(tags) do
            self:PushLine("", tag)
        end
    end
end

return SelectedTagsData
