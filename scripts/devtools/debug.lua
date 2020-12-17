----
-- Debugging.
--
-- Includes different debugging-related stuff.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod Debug
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
require "class"

local Events = require "devtools/debug/events"
local Globals = require "devtools/debug/globals"
local PlayerController = require "devtools/debug/playercontroller"
local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam string modname Mod name
-- @usage local debug = Debug(modname)
local Debug = Class(function(self, modname)
    self:DoInit(modname)
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

--- Gets `Events` debug class.
-- @treturn table
function Debug:GetEvents()
    return self.events
end

--- Gets `Globals` debug class.
-- @treturn table
function Debug:GetGlobals()
    return self.globals
end

--- Gets `PlayerController` debug class.
-- @treturn table
function Debug:GetPlayerController()
    return self.playercontroller
end

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

--- Initializes.
--
-- Sets empty fields and adds debug functions.
--
-- @tparam string modname
function Debug:DoInit(modname)
    SDK.Debug.AddMethods(self)

    -- general
    self.is_debug = {}
    self.is_enabled = false
    self.modname = modname
    self.name = "Debug"
    self.start_time = nil

    -- submodules
    self.events = nil
    self.globals = nil
    self.playercontroller = nil

    -- other
    self:DebugInit(self.name)
end

--- Initializes when the game is initialized.
--
-- Initializes the corresponding `Events` and `Globals` debug classes for debugging events and
-- globals respectively.
function Debug:DoInitGame()
    if not self.events then
        self.events = Events(self)
    end

    if not self.globals then
        self.globals = Globals(self)
    end

    self:DebugInit(self.name, "(DoInitGame)")
end

--- Initializes when the player controller is initialized.
--
-- Initializes the corresponding `PlayerController` debug class for debugging some its methods.
--
-- @tparam table playercontroller Player controller
function Debug:DoInitPlayerController(playercontroller)
    if not self.playercontroller then
        self.playercontroller = PlayerController(self)
    end

    self.playercontroller:OverrideMouseClicks(playercontroller)
    self.playercontroller:OverrideRemotes(playercontroller)
    self:DebugInit(self.name, "(DoInitPlayerController)")
end

return Debug
