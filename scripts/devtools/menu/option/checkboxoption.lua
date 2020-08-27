----
-- Checkbox option.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.CheckboxOption
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Option = require "devtools/menu/option/option"

--
-- Class
--

local CheckboxOption = Class(Option, function(self, options)
    Option._ctor(self, options)

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

--
-- General
--

function CheckboxOption:Left()
    self.current = false
    self.on_set_fn(false)
end

function CheckboxOption:Right()
    self.current = true
    self.on_set_fn(true)
end

function CheckboxOption:__tostring()
    local label = Option.__tostring(self)
    local value = self.on_get_fn
        and (self.on_get_fn() and "true" or "false")
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
