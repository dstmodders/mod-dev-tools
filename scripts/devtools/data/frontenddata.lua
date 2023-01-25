----
-- Front-end data.
--
-- Includes front-end data in data sidebar.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod data.FrontEndData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
----
require("class")

local Data = require("devtools/data/data")
local Utils = require("devtools/utils")

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam screens.DevToolsScreen screen
-- @usage local frontenddata = FrontEndData(screen)
local FrontEndData = Class(Data, function(self, screen)
    Data._ctor(self, screen)

    -- general
    self.front_end = TheFrontEnd

    -- self
    self:Update()
end)

--- General
-- @section general

--- Updates lines stack.
function FrontEndData:Update()
    Data.Update(self)

    self:PushTitleLine("Front-End")
    self:PushEmptyLine()
    self:PushFrontEndData()

    self:PushEmptyLine()
    self:PushTitleLine("Screen Stack")
    self:PushEmptyLine()
    self:PushScreenData()
end

--- Pushes front-end data.
function FrontEndData:PushFrontEndData()
    local w, h = TheSim:GetScreenSize()
    self:PushLine("Resolution", string.format("%d x %d", w, h))

    local pos = TheInput:GetScreenPosition()
    if pos then
        self:PushLine("Mouse Position (X, Y)", string.format("%d, %d", pos.x, pos.y))
    end

    self:PushLine("HUD Scale", Utils.String.ValueFloat(self.front_end:GetHUDScale()))
    self:PushLine("Locale Text Scale", Utils.String.ValueFloat(LOC.GetTextScale()))
end

--- Pushes screen data.
function FrontEndData:PushScreenData()
    local stack = self.front_end.screenstack
    self:PushLine("Size", #stack)
    for _, v in pairs(stack) do
        self:PushLine(tostring(v), v:IsVisible() and "visible" or "hidden")
    end
end

return FrontEndData
