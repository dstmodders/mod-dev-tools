----
-- Player vision submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod submenus.PlayerVisionSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu"

local CC_CHOICES = {
    { name = "Default", value = "nil" },
    { name = "Empty", value = {} },
    {
        name = "Beaver-Vision",
        value = {
            day = "images/colour_cubes/beaver_vision_cc.tex",
            dusk = "images/colour_cubes/beaver_vision_cc.tex",
            full_moon = "images/colour_cubes/beaver_vision_cc.tex",
            night = "images/colour_cubes/beaver_vision_cc.tex",
            calm = "images/colour_cubes/ruins_dark_cc.tex",
            dawn = "images/colour_cubes/ruins_dim_cc.tex",
            warn = "images/colour_cubes/ruins_dim_cc.tex",
            wild = "images/colour_cubes/ruins_light_cc.tex",
        },
    },
    {
        name = "Ghost-Vision",
        value = {
            day = "images/colour_cubes/ghost_cc.tex",
            dusk = "images/colour_cubes/ghost_cc.tex",
            full_moon = "images/colour_cubes/ghost_cc.tex",
            night = "images/colour_cubes/ghost_cc.tex",
            calm = "images/colour_cubes/ruins_dark_cc.tex",
            dawn = "images/colour_cubes/ruins_dim_cc.tex",
            warn = "images/colour_cubes/ruins_dim_cc.tex",
            wild = "images/colour_cubes/ruins_light_cc.tex",
        },
    },
    {
        name = "Nightmare",
        value = {
            day = "images/colour_cubes/ruins_dark_cc.tex",
            dusk = "images/colour_cubes/ruins_dark_cc.tex",
            full_moon = "images/colour_cubes/ruins_dark_cc.tex",
            night = "images/colour_cubes/ruins_dark_cc.tex",
            calm = "images/colour_cubes/ruins_dark_cc.tex",
            dawn = "images/colour_cubes/ruins_dim_cc.tex",
            warn = "images/colour_cubes/ruins_dim_cc.tex",
            wild = "images/colour_cubes/ruins_light_cc.tex",
        },
    },
    {
        name = "Night-Vision",
        value = {
            day = "images/colour_cubes/mole_vision_off_cc.tex",
            dusk = "images/colour_cubes/mole_vision_on_cc.tex",
            full_moon = "images/colour_cubes/mole_vision_off_cc.tex",
            night = "images/colour_cubes/mole_vision_on_cc.tex",
            calm = "images/colour_cubes/ruins_dark_cc.tex",
            dawn = "images/colour_cubes/ruins_dim_cc.tex",
            warn = "images/colour_cubes/ruins_dim_cc.tex",
            wild = "images/colour_cubes/ruins_light_cc.tex",
        },
    },
}

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local playervisionsubmenu = PlayerVisionSubmenu(devtools, root)
local PlayerVisionSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Player Vision", "PlayerVisionSubmenu")

    -- general
    self.vision = devtools.player and devtools.player.vision

    -- options
    if self.vision then
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- Helpers
-- @section helpers

local function AddCCOTOption(self)
    self:AddChoicesOption({
        label = "CCT",
        choices = CC_CHOICES,
        on_get_fn = function()
            local override = self.vision:GetCCT()
            return override and override or "nil"
        end,
        on_set_fn = function(value)
            self.vision:SetCCT(value)
            value = value ~= nil and value or "nil"
            self.vision:UpdatePlayerVisionCCT(value)
        end,
    })
end

--- General
-- @section general

local function AddToggleOption(self, name, get, toggle)
    self:AddToggleOption(
        { name = name },
        { src = self.vision, name = get },
        { src = self.vision, name = toggle }
    )
end

--- Adds options.
function PlayerVisionSubmenu:AddOptions()
    AddToggleOption(
        self,
        "Forced HUD Visibility",
        "IsForcedHUDVisibility",
        "ToggleForcedHUDVisibility"
    )

    AddToggleOption(self, "Forced Unfading", "IsForcedUnfading", "ToggleForcedUnfading")

    self:AddDividerOption()
    AddCCOTOption(self)
end

return PlayerVisionSubmenu
