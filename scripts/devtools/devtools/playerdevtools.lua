----
-- General player tools.
--
-- Extends `devtools.DevTools` and includes different player functionality. Acts as a layer to all
-- other player-specific methods defined in the corresponding subclasses. Besides, it also includes
-- some general player-specific methods.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.player
--
-- During initialization it adds corresponding 5 subclasses which can be accessed directly through
-- the global `DevTools` as well:
--
--    DevTools.player.console
--    DevTools.player.crafting
--    DevTools.player.inventory
--    DevTools.player.map
--    DevTools.player.vision
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod devtools.PlayerDevTools
-- @see DevTools
-- @see devtools.DevTools
-- @see devtools.player.ConsoleDevTools
-- @see devtools.player.CraftingDevTools
-- @see devtools.player.InventoryDevTools
-- @see devtools.player.MapDevTools
-- @see devtools.player.VisionDevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
require "class"
require "consolecommands"

local ConsolePlayerDevTools = require "devtools/devtools/player/consoledevtools"
local CraftingPlayerDevTools = require "devtools/devtools/player/craftingdevtools"
local DevTools = require "devtools/devtools/devtools"
local InventoryPlayerDevTools = require "devtools/devtools/player/inventorydevtools"
local MapPlayerDevTools = require "devtools/devtools/player/mapdevtools"
local SDK = require "devtools/sdk/sdk/sdk"
local Utils = require "devtools/utils"
local VisionPlayerDevTools = require "devtools/devtools/player/visiondevtools"

-- event listeners
local OnWereModeDirty

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam EntityScript inst
-- @tparam devtools.WorldDevTools world
-- @tparam DevTools devtools
-- @usage local playerdevtools = PlayerDevTools(ThePlayer, world, devtools)
local PlayerDevTools = Class(DevTools, function(self, inst, world, devtools)
    DevTools._ctor(self, "PlayerDevTools", devtools)

    -- general
    self.controller = nil
    self.inst = inst
    self.is_fake_teleport = false
    self.is_move_button_down = false
    self.ismastersim = world.inst.ismastersim
    self.speech = nil
    self.wereness_mode = nil
    self.world = world

    -- god mode
    self.god_mode_players = {}

    -- selection
    self.selected_client = ConsoleCommandPlayer()
    self.selected_server = nil

    -- speech
    if inst and inst.prefab then
        local filename = "speech_" .. inst.prefab
        if kleifileexists("scripts/" .. filename .. ".lua") then
            self.speech = require(filename)
        end
    end

    -- submodules (order-dependent)
    self.console = ConsolePlayerDevTools(self, devtools)
    self.inventory = InventoryPlayerDevTools(self, devtools)
    self.crafting = CraftingPlayerDevTools(self, devtools)
    self.vision = VisionPlayerDevTools(self, devtools)
    self.map = MapPlayerDevTools(self, devtools)

    if inst and inst:HasTag("wereness") then
        OnWereModeDirty = function(_inst)
            self.wereness_mode = _inst.weremode:value()
        end

        self:DebugActivateEventListener("weremodedirty")
        inst:ListenForEvent("weremodedirty", OnWereModeDirty)
    end

    -- self
    self:DoInit()
end)

--- General
-- @section general

--- Gets `ThePlayer`.
-- @treturn table
function PlayerDevTools:GetPlayer()
    return self.inst
end

--- Gets character speech.
-- @treturn table
function PlayerDevTools:GetSpeech()
    return self.speech
end

--- Gets wereness mode.
--
-- Is set when the owner is playing as Woodie and the "weremodedirty" event is triggered.
--
-- @treturn number
function PlayerDevTools:GetWerenessMode()
    return self.wereness_mode
end

--- Checks if the move button is down.
--
-- Returns the value set earlier by `SetIsMoveButtonDown`.
--
-- @treturn boolean
function PlayerDevTools:IsMoveButtonDown()
    return self.is_move_button_down
end

--- Sets the move button down state.
--
-- This setter is called in the **modmain** through the `PlayerController` hook.
--
-- @tparam boolean down
function PlayerDevTools:SetIsMoveButtonDown(down)
    self.is_move_button_down = down
end

--- Checks if the player is sinking.
-- @tparam[opt] EntityScript player Player instance (the owner by default)
-- @treturn boolean
function PlayerDevTools:IsSinking(player)
    player = player ~= nil and player or self.inst
    if player and player.AnimState and player.AnimState.IsCurrentAnimation then
        return player.AnimState:IsCurrentAnimation("sink")
            or player.AnimState:IsCurrentAnimation("plank_hop")
    end
end

--- Checks if the player is a ghost.
-- @tparam[opt] EntityScript player Player instance (the owner by default)
-- @treturn boolean
function PlayerDevTools:IsGhost(player)
    player = player ~= nil and player or self.inst
    return player and player.HasTag and player:HasTag("playerghost")
end

