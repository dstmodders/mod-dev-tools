----
-- Debug player controller.
--
-- Includes player controller (`PlayerController`) debugging functionality as a part of `Debug`.
-- Shouldn't be used on its own.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod debug.PlayerController
-- @see Debug
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0
----
require "class"

--- Constructor.
-- @function _ctor
-- @tparam Debug debug
-- @usage local playercontroller = PlayerController(debug)
local PlayerController = Class(function(self, debug)
    -- general
    self.debug = debug
    self.name = "PlayerController"

    -- event listeners
    self.activated_player = {}
    self.activated_player_classified = {}

    -- other
    self.debug:DebugInit("Debug (PlayerController)")
end)

--- Shared
-- @section shared

local function EntsString(self, ...)
    return self.debug.EntsString(self.debug, ...)
end

local function ConcatParameters(self, ...)
    return self.debug.ConcatParameters(self.debug, ...)
end

--- Helpers
-- @section helpers

local function ActionCode(act)
    return tostring(act ~= nil
        and string.format("ACTIONS.%s.code", act.action.id)
        or nil
    )
end

local function ActionModName(act)
    return tostring(act ~= nil and act.action.mod_name or nil)
end

local function ActionNoForce(locomotor, act)
    return tostring(locomotor == nil and act ~= nil and act.action.canforce or nil)
end

local function ActionTarget(self, act)
    return EntsString(self, act ~= nil and act.target or nil)
end

local function BufferedActionString(self, playercontroller, act)
    local distance = act.distance and tostring(act.distance) or "nil"
    local pos = (act.pos and act.pos.local_pt)
        and string.format("Point(%0.2f, 0, %0.2f)", act.pos.local_pt.x, act.pos.local_pt.z)
        or "nil"

    -- Reference: BufferedAction(self, doer, target, action, invobject, pos, recipe, distance, forced, rotation)
    return string.format("BufferedAction(%s)", ConcatParameters(self, {
        "ThePlayer",
        act.target,
        "ACTIONS." .. act.action.id,
        act.invobject,
        pos,
        tostring(nil),
        distance,
        tostring(ActionNoForce(playercontroller.locomotor, act)),
        tostring(act.rotation ~= 0 and act.rotation or nil)
    }))
end

--- Mouse Clicks
-- @section mouse-clicks

local function DebugMB(mb, str)
    if mb and str then
        print(string.format("[debug] [%s] %s", mb, str))
    end
end

local function DebugMBSendRPCToServer(self, mb, params)
    if mb and type(params) == "table" and #params > 0 then
        DebugMB(mb, string.format("SendRPCToServer(%s)", ConcatParameters(self, params)))
    end
end

local function DebugMBBufferedAction(self, playercontroller, mb, action)
    if playercontroller and action then
        DebugMB(mb, "[action] " .. BufferedActionString(self, playercontroller, action))
    end
end

local function DebugMBBufferedActionPreview(self, playercontroller, mb, action)
    if playercontroller and action then
        DebugMB(mb, "[preview] " .. BufferedActionString(self, playercontroller, action))
    end
end

local function DebugLMBClickSendRPCToServer(
    self,
    playercontroller,
    act,
    x,
    z,
    mouseover,
    is_released,
    control_mods,
    platform
)
    DebugMBSendRPCToServer(self, "lmb", {
        "RPC.LeftClick",
        act.action.code,
        x,
        z,
        mouseover,
        tostring(is_released),
        tostring(control_mods),
        ActionNoForce(playercontroller.locomotor, act),
        ActionModName(act),
        platform,
        platform ~= nil
    })
end

local function DebugRMBClickSendRPCToServer(
    self,
    playercontroller,
    act,
    x,
    z,
    mouseover,
    is_released,
    control_mods,
    platform
)
    DebugMBSendRPCToServer(self, "rmb", {
        "RPC.RightClick",
        act.action.code,
        x,
        z,
        mouseover,
        tostring(act.rotation ~= 0 and act.rotation or nil),
        tostring(is_released),
        tostring(control_mods),
        ActionNoForce(playercontroller.locomotor, act),
        ActionModName(act),
        platform,
        platform ~= nil

    })
end

