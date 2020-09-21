----
-- Player vision tools.
--
-- Extends `devtools.DevTools` and includes different vision functionality most of which can be
-- accessed from the "Player Vision..." submenu.
--
-- When available, all (or most) methods can be accessed within `DevTools` global class:
--
--    DevTools:...
--
-- Or the whole module can be accessed directly through the same global `DevTools`:
--
--    DevTools.player.vision
--
-- **Abbreviations:**
--
--   - **CC** (Colour Cubes)
--   - **CCT** (Colour Cubes Table)
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod devtools.player.VisionDevTools
-- @see DevTools
-- @see devtools.DevTools
-- @see devtools.PlayerDevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.4.0
----
require "class"

local DevTools = require "devtools/devtools/devtools"
local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam devtools.PlayerDevTools playerdevtools
-- @tparam DevTools devtools
-- @usage local visiondevtools = VisionDevTools(playerdevtools, devtools)
local VisionDevTools = Class(DevTools, function(self, playerdevtools, devtools)
    DevTools._ctor(self, "VisionDevTools", devtools)

    -- asserts
    Utils.AssertRequiredField(self.name .. ".playerdevtools", playerdevtools)
    Utils.AssertRequiredField(self.name .. ".inst", playerdevtools.inst)
    Utils.AssertRequiredField(self.name .. ".inventory", playerdevtools.inventory)

    -- general
    self.cct = nil
    self.inst = playerdevtools.inst
    self.inventory = playerdevtools.inventory
    self.playerdevtools = playerdevtools

    -- HUD
    self.is_forced_hud_visibility = false

    -- unfading
    self.is_forced_unfading = false

    -- self
    self:DoInit()
end)

--- General
-- @section general

--- Gets the CCT.
-- @treturn table
function VisionDevTools:GetCCT()
    return self.cct
end

--- Sets the CCT.
-- @tparam table cct
function VisionDevTools:SetCCT(cct)
    self.cct = cct
end

--- Gets the PlayerVision CCT.
-- @treturn table
function VisionDevTools:GetPlayerVisionCCT()
    if self.inst and self.inst.components and self.inst.components.playervision then
        local playervision = self.inst.components.playervision
        return playervision and playervision.GetCCTable and playervision:GetCCTable()
    end
end

--- Updates the PlayerVision CCT.
--
-- Instead of the table, the parameter can be the "nil" string which will set the custom PlayerVision CCT to nil.
--
-- @tparam[opt] table|string cct
-- @treturn boolean
function VisionDevTools:UpdatePlayerVisionCCT(cct)
    if self.inst and self.inst.components and self.inst.components.playervision then
        local playervision = self.inst.components.playervision
        if playervision then
            local cct_table = cct ~= "nil" and cct or nil
            playervision.currentcctable = cct_table
            playervision.overridecctable = cct_table
            self.inst:PushEvent("ccoverrides", cct_table)
            return true
        end
    end
    return false
end

--- HUD
-- @section hud

local function OnPlayerHUDDirty(inst)
    if inst._parent and inst._parent.HUD then
        inst._parent.HUD:Show()
        -- the line below is not really needed
        inst.ishudvisible:set_local(true)
    end
end

--- Gets the forced HUD visibility state.
-- @treturn boolean
function VisionDevTools:IsForcedHUDVisibility()
    return self.is_forced_hud_visibility
end

--- Toggles the forced HUD visibility state.
--
-- When enabled, forces to show the HUD in some cases.
--
-- @todo Improve the VisionDevTools:ToggleForcedHUDVisibility() behaviour
-- @treturn boolean
function VisionDevTools:ToggleForcedHUDVisibility()
    if not self.inst or not self.inst.player_classified then
        return
    end

    local classified = self.inst.player_classified

    self.is_forced_hud_visibility = not self.is_forced_hud_visibility
    if self.is_forced_hud_visibility then
        self:DebugActivateEventListener("playerhuddirty")
        classified:ListenForEvent("playerhuddirty", OnPlayerHUDDirty)
        return true
    else
        self:DebugDeactivateEventListener("playerhuddirty")
        classified:RemoveEventCallback("playerhuddirty", OnPlayerHUDDirty)
        return false
    end
end

--- Unfading
-- @section unfading

local function OnPlayerFadeDirty(inst)
    if inst
        and inst._parent
        and inst._parent.HUD
        and type(inst.isfadein) == "userdata"
        and type(inst.fadetime) == "userdata"
    then
        TheFrontEnd:Fade(true, 0)
        TheFrontEnd:SetFadeLevel(0)
        -- the lines below are not really needed
        inst.isfadein:set_local(true)
        inst.fadetime:set_local(0)
    end
end

--- Gets the forced unfading state.
-- @treturn boolean
function VisionDevTools:IsForcedUnfading()
    return self.is_forced_unfading
end

--- Toggles the forced unfading state.
--
-- When enabled, disables the front-end black/white screen fading.
--
-- @treturn boolean
function VisionDevTools:ToggleForcedUnfading()
    if not self.inst or not self.inst.player_classified then
        return
    end

    local classified = self.inst.player_classified

    self.is_forced_unfading = not self.is_forced_unfading
    if self.is_forced_unfading then
        self:DebugActivateEventListener("playerfadedirty")
        classified:ListenForEvent("playerfadedirty", OnPlayerFadeDirty)
        return true
    else
        self:DebugDeactivateEventListener("playerfadedirty")
        classified:RemoveEventCallback("playerfadedirty", OnPlayerFadeDirty)
        return false
    end
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function VisionDevTools:DoInit()
    DevTools.DoInit(self, self.playerdevtools, "vision", {
        -- general
        "GetCCT",
        "SetCCT",
        "GetPlayerVisionCCT",
        "UpdatePlayerVisionCCT",

        -- forced HUD visibility
        "IsForcedHUDVisibility",
        "ToggleForcedHUDVisibility",

        -- forced unfading
        "IsForcedUnfading",
        "ToggleForcedUnfading",
    })
end

return VisionDevTools
