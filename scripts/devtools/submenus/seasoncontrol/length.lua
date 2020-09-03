----
-- Season control length submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.SeasonControl.Length
-- @see DevTools.CreateSubmenuInstFromData
-- @see menu.Menu
-- @see menu.Menu.AddSubmenu
-- @see menu.Submenu
-- @see submenus.SeasonControl
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "devtools/constants"

local Length = {}

local _SEASONS = {
    { name = "Autumn", value = "autumn", default = TUNING.AUTUMN_LENGTH },
    { name = "Spring", value = "spring", default = TUNING.SPRING_LENGTH },
    { name = "Summer", value = "summer", default = TUNING.SUMMER_LENGTH },
    { name = "Winter", value = "winter", default = TUNING.WINTER_LENGTH },
}

for _, season in pairs(_SEASONS) do
    table.insert(Length, {
        type = MOD_DEV_TOOLS.OPTION.NUMERIC,
        options = {
            label = season.name,
            min = 1,
            max = 100,
            on_accept_fn = function(_, submenu)
                submenu.console:SetSeasonLength(season.value, season.default)
                submenu:UpdateScreen("world", true)
            end,
            on_get_fn = function(_, submenu)
                return submenu.world:GetState(season.value .. "length")
            end,
            on_set_fn = function(_, submenu, value)
                submenu.console:SetSeasonLength(season.value, value)
                submenu:UpdateScreen("world", true)
            end,
        },
    })
end

return Length
