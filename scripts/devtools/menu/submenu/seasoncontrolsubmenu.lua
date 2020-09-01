----
-- Season control submenu.
--
-- Extends `menu.submenu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.submenu.SeasonControlSubmenu
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
-- @usage local seasoncontrolsubmenu = SeasonControlSubmenu(devtools, root)
local SeasonControlSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Season Control", "SeasonControlSubmenu", #root + 1)

    -- general
    self.console = devtools.player and devtools.player.console
    self.player = devtools.player
    self.world = devtools.world

    -- options
    if self.devtools
        and self.world
        and self.player
        and self.player:IsAdmin()
        and self.console
        and self.screen
    then
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
        { name = "Autumn", value = "autumn", default = TUNING.AUTUMN_LENGTH },
        { name = "Spring", value = "spring", default = TUNING.SPRING_LENGTH },
        { name = "Summer", value = "summer", default = TUNING.SUMMER_LENGTH },
        { name = "Winter", value = "winter", default = TUNING.WINTER_LENGTH },
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
function SeasonControlSubmenu:AddOptions()
    AddAdvanceSeasonOption(self)
    AddRetreatSeasonOption(self)

    self:AddDividerOption()
    AddSeasonOption(self)

    self:AddDividerOption()
    AddSeasonLengthOptions(self)
end

return SeasonControlSubmenu
