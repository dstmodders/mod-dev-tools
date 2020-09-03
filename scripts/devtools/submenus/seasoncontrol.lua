----
-- Season control submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.SeasonControl
-- @see DevTools.CreateSubmenuInstFromData
-- @see menu.Menu
-- @see menu.Menu.AddSubmenu
-- @see menu.Submenu
-- @see submenus.SeasonControl.Length
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "devtools/constants"

local function UpdateScreen(submenu)
    if submenu.devtools:IsPaused() then
        submenu.devtools:Unpause()
    end
    submenu:UpdateScreen("world")
end

return {
    label = "Season Control",
    name = "SeasonControlSubmenu",
    on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
    options = {
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Advance Season",
                on_accept_fn = function(_, submenu)
                    for _ = 1, submenu.world:GetStateRemainingDaysInSeason() do
                        submenu.console:PushWorldEvent("ms_advanceseason")
                    end
                    UpdateScreen(submenu)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Retreat Season",
                on_accept_fn = function(_, submenu)
                    for _ = 1, submenu.world:GetStateRemainingDaysInSeason() do
                        submenu.console:PushWorldEvent("ms_retreatseason")
                    end
                    UpdateScreen(submenu)
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.CHOICES,
            options = {
                label = "Season",
                choices = {
                    { name = "Autumn", value = "autumn" },
                    { name = "Spring", value = "spring" },
                    { name = "Summer", value = "summer" },
                    { name = "Winter", value = "winter" },
                },
                on_get_fn = function(_, submenu)
                    return submenu.world:GetStateSeason()
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.console:SetSeason(value)
                    UpdateScreen(submenu)
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.SUBMENU,
            options = {
                label = "Length",
                name = "SeasonControlLengthSubmenu",
                on_init_fn = function(self, devtools)
                    self.console = devtools.player and devtools.player.console
                    self.player = devtools.player
                    self.world = devtools.world
                end,
                options = require("devtools/submenus/seasoncontrol/length"),
            },
        },
    },
}
