----
-- General tools.
--
-- The globally exposed module which can be called directly through the console. Includes indirectly
-- both player and world functionality. Besides including some general methods this class doesn't do
-- much except passing data to the submodules which then add their methods to this class.
--
-- For example, when loading the world only the world-related methods are added. As soon as the
-- owner chooses the character, player-related ones are added as well. When the player decides to
-- leave the game, all earlier added methods are removed.
--
-- This approach is especially handy when playing around in the in-game console as the global
-- `DevTools` may include some methods that can help out in testing some ideas without bothering
-- "diving too deep".
--
-- All world (when available) functionality can be accessed directly as:
--
--    DevTools.world
--
-- All player (when available) functionality can be accessed directly as:
--
--    DevTools.player
--
-- @classmod DevTools
-- @see devtools.PlayerDevTools
-- @see devtools.WorldDevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"
require "consolecommands"

local PlayerDevTools = require "devtools/devtools/playerdevtools"
local Utils = require "devtools/utils"
local WorldDevTools = require "devtools/devtools/worlddevtools"

local DevTools = Class(function(self, modname, debug)
    self:DoInit(modname, debug)
end)

--- Helpers
-- @section helpers

local function GetFnFullName(fn_name)
    return string.format("%s:%s()", "DevTools", fn_name)
end

--- Debugging
-- @section debugging

--- Gets `screens.DevToolsScreen`.
-- @treturn screens.DevToolsScreen
function DevTools:GetScreen()
    return self.screen
end

--- Gets `Debug`.
-- @treturn Debug
function DevTools:GetDebug()
    return self.debug
end

--- General
-- @section general

--- Checks if a user can press our key.
-- @treturn boolean
function DevTools:CanPressKeyInGamePlay()
    local playerdevtools = self.player
    return InGamePlay()
        and playerdevtools
        and not playerdevtools:IsHUDChatInputScreenOpen()
        and not playerdevtools:IsHUDConsoleScreenOpen()
        and not playerdevtools:IsHUDWritableScreenActive()
end

--- Checks if it's a dedicated server game.
-- @treturn boolean
function DevTools:IsDedicated() -- luacheck: only
    return TheNet:IsDedicated()
end

--- Gets character select state.
-- @treturn boolean
function DevTools:IsInCharacterSelect()
    return self.is_in_character_select
end

--- Sets character select state.
-- @tparam boolean is_in_character_select
function DevTools:SetIsInCharacterSelect(is_in_character_select)
    self.is_in_character_select = is_in_character_select
end

--- Gets client table for the user.
-- @tparam table user Player
-- @treturn table
function DevTools:GetClientTableForUser(user) -- luacheck: only
    user = user ~= nil and user or self.inst
    if user and user.userid then
        return TheNet:GetClientTableForUser(user.userid)
    end
end

--- Gets players client table.
-- @treturn table
function DevTools:GetPlayersClientTable() -- luacheck: only
    local clients = TheNet and TheNet.GetClientTable and TheNet:GetClientTable() or {}
    if not TheNet:GetServerIsClientHosted() then
        for i, v in pairs(clients) do
            if v.performance ~= nil then
                table.remove(clients, i) -- remove "host" object
                break
            end
        end
    end
    return clients
end

--- Pausing
-- @section pausing

--- Checks if the world is paused.
-- @treturn boolean
function DevTools:IsPaused() -- luacheck: only
    return TheSim:GetTimeScale() == 0
end

--- Pauses world.
-- @treturn boolean
function DevTools:Pause()
    local playerdevtools = self.player
    if playerdevtools then
        local fn_full_name = GetFnFullName("Pause")
        if self:IsPaused() then
            self:DebugError(fn_full_name .. ": Game is already paused")
            return false
        end

        local consoledevtools = playerdevtools.console
        if consoledevtools then
            local timescale = TheSim:GetTimeScale()
            if consoledevtools:SetTimeScale(0) then
                TheSim:SetTimeScale(0)
                SetPause(true, "console")
                self.timescale = timescale
                self:DebugString("Game is paused")
                return true
            end

            return false
        end
    end
end

--- Unpauses world.
-- @treturn boolean
function DevTools:Unpause()
    local playerdevtools = self.player
    if playerdevtools then
        local fn_full_name = GetFnFullName("Unpause")
        if not self:IsPaused() then
            self:DebugError(fn_full_name .. ": Game is already resumed")
            return false
        end

        local consoledevtools = playerdevtools.console
        if consoledevtools then
            local timescale = self.timescale or 1
            if consoledevtools:SetTimeScale(timescale) then
                TheSim:SetTimeScale(timescale)
                SetPause(false, "console")
                self:DebugString("Game is resumed")
                return true
            end

            return false
        end
    end
end

--- Toggle pause.
-- @treturn boolean
function DevTools:TogglePause()
    if self:IsPaused() then
        return self:Unpause()
    else
        return self:Pause()
    end
