----
-- Toggle data option.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @module submenus.option.Toggle
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
require "devtools/constants"

--- Toggle data option.
-- @function Toggle
-- @tparam string field Field name in `menu.Submenu`
-- @tparam string label Label name
-- @tparam string get_name Get method name
-- @tparam string set_fn Set method name
-- @tparam function on_add_to_root_fn Function to check if an option can be added
-- @usage local toggle = Toggle(field, label, get_name, set_fn)
return function(field, label, get_name, set_name, on_add_to_root_fn)
    return {
        type = MOD_DEV_TOOLS.OPTION.TOGGLE_CHECKBOX,
        on_add_to_root_fn = on_add_to_root_fn,
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
