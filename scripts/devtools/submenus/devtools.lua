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

local screen_width, screen_height = TheSim:GetScreenSize()

local function OnAcceptConfig(submenu, name)
    submenu.devtools:ResetConfig(name)
    submenu.devtools.screen:UpdateFromConfig()
end

local function OnSetConfig(submenu, name, value)
    submenu.devtools:SetConfig(name, value)
    submenu.devtools.screen:UpdateFromConfig()
end

return {
    label = "Dev Tools",
    name = "DevToolsSubmenu",
    options = {
        {
            type = MOD_DEV_TOOLS.OPTION.SUBMENU,
            options = {
                label = "Font",
                name = "FontDevToolsSubmenu",
                options = {
                    {
                        type = MOD_DEV_TOOLS.OPTION.CHECKBOX,
                        options = {
                            label = "Toggle Locale Text Scale",
                            on_accept_fn = function(_, submenu)
                                OnAcceptConfig(submenu, "locale_text_scale")
                            end,
                            on_get_fn = function(_, submenu)
                                return submenu.devtools:GetConfig("locale_text_scale")
                            end,
                            on_set_fn = function(_, submenu, value)
                                OnSetConfig(submenu, "locale_text_scale", value)
                            end,
                        },
                    },
                    { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
                    {
                        type = MOD_DEV_TOOLS.OPTION.CHOICES,
                        options = {
                            label = "Family",
                            choices = {
                                { name = "Belisa Plumilla Manual (50)", value = UIFONT },
                                { name = "Belisa Plumilla Manual (100)", value = TITLEFONT },
                                { name = "Belisa Plumilla Manual (Button)", value = BUTTONFONT },
                                { name = "Belisa Plumilla Manual (Talking)", value = TALKINGFONT },
                                { name = "Bellefair", value = CHATFONT },
                                { name = "Bellefair Outline", value = CHATFONT_OUTLINE },
                                { name = "Hammerhead", value = HEADERFONT },
                                { name = "Henny Penny (Wormwood)", value = TALKINGFONT_WORMWOOD },
                                {
                                    name = "Mountains of Christmas (Hermit)",
                                    value = TALKINGFONT_HERMIT,
                                },
                                { name = "Open Sans", value = DIALOGFONT },
                                { name = "PT Mono", value = CODEFONT },
                                { name = "Spirequal Light", value = NEWFONT },
                                { name = "Spirequal Light (Small)", value = NEWFONT_SMALL },
                                { name = "Spirequal Light Outline", value = NEWFONT_OUTLINE },
                                {
                                    name = "Spirequal Light Outline (Small)",
                                    value = NEWFONT_OUTLINE_SMALL,
                                },
                                { name = "Stint Ultra Condensed", value = BODYTEXTFONT },
                                { name = "Stint Ultra Condensed (Small)", value = SMALLNUMBERFONT },
                            },
                            on_accept_fn = function(_, submenu)
                                OnAcceptConfig(submenu, "font")
                            end,
                            on_get_fn = function(_, submenu)
                                local font = submenu.devtools:GetConfig("font")
                                return font and font or BODYTEXTFONT
                            end,
                            on_set_fn = function(_, submenu, value)
                                OnSetConfig(submenu, "font", value)
                            end,
                        },
                    },
                    {
                        type = MOD_DEV_TOOLS.OPTION.NUMERIC,
                        options = {
                            label = "Size",
                            min = 8,
                            max = 24,
                            on_accept_fn = function(_, submenu)
                                OnAcceptConfig(submenu, "font_size")
                            end,
                            on_get_fn = function(_, submenu)
                                return submenu.devtools:GetConfig("font_size")
                            end,
                            on_set_fn = function(_, submenu, value)
                                OnSetConfig(submenu, "font_size", value)
                            end,
                        },
                    },
                },
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.SUBMENU,
            options = {
                label = "Size",
                name = "SizeDevToolsSubmenu",
                options = {
                    {
                        type = MOD_DEV_TOOLS.OPTION.NUMERIC,
                        options = {
                            label = "Height",
                            min = 10,
                            max = function(_, submenu)
                                return math.floor(screen_height
                                    / submenu.devtools:GetConfig("font_size")
                                    / 2)
                            end,
                            on_accept_fn = function(_, submenu)
                                OnAcceptConfig(submenu, "size_height")
                            end,
                            on_get_fn = function(_, submenu)
                                return submenu.devtools:GetConfig("size_height")
                            end,
                            on_set_fn = function(_, submenu, value)
                                OnSetConfig(submenu, "size_height", value)
                            end,
                        },
                    },
                    {
                        type = MOD_DEV_TOOLS.OPTION.NUMERIC,
                        options = {
                            label = "Width",
                            min = 640,
                            max = screen_width,
                            step = 10,
                            on_accept_fn = function(_, submenu)
                                OnAcceptConfig(submenu, "size_width")
                            end,
                            on_get_fn = function(_, submenu)
                                return submenu.devtools:GetConfig("size_width")
                            end,
                            on_set_fn = function(_, submenu, value)
                                OnSetConfig(submenu, "size_width", value)
                            end,
                        },
                    },
                },
            },
        },
    },
}
