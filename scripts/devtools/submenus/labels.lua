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
-- @release 0.3.0
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
            type = MOD_DEV_TOOLS.OPTION.CHOICES,
            options = {
                label = "Font",
                choices = {
                    { name = "Belisa Plumilla Manual (50)", value = UIFONT },
                    { name = "Belisa Plumilla Manual (100)", value = TITLEFONT },
                    { name = "Belisa Plumilla Manual (Button)", value = BUTTONFONT },
                    { name = "Belisa Plumilla Manual (Talking)", value = TALKINGFONT },
                    { name = "Bellefair", value = CHATFONT },
                    { name = "Bellefair Outline", value = CHATFONT_OUTLINE },
                    { name = "Hammerhead", value = HEADERFONT },
                    { name = "Henny Penny (Wormwood)", value = TALKINGFONT_WORMWOOD },
                    { name = "Mountains of Christmas (Hermit)", value = TALKINGFONT_HERMIT },
                    { name = "Open Sans", value = DIALOGFONT },
                    { name = "PT Mono", value = CODEFONT },
                    { name = "Spirequal Light", value = NEWFONT },
                    { name = "Spirequal Light (Small)", value = NEWFONT_SMALL },
                    { name = "Spirequal Light Outline", value = NEWFONT_OUTLINE },
                    { name = "Spirequal Light Outline (Small)", value = NEWFONT_OUTLINE_SMALL },
                    { name = "Stint Ultra Condensed", value = BODYTEXTFONT },
                    { name = "Stint Ultra Condensed (Small)", value = SMALLNUMBERFONT },
                },
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
