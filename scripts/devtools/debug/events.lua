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
-- @release 0.1.0-alpha
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

    -- event listeners
    self.activated_player = {}
    self.activated_player_classified = {}

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

--- General
-- @section general

--- Activates player.
-- @tparam EntityScript player Player instance
function Events:ActivatePlayer(player)
    local fn_name = "ActivatePlayer"
    local name = "ThePlayer"

    if not player
        or not player.event_listeners
        or Utils.Table.Count(player.event_listeners) == 0
        or CheckIfAlreadyActivated(self, fn_name, self.activated_player)
    then
        return false
    end

    self.activated_player = Activate(self, name, player)

    return true
end

--- Deactivates player.
-- @tparam EntityScript player Player instance
function Events:DeactivatePlayer(player)
    local fn_name = "DeactivatePlayer"
    local name = "ThePlayer"

    if not player or CheckIfAlreadyDeactivated(self, fn_name, self.activated_player) then
        return false
    end

    self.activated_player = Deactivate(self, name, player, self.activated_player)

    return true
end

--- Activate player classified.
-- @tparam EntityScript player Player instance
function Events:ActivatePlayerClassified(player)
    local fn_name = "ActivatePlayerClassified"
    local name = "ThePlayer.player_classified"

    if not player
        or not player.player_classified
        or not player.player_classified.event_listeners
        or Utils.Table.Count(player.player_classified.event_listeners) == 0
        or CheckIfAlreadyActivated(self, fn_name, self.activated_player_classified)
    then
        return false
    end

    self.activated_player_classified = Activate(self, name, player.player_classified)

    return true
end

--- Deactivates player classified.
-- @tparam EntityScript player Player instance
function Events:DeactivatePlayerClassified(player)
    local fn_name = "DeactivatePlayerClassified"
    local name = "ThePlayer.player_classified"

    if not player or CheckIfAlreadyDeactivated(self, fn_name, self.activated_player_classified) then
        return false
    end

    self.activated_player_classified = Deactivate(
        self,
        name,
        player.player_classified,
        self.activated_player_classified
    )

    return true
end

return Events
