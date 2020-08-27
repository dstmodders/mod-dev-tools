----
-- Labels submenu.
--
-- Extends `menu.submenu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.submenu.LabelsSubmenu
-- @see menu.submenu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu/submenu"

local LabelsSubmenu = Class(Submenu, function(self, root, devtools)
    Submenu._ctor(self, root, "Labels", "LabelsSubmenu")

    -- general
    self.devtools = devtools

    if self.devtools then
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- Helpers
-- @section helpers

local function AddFontSizeOption(self)
    local default = 18
    local choices = {}
    local sizes = { 14, 16, 18, 20, 22, 24, 26 }
    for i = 1, #sizes do
        choices[i] = { name = tostring(sizes[i]), value = sizes[i] }
    end

    self:AddChoicesOption({
        label = "Font size",
        choices = choices,
        on_get_fn = function()
            local size = self.devtools:GetLabelsFontSize()
            return size and size or default
        end,
        on_set_fn = function(value)
            self.devtools:SetLabelsFontSize(value)
        end,
    })
end

local function AddUsernameOption(self)
    local default = false
    local choices = {
        { name = "Disabled", value = false },
        { name = "Default", value = "default" },
        { name = "Coloured", value = "coloured" },
    }

    self:AddChoicesOption({
        label = "Username",
        choices = choices,
        on_get_fn = function()
            local mode = self.devtools:GetUsernameLabelsMode()
            return mode and mode or default
        end,
        on_set_fn = function(value)
            self.devtools:SetUsernameLabelsMode(value)
        end,
    })
end

--- General
-- @section general

--- Adds options.
function LabelsSubmenu:AddOptions()
    AddFontSizeOption(self)

    self:AddDividerOption()
    AddUsernameOption(self)
end

return LabelsSubmenu
