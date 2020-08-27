----
-- Do action option.
--
-- Extends `menu.option.Option`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.DoActionOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Option = require "devtools/menu/option/option"

local DoActionOption = Class(Option, function(self, options)
    Option._ctor(self, options)
end)

return DoActionOption
