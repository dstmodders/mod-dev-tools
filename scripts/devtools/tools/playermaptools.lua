----
-- Player map tools.
--
-- Extends `tools.Tools` and includes different map functionality most of which can be accessed from
-- the "Map..." submenu.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.player.map
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod tools.PlayerMapTools
-- @see DevTools
-- @see tools.PlayerTools
-- @see tools.Tools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
local DevTools = require "devtools/tools/tools"
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam PlayerTools playertools
-- @tparam DevTools devtools
-- @usage local playermaptools = PlayerMapTools(playertools, devtools)
local PlayerMapTools = Class(DevTools, function(self, playertools, devtools)
    DevTools._ctor(self, "PlayerMapTools", devtools)

    -- asserts
    SDK.Utils.AssertRequiredField(self.name .. ".playertools", playertools)
    SDK.Utils.AssertRequiredField(self.name .. ".world", playertools.world)
    SDK.Utils.AssertRequiredField(self.name .. ".inst", playertools.inst)

    -- general
    self.inst = playertools.inst
    self.playertools = playertools
    self.world = playertools.world

    -- other
    self:DoInit()
end)

--- General
-- @section general

--- Checks if map screen is open.
-- @treturn boolean
function PlayerMapTools:IsMapScreenOpen() -- luacheck: only
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
function PlayerMapTools:Reveal()
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
function PlayerMapTools:DoInit()
    DevTools.DoInit(self, self.playertools, "map", {
        -- general
        "IsMapScreenOpen",
        "Reveal",
    })
end

return PlayerMapTools
