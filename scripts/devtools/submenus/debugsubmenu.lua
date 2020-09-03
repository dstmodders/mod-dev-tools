----
-- Debug submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod submenus.DebugSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Utils = require "devtools/utils"
local Submenu = require "devtools/menu/submenu"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local debugsubmenu = DebugSubmenu(devtools, root)
local DebugSubmenu = Class(Submenu, function(self, devtools, root)
    Utils.Debug.AddMethods(self)
    Submenu._ctor(self, devtools, root, "Debug", "DebugSubmenu")

    -- general
    self.debug = devtools.debug
    self.player = devtools.player
    self.world = devtools.world

    -- options
    if self.debug and self.world and self.player then
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- Helpers
-- @section helpers

local function AddDebugOption(self, label, debug_keys)
    if type(debug_keys) == "table" then
        self:AddCheckboxOption({
            label = {
                name = label,
                left = true,
            },
            on_get_fn = function()
                for _, debug_key in pairs(debug_keys) do
                    if not self.debug:IsDebug(debug_key) then
                        return false
                    end
                end
                return true
            end,
            on_set_fn = function(_, _, value)
                for _, debug_key in pairs(debug_keys) do
                    self.debug:SetIsDebug(debug_key, value)
                end
            end,
        })
    elseif type(debug_keys) == "string" then
        self:AddCheckboxOption({
            label = {
                name = label,
                left = true,
            },
            on_get_fn = function()
                return self.debug:IsDebug(debug_keys)
            end,
            on_set_fn = function(_, _, value)
                self.debug:SetIsDebug(debug_keys, value)
            end,
        })
    end
end

local function AddDebugPlayerEventsOption(self)
    local name = "ThePlayer"
    self:AddCheckboxOption({
        label = {
            name = string.format("Events (%s)", name),
            left = true,
        },
        on_get_fn = function()
            return self.debug:IsDebug(name)
        end,
        on_set_fn = function(_, _, value)
            if value ~= self.debug:IsDebug(name) then
                self.debug:SetIsDebug(name, value)
                local player = self.player.inst
                return value
                    and self.debug:GetEvents():ActivatePlayer(player)
                    or self.debug:GetEvents():DeactivatePlayer(player)
            end
        end,
    })
end

local function AddDebugPlayerClassifiedEventsOption(self)
    local name = "ThePlayer.player_classified"
    self:AddCheckboxOption({
        label = {
            name = string.format("Events (%s)", name),
            left = true,
        },
        on_get_fn = function()
            return self.debug:IsDebug(name)
        end,
        on_set_fn = function(_, _, value)
            if value ~= self.debug:IsDebug(name) then
                self.debug:SetIsDebug(name, value)
                local player = self.player.inst
                return value
                    and self.debug:GetEvents():ActivatePlayerClassified(player)
                    or self.debug:GetEvents():DeactivatePlayerClassified(player)
            end
        end,
    })
end

local function AddDebugToggleAllOption(self, name, debug_keys)
    AddDebugOption(self, string.format("Toggle All (%s)", name), debug_keys)
end

local function AddDebugToggleAllPlayerEventsOption(self)
    local debug_keys = {
        ["ThePlayer"] = { "ActivatePlayer", "DeactivatePlayer" },
        ["ThePlayer.player_classified"] = {
            "ActivatePlayerClassified",
            "DeactivatePlayerClassified",
        },
    }

    self:AddCheckboxOption({
        label = {
            name = "Toggle All (Events)",
            left = true,
        },
        on_get_fn = function()
            for debug_key, _ in pairs(debug_keys) do
                if not self.debug:IsDebug(debug_key) then
                    return false
                end
            end
            return true
        end,
        on_set_fn = function(_, _, value)
            for debug_key, functions in pairs(debug_keys) do
                if value ~= self.debug:IsDebug(debug_key) then
                    self.debug:SetIsDebug(debug_key, value)
                    local player = self.player.inst
                    local events = self.debug:GetEvents()
                    if value then
                        events[functions[1]](events, player)
                    else
                        events[functions[2]](events, player)
                    end
                end
            end
        end,
    })
end

--- General
-- @section general

--- Adds options.
function DebugSubmenu:AddOptions()
    local debug_keys_remotes = {
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

    AddDebugToggleAllPlayerEventsOption(self)
    AddDebugToggleAllOption(self, "Mouse Clicks", { "lmb", "rmb" })

    if not self.world.ismastersim then
        AddDebugToggleAllOption(self, "Remotes", debug_keys_remotes)
        AddDebugToggleAllOption(self, "SendRPCToServer", "rpc")
    end

    self:AddDividerOption()
    AddDebugPlayerEventsOption(self)
    AddDebugPlayerClassifiedEventsOption(self)

    self:AddDividerOption()
    AddDebugOption(self, "Mouse Clicks (LMB)", "lmb")
    AddDebugOption(self, "Mouse Clicks (RMB)", "rmb")

    if not self.world.ismastersim then
        self:AddDividerOption()
        AddDebugOption(self, "Remotes (Action Button)", "RemoteActionButton")
        AddDebugOption(self, "Remotes (Attack Button)", "RemoteAttackButton")
        AddDebugOption(self, "Remotes (Buffered Action)", "RemoteBufferedAction")
        AddDebugOption(self, "Remotes (Direct Walking)", "RemoteDirectWalking")
        AddDebugOption(self, "Remotes (Drag Walking)", "RemoteDragWalking")
        AddDebugOption(self, "Remotes (Drop Inventory Item)", "RemoteDropItemFromInvTile")
        AddDebugOption(self, "Remotes (Inspect Button)", "RemoteInspectButton")
        AddDebugOption(self, "Remotes (Inspect Inventory Item)", "RemoteInspectItemFromInvTile")
        AddDebugOption(self, "Remotes (Make Recipe At Point)", "RemoteMakeRecipeAtPoint")
        AddDebugOption(self, "Remotes (Make Recipe From Menu)", "RemoteMakeRecipeFromMenu")
        AddDebugOption(self, "Remotes (Predict Walking)", "RemotePredictWalking")
        AddDebugOption(self, "Remotes (Stop Walking)", "RemoteStopWalking")
        AddDebugOption(self, "Remotes (Use Inventory Item)", "RemoteUseItemFromInvTile")
    end
end

return DebugSubmenu
