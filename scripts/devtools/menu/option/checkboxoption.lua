----
-- Checkbox option.
--
-- Extends `menu.option.Option`.
--
--    local checkboxoption = CheckboxOption({
--        name = "your_option", -- optional
--        label = {
--            name = "Your option",
--            left = true,
--            prefix = "(prefix) ",
--        },
--        on_accept_fn = function(self, submenu, textmenu)
--            print("Your option is accepted")
--        end,
--        on_cursor_fn = function(self, submenu, textmenu)
--            print("Your option is selected")
--        end,
--        on_get_fn = function(self, submenu)
--            return true -- enabled
--        end,
--        on_set_fn = function(self, submenu, value)
--            print("Your option has changed: " .. tostring(value))
--        end,
--    }, submenu)
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.CheckboxOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0
----
require "class"

local Option = require "devtools/menu/option/option"

--- Class
-- @section class

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @tparam menu.Submenu submenu
-- @usage local checkboxoption = CheckboxOption(options, submenu)
local CheckboxOption = Class(Option, function(self, options, submenu)
    Option._ctor(self, options, submenu)

    -- asserts (label)
    if type(options.label) == "table" then
        self._OptionType(options.label.left, "label.left", "boolean", true)
        self._OptionType(options.label.prefix, "label.prefix", "string", true)
    end

    -- general
    self.current = false

    -- options
    self.on_get_fn = options.on_get_fn
    self.on_set_fn = options.on_set_fn
end)

--- Navigation
-- @section navigation

--- Left.
function CheckboxOption:Left()
    self.current = false
    self.on_set_fn(self, self.submenu, false)
end

--- Right.
function CheckboxOption:Right()
    self.current = true
    self.on_set_fn(self, self.submenu, true)
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function CheckboxOption:__tostring()
    local label = Option.__tostring(self)
    local value = self.on_get_fn
        and (self.on_get_fn(self, self.submenu) and "true" or "false")
        or tostring(self.current)

    if type(self.label) == "table" and self.label.left then
        local spaces = value == "true" and "   " or "  "
        local prefix = self.label.prefix
        return prefix and string.len(prefix) > 0
            and string.format("%s%s    [ %s ]", prefix, label, value)
            or string.format("[ %s ]%s%s", value, spaces, label)
    end

    local prefix = type(self.label) == "table" and self.label.prefix
    return prefix and string.len(prefix) > 0
        and string.format("%s%s    [ %s ]", prefix, label, value)
        or string.format("%s    [ %s ]", label, value)
end

return CheckboxOption
