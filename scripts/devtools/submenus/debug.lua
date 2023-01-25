----
-- Debug submenu.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @module submenus.Debug
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
----
require("devtools/constants")

local _TOGGLE_ALL_MOUSE_CLICKS = { "lmb", "rmb" }

local _TOGGLE_ALL_EVENTS = {
    ["ThePlayer"] = { "ActivatePlayer", "DeactivatePlayer" },
    ["ThePlayer.player_classified"] = { "ActivatePlayerClassified", "DeactivatePlayerClassified" },
    ["TheWorld"] = { "ActivateWorld", "DeactivateWorld" },
}

local _TOGGLE_ALL_REMOTES = {
    "RemoteActionButton",
    "RemoteAttackButton",
    "RemoteBufferedAction",
    "RemoteDirectWalking",
    "RemoteDragWalking",
    "RemoteDropItemFromInvTile",
    "RemoteInspectButton",
    "RemoteInspectItemFromInvTile",
    "RemoteMakeRecipeAtPoint",
    "RemoteMakeRecipeFromMenu",
    "RemotePredictWalking",
    "RemoteStopWalking",
    "RemoteUseItemFromInvTile",
}

local function Debug(label, debug_keys, on_add_to_root_fn)
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

local function DebugEvents(name, activate, deactivate, on_add_to_root_fn)
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

return {
    label = "Debug",
    name = "DebugSubmenu",
    on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_PLAYER,
    options = {
        {
            type = MOD_DEV_TOOLS.OPTION.CHECKBOX,
            options = {
                label = {
                    name = "Toggle All (Events)",
                    left = true,
                },
                name = "DebugToggleAllEvents",
                on_get_fn = function(_, submenu)
                    for debug_key, _ in pairs(_TOGGLE_ALL_EVENTS) do
                        if not submenu.debug:IsDebug(debug_key) then
                            return false
                        end
                    end
                    return true
                end,
                on_set_fn = function(_, submenu, value)
                    for debug_key, functions in pairs(_TOGGLE_ALL_EVENTS) do
                        if value ~= submenu.debug:IsDebug(debug_key) then
                            submenu.debug:SetIsDebug(debug_key, value)
                            local events = submenu.debug:GetEvents()
                            events[value and functions[1] or functions[2]](events)
                        end
                    end
                end,
            },
        },
        Debug("Toggle All (Mouse Clicks)", _TOGGLE_ALL_MOUSE_CLICKS),
        Debug(
            "Toggle All (Remotes)",
            _TOGGLE_ALL_REMOTES,
            MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_NOT_MASTER_SIM
        ),
        Debug(
            "Toggle All (SendRPCToServer)",
            "rpc",
            MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_NOT_MASTER_SIM
        ),
        { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
        {
            type = MOD_DEV_TOOLS.OPTION.SUBMENU,
            options = {
                label = "Events",
                name = "DebugEventsSubmenu",
                options = {
                    DebugEvents("ThePlayer", "ActivatePlayer", "DeactivatePlayer"),
                    DebugEvents(
                        "ThePlayer.player_classified",
                        "ActivatePlayerClassified",
                        "DeactivatePlayerClassified"
                    ),
                    { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
                    DebugEvents("TheWorld", "ActivateWorld", "DeactivateWorld"),
                },
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.SUBMENU,
            options = {
                label = "Mouse Clicks",
                name = "DebugMouseClicksSubmenu",
                options = {
                    Debug("Left Mouse Button (LMB)", "lmb"),
                    Debug("Right Mouse Button (RMB)", "rmb"),
                },
            },
        },
        {
            type = MOD_DEV_TOOLS.OPTION.SUBMENU,
            options = {
                label = "Remote",
                name = "DebugRemoteSubmenu",
                on_add_to_root_fn = MOD_DEV_TOOLS.ON_ADD_TO_ROOT_FN.IS_NOT_MASTER_SIM,
                options = {
                    Debug("Action Button", "RemoteActionButton"),
                    Debug("Attack Button", "RemoteAttackButton"),
                    Debug("Inspect Button", "RemoteInspectButton"),
                    { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
                    Debug("Direct Walking", "RemoteDirectWalking"),
                    Debug("Drag Walking", "RemoteDragWalking"),
                    Debug("Predict Walking", "RemotePredictWalking"),
                    Debug("Stop Walking", "RemoteStopWalking"),
                    { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
                    Debug("Drop Item From Inventory Tile", "RemoteDropItemFromInvTile"),
                    Debug("Inspect Item From Inventory Tile", "RemoteInspectItemFromInvTile"),
                    Debug("Use Item From Inventory Tile", "RemoteUseItemFromInvTile"),
                    { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
                    Debug("Make Recipe At Point", "RemoteMakeRecipeAtPoint"),
                    Debug("Make Recipe From Menu", "RemoteMakeRecipeFromMenu"),
                    { type = MOD_DEV_TOOLS.OPTION.DIVIDER },
                    Debug("Buffered Action", "RemoteBufferedAction"),
                },
            },
        },
    },
}
