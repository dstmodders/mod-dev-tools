----
-- Time control submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.TimeControl
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
    label = "Time Control",
    name = "TimeControlSubmenu",
    data_sidebar = MOD_DEV_TOOLS.DATA_SIDEBAR.WORLD,
    on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
    options = {
        {
            type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
            on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.ONE_PLAYER,
            options = {
                label = "Pause",
                get = {
                    src = SDK,
                    name = "IsPaused",
                    args = {},
                },
                set = {
                    src = SDK,
                    name = "TogglePause",
                    args = {},
                },
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.DIVIDER,
            on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.ONE_PLAYER,
        },
        {
            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
            on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.ONE_PLAYER,
            options = {
                label = "Time Scale",
                min = 1,
                max = 400,
                step = 10,
                on_accept_fn = function()
                    SDK.SetTimeScale(1)
                end,
                on_get_fn = function()
                    return math.ceil(TheSim:GetTimeScale() * 100)
                end,
                on_set_fn = function(_, _, value)
                    SDK.SetTimeScale(value / 100)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.DIVIDER,
            on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.ONE_PLAYER,
        },
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Next Day",
                on_accept_fn = function(_, submenu)
                    SDK.Remote.World.PushEvent("ms_nextcycle")
                    submenu:UpdateScreen(nil, true)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Next Phase",
                on_accept_fn = function(_, submenu)
                    SDK.Remote.World.PushEvent("ms_nextphase")
                    submenu:UpdateScreen(nil, true)
                end,
            },
        },
    },
}
