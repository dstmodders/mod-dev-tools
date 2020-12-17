----
-- Modmain.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
local _G = GLOBAL
local require = _G.require

_G.MOD_DEV_TOOLS_TEST = false

require "devtools/console"

--- Globals
-- @section globals

local CONTROL_ACCEPT = _G.CONTROL_ACCEPT
local CONTROL_MOVE_DOWN = _G.CONTROL_MOVE_DOWN
local CONTROL_MOVE_LEFT = _G.CONTROL_MOVE_LEFT
local CONTROL_MOVE_RIGHT = _G.CONTROL_MOVE_RIGHT
local CONTROL_MOVE_UP = _G.CONTROL_MOVE_UP
local KEY_SHIFT = _G.KEY_SHIFT
local TheInput = _G.TheInput

--- SDK
-- @section sdk

local SDK

SDK = require "devtools/sdk/sdk/sdk"
SDK.Load(env, "scripts/devtools/sdk", {
    "Config",
    "Console",
    "Constant",
    "Debug",
    "DebugUpvalue",
    "Dump",
    "Entity",
    "Input",
    "ModMain",
    "Player",
    "Thread",
    "World",
})

--- Debugging
-- @section debugging

SDK.Debug.SetIsEnabled(GetModConfigData("debug") and true or false)
SDK.Debug.ModConfigs()

--- Helpers
-- @section helpers

local function GetKeyFromConfig(config)
    local key = GetModConfigData(config)
    return key and (type(key) == "number" and key or _G[key]) or -1
end

local function IsMoveButton(control)
    return control == CONTROL_MOVE_UP
        or control == CONTROL_MOVE_DOWN
        or control == CONTROL_MOVE_LEFT
        or control == CONTROL_MOVE_RIGHT
end

--- Initialization
-- @section initialization

local devtools

devtools = require("devtools")(modname)

_G.DevTools = devtools
_G.DevToolsAPI = devtools:GetAPI()

-- config
devtools:SetConfig("key_select", GetKeyFromConfig("key_select"))
devtools:SetConfig("key_switch_data", GetKeyFromConfig("key_switch_data"))

local DevToolsScreen -- not an instance

DevToolsScreen = require "screens/devtoolsscreen"
DevToolsScreen:DoInit(devtools)

--- Mod warning override
-- @section mod-warning-override

_G.DISABLE_MOD_WARNING = GetModConfigData("default_mod_warning")

--- Player
-- @section player

SDK.OnEnterCharacterSelect(function(world)
    devtools:SetIsInCharacterSelect(true)
    devtools:DoTermPlayer()
    devtools:DoTermWorld()
    devtools:DoInitWorld(world)
end)

SDK.OnPlayerActivated(function(world, player)
    devtools.inst = player
    devtools:SetIsInCharacterSelect(false)
    devtools:DoInitWorld(world)
    devtools:DoInitPlayer(player)

    if devtools then
        local playerdevtools = devtools.player
        if playerdevtools then
            local crafting = playerdevtools.crafting
            local vision = playerdevtools.vision

            if SDK.Player.IsAdmin() and GetModConfigData("default_god_mode") then
                if GetModConfigData("default_god_mode") then
                    playerdevtools:ToggleGodMode()
                end
            end

            if crafting and SDK.Player.IsAdmin() then
                if GetModConfigData("default_free_crafting") then
                    crafting:ToggleFreeCrafting()
                end
            end

            if vision then
                if GetModConfigData("default_forced_hud_visibility") then
                    vision:ToggleForcedHUDVisibility()
                end

                if GetModConfigData("default_forced_unfading") then
                    vision:ToggleForcedUnfading()
                end
            end
        end

        if devtools.labels then
            devtools.labels:SetFont(_G[GetModConfigData("default_labels_font")])
            devtools.labels:SetFontSize(GetModConfigData("default_labels_font_size"))
            devtools.labels:SetIsSelectedEnabled(GetModConfigData("default_selected_labels"))
            devtools.labels:SetIsUsernameEnabled(GetModConfigData("default_username_labels"))
            devtools.labels:SetUsernameMode(GetModConfigData("default_username_labels_mode"))
        end
    end
end)

SDK.OnPlayerDeactivated(function()
    devtools.inst = nil
    devtools:SetIsInCharacterSelect(false)
end)

SDK.Console.AddWordPredictionDictionaries({
    { delim = "De", num_chars = 0, words = { "vTools" } },
    { delim = "du", num_chars = 2, words = { "mptable" } },
    { delim = "d_", num_chars = 0, words = {
        -- general
        "decodefile",
        "decodesavedata",
        "doaction",
        "emote",
        "emotepose",
        "emotestop",
        "findinventoryitem",
        "findinventoryitems",
        "gettags",
        "say",
        "says",

        -- animstate
        "getanim",
        "getanimbank",
        "getanimbuild",

        -- dump
        "dumpcomponents",
        "dumpeventlisteners",
        "dumpfields",
        "dumpfunctions",
        "dumpreplicas",
        "getcomponents",
        "geteventlisteners",
        "getfields",
        "getfunctions",
        "getreplicas",

        -- stategraph
        "getsgname",
        "getsgstate",

        -- table
        "tablecompare",
        "tablecount",
        "tablehasvalue",
        "tablekeybyvalue",
        "tablemerge",
    } },
    function()
        local words = SDK.Dump.GetFunctions(devtools, true)
        for k, word in pairs(words) do
            if word == "is_a" or word ~= "_ctor" or not string.match(word, "^Debug") then
                table.remove(words, k)
            end
        end
        return { delim = "DevTools:", num_chars = 0, words = words }
    end
})

