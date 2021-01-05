----
-- Player console commands.
--
-- Extends `tools.Tools` and includes different functionality to send remote console commands for
-- both the player and the world.
--
-- Of course, the mod owner should have administrator rights on the server for most methods to work.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.player.console
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod tools.PlayerConsoleTools
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
-- @usage local playerconsoletools = PlayerConsoleTools(playertools, devtools)
local PlayerConsoleTools = Class(DevTools, function(self, playertools, devtools)
    DevTools._ctor(self, "PlayerConsoleTools", devtools)

    -- asserts
    SDK.Utils.AssertRequiredField(self.name .. ".playertools", playertools)
    SDK.Utils.AssertRequiredField(self.name .. ".world", playertools.world)
    SDK.Utils.AssertRequiredField(self.name .. ".inst", playertools.inst)

    -- general
    self.inst = playertools.inst
    self.playertools = playertools
    self.worldtools = playertools.world

    -- other
    self:DoInit()
end)

--- Lifecycle
-- @section lifecycle

--- Initializes.
function PlayerConsoleTools:DoInit()
    DevTools.DoInit(self, self.playertools, "console", {})
end

return PlayerConsoleTools
