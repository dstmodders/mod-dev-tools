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
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod menu.option.ActionOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
----
require "class"

local Option = require "devtools/menu/option/option"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @usage local actionoption = ActionOption(options, submenu)
local ActionOption = Class(Option, function(self, options, submenu)
    Option._ctor(self, options, submenu)
end)

return ActionOption
