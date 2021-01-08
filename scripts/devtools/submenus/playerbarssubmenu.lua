----
-- Player bars submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod submenus.PlayerBarsSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0
----
local SDK = require "devtools/sdk/sdk/sdk"
local Submenu = require "devtools/menu/submenu"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local playerbarssubmenu = PlayerBarsSubmenu(devtools, root)
local PlayerBarsSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(
        self,
        devtools,
        root,
        "Player Bars",
        "PlayerBarsSubmenu",
        MOD_DEV_TOOLS.DATA_SIDEBAR.SELECTED
    )

    -- options
    if self.world and self.player and SDK.Player.IsAdmin() and self.screen then
        self:AddSelectedPlayerLabelPrefix(devtools, self.player)
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- General
-- @section general

--- Adds full option.
-- @tparam[opt] boolean is_inst_in_wereness_form
function PlayerBarsSubmenu:AddFullOption(is_inst_in_wereness_form)
    self:AddActionOption({
        label = "Full",
        on_accept_fn = function()
            local player = ConsoleCommandPlayer()
            SDK.Player.SetHealthLimitPercent(100, player)
            SDK.Player.SetHealthPercent(100, player)
            SDK.Player.SetHungerPercent(100, player)
            SDK.Player.SetSanityPercent(100, player)
            SDK.Player.SetMoisturePercent(0, player)
            SDK.Player.SetTemperature(36, player)

            if is_inst_in_wereness_form then
                SDK.Player.SetWerenessPercent(100, player)
            end

            self:UpdateScreen()
        end,
    })
end

--- Adds player bar option.
-- @tparam table|string label
-- @tparam string getter
-- @tparam string setter
-- @tparam[opt] number min
-- @tparam[opt] number max
-- @tparam[opt] number step
function PlayerBarsSubmenu:AddPlayerBarOption(label, getter, setter, min, max, step)
    min = min ~= nil and min or 1
    max = max ~= nil and max or 100
    step = step ~= nil and step or 5

    self:AddNumericOption({
        label = label,
        min = min,
        max = max,
        step = step,
        on_cursor_fn = function()
            self:UpdateScreen()
        end,
        on_get_fn = function()
            return math.floor(SDK.Player[getter](ConsoleCommandPlayer()))
        end,
        on_set_fn = function(_, _, value)
            SDK.Player[setter](value, ConsoleCommandPlayer())
            self:UpdateScreen()
        end,
    })
end

--- Adds options.
function PlayerBarsSubmenu:AddOptions()
    local player = self.player:GetSelected()
    local is_inst_in_wereness_form = player
        and player:HasTag("werehuman")
        and self.player:GetWerenessMode() ~= 0

    self:AddFullOption(is_inst_in_wereness_form)

    if SDK.Player.IsOwner(player) or not SDK.Player.IsReal(player) then
        self:AddDividerOption()
        self:AddPlayerBarOption("Health", "GetHealthPercent", "SetHealthPercent")
        self:AddPlayerBarOption("Hunger", "GetHungerPercent", "SetHungerPercent")
        self:AddPlayerBarOption("Sanity", "GetSanityPercent", "SetSanityPercent")

        self:AddDividerOption()
        self:AddPlayerBarOption(
            "Maximum Health",
            "GetHealthLimitPercent",
            "SetHealthLimitPercent",
            25
        )

        self:AddDividerOption()
        self:AddPlayerBarOption("Moisture", "GetMoisturePercent", "SetMoisturePercent", 0)
        self:AddPlayerBarOption(
            "Temperature",
            "GetTemperature",
            "SetTemperature",
            TUNING.MIN_ENTITY_TEMP,
            TUNING.MAX_ENTITY_TEMP
        )

        if is_inst_in_wereness_form then
            self:AddPlayerBarOption("Wereness", "GetWerenessPercent", "SetWerenessPercent")
        end
    end
end

return PlayerBarsSubmenu
