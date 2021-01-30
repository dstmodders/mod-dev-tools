----
-- Map submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.Map
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
    label = "Map",
    name = "MapSubmenu",
    on_add_to_root_fn = {
        MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
        MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_MASTER_SIM,
    },
    options = {
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Reveal",
                on_accept_fn = function(_, submenu)
                    SDK.Player.Reveal()
                    submenu.screen:Close()
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
            options = {
                label = "Clearing",
                get = {
                    src = SDK.MiniMap,
                    name = "IsClearing",
                    args = {},
                },
                set = {
                    src = SDK.MiniMap,
                    name = "ToggleClearing",
                    args = {},
                },
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
            options = {
                label = "Fog of War",
                get = {
                    src = SDK.MiniMap,
                    name = "IsFogOfWar",
                    args = {},
                },
                set = {
                    src = SDK.MiniMap,
                    name = "ToggleFogOfWar",
                    args = {},
                },
            },
        },
    },
}
