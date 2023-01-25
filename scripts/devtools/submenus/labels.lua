----
-- Labels submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.Labels
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
----
require "devtools/constants"

local Toggle = require "devtools/submenus/option/toggle"

return {
    label = "Labels",
    name = "LabelsSubmenu",
    on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_WORLD,
    options = {
        Toggle("labels", "Selected", "IsSelectedEnabled", "ToggleSelectedEnabled"),
        Toggle("labels", "Username", "IsUsernameEnabled", "ToggleUsernameEnabled"),
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.CHOICES,
            options = {
                label = "Username Mode",
                choices = {
                    { name = "Default", value = "default" },
                    { name = "Coloured", value = "coloured" },
                },
                on_accept_fn = function(_, submenu)
                    submenu.labels:SetUsernameMode(submenu.labels:GetDefaultUsernameMode())
                end,
                on_get_fn = function(_, submenu)
                    local mode = submenu.labels:GetUsernameMode()
                    return mode and mode or "default"
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.labels:SetUsernameMode(value)
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.FONT,
            options = {
                on_accept_fn = function(_, submenu)
                    submenu.labels:SetFont(submenu.labels:GetDefaultFont())
                end,
                on_get_fn = function(_, submenu)
                    local size = submenu.labels:GetFont()
                    return size and size or BODYTEXTFONT
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.labels:SetFont(value)
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
            options = {
                label = "Font Size",
                min = 6,
                max = 32,
                on_accept_fn = function(_, submenu)
                    submenu.labels:SetFontSize(submenu.labels:GetDefaultFontSize())
                end,
                on_get_fn = function(_, submenu)
                    local size = submenu.labels:GetFontSize()
                    return size and size or 18
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.labels:SetFontSize(value)
                end,
            },
        },
    },
}
