----
-- General player tools.
--
-- Extends `tools.Tools` and includes different player functionality. Acts as a layer to all other
-- player-specific methods defined in the corresponding subclasses. Besides, it also includes some
-- general player-specific methods.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.player
--
-- During initialization it adds corresponding 3 subclasses which can be accessed directly through
-- the global `DevTools` as well:
--
--    DevTools.player.crafting
--    DevTools.player.inventory
--    DevTools.player.vision
--
-- **Source Code:** [https://github.com/dstmodders/dst-mod-dev-tools](https://github.com/dstmodders/dst-mod-dev-tools)
--
-- @classmod tools.PlayerTools
-- @see DevTools
-- @see tools.PlayerCraftingTools
-- @see tools.PlayerInventoryTools
-- @see tools.PlayerVisionTools
-- @see tools.Tools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
require "consolecommands"

local DevTools = require "devtools/tools/tools"
local PlayerCraftingTools = require "devtools/tools/playercraftingtools"
local PlayerInventoryTools = require "devtools/tools/playerinventorytools"
local PlayerVisionTools = require "devtools/tools/playervisiontools"
local SDK = require "devtools/sdk/sdk/sdk"

-- event listeners
local OnWereModeDirty

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam EntityScript inst
-- @tparam WorldTools worldtools
-- @tparam DevTools devtools
-- @usage local playertools = PlayerTools(ThePlayer, worldtools, devtools)
local PlayerTools = Class(DevTools, function(self, inst, worldtools, devtools)
    DevTools._ctor(self, "PlayerTools", devtools)

    -- general
    self.controller = nil
    self.inst = inst
    self.is_fake_teleport = false
    self.is_move_button_down = false
    self.speech = nil
    self.wereness_mode = nil
    self.world = worldtools

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
    self.inventory = PlayerInventoryTools(self, devtools)
    self.crafting = PlayerCraftingTools(self, devtools)
    self.vision = PlayerVisionTools(self, devtools)

    if inst and inst:HasTag("wereness") then
        OnWereModeDirty = function(_inst)
            self.wereness_mode = _inst.weremode:value()
        end

        self:DebugString("[event]", "[weremodedirty]", "Activated")
        inst:ListenForEvent("weremodedirty", OnWereModeDirty)
    end

    -- other
    self:DoInit()
end)

--- General
-- @section general

--- Gets `ThePlayer`.
-- @treturn table
function PlayerTools:GetPlayer()
    return self.inst
end

--- Gets character speech.
-- @treturn table
function PlayerTools:GetSpeech()
    return self.speech
end

--- Gets wereness mode.
--
-- Is set when the owner is playing as Woodie and the "weremodedirty" event is triggered.
--
-- @treturn number
function PlayerTools:GetWerenessMode()
    return self.wereness_mode
end

--- Checks if the move button is down.
--
-- Returns the value set earlier by `SetIsMoveButtonDown`.
--
-- @treturn boolean
function PlayerTools:IsMoveButtonDown()
    return self.is_move_button_down
end

--- Sets the move button down state.
--
-- This setter is called in the **modmain** through the `PlayerController` hook.
--
-- @tparam boolean down
function PlayerTools:SetIsMoveButtonDown(down)
    self.is_move_button_down = down
end

--- Checks if the player is platform jumping.
-- @tparam[opt] EntityScript player Player instance (the owner by default)
-- @treturn boolean
function PlayerTools:IsPlatformJumping(player)
    player = player ~= nil and player or self.inst
    return player and player.HasTag and player:HasTag("ignorewalkableplatforms")
end

--- God Mode
-- @section god-mode

--- Gets a list of players in god mode.
-- @treturn table
function PlayerTools:GetGodModePlayers()
    return self.god_mode_players
end

--- Checks if a player is in god mode.
-- @tparam[opt] EntityScript player Player instance (the selected one by default)
-- @treturn boolean
function PlayerTools:IsGodMode(player)
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
function PlayerTools:ToggleGodMode(player)
    player = player ~= nil and player or self:GetSelected()

    if not player or not SDK.Player.IsAdmin() then
        self:DebugError("PlayerTools:ToggleGodMode():", "not an admin")
    end

    local is_god_mode = self:IsGodMode(player)
    if is_god_mode ~= nil then
        for k, v in pairs(self.god_mode_players) do
            if v == player.userid then
                table.remove(self.god_mode_players, k)
            end
        end

        if is_god_mode then
            SDK.Remote.Send(
                'LookupPlayerInstByUserID("%s").components.health:SetInvincible(false)',
                { player.userid }
            )

            self:DebugString(
                player and "(" .. player:GetDisplayName() .. ")",
                "God Mode is disabled"
            )

            return false
        elseif is_god_mode == false then
            SDK.Remote.Send(
                'LookupPlayerInstByUserID("%s").components.health:SetInvincible(true)',
                { player.userid }
            )

            table.insert(self.god_mode_players, player.userid)
            self:DebugString(
                player and "(" .. player:GetDisplayName() .. ")",
                "God Mode is enabled"
            )

            return true
        end
    end
end

--- Light Watcher
-- @section light-watcher

--- Checks if Grue (Charlie) can attack the owner.
-- @treturn boolean
function PlayerTools:CanGrueAttack()
    return not (self:IsGodMode()
        or SDK.Player.IsInLight()
        or SDK.Player.IsGhost()
        or SDK.Player.Inventory.HasEquippedItemWithTag(EQUIPSLOTS.HEAD, "nightvision"))
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
function PlayerTools:GetSelected() -- luacheck: only
    return ConsoleCommandPlayer()
end

--- Selects the player.
-- @tparam EntityScript player Player instance
-- @treturn boolean
function PlayerTools:Select(player)
    local name = player:GetDisplayName()

    SetDebugEntity(player)
    self.selected_client = player
    self.devtools.labels:AddSelected(player)

    if SDK.World.IsMasterSim() then
        self:DebugString("Selected", name)
    elseif SDK.Player.IsAdmin() then
        SDK.Remote.Send('SetDebugEntity(LookupPlayerInstByUserID("%s"))', { player.userid })
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
function PlayerTools:IsSelectedInSync()
    if SDK.World.IsMasterSim() then
        return self.selected_client ~= nil
    end
    return self.selected_client == self.selected_server
end

--- Teleport
-- @section teleport

--- Checks fake teleport state.
-- @treturn boolean
function PlayerTools:IsFakeTeleport()
    return self.is_fake_teleport
end

--- Sets fake teleport state.
-- @tparam boolean is_fake_teleport
function PlayerTools:SetIsFakeTeleport(is_fake_teleport)
    self.is_fake_teleport = is_fake_teleport
end

--- Teleport a currently selected player.
--
-- Supports teleporting on the map as well.
--
-- @treturn boolean
function PlayerTools:Teleport()
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
            if SDK.World.IsMasterSim() and SDK.Player.IsAdmin() then
                player.Physics:Teleport(x, 0, y)
                return true
            elseif SDK.Player.IsAdmin() then
                SDK.Remote.Send(
                    'player = LookupPlayerInstByUserID("%s") player.Physics:Teleport(%d, 0, %d)',
                    { player.userid, x, y }
                )
                return true
            end
        else
            player.Physics:Teleport(x, 0, y)
            return true
        end
    elseif not self.is_fake_teleport and SDK.World.IsMasterSim() and SDK.Player.IsAdmin() then
        player.Physics:Teleport(TheInput:GetWorldPosition():Get())
        return true
    elseif not self.is_fake_teleport and SDK.Player.IsAdmin() then
        local pos = TheInput:GetWorldPosition()
        SDK.Remote.Send(
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
function PlayerTools:DoInit()
    DevTools.DoInit(self, self.devtools, "player", {
        GetSelectedPlayer = "GetSelected",
        SelectPlayer = "Select",

        -- general
        "GetPlayer",
        "GetSpeech",
        "GetWerenessMode",
        "IsMoveButtonDown",
        --"SetIsMoveButtonDown",
        "IsPlatformJumping",

        -- god mode
        "GetGodModePlayers",
        "IsGodMode",
        "ToggleGodMode",

        -- lightwatcher
        "CanGrueAttack",

        -- selection
        "IsSelectedInSync",

        -- teleport
        "Teleport",
    })
end

--- Terminates.
function PlayerTools:DoTerm()
    if self.crafting then
        self.crafting.DoTerm(self.crafting)
    end

    if self.vision then
        self.vision.DoTerm(self.vision)
    end

    if self.inst then
        if OnWereModeDirty then
            self.inst:RemoveEventCallback("weremodedirty", OnWereModeDirty)
            self:DebugString("[event]", "[weremodedirty]", "Deactivated")
        end
    end

    DevTools.DoTerm(self)
end

return PlayerTools
