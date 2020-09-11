----
-- Text menu.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.TextMenu
-- @see menu.Menu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.2.0
----
require "class"

--- Constructor.
-- @function _ctor
-- @tparam[opt] string name
-- @usage local textmenu = TextMenu()
local TextMenu = Class(function(self, name)
    self.index = 1
    self.stack_idx = {}
    self.stack_names = {}
    self.stack_options = {}
    self.title = name or "TextMenu"
end)

--- General
-- @section general

--- Gets index.
-- @treturn number
function TextMenu:GetIndex()
    return self.index
end

--- Sets index.
-- @tparam number idx
function TextMenu:SetIndex(idx)
    self.index = idx
end

--- Gets current option.
-- @treturn number
function TextMenu:GetOption()
    if #self.stack_options > 0 then
        return self.stack_options[#self.stack_options][self.index]
    end
end

--- Pushes provided options.
-- @tparam table options
-- @tparam string name
function TextMenu:PushOptions(options, name)
    -- name
    self.name = name or self.name
    table.insert(self.stack_names, self.name)

    -- index
    if #self.stack_options > 0 then
        table.insert(self.stack_idx, self.index)
    end
    self.index = 1

    -- options
    table.insert(self.stack_options, options)
end

--- Navigation
-- @section navigation

--- Checks if at root.
function TextMenu:AtRoot()
    return #self.stack_options <= 1
end

--- Moves current options cursor up.
function TextMenu:Up()
    if #self.stack_options > 0 then
        local index = self.index - 1
        local option = self.stack_options[#self.stack_options][index]

        if option and option.is_divider then
            index = index - 1
        end

        self.index = index
        if self.index == 0 then
            if #self.stack_options[#self.stack_options] > 0 then
                self.index = #self.stack_options[#self.stack_options]
            else
                self.index = 1
            end
        end

        option = self:GetOption()
        if option and option.OnCursor then
            option:OnCursor(self)
        end
    end
end

--- Moves current options cursor down.
function TextMenu:Down()
    if #self.stack_options > 0 then
        local index = self.index + 1
        local option = self.stack_options[#self.stack_options][index]
        if option and option.is_divider then
            index = index + 1
            option:OnCursor()
        end

        self.index = index
        if self.index > #self.stack_options[#self.stack_options] then
            self.index = 1
        end

        option = self:GetOption()
        if option then
            option:OnCursor()
        end
    end
end

--- Moves current options cursor left.
function TextMenu:Left()
    local option = self:GetOption()
    if option then
        option:Left(self)
    end
end

--- Moves current options cursor right.
function TextMenu:Right()
    local option = self:GetOption()
    if option then
        option:Right(self)
    end
end

--- Accepts current option.
function TextMenu:Accept()
    local option = self:GetOption()
    if option and option.OnAccept then
        option:OnAccept(self)
        option = self:GetOption()
        if option and option.OnCursor then
            option:OnCursor(self)
        end
    end
end

--- Cancels current option.
function TextMenu:Cancel()
    local option = self:GetOption()
    if option and option.OnCancel then
        return option:OnCancel(self)
    end
end

--- Pops the current options stack.
function TextMenu:Pop()
    if #self.stack_options > 1 then
        table.remove(self.stack_options)

        if #self.stack_idx > 0 then
            self.index = table.remove(self.stack_idx)
        end

        if #self.stack_names > 0 then
            self.name = table.remove(self.stack_names)
        end

        return true
    end
end

--- Other
-- @section other

local function Divider(size, symbol)
    size = size == nil and 50 or size
    symbol = symbol == nil and "-" or symbol

    local str = ""
    for _ = 1, size do
        str = str .. symbol
    end

    return str
end

local function DividerScroll(value, size, symbol)
    size = size == nil and 50 or size
    symbol = symbol == nil and "_" or symbol

    local str
    local half = math.abs(size / 2)

    str = Divider(half - 2, symbol)
    str = str .. " " .. value .. " "
    str = str .. Divider(half - (value > 9 and 3 or 2), symbol)

    return str
end

local function Spacing(size)
    size = size == nil and 9 or size
    return Divider(size, " ")
end

local function Cursor(size)
    size = size == nil and 6 or size - 3

    local str

    str = Divider(size, " ")
    str = str .. "> "

    return str
end

local function TableInsertOption(self, t, divider_size, key, option)
    local pre

    if option.is_divider then
        option:SetLabel(Divider(divider_size))
    else
        pre = key == self.index and Cursor() or Spacing()
    end

    table.insert(t, pre)
    table.insert(t, tostring(option))
    table.insert(t, "\n")
end

--- __tostring
-- @treturn string
function TextMenu:__tostring()
    local t, divider_size, scroll_size, scroll_half, scroll_top, scroll_bottom

    t = {}
    divider_size = 54
    scroll_size = 18
    scroll_half = math.abs(scroll_size / 2)
    scroll_top = 1
    scroll_bottom = scroll_size + 1

    table.insert(t, "***** ")
    table.insert(t, string.upper(self.title))
    table.insert(t, " *****\n\n")

    if #self.stack_options > 0 then
        local options = self.stack_options[#self.stack_options]
        local scroll_hidden = #options - scroll_size - 1

        for k, v in pairs(options) do
            if self.index > scroll_half then
                scroll_top = scroll_half + (self.index - scroll_size)
                scroll_bottom = self.index + scroll_half
                scroll_hidden = #options - self.index - scroll_half
            end

            if self.index > #options - scroll_half then
                scroll_top = #options - scroll_size
                scroll_bottom = #options
                scroll_hidden = 0
            end

            if k >= scroll_top and k <= scroll_bottom then
                TableInsertOption(self, t, divider_size, k, v)
            end
        end

        if scroll_hidden > 0 and #options > scroll_size then
            table.insert(t, DividerScroll(scroll_hidden, divider_size - 2))
            table.insert(t, "\n")
        end
    end

    return table.concat(t)
end

return TextMenu
