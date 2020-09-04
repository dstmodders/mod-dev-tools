----
-- Season control submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.SeasonControl
-- @see DevTools.CreateSubmenuInstFromData
-- @see menu.Menu
-- @see menu.Menu.AddSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "devtools/constants"

local _SEASONS = {
    { name = "Autumn", value = "autumn", default = TUNING.AUTUMN_LENGTH },
    { name = "Spring", value = "spring", default = TUNING.SPRING_LENGTH },
    { name = "Summer", value = "summer", default = TUNING.SUMMER_LENGTH },
    { name = "Winter", value = "winter", default = TUNING.WINTER_LENGTH },
}

local function LengthSubmenu()
    local options = {}

    for _, season in pairs(_SEASONS) do
        table.insert(options, {
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

    return {
        type = MOD_DEV_TOOLS.OPTION.SUBMENU,
        options = {
            label = "Length",
            name = "SeasonControlLengthSubmenu",
            options = options,
        },
    }
end

return {
    label = "Season Control",
    name = "SeasonControlSubmenu",
    on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_ADMIN,
    options = {
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Advance Season",
                on_accept_fn = function(_, submenu)
                    for _ = 1, submenu.world:GetStateRemainingDaysInSeason() do
                        submenu.console:PushWorldEvent("ms_advanceseason")
                    end
                    submenu:UpdateScreen("world", true)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.ACTION,
            options = {
                label = "Retreat Season",
                on_accept_fn = function(_, submenu)
                    for _ = 1, submenu.world:GetStateRemainingDaysInSeason() do
                        submenu.console:PushWorldEvent("ms_retreatseason")
                    end
                    submenu:UpdateScreen("world", true)
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.CHOICES,
            options = {
                label = "Season",
                choices = {
                    { name = "Autumn", value = "autumn" },
                    { name = "Spring", value = "spring" },
                    { name = "Summer", value = "summer" },
                    { name = "Winter", value = "winter" },
                },
                on_get_fn = function(_, submenu)
                    return submenu.world:GetStateSeason()
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.console:SetSeason(value)
                    submenu:UpdateScreen("world", true)
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        LengthSubmenu(),
    },
}
