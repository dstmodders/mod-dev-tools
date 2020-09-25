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
--                 on_accept_fn = function(self, submenu, textmenu)
--                     print("Your option is accepted")
--                 end,
--             }),
--         },
--     }, submenu)
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.SubmenuOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.6.0-alpha
----
require "class"

local DividerOption = require "devtools/menu/option/divideroption"
local ActionOption = require "devtools/menu/option/actionoption"
local Option = require "devtools/menu/option/option"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @tparam menu.Submenu submenu
-- @usage local submenuoption = SubmenuOption(options, submenu)
local SubmenuOption = Class(Option, function(self, options, submenu)
    Option._ctor(self, options, submenu)

    -- asserts
    self._OptionType(options.options, "options", "table")

    -- options
    self.options = options.options
end)

--- Callbacks
-- @section callbacks

--- Triggers when accepted.
-- @tparam menu.TextMenu textmenu
function SubmenuOption:OnAccept(textmenu)
    local options = shallowcopy(self.options)
    table.insert(options, DividerOption())
    table.insert(options, ActionOption({
        label = "Back",
        on_accept_fn = function()
            textmenu:Pop()
        end,
    }))
    textmenu:PushOptions(options, self.name)
    Option.OnAccept(self, textmenu)
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function SubmenuOption:__tostring()
    return Option.__tostring(self) .. "..."
end

return SubmenuOption
