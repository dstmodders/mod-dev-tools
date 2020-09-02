----
-- Do action option.
--
-- _**NB!** This option may be removed in the upcoming version._
--
-- Extends `menu.option.Option` but doesn't add anything. It's a leftover from my private one based
-- on which this mod has been created.
--
--    local actionoption = ActionOption({
--        name = "your_option", -- optional
--        label = "Your option",
--        on_accept_fn = function()
--            print("Your option is accepted")
--        end,
--        on_cursor_fn = function()
--            print("Your option is selected")
--        end,
--    })
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.ActionOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Option = require "devtools/menu/option/option"

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @usage local actionoption = ActionOption({
--     name = "your_option", -- optional
--     label = "Your option",
--     on_accept_fn = function()
--         print("Your option is accepted")
--     end,
--     on_cursor_fn = function()
--         print("Your option is selected")
--     end,
-- })
local ActionOption = Class(Option, function(self, options)
    Option._ctor(self, options)
end)

return ActionOption
