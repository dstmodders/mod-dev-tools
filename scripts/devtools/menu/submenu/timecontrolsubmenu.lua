----
-- Time control submenu.
--
-- Extends `menu.submenu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.submenu.TimeControlSubmenu
-- @see menu.submenu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu/submenu"

local TimeControlSubmenu = Class(Submenu, function(
    self,
    root,
    devtools,
    worlddevtools,
    playerdevtools,
    screen
)
    Submenu._ctor(self, root, "Time Control", "TimeControlSubmenu", screen, #root + 1)

    -- general
    self.console = playerdevtools.console
    self.devtools = devtools
    self.player = playerdevtools
    self.world = worlddevtools

    if self.world and self.console and screen then
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

local function AddTimeScaleOption(self)
    self:AddNumericToggleOption({
        label = "Time Scale",
        min = 1,
        max = 400,
        step = 10,
        on_accept_fn = function()
            TheSim:SetTimeScale(1)
            if not self.world.ismastersim then
                self.console:SetTimeScale(1)
            end
        end,
        on_get_fn = function()
            return math.ceil(TheSim:GetTimeScale() * 100)
        end,
        on_set_fn = function(value)
            value = value / 100
            TheSim:SetTimeScale(value)
            if not self.world.ismastersim then
                self.console:SetTimeScale(value)
            end
        end,
    })
end

local function AddPushWorldEventOption(self, label, event)
    self:AddDoActionOption({
        label = label,
        on_accept_fn = function()
            self.console:PushWorldEvent(event)
            UpdateScreen(self)
        end,
    })
end

local function AddAdvanceSeasonOption(self)
    self:AddDoActionOption({
        label = "Advance Season",
        on_accept_fn = function()
            for _ = 1, self.world:GetStateRemainingDaysInSeason() do
                self.console:PushWorldEvent("ms_advanceseason")
            end
            UpdateScreen(self)
        end,
    })
end

local function AddRetreatSeasonOption(self)
    self:AddDoActionOption({
        label = "Retreat Season",
        on_accept_fn = function()
            for _ = 1, self.world:GetStateRemainingDaysInSeason() do
                self.console:PushWorldEvent("ms_retreatseason")
            end
            UpdateScreen(self)
        end,
    })
end

local function AddSeasonOption(self)
    local choices = {
        { name = "Autumn", value = "autumn" },
        { name = "Spring", value = "spring" },
        { name = "Summer", value = "summer" },
        { name = "Winter", value = "winter" },
    }

    self:AddChoicesOption({
        label = "Season",
        choices = choices,
        on_get_fn = function()
            return self.world:GetStateSeason()
        end,
        on_set_fn = function(value)
            self.console:SetSeason(value)
            UpdateScreen(self)
        end,
    })
end

local function AddSeasonLengthOptions(self)
    local seasons = {
        { name = "Autumn", value = "autumn", default = 20 },
        { name = "Spring", value = "spring", default = 20 },
        { name = "Summer", value = "summer", default = 15 },
        { name = "Winter", value = "winter", default = 15 },
    }

    for _, season in pairs(seasons) do
        self:AddNumericToggleOption({
            label = string.format("Season Length (%s)", season.name),
            min = 1,
            max = 100,
            on_accept_fn = function()
                self.console:SetSeasonLength(season.value, season.default)
                UpdateScreen(self)
            end,
            on_get_fn = function()
                return self.world:GetState(season.value .. "length")
            end,
            on_set_fn = function(value)
                self.console:SetSeasonLength(season.value, value)
                UpdateScreen(self)
            end,
        })
    end
end

--- General
-- @section general

--- Adds options.
function TimeControlSubmenu:AddOptions()
    if self.devtools and #self.devtools:GetPlayersClientTable() == 1 then
        self:AddToggleOption(
            { name = "Pause" },
            { src = self.devtools, name = "IsPaused" },
            { src = self.devtools, name = "TogglePause" }
        )

        self:AddDividerOption()

        if TheSim then
            AddTimeScaleOption(self)
            self:AddDividerOption()
        end
    end

    AddPushWorldEventOption(self, "Next Day", "ms_nextcycle")
    AddPushWorldEventOption(self, "Next Phase", "ms_nextphase")

    self:AddDividerOption()
    AddAdvanceSeasonOption(self)
    AddRetreatSeasonOption(self)

    self:AddDividerOption()
    AddSeasonOption(self)

    self:AddDividerOption()
    AddSeasonLengthOptions(self)
end

return TimeControlSubmenu
