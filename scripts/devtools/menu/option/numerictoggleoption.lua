----
-- Numeric toggle option.
--
-- Extends `menu.option.Option`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.NumericToggleOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Option = require "devtools/menu/option/option"

local NumericToggleOption = Class(Option, function(self, options)
    Option._ctor(self, options)

    -- asserts
    self._OptionType(options.max, "max", "number")
    self._OptionType(options.min, "min", "number")
    self._OptionType(options.step, "step", "number", true)

    -- options
    self.max = options.max
    self.min = options.min
    self.on_get_fn = options.on_get_fn
    self.on_set_fn = options.on_set_fn
    self.step = options.step or 1
end)

--- Navigation
-- @section navigation

--- Left.
function NumericToggleOption:Left()
    local value = self.on_get_fn()
    if value > self.min then
        if TheInput:IsKeyDown(KEY_LSHIFT) or TheInput:IsKeyDown(KEY_RSHIFT) then
            self.on_set_fn(self.min)
        else
            self.on_set_fn(math.max(self.min, value - self.step))
        end
    end
end

--- Right.
function NumericToggleOption:Right()
    local value = self.on_get_fn()
    if value < self.max then
        if TheInput:IsKeyDown(KEY_LSHIFT) or TheInput:IsKeyDown(KEY_RSHIFT) then
            self.on_set_fn(self.max)
        else
            self.on_set_fn(math.min(self.max, value + self.step))
        end
    end
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function NumericToggleOption:__tostring()
    local label = Option.__tostring(self)
    if type(self.on_get_fn) == "function" and self.on_get_fn() then
        return label .. "    [ " .. tostring(self.on_get_fn()) .. " ]"
    end
    return label
end

return NumericToggleOption
