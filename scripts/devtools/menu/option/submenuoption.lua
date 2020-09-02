----
-- Submenu option.
--
-- Extends `menu.option.Option`.
--
--     local submenuoption = SubmenuOption({
--         name = "your_submenu", -- optional
--         label = "Your submenu", -- label in the menu will be: "Your submenu..."
--         options = {
--             Option({
--                 name = "your_option", -- optional
--                 label = "Your option",
--                 on_accept_fn = function()
--                     print("Your option is accepted")
--                 end,
--             }),
--         },
--     })
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.SubmenuOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local DividerOption = require "devtools/menu/option/divideroption"
local ActionOption = require "devtools/menu/option/actionoption"
local Option = require "devtools/menu/option/option"

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @usage local submenuoption = SubmenuOption({
--     name = "your_submenu", -- optional
--     label = "Your submenu", -- label in the menu will be: "Your submenu..."
--     options = {
--         Option({
--             name = "your_option", -- optional
--             label = "Your option",
--             on_accept_fn = function()
--                 print("Your option is accepted")
--             end,
--         }),
--     },
-- })
local SubmenuOption = Class(Option, function(self, options)
    Option._ctor(self, options)

    -- asserts
    self._OptionType(options.options, "options", "table")

    -- options
    self.options = options.options
end)

--- Callbacks
-- @section callbacks

--- Triggers when accepted.
-- @tparam menu.TextMenu text_menu
function SubmenuOption:OnAccept(text_menu)
    local options = shallowcopy(self.options)
    table.insert(options, DividerOption())
    table.insert(options, ActionOption({
        label = "Back",
        on_accept_fn = function(_menu)
            _menu:Pop()
        end,
    }))
    text_menu:PushOptions(options, self.name)
    Option.OnAccept(self, text_menu)
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function SubmenuOption:__tostring()
    return Option.__tostring(self) .. "..."
end

return SubmenuOption
