----
-- Player vision tools.
--
-- Extends `tools.Tools` and includes different vision functionality most of which can be accessed
-- from the "Player Vision..." submenu.
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
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod tools.PlayerVisionTools
-- @see DevTools
-- @see tools.PlayerTools
-- @see tools.Tools
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
local DevTools = require("devtools/tools/tools")
local SDK = require("devtools/sdk/sdk/sdk")

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam PlayerTools playertools
-- @tparam DevTools devtools
-- @usage local playervisiontools = PlayerVisionTools(playertools, devtools)
local PlayerVisionTools = Class(DevTools, function(self, playertools, devtools)
    DevTools._ctor(self, "PlayerVisionTools", devtools)

    -- asserts
    SDK.Utils.AssertRequiredField(self.name .. ".playertools", playertools)
    SDK.Utils.AssertRequiredField(self.name .. ".inst", playertools.inst)
    SDK.Utils.AssertRequiredField(self.name .. ".inventory", playertools.inventory)

    -- general
    self.inst = playertools.inst
    self.inventory = playertools.inventory
    self.playertools = playertools

    -- HUD
    self.is_forced_hud_visibility = false

    -- unfading
    self.is_forced_unfading = false

    -- spawners
    self.is_spawners_visibility = false

    -- other
    self:DoInit()
end)

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
function PlayerVisionTools:IsForcedHUDVisibility()
    return self.is_forced_hud_visibility
end

--- Toggles the forced HUD visibility state.
--
-- When enabled, forces to show the HUD in some cases.
--
-- @todo Improve the PlayerVisionTools:ToggleForcedHUDVisibility() behaviour
-- @treturn boolean
function PlayerVisionTools:ToggleForcedHUDVisibility()
    if not self.inst or not self.inst.player_classified then
        return
    end

    local classified = self.inst.player_classified

    self.is_forced_hud_visibility = not self.is_forced_hud_visibility
    if self.is_forced_hud_visibility then
        self:DebugString("[event]", "[playerhuddirty]", "Activated")
        classified:ListenForEvent("playerhuddirty", OnPlayerHUDDirty)
        return true
    else
        self:DebugString("[event]", "[playerhuddirty]", "Deactivated")
        classified:RemoveEventCallback("playerhuddirty", OnPlayerHUDDirty)
        return false
    end
end

--- Checks if an instance is a spawner.
-- @tparam EntityScript inst
-- @treturn boolean
function PlayerVisionTools:IsSpawner(inst) -- luacheck: only
    if not inst or not inst.prefab then
        return false
    end
    if inst.components.childspawner then
        return true
    end
    if string.find(inst.prefab, "spawner") or inst.prefab == "dropperweb" then
        return true
    end
    return false
end

--- Gets the spawners visibility state.
-- @treturn boolean
function PlayerVisionTools:IsSpawnersVisibility()
    return self.is_spawners_visibility
end

--- Shows a spawner for an instance.
-- @tparam EntityScript inst
-- @treturn boolean
function PlayerVisionTools:ShowSpawner(inst)
    if not self:IsSpawner(inst) then
        return
    end

    if inst.AnimState and inst.AnimState:GetBuild() and inst.entity:IsVisible() then
        return
    end

    if not inst.AnimState then
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
    end

    local build = "star_cold"
    inst.AnimState:SetBuild(build)
    inst.AnimState:SetBank(build)
    inst.AnimState:PlayAnimation("idle_loop", true)

    if inst.components.childspawner then
        inst.AnimState:SetAddColour(1.0, 0.5, 0.0, 1.0) -- Orange
    else
        inst.AnimState:SetAddColour(0.0, 1.0, 0.0, 1.0) -- Green
    end

    inst.entity:Show()
end

--- Hides a spawner for an instance.
-- @tparam EntityScript inst
-- @treturn boolean
function PlayerVisionTools:HideSpawner(inst)
    if not self:IsSpawner(inst) then
        return
    end
    if
        not inst.AnimState
        or inst.AnimState:GetBuild() ~= "star_cold"
        or not inst.entity:IsVisible()
    then
        return
    end
    inst.AnimState:SetAddColour(0.0, 0.0, 0.0, 0.0)
    inst.entity:Hide()
end

--- Toggles the spawners visibility state.
--
-- When enabled, spawners become visible and clickable.
--
-- @treturn boolean
function PlayerVisionTools:ToggleSpawnersVisibility()
    if not self.inst or not self.inst.player_classified then
        return
    end

    self.is_spawners_visibility = not self.is_spawners_visibility
    if self.is_spawners_visibility then
        for _, obj in pairs(Ents) do
            if self:IsSpawner(obj) then
                self:ShowSpawner(obj)
            end
        end
        return true
    else
        for _, obj in pairs(Ents) do
            if self:IsSpawner(obj) then
                self:HideSpawner(obj)
            end
        end
        return false
    end
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
function PlayerVisionTools:DoInit()
    DevTools.DoInit(self, self.playertools, "vision", {
        -- forced HUD visibility
        "IsForcedHUDVisibility",
        "ToggleForcedHUDVisibility",
        "IsSpawnersVisibility",
        "IsSpawner",
        "ShowSpawner",
        "HideSpawner",
    })
end

return PlayerVisionTools
