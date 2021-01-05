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
-- @release 0.7.0
----
require "devtools/constants"

local SDK = require "devtools/sdk/sdk/sdk"
local Toggle = require "devtools/submenus/option/toggle"

return {
    label = "Time Control",
    name = "TimeControlSubmenu",
    data_sidebar = MOD_DEV_TOOLS.DATA_SIDEBAR.WORLD,
    on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
    options = {
        Toggle(
            "devtools",
            "Pause",
            "IsPaused",
            "TogglePause",
            MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.ONE_PLAYER
        ),
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
                    TheSim:SetTimeScale(1)
                    if not SDK.World.IsMasterSim() then
                        SDK.Remote.World.SetTimeScale(1)
                    end
                end,
                on_get_fn = function()
                    return math.ceil(TheSim:GetTimeScale() * 100)
                end,
                on_set_fn = function(_, _, value)
                    value = value / 100
                    TheSim:SetTimeScale(value)
                    if not SDK.World.IsMasterSim() then
                        SDK.Remote.World.SetTimeScale(value)
                    end
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
