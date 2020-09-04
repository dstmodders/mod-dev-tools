----
-- Language submenu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.Language
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

return {
    label = "Language",
    name = "LanguageSubmenu",
    on_init_fn = function(self)
        self.language = LANGUAGE
        self.loc = LOC
    end,
    on_add_to_root_fn = function(self)
        return self.language and self.loc and true or false
    end,
    options = function()
        local t = {}
        for name, id in pairs(LANGUAGE) do
            local label = STRINGS.PRETRANSLATED.LANGUAGES[id]
            if label then
                table.insert(t, {
                    type = MOD_DEV_TOOLS.OPTION.ACTION,
                    options = {
                        label = label,
                        on_accept_fn = function(_, submenu)
                            LOC.SwapLanguage(LANGUAGE[name])
                            Profile:SetLanguageID(LANGUAGE[name])
                            submenu.screen:Close()
                        end,
                    },
                })
            end
        end
        return t
    end
}
