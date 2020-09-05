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
-- @release 0.1.0
----
require "class"

local Events = require "devtools/debug/events"
local Globals = require "devtools/debug/globals"
local PlayerController = require "devtools/debug/playercontroller"

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

--- General
-- @section general

--- Checks if debugging is enabled.
-- @treturn boolean
function Debug:IsEnabled()
    return self.is_enabled
end

--- Sets debugging state.
-- @tparam boolean enable
function Debug:SetIsEnabled(enable)
    self.is_enabled = enable
end

--- Enables debugging.
function Debug:Enable()
    self.is_enabled = true
end

--- Disables debugging.
function Debug:Disable()
    self.is_enabled = false
end

--- Checks if named debugging is enabled.
-- @tparam string name
-- @treturn boolean
function Debug:IsDebug(name)
    return self.is_debug[name] and true or false
end

--- Adds named debugging state.
-- @tparam string name
-- @tparam boolean enable
function Debug:SetIsDebug(name, enable)
    enable = enable and true or false
    self.is_debug[name] = enable
end

--- Prints
-- @section prints

--- Prints the provided strings.
-- @tparam string ... Strings
function Debug:DebugString(...) -- luacheck: only
    if self.is_enabled then
        local task = scheduler:GetCurrentTask()
        local msg = string.format("[%s]", self.modname)

        if task then
            msg = msg .. " [" .. task.id .. "]"
        end

        for i = 1, arg.n do
            msg = msg .. " " .. tostring(arg[i])
        end

        print(msg)
    end
end

--- Prints the provided strings.
--
-- Unlike the `DebugString` it also starts the timer which later can be stopped using the
-- corresponding `DebugStringStop` method.
--
-- @tparam string ... Strings
function Debug:DebugStringStart(...)
    self.start_time = os.clock()
    self:DebugString(...)
end

--- Prints the provided strings.
--
-- Stops the timer started earlier by the `DebugStringStart` method and prints the provided strings
-- alongside with the time.
--
-- @tparam string ... Strings
function Debug:DebugStringStop(...)
    if self.start_time then
        local arg = { ... }
        local last = string.gsub(arg[#arg], "%.$", "") .. "."
        arg[#arg] = last
        table.insert(arg, string.format("Time: %0.4f", os.clock() - self.start_time))
        self:DebugString(unpack(arg))
        self.start_time = nil
    else
        self:DebugString(...)
    end
end

--- Prints an initialized method name.
-- @tparam string name Method name
function Debug:DebugInit(name)
    self:DebugString("[life_cycle]", "Initialized", name)
end

--- Prints an initialized method name.
-- @tparam string name Method name
function Debug:DebugTerm(name)
    self:DebugString("[life_cycle]", "Terminated", name)
end

--- Prints the provided error strings.
--
-- Acts just like the `DebugString` but also prepends the "[error]" string.
--
-- @tparam string ... Strings
function Debug:DebugError(...)
    self:DebugString("[error]", ...)
end

--- Prints all mod configurations.
--
-- Should be used to debug mod configurations.
function Debug:DebugModConfigs()
    local config = KnownModIndex:GetModConfigurationOptions_Internal(self.modname, false)
    if config and type(config) == "table" then
        for _, v in pairs(config) do
            if v.name == "" then
                self:DebugString("[config]", "[section]", v.label)
            else
                self:DebugString(
                    "[config]",
                    v.label .. ":",
                    v.saved == nil and v.default or v.saved
                )
            end
        end
    end
end

--- Prints (project)
-- @section prints-project

--- Prints an activated event listener.
-- @tparam string name Event listener name
function Debug:DebugActivateEventListener(name)
    self:DebugString("[event]", "[" .. name .. "]", "Activated")
end

--- Prints a deactivated event listener.
-- @tparam string name Event listener name
function Debug:DebugDeactivateEventListener(name)
    self:DebugString("[event]", "[" .. name .. "]", "Deactivated")
end

--- Prints a non-admin error.
-- @tparam string name Method name
function Debug:DebugErrorNotAdmin(name)
    self:DebugError(name ~= nil and name .. ":" or nil, "not an admin")
end

--- Prints a not in the cave world error.
-- @tparam string name Method name
function Debug:DebugErrorNotInCave(name)
    self:DebugError(name ~= nil and name .. ":" or nil, "not in the cave world")
end

--- Prints a not in the forest world error.
-- @tparam string name Method name
function Debug:DebugErrorNotInForest(name)
    self:DebugError(name ~= nil and name .. ":" or nil, "not in the forest world")
end

--- Prints a not in the forest world error.
--
-- Acts just like the `DebugString` but also prepends the `ConsoleCommandPlayer()` player name.
--
-- @tparam string ... Strings
function Debug:DebugSelectedPlayerString(...)
    if self.is_enabled then
        local player = ConsoleCommandPlayer()
        self:DebugString("(" .. player:GetDisplayName() .. ")", ...)
    end
end

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
    return self.events
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
