----
-- Map submenu.
--
-- Extends `menu.submenu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.submenu.MapSubmenu
-- @see menu.submenu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu/submenu"

local MapSubmenu = Class(Submenu, function(self, root, worlddevtools, mapdevtools, screen)
    Submenu._ctor(self, root, "Map", "MapSubmenu", screen)

    -- general
    self.map = mapdevtools
    self.world = worlddevtools

    if self.world and self.map and screen then
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
