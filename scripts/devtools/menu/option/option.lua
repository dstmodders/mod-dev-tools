----
-- Base option.
--
-- Includes base option functionality and may be extended by other option classes.
--
--    local option = Option({
--        name = "your_option", -- optional
--        label = "Your option", -- or table: { name = "Your option" }
--        on_accept_fn = function(self, submenu, textmenu)
--            print("Your option is accepted")
--        end,
--        on_cursor_fn = function(self, submenu, textmenu)
--            print("Your option is selected")
--        end,
--    }, submenu)
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.Option
-- @see menu.option.ActionOption
-- @see menu.option.CheckboxOption
-- @see menu.option.ChoicesOption
-- @see menu.option.DividerOption
-- @see menu.option.NumericOption
-- @see menu.option.SubmenuOption
-- @see menu.option.ToggleCheckboxOption
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.4.0
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
-- @tparam menu.Submenu submenu
-- @usage local option = Option(options, submenu)
local Option = Class(function(self, options, submenu)
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
    self.submenu = submenu

    if not options.name then
        self.name = self.label
    end

    -- callbacks
    self.on_accept_fn = options.on_accept_fn
    self.on_cursor_fn = options.on_cursor_fn

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
-- @tparam menu.TextMenu textmenu
function Option:OnAccept(textmenu)
    if type(self.on_accept_fn) == "function" or type(self.on_accept_fn) == "table" then
        self.on_accept_fn(self, self.submenu, textmenu)
    end
end

--- Triggers when focused.
-- @tparam menu.TextMenu textmenu
function Option:OnCursor(textmenu)
    if type(self.on_cursor_fn) == "function" or type(self.on_accept_fn) == "table" then
        self.on_cursor_fn(self, self.submenu, textmenu)
    end
end

--- Triggers when cancelled.
-- @tparam menu.TextMenu textmenu
function Option:OnCancel(textmenu) -- luacheck: only
    return textmenu:Pop()
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