--- Overrides `PlayerController` mouse clicks.
-- @tparam debug.PlayerController playercontroller
function PlayerController:OverrideMouseClicks(playercontroller)
    local OldOnLeftClick = playercontroller.OnLeftClick
    local OldOnRightClick = playercontroller.OnRightClick

    local function NewOnLeftClick(_self, down)
        OldOnLeftClick(_self, down)

        if self.debug:IsDebug("lmb") and down and not TheInput:GetHUDEntityUnderMouse() then
            local act
            if _self:IsAOETargeting() then
                act = _self:GetRightMouseAction()
            else
                act = _self:GetLeftMouseAction() or BufferedAction(
                    _self.inst,
                    nil,
                    ACTIONS.WALKTO,
                    nil,
                    TheInput:GetWorldPosition()
                )
            end

            local mouseover, platform, x, z
            if act.action == ACTIONS.CASTAOE then
                platform = act.pos.walkable_platform
                x = act.pos.local_pt.x
                z = act.pos.local_pt.z
            else
                local position = TheInput:GetWorldPosition()
                platform, x, z = _self:GetPlatformRelativePosition(position.x, position.z)
                mouseover = act.action ~= ACTIONS.DROP
                    and TheInput:GetWorldEntityUnderMouse()
                    or nil
            end

            local is_previewed = false
            local control_mods = _self:EncodeControlMods()

            if _self.locomotor == nil then
                DebugLMBClickSendRPCToServer(
                    self,
                    _self,
                    act,
                    x,
                    z,
                    mouseover,
                    nil,
                    control_mods,
                    platform
                )
            elseif act.action ~= ACTIONS.WALKTO and _self:CanLocomote() then
                is_previewed = true
                local is_released = not TheInput:IsControlPressed(CONTROL_PRIMARY)
                DebugMBBufferedActionPreview(self, _self, "lmb", act)
                DebugLMBClickSendRPCToServer(
                    self,
                    _self,
                    act,
                    x,
                    z,
                    mouseover,
                    is_released,
                    control_mods,
                    platform
                )
            end

            if is_previewed == false then
                DebugMBBufferedAction(self, _self, "lmb", act)
            end
        end
    end

    local function NewOnRightClick(_self, down)
        OldOnRightClick(_self, down)

        if self.debug:IsDebug("rmb") and down and not TheInput:GetHUDEntityUnderMouse() then
            local act = _self:GetRightMouseAction()
            if act then
                if _self.deployplacer ~= nil and act.action == ACTIONS.DEPLOY then
                    act.rotation = _self.deployplacer.Transform:GetRotation()
                end

                local is_previewed = false
                local position = TheInput:GetWorldPosition()
                local mouseover = TheInput:GetWorldEntityUnderMouse()
                local control_mods = _self:EncodeControlMods()
                local platform, x, z = _self:GetPlatformRelativePosition(position.x, position.z)

                if self.locomotor == nil then
                    DebugRMBClickSendRPCToServer(
                        self,
                        _self,
                        act,
                        x,
                        z,
                        mouseover,
                        nil,
                        control_mods,
                        platform
                    )
                elseif act.action ~= ACTIONS.WALKTO and self:CanLocomote() then
                    is_previewed = true
                    local is_released = not TheInput:IsControlPressed(CONTROL_SECONDARY)
                    DebugMBBufferedActionPreview(self, _self, "lmb", act)
                    DebugRMBClickSendRPCToServer(
                        self,
                        _self,
                        act,
                        x,
                        z,
                        mouseover,
                        is_released,
                        control_mods,
                        platform
                    )
                end

                if is_previewed == false then
                    DebugMBBufferedAction(self, _self, "rmb", act)
                end
            end
        end
    end

    playercontroller.OnLeftClick = NewOnLeftClick
    playercontroller.OnRightClick = NewOnRightClick
end

--- Remotes
-- @section remotes

local function DebugRemote(str)
    if str then
        print("[debug] [remote] " .. str)
    end
end

local function DebugRemoteSendRPCToServer(self, params)
    if type(params) == "table" and #params > 0 then
        DebugRemote(string.format("SendRPCToServer(%s)", ConcatParameters(self, params)))
    end
