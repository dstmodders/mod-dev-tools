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
-- @release 0.1.0-beta
----
require "devtools/constants"

local Toggle = require "devtools/submenus/option/toggle"

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
                    submenu.map:Reveal()
                    submenu.screen:Close()
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        Toggle("world", "Clearing", "IsMapClearing", "ToggleMapClearing"),
        Toggle("world", "Fog of War", "IsMapFogOfWar", "ToggleMapFogOfWar"),
    },
}
