----
-- Debug option.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.Debug.DebugOption
-- @see submenus.Debug
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "devtools/constants"

return function(label, debug_keys, on_add_to_root_fn)
    if type(debug_keys) == "table" then
        return {
            type = MOD_DEV_TOOLS.OPTION.CHECKBOX,
            on_add_to_root_fn = on_add_to_root_fn,
            options = {
                label = {
                    name = label,
                    left = true,
                },
                on_get_fn = function(_, submenu)
                    for _, debug_key in pairs(debug_keys) do
                        if not submenu.debug:IsDebug(debug_key) then
                            return false
                        end
                    end
                    return true
                end,
                on_set_fn = function(_, submenu, value)
                    for _, debug_key in pairs(debug_keys) do
                        submenu.debug:SetIsDebug(debug_key, value)
                    end
                end,
            },
        }
    elseif type(debug_keys) == "string" then
        return {
            type = MOD_DEV_TOOLS.OPTION.CHECKBOX,
            on_add_to_root_fn = on_add_to_root_fn,
            options = {
                label = {
                    name = label,
                    left = true,
                },
                on_get_fn = function(_, submenu)
                    return submenu.debug:IsDebug(debug_keys)
                end,
                on_set_fn = function(_, submenu, value)
                    submenu.debug:SetIsDebug(debug_keys, value)
                end,
            },
        }
    end
end