end

local function DebugRemoteBufferedActionPreview(self, playercontroller, action)
    if playercontroller and action then
        DebugRemote("[preview] " .. BufferedActionString(self, playercontroller, action))
    end
end

local function RemoteActionButton(self, playercontroller, act, is_released)
    DebugRemoteSendRPCToServer(self, {
        "RPC.ActionButton",
        ActionCode(act),
        ActionTarget(self, act),
        is_released,
        ActionNoForce(playercontroller.locomotor, act),
        ActionModName(act)
    })
end

local function RemoteAttackButton(self, playercontroller, target, force_attack)
    local params
    if playercontroller.locomotor ~= nil then
        params = { "RPC.AttackButton", target, force_attack }
    elseif target ~= nil then
        params = { "RPC.AttackButton", target, force_attack }
    else
        params = { "RPC.AttackButton" }
    end
    DebugRemoteSendRPCToServer(self, params)
end

local function RemoteBufferedAction(self, playercontroller, action)
    if not playercontroller.ismastersim and action.preview_cb ~= nil then
        DebugRemoteBufferedActionPreview(self, playercontroller, action)
    end
end

local function RemoteDirectWalking(self, playercontroller, x, z)
    if playercontroller.remote_vector.x ~= x
        or playercontroller.remote_vector.z ~= z
        or playercontroller.remote_vector.y ~= 1
    then
        DebugRemoteSendRPCToServer(self, { "RPC.DirectWalking", x, z })
    end
end

local function RemoteDragWalking(self, playercontroller, x, z)
    if playercontroller.remote_vector.x ~= x
        or playercontroller.remote_vector.z ~= z
        or playercontroller.remote_vector.y ~= 2
    then
        local platform, px, pz = playercontroller:GetPlatformRelativePosition(x, z)
        DebugRemoteSendRPCToServer(self, { "RPC.DragWalking", px, pz, platform, platform ~= nil })
    end
end

local function RemoteDropItemFromInvTile(self, playercontroller, item, single)
    if playercontroller.ismastersim then
        return
    end

    local params
    if playercontroller.locomotor == nil then
        params = { "RPC.DropItemFromInvTile", item, (single or tostring(nil)) }
    elseif playercontroller:CanLocomote() then
        params = { "RPC.DropItemFromInvTile", item, (single or tostring(nil)) }
        local inst = playercontroller.inst
        local action = BufferedAction(inst, nil, ACTIONS.DROP, item, inst:GetPosition())
        DebugRemoteBufferedActionPreview(self, playercontroller, action)
    end
    DebugRemoteSendRPCToServer(self, params)
end

local function RemoteInspectButton(self, act)
    DebugRemoteSendRPCToServer(self, { "RPC.InspectButton", ActionTarget(self, act) })
end

local function RemoteInspectItemFromInvTile(self, playercontroller, item)
    if playercontroller.ismastersim then
        return
    end

    local params
    if playercontroller.locomotor == nil then
        params = { "RPC.InspectItemFromInvTile", item }
    elseif playercontroller:CanLocomote() then
        params = { "RPC.InspectItemFromInvTile", item }
        local action = BufferedAction(playercontroller.inst, nil, ACTIONS.LOOKAT, item)
        DebugRemoteBufferedActionPreview(self, playercontroller, action)
    end
    DebugRemoteSendRPCToServer(self, params)
end

local function RemoteMakeRecipeAtPoint(self, playercontroller, recipe, pt, rot, skin)
    if playercontroller.ismastersim then
        return
    end

    local params
    local skin_idx = skin ~= nil and PREFAB_SKINS_IDS[recipe.name][skin] or nil
    if playercontroller.locomotor == nil then
        local platform, x, z = playercontroller:GetPlatformRelativePosition(pt.x, pt.z)
        params = {
            "RPC.MakeRecipeAtPoint",
            recipe.rpc_id,
            x,
            z,
            rot,
            skin_idx,
            platform,
            platform ~= nil,
        }
    elseif playercontroller:CanLocomote() then
        local act = BufferedAction(
            playercontroller.inst,
            nil,
            ACTIONS.BUILD,
            nil,
            pt,
            recipe.name,
            1,
            nil,
            rot
        )

        params = {
            "RPC.MakeRecipeAtPoint",
            recipe.rpc_id,
            act.pos.local_pt.x,
            act.pos.local_pt.z,
            rot,
            skin_idx,
            act.pos.walkable_platform,
            act.pos.walkable_platform ~= nil,
        }

        DebugRemoteBufferedActionPreview(self, playercontroller, act)
    end
    DebugRemoteSendRPCToServer(self, params)
