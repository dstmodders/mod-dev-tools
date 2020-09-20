----
-- Screen data.
--
-- Includes screen data functionality which aim is to display some screen related data.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.ScreenData
-- @see data.Data
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.4.0-alpha
----
require "class"

local Data = require "devtools/data/data"
local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam screens.DevToolsScreen screen
-- @usage local screendata = ScreenData(screen)
local FrontEndData = Class(Data, function(self, screen)
    Data._ctor(self)

    -- general
    self.front_end = TheFrontEnd
    self.front_end_lines_stack = {}
    self.screen = screen
    self.screen_lines_stack = {}

    -- update
    self:Update()
end)

--- General
-- @section general

--- Clears lines stack.
function FrontEndData:Clear()
    self.front_end_lines_stack = {}
    self.screen_lines_stack = {}
end

--- Updates lines stack.
function FrontEndData:Update()
    self:Clear()
    self:PushFrontEndData()
    self:PushScreenData()
end

--- Front-End
-- @section front-end

--- Pushes front-end line.
-- @tparam string name
-- @tparam string value
function FrontEndData:PushFrontEndLine(name, value)
    self:PushLine(self.front_end_lines_stack, name, value)
end

--- Pushes front-end data.
function FrontEndData:PushFrontEndData()
    local w, h = TheSim:GetScreenSize()
    self:PushFrontEndLine("Resolution", string.format("%d x %d", w, h))

    local pos = TheInput:GetScreenPosition()
    if pos then
        self:PushFrontEndLine("Mouse Position (X, Y)", string.format("%d, %d", pos.x, pos.y))
    end

    self:PushFrontEndLine("HUD Scale", Utils.String.ValueFloat(self.front_end:GetHUDScale()))
    self:PushFrontEndLine("Locale Text Scale", Utils.String.ValueFloat(LOC.GetTextScale()))
end

--- Screen
-- @section screen

--- Pushes screen line.
-- @tparam string name
-- @tparam string value
function FrontEndData:PushScreenLine(name, value)
    self:PushLine(self.screen_lines_stack, name, value)
end

--- Pushes screen data.
function FrontEndData:PushScreenData()
    local stack = self.front_end.screenstack
    self:PushScreenLine("Size", #stack)
    for _, v in pairs(stack) do
        self:PushScreenLine(tostring(v), v:IsVisible() and "visible" or "hidden")
    end
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function FrontEndData:__tostring()
    if #self.front_end_lines_stack == 0 then
        return
    end

    local t = {}

    self:TableInsertTitle(t, "Front-End")

    self:TableInsertData(t, self.front_end_lines_stack)
    table.insert(t, "\n")

    if #self.screen_lines_stack > 0 then
        self:TableInsertTitle(t, "Screen Stack")
        self:TableInsertData(t, self.screen_lines_stack)
    end

    return table.concat(t)
end

return FrontEndData
