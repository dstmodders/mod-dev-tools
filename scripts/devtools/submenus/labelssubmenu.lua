----
-- Labels submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod submenus.LabelsSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local labelssubmenu = LabelsSubmenu(devtools, root)
local LabelsSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Labels", "LabelsSubmenu")

    -- options
    if self.devtools and self.devtools.labels then
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- Helpers
-- @section helpers

local function AddToggleOptions(self)
    self:AddToggleOption(
        { name = "Selected" },
        { src = self.devtools.labels, name = "IsSelectedEnabled" },
        { src = self.devtools.labels, name = "ToggleSelectedEnabled" }
    )

    self:AddToggleOption(
        { name = "Username" },
        { src = self.devtools.labels, name = "IsUsernameEnabled" },
        { src = self.devtools.labels, name = "ToggleUsernameEnabled" }
    )
end

local function AddFontOption(self)
    local default = BODYTEXTFONT
    local choices = {
        { name = "Belisa Plumilla Manual (50)", value = UIFONT },
        { name = "Belisa Plumilla Manual (100)", value = TITLEFONT },
        { name = "Belisa Plumilla Manual (Button)", value = BUTTONFONT },
        { name = "Belisa Plumilla Manual (Talking)", value = TALKINGFONT },
        { name = "Bellefair", value = CHATFONT },
        { name = "Bellefair Outline", value = CHATFONT_OUTLINE },
        { name = "Hammerhead", value = HEADERFONT },
        { name = "Henny Penny (Wormwood)", value = TALKINGFONT_WORMWOOD },
        { name = "Mountains of Christmas (Hermit)", value = TALKINGFONT_HERMIT },
        { name = "Open Sans", value = DIALOGFONT },
        { name = "PT Mono", value = CODEFONT },
        { name = "Spirequal Light", value = NEWFONT },
        { name = "Spirequal Light (Small)", value = NEWFONT_SMALL },
        { name = "Spirequal Light Outline", value = NEWFONT_OUTLINE },
        { name = "Spirequal Light Outline (Small)", value = NEWFONT_OUTLINE_SMALL },
        { name = "Stint Ultra Condensed", value = BODYTEXTFONT },
        { name = "Stint Ultra Condensed (Small)", value = SMALLNUMBERFONT },
    }

    self:AddChoicesOption({
        label = "Font",
        choices = choices,
        on_accept_fn = function()
            self.devtools.labels:SetFont(self.devtools.labels:GetDefaultFont())
        end,
        on_get_fn = function()
            local size = self.devtools.labels:GetFont()
            return size and size or default
        end,
        on_set_fn = function(value)
            self.devtools.labels:SetFont(value)
        end,
    })
end

local function AddFontSizeOption(self)
    local default = 18
    self:AddNumericOption({
        label = "Font Size",
        min = 6,
        max = 32,
        on_accept_fn = function()
            self.devtools.labels:SetFontSize(self.devtools.labels:GetDefaultFontSize())
        end,
        on_get_fn = function()
            local size = self.devtools.labels:GetFontSize()
            return size and size or default
        end,
        on_set_fn = function(value)
            self.devtools.labels:SetFontSize(value)
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
        on_accept_fn = function()
            self.devtools.labels:SetUsernameMode(self.devtools.labels:GetDefaultUsernameMode())
        end,
        on_get_fn = function()
            local mode = self.devtools.labels:GetUsernameMode()
            return mode and mode or default
        end,
        on_set_fn = function(value)
            self.devtools.labels:SetUsernameMode(value)
        end,
    })
end

--- General
-- @section general

--- Adds options.
function LabelsSubmenu:AddOptions()
    AddToggleOptions(self)

    self:AddDividerOption()
    AddFontOption(self)
    AddFontSizeOption(self)

    self:AddDividerOption()
    AddUsernameOption(self)
end

return LabelsSubmenu
