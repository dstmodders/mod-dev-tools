----
-- Modmain.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
local _G = GLOBAL
local require = _G.require

_G.MOD_DEV_TOOLS_TEST = false

local DebugUpvalue = require "devtools/debugupvalue"
local Utils = require "devtools/utils"

require "devtools/console"

--- Globals
-- @section globals

local CONTROL_ACCEPT = _G.CONTROL_ACCEPT
local CONTROL_MOVE_DOWN = _G.CONTROL_MOVE_DOWN
local CONTROL_MOVE_LEFT = _G.CONTROL_MOVE_LEFT
local CONTROL_MOVE_RIGHT = _G.CONTROL_MOVE_RIGHT
local CONTROL_MOVE_UP = _G.CONTROL_MOVE_UP
local InGamePlay = _G.InGamePlay
local KEY_ALT = _G.KEY_ALT
local KEY_CTRL = _G.KEY_CTRL
local KEY_R = _G.KEY_R
local KEY_SHIFT = _G.KEY_SHIFT
local TheInput = _G.TheInput
local TheSim = _G.TheSim

--- Debugging
-- @section debugging

local debug

debug = require("devtools/debug")(modname)
debug:SetIsEnabled(GetModConfigData("debug") and true or false)
debug:DebugModConfigs()

_G.ModDevToolsDebug = debug

local function DebugString(...)
    return debug and debug:DebugString(...)
end

local function DebugInit(...)
    return debug and debug:DebugInit(...)
end

--- Helpers
-- @section helpers

local function GetKeyFromConfig(config)
    local key = GetModConfigData(config)
    return key and (type(key) == "number" and key or _G[key]) or -1
end

local function IsDST()
    return TheSim:GetGameID() == "DST"
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

devtools = require("devtools")(modname, debug)

_G.DevTools = devtools

-- keep in mind, we are NOT dealing with a DevToolsScreen instance
local DevToolsScreen

DevToolsScreen = require "screens/devtoolsscreen"
DevToolsScreen:DoInit(devtools)

--- Mod warning override
-- @section mod-warning-override

_G.DISABLE_MOD_WARNING = GetModConfigData("default_mod_warning")

--- Player
-- @section player

local function OnEnterCharacterSelect(world)
    devtools:SetIsInCharacterSelect(true)
    devtools:DoTermPlayer()
    devtools:DoTermWorld()
    devtools:DoInitWorld(world)
    DebugString("Player is selecting character")
end

local function OnPlayerActivated(world, player)
    debug:DoInitGame()

    devtools.inst = player
    devtools:SetIsInCharacterSelect(false)
    devtools:DoInitWorld(world)
    devtools:DoInitPlayer(player)

    if devtools then
        devtools:SetLabelsFontSize(GetModConfigData("default_labels_font_size"))
        devtools:SetUsernameLabelsMode(GetModConfigData("default_username_labels_mode"))

        local playerdevtools = devtools.player
        if playerdevtools then
            local crafting = playerdevtools.crafting
            local vision = playerdevtools.vision

            if playerdevtools:IsAdmin() and GetModConfigData("default_god_mode") then
                if GetModConfigData("default_god_mode") then
                    playerdevtools:ToggleGodMode()
                end
            end

            if crafting and playerdevtools:IsAdmin() then
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
    end

    DebugString("Player", player:GetDisplayName(), "activated")
end

local function OnPlayerDeactivated(_, player)
    devtools.inst = nil
    devtools:SetIsInCharacterSelect(false)
    DebugString("Player", player:GetDisplayName(), "deactivated")
end

local function AddPlayerPostInit(onActivatedFn, onDeactivatedFn)
    DebugString("Game ID -", TheSim:GetGameID())
    if IsDST() then
        env.AddPrefabPostInit("world", function(_world)
            if not devtools.world then
                devtools:DoInitWorld(_world)
            end

            _world:ListenForEvent("entercharacterselect", function(world)
                OnEnterCharacterSelect(world)
            end)

            _world:ListenForEvent("playeractivated", function(world, player)
                if player == _G.ThePlayer then
                    onActivatedFn(world, player)
                end
            end)

            _world:ListenForEvent("playerdeactivated", function(world, player)
                if player == _G.ThePlayer then
                    onDeactivatedFn(world, player)
                end
            end)
        end)
    else
        env.AddPlayerPostInit(function(player)
            onActivatedFn(nil, player)
        end)
    end
    DebugInit("AddPlayerPostInit")
end

