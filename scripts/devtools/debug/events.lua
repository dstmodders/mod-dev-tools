----
-- Debug events.
--
-- Includes events debugging functionality as a part of `Debug`. Shouldn't be used on its own.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod debug.Events
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.6.0-alpha
----
require "class"

local Utils = require "devtools/utils"

--- Helpers
-- @section class

local function DebugEvent(name, value)
    print(string.format("[debug] [event] [%s] %s", name, value))
end

local function CheckIfAlreadyActivated(self, fn_name, activated)
    local count = Utils.Table.Count(activated)
    if count > 0 then
        self.debug:DebugError(
            string.format("%s:%s():", self.name, fn_name),
            string.format("already %d activated, deactivate first", count)
        )
    end
    return count > 0
end

local function CheckIfAlreadyDeactivated(self, fn_name, activated)
    local count = Utils.Table.Count(activated)
    if count == 0 then
        self.debug:DebugError(
            string.format("%s:%s():", self.name, fn_name),
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

    self.debug:DebugString(
        "Activated debugging of the",
        Utils.Table.Count(result),
        name,
        "event listeners"
    )

    return result
end

local function Deactivate(self, name, entity, activated)
    local count = Utils.Table.Count(activated)

    for event, callback in pairs(activated) do
        entity:RemoveEventCallback(event, callback)
    end

    self.debug:DebugString("Deactivated debugging of the", count, name, "event listeners")

    return {}
end

--- Class
-- @section class

--- Constructor.
-- @function _ctor
-- @tparam Debug debug
-- @usage local events = Events(debug)
local Events = Class(function(self, debug)
    -- general
    self.debug = debug
    self.name = "Events"

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
    self.debug:DebugInit("Debug (Events)")
end)

--- Player
-- @section player

--- Activates `ThePlayer`.
function Events:ActivatePlayer()
    local fn_name = "ActivatePlayer"
    local name = "ThePlayer"

    if not ThePlayer
        or not ThePlayer.event_listeners
        or Utils.Table.Count(ThePlayer.event_listeners) == 0
        or CheckIfAlreadyActivated(self, fn_name, self.activated_player)
    then
        return false
    end

    self.activated_player = Activate(self, name, ThePlayer)

    return true
end

--- Deactivates `ThePlayer`.
function Events:DeactivatePlayer()
    local fn_name = "DeactivatePlayer"
    local name = "ThePlayer"

    if not ThePlayer or CheckIfAlreadyDeactivated(self, fn_name, self.activated_player) then
        return false
    end

    self.activated_player = Deactivate(self, name, ThePlayer, self.activated_player)

    return true
end

--- Activate `ThePlayer.player_classified`.
function Events:ActivatePlayerClassified()
    local fn_name = "ActivatePlayerClassified"
    local name = "ThePlayer.player_classified"

    if not ThePlayer
        or not ThePlayer.player_classified
        or not ThePlayer.player_classified.event_listeners
        or Utils.Table.Count(ThePlayer.player_classified.event_listeners) == 0
        or CheckIfAlreadyActivated(self, fn_name, self.activated_player_classified)
    then
        return false
    end

    self.activated_player_classified = Activate(self, name, ThePlayer.player_classified)

    return true
end

--- Deactivates `ThePlayer.player_classified`.
function Events:DeactivatePlayerClassified()
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
function Events:ActivateWorld()
    local fn_name = "ActivateWorld"
    local name = "TheWorld"

    if not TheWorld
        or not TheWorld.event_listeners
        or Utils.Table.Count(TheWorld.event_listeners) == 0
        or CheckIfAlreadyActivated(self, fn_name, self.activated_world)
    then
        return false
    end

    self.activated_world = Activate(self, name, TheWorld)

    return true
end

--- Deactivates `TheWorld`.
function Events:DeactivateWorld()
    local fn_name = "DeactivateWorld"
    local name = "TheWorld"

    if not TheWorld or CheckIfAlreadyDeactivated(self, fn_name, self.activated_world) then
        return false
    end

    self.activated_world = Deactivate(self, name, TheWorld, self.activated_world)

    return true
end

return Events
