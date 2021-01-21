----
-- Weather control submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.WeatherControl
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
require "devtools/constants"

local SDK = require "devtools/sdk/sdk/sdk"

return {
    label = "Weather Control",
    name = "WeatherControlSubmenu",
    data_sidebar = MOD_DEV_TOOLS.DATA_SIDEBAR.WORLD,
    on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
    options = {
        {
            type = MOD_DEV_TOOLS.OPTION.CHECKBOX,
            options = {
                label = "Toggle Precipitation",
                on_get_fn = function()
                    return SDK.World.Weather.HasPrecipitation()
                end,
                on_set_fn = function(_, submenu, value)
                    if value ~= SDK.World.Weather.HasPrecipitation() then
                        SDK.Remote.World.SetPrecipitation(value)
                        submenu:UpdateScreen(nil, true)
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
                    SDK.Remote.World.SendLightningStrike(TheInput:GetWorldPosition())
                    submenu:UpdateScreen(nil, true)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_CAVE,
            options = {
                label = "Send Mini Earthquake",
                on_accept_fn = function(_, submenu)
                    SDK.Remote.Player.SendMiniEarthquake(nil, nil, nil, ConsoleCommandPlayer())
                    submenu:UpdateScreen(nil, true)
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
            on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_FOREST,
            options = {
                label = "Moisture",
                min = function()
                    return SDK.World.Weather.GetMoistureFloor()
                end,
                max = function()
                    return SDK.World.GetState("moistureceil")
                end,
                step = 25,
                on_get_fn = function()
                    return math.floor(SDK.World.GetState("moisture"))
                end,
                on_set_fn = function(_, submenu, value)
                    SDK.Remote.World.SetDeltaMoisture(math.floor(value)
                        - math.floor(SDK.World.GetState("moisture")))
                    submenu:UpdateScreen(nil, true)
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
                on_get_fn = function()
                    return math.floor(SDK.World.GetState("snowlevel") * 100)
                end,
                on_set_fn = function(_, submenu, value)
                    SDK.Remote.World.SetSnowLevel(value / 100)
                    submenu:UpdateScreen(nil, true)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
            options = {
                label = "Wetness",
                min = 0,
                max = 100,
                on_get_fn = function()
                    return math.floor(SDK.World.GetState("wetness"))
                end,
                on_set_fn = function(_, submenu, value)
                    SDK.Remote.World.SetDeltaWetness(math.floor(value)
                        - math.floor(SDK.World.GetState("wetness")))
                    submenu:UpdateScreen(nil, true)
                end,
            },
        },
    },
}
