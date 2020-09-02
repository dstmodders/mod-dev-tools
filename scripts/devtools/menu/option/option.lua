----
-- Base option.
--
-- Includes base option functionality and may be extended by other option classes.
--
--    local option = Option({
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
-- @classmod menu.option.Option
-- @see menu.option.CheckboxOption
-- @see menu.option.ChoicesOption
-- @see menu.option.DividerOption
-- @see menu.option.ActionOption
-- @see menu.option.NumericOption
-- @see menu.option.SubmenuOption
-- @see menu.option.ToggleCheckboxOption
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

--- Helpers
-- @section helpers

local function OptionRequired(field, name)
    assert(field ~= nil, "Option " .. name .. " is required")
end

local function OptionType(field, name, _type, is_optional)
    if is_optional and not field then
        return
    end
    OptionRequired(field, name)
    assert(type(field) == _type, string.format(
        "Option %s should be a %s",
        name,
        _type
    ))
end

--- Class
-- @section class

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @usage local option = Option({
--     name = "your_option", -- optional
--     label = "Your option",
--     on_accept_fn = function()
--         print("Your option is accepted")
--     end,
--     on_cursor_fn = function()
--         print("Your option is selected")
--     end,
-- })
local Option = Class(function(self, options)
    -- asserts (general)
    assert(type(options) == "table", "Options must be a table")

    -- asserts (label)
    OptionRequired(options.label, "label")
    assert(
        (type(options.label) == "table" or type(options.label) == "string"),
        "Option label should be either a table or a string"
    )

    if type(options.label) == "table" then
        OptionRequired(options.label.name, "label.name")
        OptionType(options.label.name, "label.name", "string")
    end

    -- options
    self.label = options.label
    self.name = options.name
    self.on_accept_fn = options.on_accept_fn
    self.on_cursor_fn = options.on_cursor_fn

    if not options.name then
        self.name = self.label
    end

    -- local
    self._OptionRequired = OptionRequired
    self._OptionType = OptionType
end)

--- General
-- @section general

--- Gets name.
-- @treturn string
function Option:GetName()
    return self.name
end

--- Gets label.
-- @treturn string
function Option:GetLabel()
    return self.label
end

--- Sets label.
-- @tparam string label
function Option:SetLabel(label)
    self.label = label
end

--- Navigation
-- @section navigation

--- Left.
function Option:Left() -- luacheck: only
end

--- Right.
function Option:Right() -- luacheck: only
end

--- Callbacks
-- @section callbacks

--- Triggers when accepted.
-- @tparam menu.TextMenu text_menu
function Option:OnAccept(text_menu)
    if self.on_accept_fn then
        self.on_accept_fn(text_menu)
    end
end

--- Triggers when focused.
-- @tparam menu.TextMenu text_menu
function Option:OnCursor(text_menu)
    if self.on_cursor_fn then
        self.on_cursor_fn(text_menu)
    end
end

--- Triggers when cancelled.
-- @tparam menu.TextMenu text_menu
function Option:OnCancel(text_menu) -- luacheck: only
    return text_menu:Pop()
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function Option:__tostring()
    local label

    if type(self.label) == "table" and self.label.name then
        label = self.label.name
    else
        label = self.label
    end

    if type(label) == "function" then
        label = label()
    end

    if type(label) == "string" then
        label = label:gsub("\n.*", "") -- only keep the first line
        return label
    end

    return "???"
end

return Option
