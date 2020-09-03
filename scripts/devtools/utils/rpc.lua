----
-- Different chain mod utilities.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module Utils.RPC
-- @see Utils
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
local RPC = {}

local _SendRPCToServer

local function DebugString(...)
    return _G.ModDevToolsDebug and _G.ModDevToolsDebug:DebugString(...)
end

--- Checks if `SendRPCToServer()` is enabled.
-- @treturn boolean
function RPC.IsSendToServerEnabled()
    return _SendRPCToServer == nil
end

--- Disables `SendRPCToServer()`.
--
-- Only affects the `SendRPCToServer()` wrapper function Utils.and leaves the `TheNet:SendRPCToServer()`
-- as is.
function RPC.DisableSendToServer()
    if not _SendRPCToServer then
        _SendRPCToServer = SendRPCToServer
        SendRPCToServer = function() end
        DebugString("SendRPCToServer: disabled")
    else
        DebugString("SendRPCToServer: already disabled")
    end
end

--- Enables `SendRPCToServer()`.
function RPC.EnableSendToServer()
    if _SendRPCToServer then
        SendRPCToServer = _SendRPCToServer
        _SendRPCToServer = nil
        DebugString("SendRPCToServer: enabled")
    else
        DebugString("SendRPCToServer: already enabled")
    end
end

return RPC