local function AddConsoleScreenPostInit(self)
    self.console_edit:AddWordPredictionDictionary({
        words = { "vTools" },
        delim = "De",
        num_chars = 0
    })

    self.console_edit:AddWordPredictionDictionary({ words = {
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
    }, delim = "d_", num_chars = 0 })

    local words = {}
    for k, v in pairs(devtools) do
        if type(v) == "function"
            and k ~= "is_a"
            and k ~= "_ctor"
            and not string.match(k, "^Debug")
        then
            table.insert(words, k)
        end
    end
    words = Utils.TableSortAlphabetically(words)

    self.console_edit:AddWordPredictionDictionary({
        words = words,
        delim = "DevTools:",
        num_chars = 0,
    })
end

local function PlayerControllerPostInit(playercontroller, player)
    if player ~= _G.ThePlayer then
        return
    end

    --
    -- Overrides
    --

    local OldOnControl = playercontroller.OnControl
    playercontroller.OnControl = function(self, control, down)
        if not devtools then
            OldOnControl(self, control, down)
        end

        if not devtools.player.controller then
            devtools.player.controller = playercontroller
        end

        if devtools then
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
                local playerdevtools = devtools.player
                local is_move_button_down = (down and IsMoveButton(control)) and true or false

                playerdevtools:SetIsMoveButtonDown(is_move_button_down)

                -- automation
                if playerdevtools.automation
                    and playerdevtools.automation:CanStartUnsinkingMPThread()
                then
                    playerdevtools.automation:StartUnsinkingMPThread()
                end
            end
        end

        OldOnControl(self, control, down)
    end

    debug:DoInitPlayerController(playercontroller)
    DebugInit("PlayerControllerPostInit")
end

AddPlayerPostInit(OnPlayerActivated, OnPlayerDeactivated)
AddClassPostConstruct("screens/consolescreen", AddConsoleScreenPostInit)
AddComponentPostInit("playercontroller", PlayerControllerPostInit)

--- Weather
-- @section weather

local function WeatherPostInit(weather)
    local OldOnUpdate = weather.OnUpdate
    weather.OnUpdate = function(...)
        OldOnUpdate(...)
        if devtools.world then
            local _moisturefloor = DebugUpvalue.GetUpvalue(weather.GetDebugString, "_moisturefloor")
            local _moisturerate = DebugUpvalue.GetUpvalue(weather.GetDebugString, "_moisturerate")
            local _temperature = DebugUpvalue.GetUpvalue(weather.GetDebugString, "_temperature")

            local _peakprecipitationrate = DebugUpvalue.GetUpvalue(
                weather.GetDebugString,
                "_peakprecipitationrate"
            )

            local precipitation_rate, wetness_rate

            local CalculatePrecipitationRate = DebugUpvalue.GetUpvalue(
                weather.GetDebugString,
                "CalculatePrecipitationRate"
            )

            local CalculateWetnessRate = DebugUpvalue.GetUpvalue(
                weather.GetDebugString,
                "CalculateWetnessRate"
            )

            if CalculatePrecipitationRate and type(CalculatePrecipitationRate) == "function" then
                precipitation_rate = CalculatePrecipitationRate()
            end

            if CalculatePrecipitationRate and type(CalculatePrecipitationRate) == "function"
                and _temperature and type(_temperature) == "number"
            then
                wetness_rate = CalculateWetnessRate(_temperature, precipitation_rate)
            end

            devtools.world:SetMoistureFloor(type(_moisturefloor) == "userdata"
                and _moisturefloor:value())

            devtools.world:SetMoistureRate(type(_moisturerate) == "userdata"
                and _moisturerate:value())

            devtools.world:SetPeakPrecipitationRate(type(_peakprecipitationrate) == "userdata"
                and _peakprecipitationrate:value())

            devtools.world:SetWetnessRate(wetness_rate)
        end
    end
end

AddComponentPostInit("caveweather", WeatherPostInit)
AddComponentPostInit("weather", WeatherPostInit)

--- Prefabs
-- @section prefabs

env.AddPlayerPostInit(function(inst)
    inst:ListenForEvent("changearea", function()
        devtools:AddUsernameLabel(inst)
    end)
end)

--- Keybinds
-- @section keybinds

local function IsMasterSim()
    if not devtools then
        return false
    end

    local worlddevtools = devtools.world
    if InGamePlay() and worlddevtools and worlddevtools:IsMasterSim() then
        return true
    end

    return false
end

