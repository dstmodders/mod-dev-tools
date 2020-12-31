----
-- Debug globals.
--
-- Includes globals debugging functionality as a part of `Debug`. Shouldn't be used on its own.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod DebugGlobals
-- @see Debug
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam Debug debug
-- @usage local globals = DebugGlobals(debug)
local DebugGlobals = Class(function(self, debug)
    SDK.Debug.AddMethods(self)
    SDK.Method.SetClass(self).AddToString("DebugGlobals")

    -- general
    self.debug = debug

    -- overrides
    self.OldSendRPCToServer = _G.SendRPCToServer
    _G.SendRPCToServer = function(...) -- luacheck: only
        self:SendRPCToServer(...)
        self.OldSendRPCToServer(...)
    end

    -- other
    self:DebugInit(tostring(self))
end)

--- General
-- @section general

--- SendRPCToServer.
-- @tparam any ...
function DebugGlobals:SendRPCToServer(...)
    if SDK.Debug.IsDebug("rpc") then
        print(string.format("[debug] [rpc] %s", self.debug:SendRPCToServerString(...)))
    end
end

return DebugGlobals
