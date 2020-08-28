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

local Utils = require "devtools/utils"

local DevTools = require "devtools"
_G.DevTools = DevTools

local DebugUpvalue = require "devtools/debugupvalue"
local DevToolsScreen = require "screens/devtoolsscreen"

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

local Debug

Debug = require "devtools/debug"
Debug:DoInit(modname)
Debug:SetIsEnabled(GetModConfigData("debug") and true or false)
Debug:DebugModConfigs()

_G.ModDevToolsDebug = Debug

local function DebugString(...)
    return Debug and Debug:DebugString(...)
end

local function DebugInit(...)
    return Debug and Debug:DebugInit(...)
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

DevTools:DoInit(modname, Debug)
DevToolsScreen:DoInit(DevTools)

--- Mod warning override
-- @section mod-warning-override

_G.DISABLE_MOD_WARNING = GetModConfigData("default_mod_warning")

--- Player
-- @section player

local function OnEnterCharacterSelect(world)
    DevTools:SetIsInCharacterSelect(true)

    if DevTools.player then
        DevTools:DoTermPlayer()
    end

    if DevTools.world then
        DevTools.world:DoTerm()
    end

    if not DevTools.world then
        DevTools:DoInitWorld(world)
        DevTools.world:DoInitSaveData()
    end

    DebugString("Player is selecting character")
end

local function OnPlayerActivated(world, player)
    Debug:DoInitGame()

    DevTools.inst = player
    DevTools:SetIsInCharacterSelect(false)
    DevTools:DoInitWorld(world)
    DevTools.world:DoInitSaveData()

    if DevTools.world then
        DevTools.world:DoInitSaveData()
    end

    DevTools:DoInitPlayer(player)

    if DevTools then
        DevTools:SetLabelsFontSize(GetModConfigData("default_labels_font_size"))
        DevTools:SetUsernameLabelsMode(GetModConfigData("default_username_labels_mode"))

        local playerdevtools = DevTools.player
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
    DevTools.inst = nil
    DevTools:SetIsInCharacterSelect(false)
    DebugString("Player", player:GetDisplayName(), "deactivated")
end

