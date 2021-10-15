----
-- Debug events.
--
-- Includes events debugging functionality as a part of `Debug`. Shouldn't be used on its own.
--
-- **Source Code:** [https://github.com/dstmodders/dst-mod-dev-tools](https://github.com/dstmodders/dst-mod-dev-tools)
--
-- @classmod DebugEvents
-- @see Debug
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local SDK = require "devtools/sdk/sdk/sdk"

--- Helpers
-- @section class

local function DebugEvent(name, value)
    print(string.format("[debug] [event] [%s] %s", name, value))
end

local function CheckIfAlreadyActivated(self, fn_name, activated)
    local count = SDK.Utils.Table.Count(activated)
    if count > 0 then
        self:DebugError(
            string.format("%s:%s():", tostring(self), fn_name),
            string.format("already %d activated, deactivate first", count)
        )
    end
    return count > 0
end

local function CheckIfAlreadyDeactivated(self, fn_name, activated)
    local count = SDK.Utils.Table.Count(activated)
    if count == 0 then
        self:DebugError(
            string.format("%s:%s():", tostring(self), fn_name),
            string.format("already deactivated, activate first", count)
        )
    end
    return count == 0
end

local function Activate(self, name, entity)
    local callback
    local result = {}
    for event, _ in pairs(entity.event_listeners) do
        callback = function()
            DebugEvent(name, event)
        end

        entity:ListenForEvent(event, callback)
        result[event] = callback
    end

    self:DebugString(
        "Activated debugging of the",
        SDK.Utils.Table.Count(result),
        name,
        "event listeners"
    )

    return result
end

local function Deactivate(self, name, entity, activated)
    local count = SDK.Utils.Table.Count(activated)

    for event, callback in pairs(activated) do
        entity:RemoveEventCallback(event, callback)
    end

    self:DebugString("Deactivated debugging of the", count, name, "event listeners")

    return {}
end

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam Debug debug
-- @usage local events = DebugEvents(debug)
local DebugEvents = Class(function(self, debug)
    SDK.Debug.AddMethods(self)
    SDK.Method.SetClass(self).AddToString("DebugEvents")

    -- general
    self.debug = debug

    -- player
    self.activated_player = {}
    self.activated_player_classified = {}

    -- world
    self.activated_world = {}

    -- tests
    if _G.MOD_DEV_TOOLS_TEST then
        self._Activate = Activate
        self._CheckIfAlreadyActivated = CheckIfAlreadyActivated
        self._CheckIfAlreadyDeactivated = CheckIfAlreadyDeactivated
        self._Deactivate = Deactivate
        self._DebugEvent = DebugEvent
    end

    -- other
    self:DebugInit("Debug (DebugEvents)")
end)

--- Player
-- @section player

--- Activates `ThePlayer`.
function DebugEvents:ActivatePlayer()
    local fn_name = "ActivatePlayer"
    local name = "ThePlayer"

    if not ThePlayer
        or not ThePlayer.event_listeners
        or SDK.Utils.Table.Count(ThePlayer.event_listeners) == 0
        or CheckIfAlreadyActivated(self, fn_name, self.activated_player)
    then
        return false
    end

    self.activated_player = Activate(self, name, ThePlayer)

    return true
end

--- Deactivates `ThePlayer`.
function DebugEvents:DeactivatePlayer()
    local fn_name = "DeactivatePlayer"
    local name = "ThePlayer"

    if not ThePlayer or CheckIfAlreadyDeactivated(self, fn_name, self.activated_player) then
        return false
    end

    self.activated_player = Deactivate(self, name, ThePlayer, self.activated_player)

    return true
end

--- Activate `ThePlayer.player_classified`.
function DebugEvents:ActivatePlayerClassified()
    local fn_name = "ActivatePlayerClassified"
    local name = "ThePlayer.player_classified"

    if not ThePlayer
        or not ThePlayer.player_classified
        or not ThePlayer.player_classified.event_listeners
        or SDK.Utils.Table.Count(ThePlayer.player_classified.event_listeners) == 0
        or CheckIfAlreadyActivated(self, fn_name, self.activated_player_classified)
    then
        return false
    end

    self.activated_player_classified = Activate(self, name, ThePlayer.player_classified)

    return true
end

--- Deactivates `ThePlayer.player_classified`.
function DebugEvents:DeactivatePlayerClassified()
    local fn_name = "DeactivatePlayerClassified"
    local name = "ThePlayer.player_classified"

    if not ThePlayer
        or CheckIfAlreadyDeactivated(self, fn_name, self.activated_player_classified)
    then
        return false
    end

    self.activated_player_classified = Deactivate(
        self,
        name,
        ThePlayer.player_classified,
        self.activated_player_classified
    )

    return true
end

--- World
-- @section

--- Player
-- @section player

--- Activates `TheWorld`.
function DebugEvents:ActivateWorld()
    local fn_name = "ActivateWorld"
    local name = "TheWorld"

    if not TheWorld
        or not TheWorld.event_listeners
        or SDK.Utils.Table.Count(TheWorld.event_listeners) == 0
        or CheckIfAlreadyActivated(self, fn_name, self.activated_world)
    then
        return false
    end

    self.activated_world = Activate(self, name, TheWorld)

    return true
end

--- Deactivates `TheWorld`.
function DebugEvents:DeactivateWorld()
    local fn_name = "DeactivateWorld"
    local name = "TheWorld"

    if not TheWorld or CheckIfAlreadyDeactivated(self, fn_name, self.activated_world) then
        return false
    end

    self.activated_world = Deactivate(self, name, TheWorld, self.activated_world)

    return true
end

return DebugEvents
