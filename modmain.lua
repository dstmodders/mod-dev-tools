----
-- Modmain.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local _G = GLOBAL
local require = _G.require

_G.MOD_DEV_TOOLS_TEST = false

--- Globals
-- @section globals

local CONTROL_ACCEPT = _G.CONTROL_ACCEPT
local KEY_SHIFT = _G.KEY_SHIFT
local TheInput = _G.TheInput

--- SDK
-- @section sdk

local SDK

SDK = require "devtools/sdk/sdk/sdk"
SDK.Load(env, "devtools/sdk")

--- Debugging
-- @section debugging

SDK.Debug.SetIsEnabled(GetModConfigData("debug") and true or false)
SDK.Debug.ModConfigs()

--- Initialization
-- @section initialization

require "devtools/console"

local devtools

devtools = require("devtools")()

_G.DevTools = devtools
_G.DevToolsAPI = devtools:GetAPI()

-- config
devtools:SetConfig("key_select", SDK.Config.GetModKeyConfigData("key_select"))
devtools:SetConfig("key_switch_data", SDK.Config.GetModKeyConfigData("key_switch_data"))

local DevToolsScreen -- not an instance

DevToolsScreen = require "screens/devtoolsscreen"
DevToolsScreen:DoInit(devtools)

--- Mod warning override
-- @section mod-warning-override

_G.DISABLE_MOD_WARNING = GetModConfigData("default_mod_warning")

--- Player
-- @section player

SDK.OnEnterCharacterSelect(function(world)
    devtools:DoTermPlayer()
    devtools:DoTermWorld()
    devtools:DoInitWorld(world)
end)

SDK.OnPlayerActivated(function(world, player)
    devtools.inst = player
    devtools:DoInitWorld(world)
    devtools:DoInitPlayer(player)

    if devtools then
        local playertools = devtools.player
        if playertools then
            local crafting = playertools.crafting
            local vision = playertools.vision

            if SDK.Player.IsAdmin() and GetModConfigData("default_god_mode") then
                if GetModConfigData("default_god_mode") then
                    playertools:ToggleGodMode()
                end
            end

            if crafting and SDK.Player.IsAdmin() then
                if GetModConfigData("default_free_crafting") then
                    SDK.Player.Craft.ToggleFreeCrafting(player)
                end
            end

            if vision then
                if GetModConfigData("default_forced_hud_visibility") then
                    vision:ToggleForcedHUDVisibility()
                end

                if GetModConfigData("default_forced_unfading") then
                    SDK.Vision.ToggleUnfading()
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
end)

--- Console
-- @section console

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

SDK.OnLoadComponent("playercontroller", function(self)
    devtools:GetDebug():DoInitPlayerController(self)
end)

SDK.OverrideComponentMethod("playercontroller", "OnControl", function(old, self, control, down)
    if not devtools then
        old(self, control, down)
        return
    end

    if not devtools.player.controller then
        devtools.player.controller = self
    end

    if devtools then
        -- screen
        if DevToolsScreen
            and not DevToolsScreen:IsOpen()
            and control == CONTROL_ACCEPT
            and SDK.Time.IsPaused()
        then
            SDK.Time.Resume()
        end

        -- player
        if devtools.player then
            devtools.player:SetIsMoveButtonDown(down and SDK.Input.IsControlMove(control))
        end
    end
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
    if _G.ThePlayer and not SDK.World.IsMasterSim() then
        SDK.Player.ToggleMovementPrediction()
    end
end, true)

SDK.Input.AddConfigKeyUpHandler("key_pause", function()
    SDK.Time.TogglePause()
end, true)

SDK.Input.AddConfigKeyUpHandler("key_god_mode", function()
    local playertools = SDK.Utils.Chain.Get(devtools, "player")
    if playertools then
        playertools:ToggleGodMode()
    end
end, true)

local _KEY_TELEPORT = SDK.Config.GetModKeyConfigData("key_teleport")
SDK.Input.AddConfigKeyDownHandler("key_teleport", function()
    local playertools = SDK.Utils.Chain.Get(devtools, "player")
    if playertools then
        playertools:Teleport(_KEY_TELEPORT)
    end
end, true)

SDK.Input.AddConfigKeyUpHandler("key_select_entity", function()
    local worldtools = SDK.Utils.Chain.Get(devtools, "world")
    if worldtools then
        worldtools:SelectEntityUnderMouse()
    end
end, true)

SDK.Input.AddConfigKeyDownHandler("key_time_scale_increase", function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        SDK.Time.SetTimeScale(4)
    else
        SDK.Time.SetDeltaTimeScale(0.1)
    end
end, true)

SDK.Input.AddConfigKeyDownHandler("key_time_scale_decrease", function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        SDK.Time.SetTimeScale(0)
    else
        SDK.Time.SetDeltaTimeScale(-0.1)
    end
end, true)

SDK.Input.AddConfigKeyUpHandler("key_time_scale_default", function()
    SDK.Time.SetTimeScale(1)
end, true)

--- Reset
-- @section reset

local KEY_R = _G.KEY_R

local function Reset(key)
    if TheInput:IsKeyDown(key) then
        SDK.Reload()
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
    SDK.ModMain.HideChangelog(true)
end