--- Checks if the player is platform jumping.
-- @tparam[opt] EntityScript player Player instance (the owner by default)
-- @treturn boolean
function PlayerDevTools:IsPlatformJumping(player)
    player = player ~= nil and player or self.inst
    return player and player.HasTag and player:HasTag("ignorewalkableplatforms")
end

--- Changes current times cale.
-- @tparam number amount Amount to change between -4 to 4.
-- @tparam boolean is_fixed Should it be fixed without increasing/decreasing?
function PlayerDevTools:ChangeTimeScale(amount, is_fixed)
    local time_scale
    time_scale = is_fixed and amount or TheSim:GetTimeScale() + amount
    time_scale = time_scale < 0 and 0 or time_scale
    time_scale = time_scale >= 4 and 4 or time_scale
    print(amount, time_scale)
    TheSim:SetTimeScale(time_scale)
    if not self.ismastersim then
        self.console:SetTimeScale(time_scale)
    end
end

--- God Mode
-- @section god-mode

--- Gets a list of players in god mode.
-- @treturn table
function PlayerDevTools:GetGodModePlayers()
    return self.god_mode_players
end

--- Checks if a player is in god mode.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn boolean
function PlayerDevTools:IsGodMode(player)
    player = player ~= nil and player or self:GetSelected()

    if SDK.Player.IsAdmin() then
        if player
            and player.components
            and player.components.health
            and player.components.health.invincible ~= nil
        then
            return player.components.health.invincible
        end

        if player then
            for _, v in pairs(self.god_mode_players) do
                if v == player.userid then
                    return true
                end
            end
        end

        return false
    end
end

--- Toggles player god mode.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn boolean
function PlayerDevTools:ToggleGodMode(player)
    player = player ~= nil and player or self:GetSelected()

    if not player or not SDK.Player.IsAdmin() then
        self:DebugErrorNotAdmin("PlayerDevTools:ToggleGodMode()")
    end

    local is_god_mode = self:IsGodMode(player)
    if is_god_mode ~= nil then
        for k, v in pairs(self.god_mode_players) do
            if v == player.userid then
                table.remove(self.god_mode_players, k)
            end
        end

        if is_god_mode then
            Utils.ConsoleRemote(
                'LookupPlayerInstByUserID("%s").components.health:SetInvincible(false)',
                { player.userid }
            )

            self:DebugSelectedPlayerString("God Mode is disabled")

            return false
        elseif is_god_mode == false then
            Utils.ConsoleRemote(
                'LookupPlayerInstByUserID("%s").components.health:SetInvincible(true)',
                { player.userid }
            )

            table.insert(self.god_mode_players, player.userid)
            self:DebugSelectedPlayerString("God Mode is enabled")

            return true
        end
    end
end

--- HUD
-- @section hud

--- Gets HUD.
-- @treturn table
function PlayerDevTools:GetHUD()
    return self.inst and self.inst.HUD
end

--- Checks if the HUD chat is open.
-- @treturn boolean
function PlayerDevTools:IsHUDChatInputScreenOpen()
    local hud = self:GetHUD()
    return hud and hud:IsChatInputScreenOpen()
end

--- Checks if the HUD console is open.
-- @treturn boolean
function PlayerDevTools:IsHUDConsoleScreenOpen()
    local hud = self:GetHUD()
    return hud and hud:IsConsoleScreenOpen()
end

--- Checks if the HUD writable screen is active.
-- @treturn boolean
function PlayerDevTools:IsHUDWritableScreenActive()
    local screen = TheFrontEnd:GetActiveScreen()
    if screen then
        local hud = self:GetHUD()
        if hud and screen == hud.writeablescreen then
            return true
        end
    end
    return false
end

--- Light Watcher
-- @section light-watcher

--- Checks if Grue (Charlie) can attack the owner.
-- @treturn boolean
function PlayerDevTools:CanGrueAttack()
    return not (self:IsGodMode()
        or SDK.Player.IsInLight()
        or self.inventory:HasEquippedMoggles()
        or self:IsGhost())
end

--- Player
-- @section player

--- Gets the Max Health value.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn number
function PlayerDevTools:GetMaxHealthPercent(player)
    player = player ~= nil and player or self:GetSelected()
    if player and player.replica and player.replica.health then
        return (1 - player.replica.health:GetPenaltyPercent()) * 100
    end
end

--- Gets the Moisture value.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn number
function PlayerDevTools:GetMoisturePercent(player)
    player = player ~= nil and player or self:GetSelected()
    return player and player.GetMoisture and player:GetMoisture()
end

--- Gets the Temperature value.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn number
function PlayerDevTools:GetTemperature(player)
    player = player ~= nil and player or self:GetSelected()
    return player and player.GetTemperature and player:GetTemperature()
end

--- Gets the Wereness value.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn number
function PlayerDevTools:GetWerenessPercent(player)
    player = player ~= nil and player or self:GetSelected()
    if player.player_classified and player.player_classified.currentwereness then
        return player.player_classified.currentwereness:value()
    end
end

--- Selection
-- @section selection

