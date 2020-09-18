----
-- Player map tools.
--
-- Extends `devtools.DevTools` and includes different map functionality most of which can be
-- accessed from the "Map..." submenu.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.player.map
--
-- @classmod devtools.player.MapDevTools
-- @see DevTools
-- @see devtools.DevTools
-- @see devtools.PlayerDevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.3.0-alpha
----
require "class"

local DevTools = require "devtools/devtools/devtools"
local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam devtools.PlayerDevTools playerdevtools
-- @tparam DevTools devtools
-- @usage local mapdevtools = MapDevTools(playerdevtools, devtools)
local MapDevTools = Class(DevTools, function(self, playerdevtools, devtools)
    DevTools._ctor(self, "MapDevTools", devtools)

    -- asserts
    Utils.AssertRequiredField(self.name .. ".playerdevtools", playerdevtools)
    Utils.AssertRequiredField(self.name .. ".world", playerdevtools.world)
    Utils.AssertRequiredField(self.name .. ".inst", playerdevtools.inst)

    -- general
    self.inst = playerdevtools.inst
    self.playerdevtools = playerdevtools
    self.world = playerdevtools.world

    -- self
    self:DoInit()
end)

--- General
-- @section general

--- Checks if map screen is open.
-- @treturn boolean
function MapDevTools:IsMapScreenOpen() -- luacheck: only
    if TheFrontEnd and TheFrontEnd.GetActiveScreen then
        local screen = TheFrontEnd:GetActiveScreen()
        if screen then
            return screen.name == "MapScreen"
        end
    end
    return false
end

--- Reveals the whole map.
--
-- Uses the player classified `MapExplorer` to reveal the map. Only works in a local game at the
-- moment.
--
-- @treturn boolean
function MapDevTools:Reveal()
    if self.inst
        and self.inst.player_classified
        and self.inst.player_classified.MapExplorer
        and self.inst.player_classified.MapExplorer.RevealArea
        and self.world and self.world.inst and self.world.inst.Map and self.world.inst.Map.GetSize
    then
        self:DebugString("Revealing map...")
        local width, height = self.world.inst.Map:GetSize()
        for x = -(width * 2), width * 2, 30 do
            for y = -(height * 2), (height * 2), 30 do
                self.inst.player_classified.MapExplorer:RevealArea(x, 0, y)
            end
        end
        self:DebugString("Map revealing has been completed")
        return true
    end
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function MapDevTools:DoInit()
    DevTools.DoInit(self, self.playerdevtools, "map", {
        -- general
        "IsMapScreenOpen",
        "Reveal",
    })
end

return MapDevTools
