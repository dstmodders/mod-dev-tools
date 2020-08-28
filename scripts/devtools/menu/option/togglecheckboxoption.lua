----
-- Toggle checkbox option.
--
-- Extends `menu.option.Option` and is very similar to `menu.option.CheckboxOption` except it
-- auto-adds `on_get_fn` and `on_set_fn` based on the provided `get` and `src` values.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.ToggleCheckboxOption
-- @see menu.option.Option
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local CheckboxOption = require "devtools/menu/option/checkboxoption"

--- Constructor.
-- @function _ctor
-- @tparam table options
-- @usage local togglecheckboxoption = ToggleCheckboxOption({
--     name = "fog_of_war", -- optional
--     label = "Fog of War",
--     get = { src = worlddevtools, name = "IsMapFogOfWar" },
--     set = { src = worlddevtools, name = "ToggleMapFogOfWar" }
--     on_accept_fn = function()
--         print("Your option is accepted")
--     end,
--     on_cursor_fn = function()
--         print("Your option is selected")
--     end,
-- })
local ToggleCheckboxOption = Class(CheckboxOption, function(self, options)
    if type(options.label) == "string" then
        options.label = "Toggle " .. options.label
    elseif type(options.label) == "table" and options.label.name then
        options.label.name = "Toggle " .. options.label.name
    end

    options.on_get_fn = function()
        return options.get.src[options.get.name](options.get.src)
    end

    options.on_set_fn = function(value)
        if value ~= options.get.src[options.get.name](options.get.src) then
            options.set.src[options.set.name](options.set.src)
        end
    end

    CheckboxOption._ctor(self, options)
end)

return ToggleCheckboxOption
