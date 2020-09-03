----
-- Mod constants.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module Constants
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----

--- Mod constants.
-- @see MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN
-- @see MOD_DEV_TOOLS.OPTION
-- @table MOD_DEV_TOOLS
-- @tfield table API
MOD_DEV_TOOLS = {
    --- General
    -- @section general

    --- `menu.Submenu.SetOnAddToRootFn` constants.
    -- @see menu.Submenu.SetOnAddToRootFn
    -- @table MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN
    -- @tfield function IS_ADMIN
    -- @tfield function IS_CAVE
    -- @tfield function IS_FOREST
    -- @tfield function IS_MASTER_SIM
    -- @tfield function IS_PLAYER
    -- @tfield function IS_WORLD
    ON_ADD_TO_ROOT_FN = {
        IS_ADMIN = function(self)
            return self.devtools.player and self.devtools.player:IsAdmin()
        end,
        IS_CAVE = function(self)
            return self.devtools.world and self.devtools.world:IsCave()
        end,
        IS_FOREST = function(self)
            return self.devtools.world and not self.devtools.world:IsCave()
        end,
        IS_MASTER_SIM = function(self)
            return self.devtools.world and self.devtools.world:IsMasterSim()
        end,
        IS_PLAYER = function(self)
            return self.devtools.player and true or false
        end,
        IS_WORLD = function(self)
            return self.devtools.world and true or false
        end,
    },

    --- Option constants.
    -- @table MOD_DEV_TOOLS.OPTION
    -- @tfield number ACTION
    -- @tfield number CHECKBOX
    -- @tfield number CHOICES
    -- @tfield number DIVIDER
    -- @tfield number NUMERIC
    -- @tfield number SUBMENU
    -- @tfield number TOGGLE_CHECKBOX
    OPTION = {
        ACTION = 1,
        CHECKBOX = 2,
        CHOICES = 3,
        DIVIDER = 4,
        NUMERIC = 5,
        SUBMENU = 6,
        TOGGLE_CHECKBOX = 7,
    },
}