local _KEY_MENU_TOGGLE = GetKeyFromConfig("key_menu_toggle")
if _KEY_MENU_TOGGLE then
    TheInput:AddKeyUpHandler(_KEY_MENU_TOGGLE, function()
        if DevToolsScreen and DevToolsScreen:CanToggle() then
            DevToolsScreen:Toggle()
        end
    end)
end

local _KEY_MOVEMENT_PREDICTION = GetKeyFromConfig("key_movement_prediction")
if _KEY_MOVEMENT_PREDICTION then
    TheInput:AddKeyUpHandler(_KEY_MOVEMENT_PREDICTION, function()
        if devtools and devtools:CanPressKeyInGamePlay() and not IsMasterSim() then
            local playerdevtools = devtools.player
            if playerdevtools then
                playerdevtools:ToggleMovementPrediction()
            end
        end
    end)
end

local _KEY_PAUSE = GetKeyFromConfig("key_pause")
if _KEY_PAUSE then
    TheInput:AddKeyUpHandler(_KEY_PAUSE, function()
        if devtools and devtools:CanPressKeyInGamePlay() then
            devtools:TogglePause()
        end
    end)
end

local _KEY_GOD_MODE = GetKeyFromConfig("key_god_mode")
if _KEY_GOD_MODE then
    TheInput:AddKeyUpHandler(_KEY_GOD_MODE, function()
        if devtools and devtools:CanPressKeyInGamePlay() then
            local playerdevtools = devtools.player
            playerdevtools:ToggleGodMode()
        end
    end)
end

local _KEY_TELEPORT = GetKeyFromConfig("key_teleport")
if _KEY_TELEPORT then
    TheInput:AddKeyDownHandler(_KEY_TELEPORT, function()
        if devtools and devtools:CanPressKeyInGamePlay() then
            local playerdevtools = devtools.player
            playerdevtools:Teleport(_KEY_TELEPORT)
        end
    end)
end

local _KEY_TIME_SCALE_INCREASE = GetKeyFromConfig("key_time_scale_increase")
if _KEY_TIME_SCALE_INCREASE then
    TheInput:AddKeyDownHandler(_KEY_TIME_SCALE_INCREASE, function()
        local playerdevtools = Utils.ChainGet(devtools, "player")
        if playerdevtools and devtools:CanPressKeyInGamePlay() then
            if TheInput:IsKeyDown(KEY_SHIFT) then
                playerdevtools:ChangeTimeScale(4, true)
            else
                playerdevtools:ChangeTimeScale(0.1)
            end
        end
    end)
end

local _KEY_TIME_SCALE_DECREASE = GetKeyFromConfig("key_time_scale_decrease")
if _KEY_TIME_SCALE_DECREASE then
    TheInput:AddKeyDownHandler(_KEY_TIME_SCALE_DECREASE, function()
        local playerdevtools = Utils.ChainGet(devtools, "player")
        if playerdevtools and devtools:CanPressKeyInGamePlay() then
            if TheInput:IsKeyDown(KEY_SHIFT) then
                playerdevtools:ChangeTimeScale(0, true)
            else
                playerdevtools:ChangeTimeScale(-0.1)
            end
        end
    end)
end

local _KEY_TIME_SCALE_DEFAULT = GetKeyFromConfig("key_time_scale_default")
if _KEY_TIME_SCALE_DEFAULT then
    TheInput:AddKeyUpHandler(_KEY_TIME_SCALE_DEFAULT, function()
        local playerdevtools = Utils.ChainGet(devtools, "player")
        if playerdevtools and devtools:CanPressKeyInGamePlay() then
            playerdevtools:ChangeTimeScale(1, true)
        end
    end)
end

--- Reset
-- @section reset

local function Reset(key)
    if devtools and TheInput:IsKeyDown(key) then
        devtools:Reset()
    end
end

local _RESET_COMBINATION = GetModConfigData("reset_combination")
if _RESET_COMBINATION == "ctrl_r" then
    TheInput:AddKeyUpHandler(KEY_R, function()
        return Reset(KEY_CTRL)
    end)
elseif _RESET_COMBINATION == "alt_r" then
    TheInput:AddKeyUpHandler(KEY_R, function()
        return Reset(KEY_ALT)
    end)
elseif _RESET_COMBINATION == "shift_r" then
    TheInput:AddKeyUpHandler(KEY_R, function()
        return Reset(KEY_SHIFT)
    end)
end

--- KnownModIndex
-- @section knownmodindex

if GetModConfigData("hide_changelog") then
    Utils.HideChangelog(modname, true)
end
