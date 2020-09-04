----
-- Toggle data option.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.option.Toggle
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "devtools/constants"

--- Toggle data option.
-- @function Toggle
-- @tparam string field Field name in `menu.Submenu`
-- @tparam string label Label name
-- @tparam string get_name Get method name
-- @tparam string set_fn Set method name
-- @usage local toggle = Toggle(field, label, get_name, set_fn)
return function(field, label, get_name, set_name)
    return {
        type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
        options = {
            label = label,
            get = {
                src = function(_, submenu)
                    return submenu[field]
                end,
                name = get_name,
            },
            set = {
                src = function(_, submenu)
                    return submenu[field]
                end,
                name = set_name,
            },
        },
    }
end
