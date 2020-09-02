----
-- Language submenu.
--
-- Extends `menu.submenu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.submenu.LanguageSubmenu
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
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local languagesubmenu = LanguageSubmenu(devtools, root)
local LanguageSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Language", "LanguageSubmenu", #root + 1)

    -- general
    self.language = LANGUAGE
    self.loc = LOC

    -- options
    if LANGUAGE and LOC then
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- Helpers
-- @section helpers

local function AddLanguageOption(self, label, name)
    self:AddDoActionOption({
        label = label,
        on_accept_fn = function()
            local id = LANGUAGE[name]
            LOC.SwapLanguage(id)
            Profile:SetLanguageID(id)
            self.screen:Close()
        end,
    })
end

--- General
-- @section general

--- Adds options.
function LanguageSubmenu:AddOptions()
    for name, id in pairs(LANGUAGE) do
        local str = STRINGS.PRETRANSLATED.LANGUAGES[id]
        if str then
            AddLanguageOption(self, str, name)
        end
    end
end

return LanguageSubmenu