--- Player Controller
-- @section player-controller

AddComponentPostInit("playercontroller", function(playercontroller, player)
    if player ~= _G.ThePlayer then
        return
    end

    -- overrides PlayerController:OnControl()
    local OldOnControl = playercontroller.OnControl
    playercontroller.OnControl = function(self, control, down)
        if not devtools then
            OldOnControl(self, control, down)
            return
        end

        if not devtools.player.controller then
            devtools.player.controller = playercontroller
        end

        if devtools then
            -- screen
            if DevToolsScreen then
                if devtools:IsPaused()
                    and not DevToolsScreen:IsOpen()
                    and control == CONTROL_ACCEPT
                then
                    devtools:Unpause()
                end
            end

            -- player
            if devtools.player then
                devtools.player:SetIsMoveButtonDown(down and IsMoveButton(control))
            end
        end

        OldOnControl(self, control, down)
    end

    devtools:GetDebug():DoInitPlayerController(playercontroller)
end)

--- Prefabs
-- @section prefabs

env.AddPlayerPostInit(function(inst)
    if not inst.Label then
        inst.entity:AddLabel()
    end

    inst:ListenForEvent("changearea", function()
        if devtools and devtools.labels then
            devtools.labels:AddUsername(inst)
        end
    end)
end)

--- Keybinds
-- @section keybinds

SDK.Input.AddConfigKeyUpHandler("key_toggle_tools", function()
    if DevToolsScreen and DevToolsScreen:CanToggle() then
        DevToolsScreen:Toggle()
    end
end)

SDK.Input.AddConfigKeyUpHandler("key_movement_prediction", function()
    if devtools and devtools:CanPressKeyInGamePlay() and not SDK.World.IsMasterSim() then
        SDK.Player.ToggleMovementPrediction()
    end
end)

SDK.Input.AddConfigKeyUpHandler("key_pause", function()
    if devtools and devtools:CanPressKeyInGamePlay() then
        devtools:TogglePause()
    end
end)

SDK.Input.AddConfigKeyUpHandler("key_god_mode", function()
    if devtools and devtools:CanPressKeyInGamePlay() then
        local playerdevtools = devtools.player
        playerdevtools:ToggleGodMode()
    end
end)

local _KEY_TELEPORT = SDK.Config.GetModKeyConfigData("key_teleport")
SDK.Input.AddConfigKeyDownHandler("key_teleport", function()
    if devtools and devtools:CanPressKeyInGamePlay() then
        local playerdevtools = devtools.player
        playerdevtools:Teleport(_KEY_TELEPORT)
    end
end)

SDK.Input.AddConfigKeyUpHandler("key_select_entity", function()
    local worlddevtools = SDK.Utils.Chain.Get(devtools, "world")
    if worlddevtools and devtools:CanPressKeyInGamePlay() then
        worlddevtools:SelectEntityUnderMouse()
    end
end)

SDK.Input.AddConfigKeyDownHandler("key_time_scale_increase", function()
    local playerdevtools = SDK.Utils.Chain.Get(devtools, "player")
    if playerdevtools and devtools:CanPressKeyInGamePlay() then
        if TheInput:IsKeyDown(KEY_SHIFT) then
            playerdevtools:ChangeTimeScale(4, true)
        else
            playerdevtools:ChangeTimeScale(0.1)
        end
    end
end)

SDK.Input.AddConfigKeyDownHandler("key_time_scale_decrease", function()
    local playerdevtools = SDK.Utils.Chain.Get(devtools, "player")
    if playerdevtools and devtools:CanPressKeyInGamePlay() then
        if TheInput:IsKeyDown(KEY_SHIFT) then
            playerdevtools:ChangeTimeScale(0, true)
        else
            playerdevtools:ChangeTimeScale(-0.1)
        end
    end
end)

SDK.Input.AddConfigKeyUpHandler("key_time_scale_default", function()
    local playerdevtools = SDK.Utils.Chain.Get(devtools, "player")
    if playerdevtools and devtools:CanPressKeyInGamePlay() then
        playerdevtools:ChangeTimeScale(1, true)
    end
end)

--- Reset
-- @section reset

local KEY_R = _G.KEY_R

local function Reset(key)
    if devtools and TheInput:IsKeyDown(key) then
        devtools:Reset()
    end
end

local _RESET_COMBINATION = GetModConfigData("reset_combination")
if _RESET_COMBINATION == "ctrl_r" then
    TheInput:AddKeyUpHandler(KEY_R, function()
        return Reset(_G.KEY_CTRL)
    end)
elseif _RESET_COMBINATION == "alt_r" then
    TheInput:AddKeyUpHandler(KEY_R, function()
        return Reset(_G.KEY_ALT)
    end)
elseif _RESET_COMBINATION == "shift_r" then
    TheInput:AddKeyUpHandler(KEY_R, function()
        return Reset(KEY_SHIFT)
    end)
end

--- KnownModIndex
-- @section knownmodindex

if GetModConfigData("hide_changelog") then
    SDK.ModMain.HideChangelog(modname, true)
end
