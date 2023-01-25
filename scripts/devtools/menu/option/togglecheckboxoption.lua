----
-- Toggle checkbox option.
--
-- Extends `menu.option.Option` and is very similar to `menu.option.CheckboxOption` except it
-- auto-adds `on_get_fn` and `on_set_fn` based on the provided `get` and `src` values.
--
--    local togglecheckboxoption = ToggleCheckboxOption({
--        name = "fog_of_war", -- optional
--        label = "Fog of War",
--        get = {
--            src = worlddevtools, -- can be a function, see "set" as a reference
--            name = "IsMapFogOfWar",
--        },
--        set = {
--            src = function(self, submenu) -- can be a field, see "get" as a reference
--                return submenu.devtools.world
--            end,
--            name = "ToggleMapFogOfWar",
--        },
--        on_accept_fn = function(self, submenu, textmenu)
--            print("Your option is accepted")
--        end,
--        on_cursor_fn = function(self, submenu, textmenu)
--            print("Your option is selected")
--        end,
--    }, submenu)
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod menu.option.ToggleCheckboxOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
----
require "class"

local CheckboxOption = require "devtools/menu/option/checkboxoption"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @tparam menu.Submenu submenu
-- @usage local togglecheckboxoption = ToggleCheckboxOption(options, submenu)
local ToggleCheckboxOption = Class(CheckboxOption, function(self, options, submenu)
    local label
    if type(options.label) == "string" then
        label = options.label
        if not label:match("^Toggle ") then
            options.label = "Toggle " .. label
        end
    elseif type(options.label) == "table" and options.label.name then
        label = options.label.name
        if not label:match("^Toggle ") then
            options.label.name = "Toggle " .. label
        end
    end

    local set_src = options.set.src
    local get_src = options.get.src

    options.on_get_fn = function()
        get_src = type(get_src) == "function" and get_src(self, submenu) or get_src
        return get_src[options.get.name](get_src)
    end

    options.on_set_fn = function(value)
        set_src = type(set_src) == "function" and set_src(self, submenu) or set_src
        if value ~= get_src[options.get.name](get_src) then
            set_src[options.set.name](set_src)
        end
    end

    CheckboxOption._ctor(self, options, submenu)
end)

return ToggleCheckboxOption
