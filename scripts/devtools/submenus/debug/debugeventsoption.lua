----
-- Debug events option.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module submenus.Debug.DebugEventsOption
-- @see submenus.Debug
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "devtools/constants"

return function(name, activate, deactivate, on_add_to_root_fn)
    return {
        type = MOD_DEV_TOOLS.OPTION.CHECKBOX,
        on_add_to_root_fn = on_add_to_root_fn,
        options = {
            label = {
                name = name,
                left = true,
            },
            on_get_fn = function(_, submenu)
                return submenu.debug:IsDebug(name)
            end,
            on_set_fn = function(_, submenu, value)
                if value ~= submenu.debug:IsDebug(name) then
                    submenu.debug:SetIsDebug(name, value)
                    local events = submenu.debug:GetEvents()
                    return value and events[activate](events) or events[deactivate](events)
                end
            end,
        },
    }
end
