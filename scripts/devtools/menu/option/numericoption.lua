----
-- Numeric toggle option.
--
-- Extends `menu.option.Option`.
--
--    local numericoption = NumericOption({
--        name = "your_option", -- optional
--        label = "Your option",
--        min = 1, -- or function: function(self, submenu) end
--        max = 100, -- or function: function(self, submenu) end
--        step = 5,
--        on_accept_fn = function(self, submenu, textmenu)
--            print("Your option is accepted")
--        end,
--        on_cursor_fn = function(self, submenu, textmenu)
--            print("Your option is selected")
--        end,
--        on_get_fn = function(self, submenu)
--            return 50
--        end,
--        on_set_fn = function(self, submenu, value)
--            print("Your option has changed: " .. tostring(value))
--        end,
--    }, submenu)
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.NumericOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.6.0-alpha
----
require "class"

local Option = require "devtools/menu/option/option"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @tparam menu.Submenu submenu
-- @usage local numericoption = NumericOption(options, submenu)
local NumericOption = Class(Option, function(self, options, submenu)
    Option._ctor(self, options, submenu)

    -- asserts
    --self._OptionType(options.max, "max", "number")
    --self._OptionType(options.min, "min", "number")
    --self._OptionType(options.step, "step", "number", true)

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
function NumericOption:Left()
    local min = type(self.min) == "function" and self.min(self, self.submenu) or self.min
    local step = type(self.step) == "function" and self.step(self, self.submenu) or self.step
    local value = self.on_get_fn(self, self.submenu)

    if value > min then
        if TheInput:IsKeyDown(KEY_SHIFT) then
            self.on_set_fn(self, self.submenu, min)
        else
            self.on_set_fn(self, self.submenu, math.max(min, value - step))
        end
    end
end

--- Right.
function NumericOption:Right()
    local max = type(self.max) == "function" and self.max(self, self.submenu) or self.max
    local step = type(self.step) == "function" and self.step(self, self.submenu) or self.step
    local value = self.on_get_fn(self, self.submenu)

    if value < max then
        if TheInput:IsKeyDown(KEY_SHIFT) then
            self.on_set_fn(self, self.submenu, max)
        else
            self.on_set_fn(self, self.submenu, math.min(max, value + step))
        end
    end
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function NumericOption:__tostring()
    local label = Option.__tostring(self)
    if type(self.on_get_fn) == "function" and self.on_get_fn(self, self.submenu) then
        return label .. "    [ " .. tostring(self.on_get_fn(self, self.submenu)) .. " ]"
    end
    return label
end

return NumericOption
