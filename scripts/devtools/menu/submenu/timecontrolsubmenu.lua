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

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam devtools.DevTools devtools
-- @tparam Widget root
-- @usage local timecontrolsubmenu = TimeControlSubmenu(devtools, root)
local TimeControlSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Time Control", "TimeControlSubmenu", #root + 1)

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
end

return TimeControlSubmenu
