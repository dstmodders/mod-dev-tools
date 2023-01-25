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
-- @release 0.7.1
----
require "class"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam screen.DevToolsScreen screen
-- @tparam[opt] string name
-- @usage local textmenu = TextMenu()
local TextMenu = Class(function(self, screen, name)
    -- general
    self.index = 1
    self.screen = screen
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

--- Returns divider string.
-- @tparam[opt] string symbol
-- @treturn string
function TextMenu:Divider(symbol)
    symbol = symbol ~= nil and symbol or "-"

    local sizes = {
        [UIFONT] = 40,
        [TITLEFONT] = 40,
        [BUTTONFONT] = 40,
        [TALKINGFONT] = 40,

        [CHATFONT] = 61,
        [CHATFONT_OUTLINE] = 57,

        [HEADERFONT] = 52,

        [TALKINGFONT_WORMWOOD] = 52,
        [TALKINGFONT_HERMIT] = 52,

        [DIALOGFONT] = 60,

        [CODEFONT] = 46,

        [NEWFONT] = 49,
        [NEWFONT_SMALL] = 49,
        [NEWFONT_OUTLINE] = 49,
        [NEWFONT_OUTLINE_SMALL] = 49,

        [BODYTEXTFONT] = 52,
        [SMALLNUMBERFONT] = 52,
    }

    local str = ""
    local size = sizes[self.screen.font] or 52
    for _ = 1, size do
        str = str .. symbol
    end

    return str
end

--- Returns divider scroll string.
-- @tparam number value
-- @tparam string symbol
-- @treturn string
function TextMenu:DividerScroll(value, symbol)
    symbol = symbol ~= nil and symbol or "_"

    local sizes = {
        [UIFONT] = 45,
        [TITLEFONT] = 42,
        [BUTTONFONT] = 45,
        [TALKINGFONT] = 45,

        [CHATFONT] = 43,
        [CHATFONT_OUTLINE] = 40,

        [HEADERFONT] = 47,

        [TALKINGFONT_WORMWOOD] = 40,
        [TALKINGFONT_HERMIT] = 47,

        [DIALOGFONT] = 48,

        [CODEFONT] = 46,

        [NEWFONT] = 38,
        [NEWFONT_SMALL] = 38,
        [NEWFONT_OUTLINE] = 40,
        [NEWFONT_OUTLINE_SMALL] = 40,

        [BODYTEXTFONT] = 50,
        [SMALLNUMBERFONT] = 53,
    }

    local str
    local size = sizes[self.screen.font] or 50
    local half = math.ceil(size / 2)

    local offsets = {
        [UIFONT] = 2,
        [TITLEFONT] = 3,
        [BUTTONFONT] = 2,
        [TALKINGFONT] = 3,

        [CHATFONT] = 3,
        [CHATFONT_OUTLINE] = 0,

        [HEADERFONT] = 3,

        [TALKINGFONT_WORMWOOD] = 3,
        [TALKINGFONT_HERMIT] = 3,

        [CODEFONT] = 2,

        [NEWFONT] = 2,
        [NEWFONT_SMALL] = 2,
        [NEWFONT_OUTLINE] = 3,
        [NEWFONT_OUTLINE_SMALL] = 2,

        [BODYTEXTFONT] = 2,
        [SMALLNUMBERFONT] = 3,
    }

    local offset = offsets[self.screen.font] or 2

    str = string.rep(symbol, half - 2)
    str = str .. " " .. value .. " "
    str = str .. string.rep(symbol, half - (value > 9 and offset + 1 or offset))

    return str .. "\n"
end

--- Returns spacing string.
-- @treturn string
function TextMenu:Spacing()
    local sizes = {
        [UIFONT] = 7,
        [TITLEFONT] = 7,
        [BUTTONFONT] = 7,
        [TALKINGFONT] = 7,

        [CHATFONT] = 7,
        [CHATFONT_OUTLINE] = 7,

        [HEADERFONT] = 11,

        [TALKINGFONT_WORMWOOD] = 9,
        [TALKINGFONT_HERMIT] = 7,

        [DIALOGFONT] = 11,

        [CODEFONT] = 6,

        [NEWFONT] = 8,
        [NEWFONT_SMALL] = 8,
        [NEWFONT_OUTLINE] = 8,
        [NEWFONT_OUTLINE_SMALL] = 8,

        [BODYTEXTFONT] = 9,
        [SMALLNUMBERFONT] = 9,
    }

    return string.rep(" ", sizes[self.screen.font] or 9)
end

--- Returns cursor string.
-- @treturn string
function TextMenu:Cursor()
    local sizes = {
        [UIFONT] = 5,
        [TITLEFONT] = 5,
        [BUTTONFONT] = 5,
        [TALKINGFONT] = 5,

        [CHATFONT] = 4,
        [CHATFONT_OUTLINE] = 4,

        [HEADERFONT] = 8,

        [TALKINGFONT_WORMWOOD] = 7,
        [TALKINGFONT_HERMIT] = 5,

        [DIALOGFONT] = 8,

        [CODEFONT] = 4,

        [NEWFONT] = 6,
        [NEWFONT_SMALL] = 6,
        [NEWFONT_OUTLINE] = 6,
        [NEWFONT_OUTLINE_SMALL] = 6,

        [BODYTEXTFONT] = 6,
        [SMALLNUMBERFONT] = 6,
    }

    return string.rep(" ", sizes[self.screen.font] or 6) .. "> "
end

--- Returns title string.
-- @tparam[opt] string title
-- @treturn string
function TextMenu:Title(title)
    title = title ~= nil and title or self.title
    return "***** " .. string.upper(title) .. " *****\n\n"
end

--- Returns option string.
-- @tparam number key
-- @tparam menu.option.Option option
-- @treturn string
function TextMenu:Option(key, option)
    local pre = ""
    if option.is_divider then
        option:SetLabel(self:Divider())
    else
        pre = key == self.index and self:Cursor() or self:Spacing()
    end
    return pre .. tostring(option) .. "\n"
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

--- __tostring
-- @treturn string
function TextMenu:__tostring()
    local t = {}

    table.insert(t, self:Title())

    if #self.stack_options == 0 then
        return table.concat(t)
    end

    local scroll_size = self.screen.size_height - 3
    local scroll_half = math.floor(scroll_size / 2)
    local scroll_top = scroll_half + self.index - scroll_size - 1
    local options = self.stack_options[#self.stack_options]
    local scroll_hidden = #options - scroll_size + 1

    if self.index > scroll_half then
        scroll_hidden = #options - scroll_half - self.index + 1
    end

    if self.index == scroll_half then
        scroll_hidden = #options - scroll_half - self.index
    end

    if self.index > #options - scroll_half then
        scroll_top = #options - scroll_size
        scroll_hidden = 0
    end

    for k, option in pairs(options) do
        if k - 2 >= scroll_top then
            table.insert(t, self:Option(k, option))
        end
    end

    if scroll_hidden > 0 then
        t[scroll_size] = self:DividerScroll(scroll_hidden + 1)
    end

    return table.concat(t)
end

return TextMenu
