----
-- Different chain mod utilities.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module Utils.Debug
-- @see Utils
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-beta
----
local Debug = {}

--- Prints the provided error strings.
-- @see Debug.DebugError
-- @tparam string ... Strings
function Debug.Error(...)
    return _G.ModDevToolsDebug and _G.ModDevToolsDebug:DebugError(...)
end

--- Prints the provided strings.
-- @see Debug.DebugString
-- @tparam string ... Strings
function Debug.String(...)
    return _G.ModDevToolsDebug and _G.ModDevToolsDebug:DebugString(...)
end

--- Adds debug methods to the destination class.
--
-- Checks the global environment if the `Debug` is available and adds the corresponding
-- methods from there. Otherwise, adds all the corresponding functions as empty ones.
--
-- @tparam table dest Destination class
function Debug.AddMethods(dest)
    local methods = {
        "DebugActivateEventListener",
        "DebugDeactivateEventListener",
        "DebugError",
        "DebugErrorNotAdmin",
        "DebugErrorNotInCave",
        "DebugErrorNotInForest",
        "DebugInit",
        "DebugSelectedPlayerString",
        "DebugSendRPCToServer",
        "DebugString",
        "DebugStringStart",
        "DebugStringStop",
        "DebugTerm",
    }

    if _G.ModDevToolsDebug then
        for _, v in pairs(methods) do
            dest[v] = function(_, ...)
                if _G.ModDevToolsDebug and _G.ModDevToolsDebug[v] then
                    return _G.ModDevToolsDebug[v](_G.ModDevToolsDebug, ...)
                end
            end
        end
    else
        for _, v in pairs(methods) do
            dest[v] = function()
            end
        end
    end
end

return Debug
