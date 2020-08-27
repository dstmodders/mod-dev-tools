----
-- Choices option.
--
-- Extends `menu.option.Option`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.ChoicesOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Option = require "devtools/menu/option/option"
local Utils = require "devtools/utils"

--- Helpers
-- @section helpers

local function GetTableKeyByValue(list, value)
    for k, v in pairs(list) do
        if v.value == value
            or (type(v.value) == "table"
            and Utils.TableCompare(v.value, value))
        then
            return k
        end
    end
end

local function GetLeftKeyValue(self, key)
    local key_prev, value

    key = key ~= nil and key or self.key
    key_prev = key - 1
    key_prev = self.choices[key_prev] and key_prev or 1
    self.key = key_prev

    value = self.choices[key_prev].value
    if value == "nil" then
        value = nil
    end

    return value
end

local function GetRightKeyValue(self, key)
    local key_next, value

    key = key ~= nil and key or self.key
    key_next = key + 1
    key_next = self.choices[key_next] and key_next or #self.choices
    self.key = key_next

    value = self.choices[key_next].value
    if value == "nil" then
        value = nil
    end

    return value
end

--- Class
-- @section class

local ChoicesOption = Class(Option, function(self, options)
    Option._ctor(self, options)

    -- asserts
    self._OptionType(options.choices, "choices", "table")

    -- general
    self.key = 1

    -- options
    self.choices = options.choices
    self.on_get_fn = options.on_get_fn
    self.on_set_fn = options.on_set_fn

    if self.choices and self.on_get_fn then
        self.key = GetTableKeyByValue(self.choices, self.on_get_fn())
    end
end)

--- Navigation
-- @section navigation

--- Left.
function ChoicesOption:Left()
    if self.on_get_fn then
        local key = GetTableKeyByValue(self.choices, self.on_get_fn())
        if key then
            self.on_set_fn(GetLeftKeyValue(self, key), key)
        end
    elseif self.key then
        GetLeftKeyValue(self)
    end
end

--- Right.
function ChoicesOption:Right()
    if self.on_get_fn then
        local key = GetTableKeyByValue(self.choices, self.on_get_fn())
        if key then
            self.on_set_fn(GetRightKeyValue(self, key), key)
        end
    elseif self.key then
        GetRightKeyValue(self)
    end
end

--- Callbacks
-- @section callbacks

--- Triggers when accepted.
-- @tparam TextMenu text_menu
function ChoicesOption:OnAccept()
    if not self.on_get_fn and self.key then
        local choice = self.choices[self.key]
        if choice and choice.value then
            self.on_set_fn(self.choices[self.key].value, self.key)
        end
    end
    Option.OnAccept(self)
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function ChoicesOption:__tostring()
    local key = self.key
    local label = Option.__tostring(self)

    if self.on_get_fn and self.choices then
        key = GetTableKeyByValue(self.choices, self.on_get_fn())
    end

    return key and label .. "    [ " .. tostring(self.choices[key].name) .. " ]" or label
end

return ChoicesOption
