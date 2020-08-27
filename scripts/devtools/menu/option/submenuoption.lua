----
-- Submenu option.
--
-- Extends `menu.option.Option`.
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
local DoActionOption = require "devtools/menu/option/doactionoption"
local Option = require "devtools/menu/option/option"

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
-- @tparam TextMenu text_menu
function SubmenuOption:OnAccept(text_menu)
    local options = shallowcopy(self.options)
    table.insert(options, DividerOption())
    table.insert(options, DoActionOption({
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
