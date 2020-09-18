----
-- Divider option.
--
-- Extends `menu.option.Option`.
--
--    local divideroption = DividerOption(submenu)
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.DividerOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.3.0-alpha
----
require "class"

local Option = require "devtools/menu/option/option"

--- Constructor.
-- @function _ctor
-- @tparam menu.Submenu submenu
-- @usage local divideroption = DividerOption(submenu)
local DividerOption = Class(Option, function(self, submenu)
    Option._ctor(self, { label = "" }, submenu)
    self.is_divider = true
end)

return DividerOption