end

local function RemoteMakeRecipeFromMenu(self, playercontroller, recipe, skin)
    if playercontroller.ismastersim then
        return
    end

    local params

    local skin_idx = skin ~= nil and PREFAB_SKINS_IDS[recipe.name][skin] or nil
    if playercontroller.locomotor == nil then
        params = { "RPC.MakeRecipeFromMenu", recipe.rpc_id, skin_idx }
    elseif playercontroller:CanLocomote() then
        params = { "RPC.MakeRecipeFromMenu", recipe.rpc_id, skin_idx }
        DebugRemoteBufferedActionPreview(self, playercontroller, BufferedAction(
            playercontroller.inst,
            nil,
            ACTIONS.BUILD,
            nil,
            nil,
            recipe.name,
            1
        ))
    end

    DebugRemoteSendRPCToServer(self, params)
end

local function RemotePredictWalking(self, playercontroller, x, z)
    local y = playercontroller.directwalking and 3 or 4
    if playercontroller.remote_vector.x ~= x
        or playercontroller.remote_vector.z ~= z
        or (playercontroller.remote_vector.y ~= y
        and playercontroller.remote_vector.y ~= 0)
    then
        local platform, px, pz = playercontroller:GetPlatformRelativePosition(x, z)
        DebugRemoteSendRPCToServer(self, {
            "RPC.PredictWalking",
            px,
            pz,
            playercontroller.directwalking,
            platform,
            platform ~= nil,
        })
    end
end

local function RemoteStopWalking(self, playercontroller)
    if playercontroller.remote_vector.y ~= 0 then
        DebugRemoteSendRPCToServer(self, { "RPC.StopWalking" })
    end
end

local function RemoteUseItemFromInvTile(self, playercontroller, act, item)
    if playercontroller.ismastersim then
        return
    end

    local params
    local control_mods = playercontroller:EncodeControlMods()

    if playercontroller.locomotor == nil then
        params = {
            "RPC.UseItemFromInvTile",
            ActionCode(act),
            item,
            control_mods,
            ActionModName(act),
        }
    elseif act.action ~= ACTIONS.WALKTO
        and playercontroller:CanLocomote()
        and not playercontroller:IsBusy()
    then
        params = {
            "RPC.UseItemFromInvTile",
            ActionCode(act),
            item,
            control_mods,
            ActionModName(act),
        }
    end

    DebugRemoteSendRPCToServer(self, params)
end

