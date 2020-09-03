----
-- Weather control submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.WeatherControl
-- @see DevTools.CreateSubmenuInstFromData
-- @see menu.Menu
-- @see menu.Menu.AddSubmenu
-- @see menu.Submenu
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
    label = "Weather Control",
    name = "WeatherControlSubmenu",
    on_init_fn = function(self, devtools)
        self.console = devtools.player and devtools.player.console
        self.player = devtools.player
        self.world = devtools.world
    end,
    on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
    options = {
        {
            type = MOD_DEV_TOOLS.OPTION.CHECKBOX,
            options = {
                label = "Toggle Force Precipitation",
                on_get_fn = function(_, submenu)
                    return submenu.world:IsPrecipitation()
                end,
                on_set_fn = function(_, submenu, value)
                    if value ~= submenu.world:IsPrecipitation() then
                        submenu.console:ForcePrecipitation(value)
                        UpdateScreen(submenu)
                    end
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_FOREST,
            options = {
                label = "Send Lightning Strike",
                on_accept_fn = function(_, submenu)
                    submenu.console:SendLightningStrike(TheInput:GetWorldPosition())
                    UpdateScreen(submenu)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_CAVE,
            options = {
                label = "Send Mini Earthquake",
                on_accept_fn = function(_, submenu)
                    submenu.console:MiniQuake()
                    UpdateScreen(submenu)
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
            on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_FOREST,
            options = {
                label = "Moisture",
                min = function(_, submenu)
                    return submenu.world:GetMoistureFloor()
                end,
                max = function(_, submenu)
                    return submenu.world:GetStateMoistureCeil()
                end,
                step = 25,
                on_get_fn = function(_, submenu)
                    return math.floor(submenu.world:GetStateMoisture())
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.console:DeltaMoisture(math.floor(value)
                        - math.floor(submenu.world:GetStateMoisture()))
                    UpdateScreen(submenu)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
            on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_FOREST,
            options = {
                label = "Snow Level",
                min = 0,
                max = 100,
                step = 10,
                on_get_fn = function(_, submenu)
                    return math.floor(submenu.world:GetStateSnowLevel() * 100)
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.console:SetSnowLevel(value / 100)
                    UpdateScreen(submenu)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
            options = {
                label = "Wetness",
                min = 0,
                max = 100,
                on_get_fn = function(_, submenu)
                    return math.floor(submenu.world:GetStateWetness())
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.console:DeltaWetness(math.floor(value)
                        - math.floor(submenu.world:GetStateWetness()))
                    UpdateScreen(submenu)
                end,
            },
        },
    },
}
