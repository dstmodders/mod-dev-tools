----
-- Debugging.
--
-- Includes different debugging-related stuff.
--
-- _Below is the list of some self-explanatory methods which have been added using SDK._
--
-- **Getters:**
--
--   - `GetEvents`
--   - `GetGlobals`
--   - `GetPlayerController`
--
-- **Source Code:** [https://github.com/dstmodders/dst-mod-dev-tools](https://github.com/dstmodders/dst-mod-dev-tools)
--
-- @classmod Debug
-- @see DebugEvents
-- @see DebugGlobals
-- @see DebugPlayerController
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local DebugEvents = require "devtools/debug/debugevents"
local DebugGlobals = require "devtools/debug/debugglobals"
local DebugPlayerController = require "devtools/debug/debugplayercontroller"
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @usage local debug = Debug()
local Debug = Class(function(self)
    SDK.Debug.AddMethods(self)
    SDK.Method
        .SetClass(self)
        .AddToString("Debug")
        .AddGetters({
            events = "GetEvents",
            globals = "GetGlobals",
            playercontroller = "GetPlayerController",
        })

    -- submodules
    self.events = nil
    self.globals = nil
    self.playercontroller = nil

    -- other
    self:DebugInit(tostring(self))
end)

--- Shared
-- @section shared

--- Gets `ACTIONS` constant from the code.
-- @tparam number code
-- @treturn string
function Debug:ActionCodeToString(code) -- luacheck: only
    for _, v in pairs(ACTIONS) do
        if v.code == code then
            return string.format("ACTIONS.%s.code", v.id)
        end
    end
end

--- Concats parameters table into a string.
-- @tparam table t
-- @treturn string
function Debug:ConcatParameters(t)
    local value
    local result = {}
    local is_first_nil = true

    for i = #t, 1, -1 do
        value = t[i]
        if not (is_first_nil and (value == nil or value == "nil")) then
            is_first_nil = false

            if type(value) == "number" and math.floor(value) ~= value then
                -- float
                value = string.format("%0.2f", value)
            elseif type(value) == "table" and value.GUID ~= nil then
                -- Ent
                value = self:EntsString(value)
            elseif type(value) == "string"
                and value ~= "nil"
                and value:sub(1, 7) ~= "ACTIONS"
                and value:sub(1, 3) ~= "RPC"
                and value:sub(1, 5) ~= "Point"
                and value:sub(1, 9) ~= "ThePlayer"
                and value:sub(1, 4) ~= "Ents"
                and value:sub(1, 4) ~= "true"
                and value:sub(1, 5) ~= "false"
            then
                -- string
                value = string.format('"%s"', tostring(value))
            elseif value == nil
                or type(value) == "boolean"
                or type(value) == "number"
            then
                -- simple
                value = tostring(value)
            end

            table.insert(result, value)
        end
    end

    return table.concat(table.reverse(result), ", ")
end

--- Gets the "Ents" string from an entity.
-- @tparam table entity
-- @treturn string
function Debug:EntsString(entity) -- luacheck: only
    return (entity and entity.GUID) and string.format("Ents[%s]", entity.GUID) or "nil"
end

--- Gets the RPC constant from the code.
-- @tparam number code
-- @treturn string
function Debug:RPCCodeToString(code) -- luacheck: only
    for k, v in pairs(RPC) do
        if v == code then
            return "RPC." .. k
        end
    end
end

--- Prints
-- @section prints

--- Prints `SendRPCToServer()`.
--
-- Uses `SendRPCToServerString`.
--
-- @tparam any ...
function Debug:DebugSendRPCToServer(...)
    self:DebugString("[rpc]", self:SendRPCToServerString(...))
end

--- Submodules
-- @section submodules

--- Returns `SendRPCToServer()` string.
-- @tparam number code RPC code
-- @tparam any ...
function Debug:SendRPCToServerString(code, ...)
    local rpc = self:RPCCodeToString(code)
    local params = { ... }
    if #params == 0 then
        return string.format("SendRPCToServer(%s)", rpc)
    elseif rpc == "RPC.UseItemFromInvTile" or rpc == "RPC.ActionButton" then
        local action = self:ActionCodeToString(params[1])
        table.remove(params, 1)
        return string.format(
            "SendRPCToServer(%s, %s, %s)",
            rpc,
            action,
            self:ConcatParameters(params)
        )
    else
        return string.format("SendRPCToServer(%s, %s)", rpc, self:ConcatParameters(params))
    end
end

--- Lifecycle
-- @section lifecycle

--- Initializes when the game is initialized.
--
-- Initializes the corresponding `DebugEvents` and `DebugGlobals` debug classes for debugging events and
-- globals respectively.
function Debug:DoInitGame()
    if not self.events then
        self.events = DebugEvents(self)
    end

    if not self.globals then
        self.globals = DebugGlobals(self)
    end

    self:DebugInit(tostring(self), "(DoInitGame)")
end

--- Initializes when the player controller is initialized.
--
-- Initializes the corresponding `DebugPlayerController` debug class for debugging some its methods.
--
-- @tparam table playercontroller Player controller
function Debug:DoInitPlayerController(playercontroller)
    if not self.playercontroller then
        self.playercontroller = DebugPlayerController(self)
    end

    self.playercontroller:OverrideMouseClicks(playercontroller)
    self.playercontroller:OverrideRemotes(playercontroller)
    self:DebugInit(tostring(self), "(DoInitPlayerController)")
end

return Debug