--- Overrides `PlayerController` remotes.
-- @tparam debug.PlayerController playercontroller
function PlayerController:OverrideRemotes(playercontroller)
    local OldRemoteActionButton = playercontroller.RemoteActionButton
    local OldRemoteAttackButton = playercontroller.RemoteAttackButton
    local OldRemoteBufferedAction = playercontroller.RemoteBufferedAction
    local OldRemoteDirectWalking = playercontroller.RemoteDirectWalking
    local OldRemoteDragWalking = playercontroller.RemoteDragWalking
    local OldRemoteDropItemFromInvTile = playercontroller.RemoteDropItemFromInvTile
    local OldRemoteInspectButton = playercontroller.RemoteInspectButton
    local OldRemoteInspectItemFromInvTile = playercontroller.RemoteInspectItemFromInvTile
    local OldRemoteMakeRecipeAtPoint = playercontroller.RemoteMakeRecipeAtPoint
    local OldRemoteMakeRecipeFromMenu = playercontroller.RemoteMakeRecipeFromMenu
    local OldRemotePredictWalking = playercontroller.RemotePredictWalking
    local OldRemoteStopWalking = playercontroller.RemoteStopWalking
    local OldRemoteUseItemFromInvTile = playercontroller.RemoteUseItemFromInvTile

    local function NewRemoteActionButton(...)
        if self.debug:IsDebug("RemoteActionButton") then
            RemoteActionButton(self, ...)
        end
        OldRemoteActionButton(...)
    end

    local function NewRemoteAttackButton(...)
        if self.debug:IsDebug("RemoteAttackButton") then
            RemoteAttackButton(self, ...)
        end
        OldRemoteAttackButton(...)
    end

    local function NewRemoteBufferedAction(...)
        if self.debug:IsDebug("RemoteBufferedAction") then
            RemoteBufferedAction(self, ...)
        end
        OldRemoteBufferedAction(...)
    end

    local function NewRemoteDirectWalking(...)
        if self.debug:IsDebug("RemoteDirectWalking") then
            RemoteDirectWalking(self, ...)
        end
        OldRemoteDirectWalking(...)
    end

    local function NewRemoteDragWalking(...)
        if self.debug:IsDebug("RemoteDragWalking") then
            RemoteDragWalking(self, ...)
        end
        OldRemoteDragWalking(...)
    end

    local function NewRemoteDropItemFromInvTile(...)
        if self.debug:IsDebug("RemoteDropItemFromInvTile") then
            RemoteDropItemFromInvTile(self, ...)
        end
        OldRemoteDropItemFromInvTile(...)
    end

    local function NewRemoteInspectButton(...)
        if self.debug:IsDebug("RemoteInspectButton") then
            RemoteInspectButton(self, ...)
        end
        OldRemoteInspectButton(...)
    end

    local function NewRemoteInspectItemFromInvTile(...)
        if self.debug:IsDebug("RemoteInspectItemFromInvTile") then
            RemoteInspectItemFromInvTile(self, ...)
        end
        OldRemoteInspectItemFromInvTile(...)
    end

    local function NewRemoteMakeRecipeAtPoint(...)
        if self.debug:IsDebug("RemoteMakeRecipeAtPoint") then
            RemoteMakeRecipeAtPoint(self, ...)
        end
        OldRemoteMakeRecipeAtPoint(...)
    end

    local function NewRemoteMakeRecipeFromMenu(...)
        if self.debug:IsDebug("RemoteMakeRecipeFromMenu") then
            RemoteMakeRecipeFromMenu(self, ...)
        end
        OldRemoteMakeRecipeFromMenu(...)
    end

    local function NewRemotePredictWalking(...)
        if self.debug:IsDebug("RemotePredictWalking") then
            RemotePredictWalking(self, ...)
        end
        OldRemotePredictWalking(...)
    end

    local function NewRemoteStopWalking(...)
        if self.debug:IsDebug("RemoteStopWalking") then
            RemoteStopWalking(self, ...)
        end
        OldRemoteStopWalking(...)
    end

    local function NewRemoteUseItemFromInvTile(...)
        if self.debug:IsDebug("RemoteUseItemFromInvTile") then
            RemoteUseItemFromInvTile(self, ...)
        end
        OldRemoteUseItemFromInvTile(...)
    end

    playercontroller.RemoteActionButton = NewRemoteActionButton
    playercontroller.RemoteAttackButton = NewRemoteAttackButton
    playercontroller.RemoteBufferedAction = NewRemoteBufferedAction
    playercontroller.RemoteDirectWalking = NewRemoteDirectWalking
    playercontroller.RemoteDragWalking = NewRemoteDragWalking
    playercontroller.RemoteDropItemFromInvTile = NewRemoteDropItemFromInvTile
    playercontroller.RemoteInspectButton = NewRemoteInspectButton
    playercontroller.RemoteInspectItemFromInvTile = NewRemoteInspectItemFromInvTile
    playercontroller.RemoteMakeRecipeAtPoint = NewRemoteMakeRecipeAtPoint
    playercontroller.RemoteMakeRecipeFromMenu = NewRemoteMakeRecipeFromMenu
    playercontroller.RemotePredictWalking = NewRemotePredictWalking
    playercontroller.RemoteStopWalking = NewRemoteStopWalking
    playercontroller.RemoteUseItemFromInvTile = NewRemoteUseItemFromInvTile
end

return PlayerController
