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
-- @release 0.5.0-alpha
----

--- Mod constants.
-- @see MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN
-- @see MOD_DEV_TOOLS.OPTION
-- @table MOD_DEV_TOOLS
-- @tfield table API
-- @tfield table CCT
-- @tfield table ON_ADD_TO_ROOT_FN
-- @tfield table OPTION
MOD_DEV_TOOLS = {
    --- General
    -- @section general

    --- API constants.
    -- @table MOD_DEV_TOOLS.API
    -- @tfield number VERSION
    API = {
        VERSION = 0.1,
    },

    --- CCT (Colour Cubes Tables) constants.
    -- @table MOD_DEV_TOOLS.CCT
    -- @tfield table BEAVER_VISION
    -- @tfield table DEFAULT
    -- @tfield table EMPTY
    -- @tfield table GHOST_VISION
    -- @tfield table NIGHT_VISION
    -- @tfield table NIGHTMARE
    -- @todo Improve CCT to match in-game ones more closely (seasons, ruins, etc.)
    CCT = {
        DEFAULT = nil,
        EMPTY = {},
        BEAVER_VISION = {
            day = "images/colour_cubes/beaver_vision_cc.tex",
            dusk = "images/colour_cubes/beaver_vision_cc.tex",
            full_moon = "images/colour_cubes/beaver_vision_cc.tex",
            night = "images/colour_cubes/beaver_vision_cc.tex",
            calm = "images/colour_cubes/ruins_dark_cc.tex",
            dawn = "images/colour_cubes/ruins_dim_cc.tex",
            warn = "images/colour_cubes/ruins_dim_cc.tex",
            wild = "images/colour_cubes/ruins_light_cc.tex",
        },
        GHOST_VISION = {
            day = "images/colour_cubes/ghost_cc.tex",
            dusk = "images/colour_cubes/ghost_cc.tex",
            full_moon = "images/colour_cubes/ghost_cc.tex",
            night = "images/colour_cubes/ghost_cc.tex",
            calm = "images/colour_cubes/ruins_dark_cc.tex",
            dawn = "images/colour_cubes/ruins_dim_cc.tex",
            warn = "images/colour_cubes/ruins_dim_cc.tex",
            wild = "images/colour_cubes/ruins_light_cc.tex",
        },
        NIGHT_VISION = {
            day = "images/colour_cubes/mole_vision_off_cc.tex",
            dusk = "images/colour_cubes/mole_vision_on_cc.tex",
            full_moon = "images/colour_cubes/mole_vision_off_cc.tex",
            night = "images/colour_cubes/mole_vision_on_cc.tex",
            calm = "images/colour_cubes/ruins_dark_cc.tex",
            dawn = "images/colour_cubes/ruins_dim_cc.tex",
            warn = "images/colour_cubes/ruins_dim_cc.tex",
            wild = "images/colour_cubes/ruins_light_cc.tex",
        },
        NIGHTMARE = {
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

    --- Submenu
    -- @section submenu

    --- `menu.Submenu.SetOnAddToRootFn` constants.
    -- @see menu.Submenu.SetOnAddToRootFn
    -- @table MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN
    -- @tfield function IS_ADMIN
    -- @tfield function IS_CAVE
    -- @tfield function IS_FOREST
    -- @tfield function IS_MASTER_SIM
    -- @tfield function IS_NO_PLAYER
    -- @tfield function IS_NO_WORLD
    -- @tfield function IS_NOT_MASTER_SIM
    -- @tfield function IS_PLAYER
    -- @tfield function IS_WORLD
    -- @tfield function ONE_PLAYER
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
        IS_NO_PLAYER = function(self)
            return (not self.devtools.player) and true or false
        end,
        IS_NO_WORLD = function(self)
            return (not self.devtools.world) and true or false
        end,
        IS_NOT_MASTER_SIM = function(self)
            return self.devtools.world and not self.devtools.world:IsMasterSim()
        end,
        IS_PLAYER = function(self)
            return self.devtools.player and true or false
        end,
        IS_WORLD = function(self)
            return self.devtools.world and true or false
        end,
        ONE_PLAYER = function(self)
            return self.devtools and #self.devtools:GetPlayersClientTable() == 1
        end,
    },

    --- Option constants.
    -- @table MOD_DEV_TOOLS.OPTION
    -- @tfield number ACTION
    -- @tfield number CHECKBOX
    -- @tfield number CHOICES
    -- @tfield number DIVIDER
    -- @tfield number FONT
    -- @tfield number NUMERIC
    -- @tfield number SUBMENU
    -- @tfield number TOGGLE_CHECKBOX
    OPTION = {
        ACTION = 1,
        CHECKBOX = 2,
        CHOICES = 3,
        DIVIDER = 4,
        FONT = 5,
        NUMERIC = 6,
        SUBMENU = 7,
        TOGGLE_CHECKBOX = 8,
    },
}
