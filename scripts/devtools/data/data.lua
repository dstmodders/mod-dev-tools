----
-- Base data.
--
-- Includes base data functionality and must be extended by other data classes. Shouldn't be used
-- on its own.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod data.Data
-- @see data.FrontEndData
-- @see data.RecipeData
-- @see data.SelectedData
-- @see data.SelectedTagsData
-- @see data.WorldData
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0-alpha
----
require "class"

local Utils = require "devtools/utils"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @usage local data = Data(screen)
local Data = Class(function(self, screen)
    Utils.Debug.AddMethods(self)

    -- general
    self.index = screen and screen.data_sidebar_idx
    self.screen = screen
    self.stack = {}
end)

--- General
-- @section general

--- Moves current cursor up.
-- @tparam[opt] number idx
-- @treturn number
function Data:Up(idx)
    self.index = idx ~= nil and idx or self.index
    if #self.stack > 0 and self.index > 1 then
        self.index = self.index - 1
    end
    return self.index
end

--- Moves current cursor down.
-- @tparam[opt] number idx
-- @treturn number
function Data:Down(idx)
    self.index = idx ~= nil and idx or self.index
    if #self.stack > 0 and self.index < #self.stack - self.screen.size_height + 3 then
        self.index = self.index + 1
    end
    return self.index
end

--- Clears stack.
function Data:Clear()
    self.stack = {}
end

--- Updates stack.
function Data:Update()
    self:Clear()
end

--- Returns divider scroll string.
-- @tparam number value
-- @tparam string symbol
-- @treturn string
function Data:DividerScroll(value, symbol)
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

--- Line
-- @section line

--- Pushes title line into stack.
function Data:PushEmptyLine()
    table.insert(self.stack, " ")
end

--- Pushes title line into stack.
-- @tparam string title
function Data:PushTitleLine(title)
    if type(title) == "string" then
        table.insert(self.stack, string.format("***** %s *****", string.upper(title)))
    end
end

--- Pushes line into stack.
-- @tparam string name
-- @tparam table|string value
function Data:PushLine(name, value) -- luacheck: only
    if value == nil then
        return
    end

    if type(value) == "table" and #value > 0 then
        value = Utils.String.TableSplit(value)
    end

    table.insert(self.stack, (name and string.len(name) > 0)
        and string.format("%s: %s", name, value)
        or value)
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function Data:__tostring()
    if #self.stack == 0 then
        return
    end

    local t, scroll_size, scroll_hidden

    t = {}
    scroll_size = self.screen.size_height - 3
    scroll_hidden = #self.stack - self.index - scroll_size

    for i = self.index, #self.stack do
        table.insert(t, tostring(self.stack[i]) .. "\n")
    end

    if scroll_hidden > 0 then
        t[scroll_size + 1] = self:DividerScroll(scroll_hidden + 1)
    end

    return table.concat(t)
end

return Data
