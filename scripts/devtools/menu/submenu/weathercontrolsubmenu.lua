----
-- Weather control submenu.
--
-- Extends `menu.submenu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.submenu.WeatherControlSubmenu
-- @see menu.submenu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu/submenu"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam devtools.DevTools devtools
-- @tparam Widget root
-- @usage local weathercontrolsubmenu = WeatherControlSubmenu(devtools, root)
local WeatherControlSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Weather Control", "WeatherControlSubmenu", #root + 1)

    -- general
    self.console = devtools.player and devtools.player.console
    self.player = devtools.player
    self.world = devtools.world

    -- options
    if self.devtools and self.world and self.player and self.player:IsAdmin() and self.console then
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- Helpers
-- @section helpers

local function UpdateScreen(self)
    if self.devtools:IsPaused() then
        self.devtools:Unpause()
    end
    self:UpdateScreen("world")
end

local function AddForcePrecipitationOption(self)
    self:AddCheckboxOption({
        label = "Toggle Force Precipitation",
        on_get_fn = function()
            return self.world:IsPrecipitation()
        end,
        on_set_fn = function(value)
            if value ~= self.world:IsPrecipitation() then
                self.console:ForcePrecipitation(value)
                UpdateScreen(self)
            end
        end,
    })
end

local function AddSendLightningStrikeOption(self)
    if not self.world:IsCave() then
        self:AddDoActionOption({
            label = "Send Lightning Strike",
            on_accept_fn = function()
                local pos = TheInput:GetWorldPosition()
                self.console:SendLightningStrike(pos)
                UpdateScreen(self)
            end,
        })
    end
end

local function AddSendMiniEarthquakeOption(self)
    if self.world:IsCave() then
        self:AddDoActionOption({
            label = "Send Mini Earthquake",
            on_accept_fn = function()
                self.console:MiniQuake()
                UpdateScreen(self)
            end,
        })
    end
end

local function AddMoistureOption(self)
    local floor = self.world:GetMoistureFloor()
    local ceil = self.world:GetStateMoistureCeil()

    if floor and ceil then
        local delta
        self:AddNumericToggleOption({
            label = "Moisture",
            min = floor,
            max = ceil,
            step = 25,
            on_get_fn = function()
                return math.floor(self.world:GetStateMoisture())
            end,
            on_set_fn = function(value)
                delta = math.floor(value) - math.floor(self.world:GetStateMoisture())
                self.console:DeltaMoisture(delta)
                UpdateScreen(self)
            end,
        })
    end
end

local function AddSnowLevelOption(self)
    if not self.world:IsCave() then
        self:AddNumericToggleOption({
            label = "Snow Level",
            min = 0,
            max = 100,
            step = 10,
            on_get_fn = function()
                return math.floor(self.world:GetStateSnowLevel() * 100)
            end,
            on_set_fn = function(value)
                self.console:SetSnowLevel(value / 100)
                UpdateScreen(self)
            end,
        })
    end
end

local function AddWetnessOption(self)
    local delta
    self:AddNumericToggleOption({
        label = "Wetness",
        min = 0,
        max = 100,
        on_get_fn = function()
            return math.floor(self.world:GetStateWetness())
        end,
        on_set_fn = function(value)
            delta = math.floor(value) - math.floor(self.world:GetStateWetness())
            self.console:DeltaWetness(delta)
            UpdateScreen(self)
        end,
    })
end

--- General
-- @section general

--- Adds options.
function WeatherControlSubmenu:AddOptions()
    AddForcePrecipitationOption(self)
    self:AddDividerOption()

    AddSendLightningStrikeOption(self)
    AddSendMiniEarthquakeOption(self)
    self:AddDividerOption()

    AddMoistureOption(self)
    AddSnowLevelOption(self)
    AddWetnessOption(self)
end

return WeatherControlSubmenu
