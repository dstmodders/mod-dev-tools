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
-- @see Labels
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.2.0
----
require "class"
require "consolecommands"
require "devtools/constants"

local API = require "devtools/api"
local Labels = require "devtools/labels"
local PlayerDevTools = require "devtools/devtools/playerdevtools"
local Submenu = require "devtools/menu/submenu"
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

--- Resets game.
-- @treturn boolean
function DevTools:Reset()
    if not InGamePlay() or not self.world then
        self:DebugString("Resetting...")
        StartNextInstance()
        return true
    end

    if self.player and not self.player:IsAdmin() then
        self:DebugErrorNotAdmin("DevTools:Reset()")
        return false
    end

    if self.world.ismastersim then
        self:DebugString("Resetting local game...")
        TheNet:SendWorldRollbackRequestToServer(0)
    else
        self:DebugString("Resetting remote game...")
        Utils.ConsoleRemote("TheNet:SendWorldRollbackRequestToServer(0)")
    end

    return true
end

--- API
-- @section api

--- Gets API.
-- @treturn API
function DevTools:GetAPI()
    return self.api
end

--- Gets submenu data.
-- @treturn table
function DevTools:GetSubmenusData()
    return self.submenus_data
end

--- Adds submenu data.
-- @tparam table data
function DevTools:AddSubmenusData(data)
    table.insert(self.submenus_data, data)
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

--- Submenu
-- @section submenu

local function SetOnAddToRootFn(on_add_to_root_fn, submenu, root)
    if type(on_add_to_root_fn) == "function" then
        submenu:SetOnAddToRootFn(on_add_to_root_fn)
    elseif type(on_add_to_root_fn) == "table" then
        local result = true

        for _, fn in pairs(on_add_to_root_fn) do
            submenu:SetOnAddToRootFn(fn)

            if type(fn) == "function" then
                result = submenu:OnOnAddToRoot(root)
            end

            if result == false then
                break
            end
        end

        submenu:SetOnAddToRootFn(function()
            return result
        end)
    else
        submenu:SetOnAddToRootFn(nil)
    end
end

--- Creates a submenu instance from data.
-- @tparam table data
-- @tparam table root
-- @treturn menu.Submenu
-- @usage local devtools = DevTools()
-- local submenu = devtools:CreateSubmenuInstFromData({
--     label = "Map",
--     name = "MapSubmenu",
--     on_init_fn = function(self, devtools)
--         self.map = devtools.player and devtools.player.map
--         self.player = devtools.player
--         self.world = devtools.world
--     end,
--     on_add_to_root_fn = {
--         MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
--         MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_MASTER_SIM,
--     },
--     options = {
--         {
--             type = MOD_DEV_TOOLS.OPTION.ACTION,
--             options = {
--                 label = "Reveal",
--                 on_accept_fn = function(_, submenu)
--                     submenu.map:Reveal()
--                     submenu.screen:Close()
--                 end,
--             },
--         },
--         { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
--         {
--             type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
--             options = {
--                 label = "Clearing",
--                 get = {
--                     src = function(_, submenu)
--                         return submenu.world
--                     end,
--                     name = "IsMapClearing",
--                 },
--                 set = {
--                     src = function(_, submenu)
--                         return submenu.world
--                     end,
--                     name = "ToggleMapClearing",
--                 },
--             },
--         },
--         {
--             type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
--             options = {
--                 label = "Fog of War",
--                 get = {
--                     src = function(_, submenu)
--                         return submenu.world
--                     end,
--                     name = "IsMapFogOfWar",
--                 },
--                 set = {
--                     src = function(_, submenu)
--                         return submenu.world
--                     end,
--                     name = "ToggleMapFogOfWar",
--                 },
--             },
--         },
--     },
-- })
function DevTools:CreateSubmenuInstFromData(data, root)
    local submenu = Submenu(self, root, data.label, data.name, data.menu_idx)

    if type(data.on_init_fn) == "function" then
        submenu:SetOnInitFn(data.on_init_fn)
        submenu:OnInit()
    end

    local options = data.options

    if type(options) == "function" then
        options = options(submenu)
    end

    if type(options) == "table" and #options > 0 then
        for _, option in pairs(options) do
            SetOnAddToRootFn(option.on_add_to_root_fn, submenu, root)

            if option.type == MOD_DEV_TOOLS.OPTION.ACTION then
                submenu:AddActionOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.CHECKBOX then
                submenu:AddCheckboxOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.CHOICES then
                submenu:AddChoicesOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.DIVIDER then
                submenu:AddDividerOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.NUMERIC then
                submenu:AddNumericOption(option.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.SUBMENU then
                self:CreateSubmenuInstFromData(option.options, submenu.options)
            elseif option.type == MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX then
                submenu:AddToggleCheckboxOption(option.options)
            end
        end
    end

    SetOnAddToRootFn(data.on_add_to_root_fn, submenu)

    submenu:AddToRoot()

    return submenu
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function DevTools:__tostring()
    return self.name
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
    Utils.Debug.AddMethods(self)

    -- general
    self.api = API(self)
    self.debug = debug
    self.inst = nil
    self.is_in_character_select = false
    self.ismastersim = nil
    self.labels = Labels(self)
    self.modname = modname
    self.name = "DevTools"
    self.player = nil
    self.screen = nil -- set in DevToolsScreen:DoInit()
    self.submenus_data = {}
    self.world = nil
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