end

--- Players
-- @section players

--- Gets all players.
--
-- This is a convenience method returning:
--
--    AllPlayers
--
-- @treturn table `AllPlayers`
function DevTools:GetAllPlayers() -- luacheck: only
    return AllPlayers
end

--- Gets a player by username.
-- @tparam string username
-- @treturn table
function DevTools:GetPlayerByUsername(username)
    for _, v in ipairs(self:GetAllPlayers()) do
        if v:GetDisplayName() == username then
            return v
        end
    end
    return nil
end

--- Labels
-- @section labels

local function AddEntityLabel(self, inst)
    inst.entity:AddLabel()
    inst.Label:SetFont(BODYTEXTFONT)
    inst.Label:SetFontSize(self.labels_font_size)
    inst.Label:SetWorldOffset(0, 2.3, 0)
    inst.Label:Enable(true)
end

--- Sets the labels font size.
-- @tparam number size Font size
function DevTools:SetLabelsFontSize(size)
    self.labels_font_size = size
    for _, inst in pairs(self:GetAllPlayers()) do
        if inst:IsValid() and inst.Label then
            inst.Label:SetFontSize(size)
        end
    end
end

--- Gets labels font size.
-- @treturn number
function DevTools:GetLabelsFontSize()
    return self.labels_font_size
end

--- Sets username labels mode.
-- @tparam boolean|string mode
function DevTools:SetUsernameLabelsMode(mode)
    self.labels_username_mode = mode
    for _, inst in pairs(self:GetAllPlayers()) do
        if inst:IsValid() and inst.Label then
            local client = self:GetClientTableForUser(inst)

            inst.Label:Enable(true)
            inst.Label:SetText(inst.name)

            if mode == "default" then
                inst.Label:SetColour(unpack(WHITE))
            elseif mode == "coloured" and client and client.colour then
                inst.Label:SetColour(unpack(client.colour))
            elseif not mode then
                inst.Label:Enable(false)
            end
        end
    end
end

--- Gets username labels mode.
-- @treturn boolean|string
function DevTools:GetUsernameLabelsMode()
    return self.labels_username_mode
end

--- Adds username label to the player.
-- @tparam table inst Player instance
-- @treturn boolean
function DevTools:AddUsernameLabel(inst)
    AddEntityLabel(self, inst)
    self:SetUsernameLabelsMode(self.labels_username_mode)
end

--- Other
-- @section other

--- Resets game.
-- @treturn boolean
function DevTools:Reset()
    local playerdevtools = self.player
    local worlddevtools = self.world
    if InGamePlay() and playerdevtools and worlddevtools then
        if worlddevtools.ismastersim then
            self:DebugString("Resetting local game...")
            TheNet:SendWorldRollbackRequestToServer(0)
            return true
        elseif playerdevtools:IsAdmin() then
            self:DebugString("Resetting remote game...")
            Utils.ConsoleRemote("TheNet:SendWorldRollbackRequestToServer(0)")
            return true
        end
    else
        self:DebugString("Resetting...")
        StartNextInstance()
        return true
    end
    return false
end

--- Player Controller
-- @section player-controller

--- Does the player controller action.
-- @tparam table pc Player controller
-- @treturn boolean
function DevTools:PlayerControllerDoAction(pc)
    local vision
    local player = self.player
    if player and player.vision then
        vision = player.vision
        if vision then
            return vision:PlayerControllerDoAction(pc)
        end
    end
    return false
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
--
-- Sets empty fields and adds debug functions.
--
-- @tparam string modname
-- @tparam boolean debug
function DevTools:DoInit(modname, debug)
    Utils.AddDebugMethods(self)

    -- general
    self.debug = debug
    self.inst = nil
    self.is_in_character_select = false
    self.ismastersim = nil
    self.modname = modname
    self.name = "DevTools"
    self.player = nil
    self.screen = nil -- set in DevToolsScreen:DoInit()
    self.world = nil

    -- labels
    self.labels_font_size = 18
    self.labels_username_mode = false
end

--- Initializes when the world is initialized.
-- @tparam table inst World instance
function DevTools:DoInitWorld(inst)
    self.world = WorldDevTools(inst, self)
end

--- Initializes when the player is initialized.
-- @tparam table inst Player instance
function DevTools:DoInitPlayer(inst)
    local msg = "Required DevTools.world is missing. Did you forget to DevTools:DoInitWorld()?"
    assert(self.world ~= nil, msg)
    self.player = PlayerDevTools(inst, self.world, self)
end

--- Terminates when the world is terminated.
-- @tparam table inst World instance
function DevTools:DoTermWorld()
    if self.world then
        self.world:DoTerm()
    end
end

--- Terminates when the player is terminated.
-- @tparam table inst Player instance
function DevTools:DoTermPlayer()
    if self.player then
        self.player:DoTerm()
    end
end

return DevTools