--- Gets the selected player.
--
-- This is a convenience method returning:
--
--    ConsoleCommandPlayer()
--
-- @treturn table
function PlayerDevTools:GetSelected() -- luacheck: only
    return ConsoleCommandPlayer()
end

--- Selects the player.
-- @tparam EntityScript player Player instance
-- @treturn boolean
function PlayerDevTools:Select(player)
    local name = player:GetDisplayName()

    SetDebugEntity(player)
    self.selected_client = player
    self.devtools.labels:AddSelected(player)

    if self.ismastersim then
        self:DebugString("Selected", name)
    elseif SDK.Player.IsAdmin() then
        Utils.ConsoleRemote('SetDebugEntity(LookupPlayerInstByUserID("%s"))', { player.userid })
        self.selected_server = player
        self:DebugString("[client]", "Selected", name)
        self:DebugString("[server]", "Selected", name)
    else
        self:DebugString("[client]", "Selected", name)
    end

    return true
end

--- Checks if selected player is synced.
--
-- Verifies if the same player is selected of both client and server.
--
-- @treturn boolean
function PlayerDevTools:IsSelectedInSync()
    if self.ismastersim then
        return self.selected_client ~= nil
    end
    return self.selected_client == self.selected_server
end

--- Teleport
-- @section teleport

--- Checks fake teleport state.
-- @treturn boolean
function PlayerDevTools:IsFakeTeleport()
    return self.is_fake_teleport
end

--- Sets fake teleport state.
-- @tparam boolean is_fake_teleport
function PlayerDevTools:SetIsFakeTeleport(is_fake_teleport)
    self.is_fake_teleport = is_fake_teleport
end

--- Teleport a currently selected player.
--
-- Supports teleporting on the map as well.
--
-- @treturn boolean
function PlayerDevTools:Teleport()
    local player = self:GetSelected()
    if not player then
        return false
    end

    local screen = TheFrontEnd:GetActiveScreen()
    if screen.minimap then
        local screen_pos = TheInput:GetScreenPosition()
        local widget_pos = screen:ScreenPosToWidgetPos(screen_pos)
        local world_pos = screen:WidgetPosToMapPos(widget_pos)
        local x, y, _ = screen.minimap:MapPosToWorldPos(world_pos:Get())
        if not self.is_fake_teleport then
            if self.ismastersim and SDK.Player.IsAdmin() then
                player.Physics:Teleport(x, 0, y)
                return true
            elseif SDK.Player.IsAdmin() then
                Utils.ConsoleRemote(
                    'player = LookupPlayerInstByUserID("%s") player.Physics:Teleport(%d, 0, %d)',
                    { player.userid, x, y }
                )
                return true
            end
        else
            player.Physics:Teleport(x, 0, y)
            return true
        end
    elseif not self.is_fake_teleport and self.ismastersim and SDK.Player.IsAdmin() then
        player.Physics:Teleport(TheInput:GetWorldPosition():Get())
        return true
    elseif not self.is_fake_teleport and SDK.Player.IsAdmin() then
        local pos = TheInput:GetWorldPosition()
        Utils.ConsoleRemote(
            'player = LookupPlayerInstByUserID("%s") player.Physics:Teleport(%d, 0, %d)',
            { player.userid, pos.x, pos.z }
        )
        return true
    elseif self.is_fake_teleport then
        player.Physics:Teleport(TheInput:GetWorldPosition():Get())
        return true
    end

    return false
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function PlayerDevTools:DoInit()
    DevTools.DoInit(self, self.devtools, "player", {
        GetSelectedPlayer = "GetSelected",
        SelectPlayer = "Select",

        -- general
        "GetPlayer",
        "GetSpeech",
        "GetWerenessMode",
        "IsMoveButtonDown",
        --"SetIsMoveButtonDown",
        "IsSinking",
        "IsGhost",
        "IsPlatformJumping",

        -- god mode
        "GetGodModePlayers",
        "IsGodMode",
        "ToggleGodMode",

        -- hud
        "GetHUD",
        "IsHUDChatInputScreenOpen",
        "IsHUDConsoleScreenOpen",
        "IsHUDWritableScreenActive",

        -- lightwatcher
        "CanGrueAttack",

        -- player
        "GetMaxHealthPercent",
        "GetMoisturePercent",
        "GetTemperature",
        "GetWerenessPercent",

        -- selection
        "IsSelectedInSync",

        -- teleport
        "Teleport",
    })
end

--- Terminates.
function PlayerDevTools:DoTerm()
    if self.crafting then
        self.crafting.DoTerm(self.crafting)
    end

    if self.console then
        self.console.DoTerm(self.console)
    end

    if self.map then
        self.map.DoTerm(self.map)
    end

    if self.vision then
        self.vision.DoTerm(self.vision)
    end

    if self.inst then
        if OnWereModeDirty then
            self.inst:RemoveEventCallback("weremodedirty", OnWereModeDirty)
            self:DebugDeactivateEventListener("weremodedirty")
        end
    end

    DevTools.DoTerm(self)
end

return PlayerDevTools
