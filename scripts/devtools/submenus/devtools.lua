----
-- Dev Tools submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.DevTools
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.4.0-alpha
----
require "devtools/constants"

local screen_width = TheSim:GetScreenSize()

return {
    label = "Dev Tools",
    name = "DevToolsSubmenu",
    options = {
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
                    submenu.devtools.config.font = BODYTEXTFONT
                    submenu.devtools.screen:UpdateFromConfig()
                end,
                on_get_fn = function(_, submenu)
                    local font = submenu.devtools.config.font
                    return font and font or BODYTEXTFONT
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.devtools.config.font = value
                    if submenu.devtools.screen then
                        submenu.devtools.screen:UpdateFromConfig()
                    end
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
            options = {
                label = "Font Size",
                min = 10,
                max = 24,
                on_accept_fn = function(_, submenu)
                    submenu.devtools.config.font_size = 16
                    submenu.devtools.screen:UpdateFromConfig()
                end,
                on_get_fn = function(_, submenu)
                    return submenu.devtools.config.font_size
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.devtools.config.font_size = value
                    if submenu.devtools.screen then
                        submenu.devtools.screen:UpdateFromConfig()
                    end
                end,
            },
        },
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
            options = {
                label = "Lines",
                min = 10,
                max = 50,
                on_accept_fn = function(_, submenu)
                    submenu.devtools.config.lines = 26
                    submenu.devtools.screen:UpdateFromConfig()
                end,
                on_get_fn = function(_, submenu)
                    return submenu.devtools.config.lines
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.devtools.config.lines = value
                    if submenu.devtools.screen then
                        submenu.devtools.screen:UpdateFromConfig()
                    end
                end,
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.NUMERIC,
            options = {
                label = "Width",
                min = 1280,
                max = screen_width,
                step = 10,
                on_accept_fn = function(_, submenu)
                    submenu.devtools.config.width = 1280
                    submenu.devtools.screen:UpdateFromConfig()
                end,
                on_get_fn = function(_, submenu)
                    return submenu.devtools.config.width
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.devtools.config.width = value
                    if submenu.devtools.screen then
                        submenu.devtools.screen:UpdateFromConfig()
                    end
                end,
            },
        },
    },
}
