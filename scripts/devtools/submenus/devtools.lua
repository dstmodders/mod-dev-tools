----
-- Dev Tools submenu.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @module submenus.DevTools
-- @see menu.Submenu
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
require("devtools/constants")

local screen_width, screen_height = TheSim:GetScreenSize()

local function OnAcceptConfig(submenu, name)
    submenu.devtools:ResetConfig(name)
    submenu.devtools.screen:ResetDataSidebarIndex()
    submenu.devtools.screen:UpdateFromConfig()
end

local function OnSetConfig(submenu, name, value)
    submenu.devtools:SetConfig(name, value)
    submenu.devtools.screen:ResetDataSidebarIndex()
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
                        type = MOD_DEV_TOOLS.OPTION.FONT,
                        options = {
                            label = "Family",
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
                                return math.floor(
                                    screen_height / submenu.devtools:GetConfig("font_size") / 2
                                )
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
