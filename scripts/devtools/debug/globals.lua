----
-- Debug globals.
--
-- Includes globals debugging functionality as a part of `Debug`. Shouldn't be used on its own.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod debug.Globals
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.5.0
----
require "class"

--- Constructor.
-- @function _ctor
-- @tparam Debug debug
-- @usage local globals = Globals(debug)
local Globals = Class(function(self, debug)
    -- general
    self.debug = debug

    -- overrides
    self.OldSendRPCToServer = _G.SendRPCToServer
    _G.SendRPCToServer = function(...) -- luacheck: only
        self:SendRPCToServer(...)
        self.OldSendRPCToServer(...)
    end

    -- other
    self.debug:DebugInit("Debug (Globals)")
end)

--- General
-- @section general

--- SendRPCToServer.
-- @tparam any ...
function Globals:SendRPCToServer(...)
    if self.debug:IsDebug("rpc") then
        print(string.format("[debug] [rpc] %s", self.debug:SendRPCToServerString(...)))
    end
end

return Globals
