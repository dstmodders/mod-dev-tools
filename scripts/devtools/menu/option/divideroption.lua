----
-- Divider option.
--
-- Extends `menu.Option`.
--
--    local divideroption = DividerOption(submenu)
--
-- **Source Code:** [https://github.com/dstmodders/dst-mod-dev-tools](https://github.com/dstmodders/dst-mod-dev-tools)
--
-- @classmod menu.DividerOption
-- @see menu.Option
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local Option = require "devtools/menu/option/option"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam menu.Submenu submenu
-- @usage local divideroption = DividerOption(submenu)
local DividerOption = Class(Option, function(self, submenu)
    Option._ctor(self, { label = "" }, submenu)
    self.is_divider = true
end)

return DividerOption
