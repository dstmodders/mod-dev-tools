----
-- Map submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.Map
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

return {
    label = "Map",
    name = "MapSubmenu",
    on_init_fn = function(self, devtools)
        self.map = devtools.player and devtools.player.map
        self.player = devtools.player
        self.world = devtools.world
    end,
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
        {
            type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
            options = {
                label = "Clearing",
                get = {
                    src = function(_, submenu)
                        return submenu.world
                    end,
                    name = "IsMapClearing",
                },
                set = {
                    src = function(_, submenu)
                        return submenu.world
                    end,
                    name = "ToggleMapClearing",
                },
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
            options = {
                label = "Fog of War",
                get = {
                    src = function(_, submenu)
                        return submenu.world
                    end,
                    name = "IsMapFogOfWar",
                },
                set = {
                    src = function(_, submenu)
                        return submenu.world
                    end,
                    name = "ToggleMapFogOfWar",
                },
            },
        },
    },
}
