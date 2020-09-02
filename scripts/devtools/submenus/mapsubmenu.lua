----
-- Map submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod submenus.MapSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local mapsubmenu = MapSubmenu(devtools, root)
local MapSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Map", "MapSubmenu")

    -- general
    self.map = devtools.player and devtools.player.map
    self.player = devtools.player
    self.world = devtools.world

    -- options
    if self.world
        and self.world:IsMasterSim()
        and self.player
        and self.player:IsAdmin()
        and self.map
        and self.screen
    then
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- Helpers
-- @section helpers

local function AddRevealOption(self)
    if self.world:IsMasterSim() then
        self:AddDoActionOption({
            label = "Reveal",
            on_accept_fn = function()
                self.map:Reveal()
                self.screen:Close()
            end,
        })
    end
end

--- General
-- @section general

--- Adds options.
function MapSubmenu:AddOptions()
    AddRevealOption(self)

    if self.world:IsMasterSim() then
        self:AddDividerOption()

        self:AddToggleOption(
            { name = "Clearing" },
            { src = self.world, name = "IsMapClearing" },
            { src = self.world, name = "ToggleMapClearing" }
        )

        self:AddToggleOption(
            { name = "Fog of War" },
            { src = self.world, name = "IsMapFogOfWar" },
            { src = self.world, name = "ToggleMapFogOfWar" }
        )
    end
end

return MapSubmenu