local function AddPlayerPostInit(onActivatedFn, onDeactivatedFn)
    DebugString("Game ID -", TheSim:GetGameID())
    if IsDST() then
        env.AddPrefabPostInit("world", function(_world)
            if not DevTools.world then
                DevTools:DoInitWorld(_world)
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
    for k, v in pairs(DevTools) do
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
        if not DevTools then
            OldOnControl(self, control, down)
        end

        if not DevTools.player.controller then
            DevTools.player.controller = playercontroller
        end

        if DevTools then
            if DevToolsScreen then
                if DevTools:IsPaused()
                    and not DevToolsScreen:IsOpen()
                    and control == CONTROL_ACCEPT
                then
                    DevTools:Unpause()
                end
            end

            -- player
            if DevTools.player then
                local playerdevtools = DevTools.player
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

    Debug:DoInitPlayerController(playercontroller)
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
        if DevTools.world then
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

            DevTools.world:SetMoistureFloor(
                type(_moisturefloor) == "userdata" and _moisturefloor:value()
            )

            DevTools.world:SetMoistureRate(
                type(_moisturerate) == "userdata" and _moisturerate:value()
            )

            DevTools.world:SetPeakPrecipitationRate(
                type(_peakprecipitationrate) == "userdata" and _peakprecipitationrate:value()
            )

            DevTools.world:SetWetnessRate(wetness_rate)
        end
    end
end

AddComponentPostInit("caveweather", WeatherPostInit)
AddComponentPostInit("weather", WeatherPostInit)

--- Prefabs
-- @section prefabs

env.AddPlayerPostInit(function(inst)
    inst:ListenForEvent("changearea", function()
        DevTools:AddUsernameLabel(inst)
    end)
end)

--- Keybinds
-- @section keybinds

local _KEY_GOD_MODE = GetKeyFromConfig("key_god_mode")
local _KEY_MAP_INDICATORS_MODE = GetKeyFromConfig("key_map_indicators_mode")
local _KEY_MENU_TOGGLE = GetKeyFromConfig("key_menu_toggle")
local _KEY_MOVEMENT_PREDICTION = GetKeyFromConfig("key_movement_prediction")
local _KEY_PAUSE = GetKeyFromConfig("key_pause")
local _KEY_TELEPORT = GetKeyFromConfig("key_teleport")
local _KEY_TIME_SCALE_DECREASE = GetKeyFromConfig("time_scale_decrease")
local _KEY_TIME_SCALE_DEFAULT = GetKeyFromConfig("time_scale_default")
local _KEY_TIME_SCALE_INCREASE = GetKeyFromConfig("time_scale_increase")

local function CanPressInGamePlay()
    if not DevTools then
        return false
    end

    local playerdevtools = DevTools.player
    if InGamePlay()
        and playerdevtools
        and not playerdevtools:IsHUDChatInputScreenOpen()
        and not playerdevtools:IsHUDConsoleScreenOpen()
        and not playerdevtools:IsHUDWritableScreenActive()
    then
        return true
    end

    return false
end

local function IsMasterSim()
    if not DevTools then
        return false
    end

    local worlddevtools = DevTools.world
    if InGamePlay() and worlddevtools and worlddevtools:IsMasterSim() then
        return true
    end

    return false
end

if _KEY_MENU_TOGGLE then
    TheInput:AddKeyUpHandler(_KEY_MENU_TOGGLE, function()
        if not DevToolsScreen then
            return
        end

        if DevToolsScreen:CanToggle() then
            DevToolsScreen:Toggle()
        end
    end)
end

if _KEY_MOVEMENT_PREDICTION then
    TheInput:AddKeyUpHandler(_KEY_MOVEMENT_PREDICTION, function()
        if CanPressInGamePlay() and not IsMasterSim() then
            local playerdevtools = DevTools.player
            if playerdevtools then
                playerdevtools:ToggleMovementPrediction()
            end
        end
    end)
end

if _KEY_PAUSE then
    TheInput:AddKeyUpHandler(_KEY_PAUSE, function()
        if CanPressInGamePlay() then
            DevTools:TogglePause()
        end
    end)
end

if _KEY_GOD_MODE then
    TheInput:AddKeyUpHandler(_KEY_GOD_MODE, function()
        if CanPressInGamePlay() then
            local playerdevtools = DevTools.player
            playerdevtools:ToggleGodMode()
        end
    end)
end

if _KEY_TELEPORT then
    TheInput:AddKeyDownHandler(_KEY_TELEPORT, function()
        if CanPressInGamePlay() then
            local playerdevtools = DevTools.player
            playerdevtools:Teleport(_KEY_TELEPORT)
        end
    end)
end

if _KEY_MAP_INDICATORS_MODE then
    TheInput:AddKeyDownHandler(_KEY_MAP_INDICATORS_MODE, function()
        if CanPressInGamePlay() and DevTools.player and DevTools.player.map then
            local mapdevtools = DevTools.player.map
            if mapdevtools and mapdevtools:IsMapScreenOpen() then
                mapdevtools:SwitchIndicatorsMode()
            end
        end
    end)
end

do
    local function changeTimeScale(amount)
        if DevTools.world and DevTools.player and DevTools.player.console then
            local console = DevTools.player.console
            local worlddevtools = DevTools.world
            local timeScale = math.ceil(TheSim:GetTimeScale() * 100)
            timeScale = (timeScale + amount) / 100
            TheSim:SetTimeScale(timeScale)
            if not worlddevtools.ismastersim then
                console:SetTimeScale(timeScale)
            end
        end
    end

    if _KEY_TIME_SCALE_INCREASE then
        TheInput:AddKeyUpHandler(_KEY_TIME_SCALE_INCREASE, function()
            if CanPressInGamePlay() then
                changeTimeScale(10)
            end
        end)
    end

    if _KEY_TIME_SCALE_DECREASE then
        TheInput:AddKeyUpHandler(_KEY_TIME_SCALE_DECREASE, function()
            if CanPressInGamePlay() then
                changeTimeScale(-10)
            end
        end)
    end
end

if _KEY_TIME_SCALE_DEFAULT then
    TheInput:AddKeyUpHandler(_KEY_TIME_SCALE_DEFAULT, function()
        if CanPressInGamePlay()
            and DevTools.world
            and DevTools.player
            and DevTools.player.console
        then
            local worlddevtools = DevTools.world
            local console = DevTools.player.console
            TheSim:SetTimeScale(1)
            if not worlddevtools.ismastersim then
                console:SetTimeScale(1)
            end
        end
    end)
end

--- Reset
-- @section reset

local _RESET_COMBINATION = GetModConfigData("reset_combination")

local function Reset(key)
    if not DevTools then
        return
    end

    if TheInput:IsKeyDown(key) then
        DevTools:Reset()
    end
end

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
