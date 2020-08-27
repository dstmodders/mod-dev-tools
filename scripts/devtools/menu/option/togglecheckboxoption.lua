----
-- Toggle checkbox option.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.option.ToggleCheckboxOption
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local CheckboxOption = require "devtools/menu/option/checkboxoption"

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
