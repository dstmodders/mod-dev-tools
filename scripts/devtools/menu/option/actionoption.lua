----
-- Action option.
--
-- Extends `menu.option.Option` but doesn't add anything. It's a leftover from my original mod based
-- on which this mod has been created.
--
-- Not removed for convenience to differentiate from the base option.
--
--    local actionoption = ActionOption({
--        name = "your_option", -- optional
--        label = "Your option", -- or table: { name = "Your option" }
--        on_accept_fn = function(self, submenu, textmenu)
--            print("Your option is accepted")
--        end,
--        on_cursor_fn = function(self, submenu, textmenu)
--            print("Your option is selected")
--        end,
--    }, submenu)
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.ActionOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.2.0-alpha
----
require "class"

local Option = require "devtools/menu/option/option"

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @usage local actionoption = ActionOption(options, submenu)
local ActionOption = Class(Option, function(self, options, submenu)
    Option._ctor(self, options, submenu)
end)

return ActionOption
